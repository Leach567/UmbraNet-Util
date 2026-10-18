#!/usr/bin/python

import os
import subprocess as sub
from umbraUtil import dLog, textLevel, debugOn
from argparse import ArgumentParser

ap = ArgumentParser(description='UmbraCC Module Manager Script')
ap.add_argument(
    'command',
    nargs='+',
    help='Command to be issued to the Module Manager')
args = ap.parse_args()

_comm = args.command
dLog('COMMAND: {}'.format(_comm))

textLevel(0)


class UmbraCC_Module_Manager:
    def __init__(self):
        dLog('Module Manager Init')
        self._modDir = ''
        try:
            self._modDir = os.environ['UMB_UCC_MODS_DIR']
            dLog('Mod Dir set to {}'.format(self._modDir))
        except BaseException:
            print('Could not access UMB_UCC_MODS_DIR. Check the configs')
        _mods = os.listdir(self._modDir)
        _modules = dict()
        for _m in _mods:
            _mPath = os.path.join(self._modDir, _m)
            if os.path.isdir(_mPath):
                _modules[_m] = _mPath
        if len(_modules) > 0:
            self._modules = _modules
        else:
            print('No modules')

    def listModules(self):
        print('Umbra Central Cortex Module List')
        for _m in self._modules:
            print('\t> {} ==> {}'.format(_m, self._modules[_m]))

    def moduleExists(self, mod_name):
        return (mod_name in self._modules)

    def findModule(self, mod_name):
        if mod_name in self._modules:
            return self._modules[mod_name]
        else:
            return ''

    def runModule(self, mode, mod_path=''):
        if mode == 'norm':
            _modRoot = ''
            _runScript = ''
            try:
                _modRoot = os.environ['UCC_MODULE_ROOT']
                _runScript = os.environ['UCC_MODULE_RUN_SCRIPT']
            except BaseException:
                print('umbModuleManager: UCC_MODULE_RUN_SCRIPT inaccessable')

            modName = os.path.basename(_runScript)
            print('Module: {} Root: {}'.format(modName, _modRoot))

            sub.call(_runScript, shell=True)

        elif mode == 'test':
            _testScript = ''
            try:
                _testScript = os.environ['UCC_MODULE_TEST_SCRIPT']
                _wd = os.environ['UCC_MODULE_WEIGHTS_DIR']
            except BaseException:
                print('umbModuleManager: UCC_MODULE_TEST_SCRIPT inaccessable')
            print('Weights Dir: {}'.format(_wd))
            sub.call(_testScript, shell=True)

        else:
            print('umbModuleManager: Invalid Run Mode: {}'.format(mode))
            return 1


_mm = UmbraCC_Module_Manager()
# Execute the command
if _comm[0] == 'list':
    _mm.listModules()

elif _comm[0] == 'find':
    if len(_comm) < 2:
        print('ModuleFind: Missing Module Name')
        exit(1)
    _res = _mm.findModule(_comm[1])
    if _res == '':
        exit(1)
    else:
        print('UCC_Module: {}'.format(_res))
        exit(0)
elif _comm[0] == 'test':
    if len(_comm) < 2:
        print('ModuleTest: Missing Module Name')
    _modPath = _mm.findModule(_comm[1])
    if _modPath == '':
        print('Module {} not found.'.format(_comm[1]))

    os.chdir(_modPath)
    dLog('New Working Directory: {}'.format(os.getcwd()))

    _mm.runModule(mode='test', mod_path=_modPath)
elif _comm[0] == 'run':
    if len(_comm) < 2:
        print('ModuleRun: Missing Module Name')
        exit(1)
    _modPath = _mm.findModule(_comm[1])
    if _modPath == '':
        print('Module {} not found.'.format(_comm[1]))

    os.chdir(_modPath)
    dLog('New Working Directory: {}'.format(os.getcwd()))

    _mm.runModule(mode='norm', mod_path=_modPath)

else:
    ap.print_help()
    exit(1)
