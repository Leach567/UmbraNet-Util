#!/usr/bin/python
import os
from umbraUtil import dLog, debugOn, textLevel

dLog('Cleaning directory =={}=='.format(os.getcwd()))

_fList = [os.path.join(os.getcwd(), _f) for _f in os.listdir('.')]
dLog('File List ( Pre Trim ): {}'.format(_fList))

for _f in _fList:
    _f = os.path.join(os.getcwd(), _f)
    _fc = _f.replace(' ', '_').replace('-', '_')

    dLog('Renaming {} to {}'.format(_f, _fc))
    os.rename(_f, _fc)
print(
    '{} has had all spaces removed from all file names. Have a nice day!'.format(
        os.getcwd()))
