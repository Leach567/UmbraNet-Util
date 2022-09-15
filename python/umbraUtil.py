#!/usr/bin/python
#
# Name: umbraUtil.py
# Author: NLeach
# Date: 03/28/2020
# Descripton:
#	- Global utility functions for the UmbraCC Python Api
#	- Will allow the python side of the system to interact with
#		the bash side
#
#
import os
import sys
import json
import subprocess as sub



# ====================================[BASH WRAPPER]======================
def UMB_ENV(_envvar):
    try:
        return str(os.environ[_envvar])
    except BaseException:
        return -1

# ====================================[DEBUG]===========================================

_TEXT_SEP = "================================"
def debugOn():
    try:
        if UMB_ENV('UMB_DEBUG') == "true":
            return True
        else:
            return False
    except BaseException:
        print('UmbraUtil::Cant access UMB_DEBUG. Defaulting to false')
        return False

# Logging Utility suite for the python side of the UmbraCC System.
# Will do my best to leverage as much of the bash side as possible


def dLog(_msg):

    if not isinstance(_msg, str):
        print('UMBDEBUG: Error: Debug Message must be a string. Exiting.')

    # Retrive the UMB_DEBUG envvar, that variable controls
    # All debugging on the Bash Side, so it should control
    # python debugging too
    _debugMode = False
    try:
        if os.environ['UMB_DEBUG'] == 'true':
            _debugMode = True
        else:
            _debugMode = False
    except BaseException:
        #	print( 'Unable to access UMB_DEBUG envvar. UmbraNet python debugging will remain disabled.' )
        return

    # It will be useful to separate differrent sections of output will indentation.
    # Instead of having to pass it into every function call, setting an envvar at the start
    # and end of a section should make it easier and more readable.
    # The idea is to just set the level of indentation for a whole section and
    # every debug print statement after that line will print on that level
    _indentLvl = 0
    try:
        _indentLvl = int(os.environ['UMB_DEBUG_TXT_LVL'])
    except BaseException:
        print(
            'Unable to access UMB_DEBUG_TXT_LVL envvar. Defaulting to ' +
            str(_indentLvl) +
            '.')

    # Add tabs to the line equal to UMB_DEBUG_TXT_LVL
    _indentStr = ''.join('\t' for _x in range(_indentLvl))

    # Contstuct the output string
    #_output = "Txt Lvl{}".format(os.environ['UMB_DEBUG_TXT_LVL'])+_indentStr + _msg
    _output = _indentStr + _msg

    print(_output)


# Set the global debug indentation level
def textLevel(_lvl):
    if _lvl == '+' or _lvl == '-':
        try:
            _temp = int(os.environ['UMB_DEBUG_TXT_LVL'])
        except BaseException:
            os.environ['UMB_DEBUG_TXT_LVL'] = str(0)
            _temp = 0

        # If the input is a '+', increment the text level
        if _lvl == '+':

            _lvl = _temp + 1

        # If the input is a '-', decrement the text level
        elif _lvl == '-':

            if _temp > 0:
                _lvl = _temp - 1

    if not isinstance(_lvl, int):
        print('Error requires integer input OR increment/decrement operators (+/-) for text level. Exiting.')
        return
    os.environ['UMB_DEBUG_TXT_LVL'] = str(_lvl)


# ==================================[Module Management]===================

# Generate a profile with the following data:
#	Time_Stamp:	{Do I need this?}
#	Mode:		{This could allow the profile to set the application into different
#				modes of operation}
#
#	Subj_Count:	Number of audio subjects to load into memory at ones ( Is there a way to further reduce mem usage? )
#	Time_Steps:	Number of samples per chunk to break the data into
#	Batch_Size:	Number of chunks to extract from the audio
# TODO: Add hashing to the profile generation for security? ( More for fun )
def generateProfile(
        output_path,
        subj_count,
        time_steps,
        batch_size,
        sample_start=0, ):

    if output_path is None:
        print('ERROR: generateProfile() requires the path for its output file.')
        exit(1)

    if os.path.exists(output_path):
        dLog('File exists, overwriting.')

    _subjCount = 1
    if subj_count is not None:
        _subjCount = subj_count

    _timeSteps = 1
    if time_steps is not None:
        _timeSteps = time_steps

    _batchSize = 1
    if batch_size is not None:
        _batchSize = batch_size

    _sampleStart = sample_start

    _pObj = dict()
    _pObj['Prof_Type'] = 'Live'
    _pObj['Subj_count'] = _subjCount
    _pObj['Time_Steps'] = _timeSteps
    _pObj['Batch_Size'] = _batchSize
#   _pObj['Sample_Start']   = _sampleStart #Live profile should start at the
# beginning

    _jpObj = json.dumps(_pObj, indent=4, sort_keys=True)
    dLog('Output json profile object: {}'.format(_jpObj))
    with open(output_path, 'w+') as _outFile:
        _outFile.write(_jpObj)

# It will probably be useful to have these separate
# Generate a training profile with the following data:
#	Time_Stamp:	{Do I need this?}
#	Mode:		{This could allow the profile to set the application into different
#				modes of operation}
#
#	Subj_Count:	Number of audio subjects to load into memory at ones ( Is there a way to further reduce mem usage? )
#	Time_Steps:	Number of samples per chunk to break the data into
#	Batch_Size:	Number of chunks to extract from the audio
# Sample_Start:   Index of the point that processing of audio data should
# begin (Training only)


def generateTrainingProfile(
        output_path,
        subj_count,
        time_steps,
        batch_size,
        sample_start=0, ):

    if output_path is None:
        print('ERROR: generateProfile() requires the path for its output file.')
        exit(1)

    if os.path.exists(output_path):
        dLog('File exists, overwriting.')

    _subjCount = 1
    if subj_count is not None:
        _subjCount = subj_count

    _timeSteps = 1
    if time_steps is not None:
        _timeSteps = time_steps

    _batchSize = 1
    if batch_size is not None:
        _batchSize = batch_size

    _sampleStart = sample_start

    _pObj = dict()
    _pObj['Prof_Type'] = 'Training'
    _pObj['Subj_Count'] = _subjCount
    _pObj['Time_Steps'] = _timeSteps
    _pObj['Batch_Size'] = _batchSize
    _pObj['Sample_Start'] = _sampleStart

    _jpObj = json.dumps(_pObj, indent=4, sort_keys=True)
    dLog('Output json profile object: {}'.format(_jpObj))
    with open(output_path, 'w+') as _outFile:
        _outFile.write(_jpObj)

# Load module profile data from the given file path
#
#


def loadProfile(prof_path):

    if prof_path is None:
        print('ERROR: loadProfile(): Must provide the path to a valid module profile.')
        return 1
    dLog('Loading profile at {}'.format(prof_path))
    if not os.path.exists(prof_path):
        print('ERROR: loadProfile(): no profile exists at {} '.format(prof_path))
        return 1

    _profileData = ''
    with open(prof_path, 'r') as _prof:
        _profileData = json.load(_prof)
    return _profileData
