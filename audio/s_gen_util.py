import os
import numpy as np
import scipy.io.wavfile as wave
import audio2numpy as ad
from umbraUtil import textLevel, dLog, debugOn
#!/usr/bin/python
#
#
#
#
#

SUBJECT_TAGS = [
    '.wav',
    '',
]

# Accepts a list of files in a directory and
# returns a list of all valid subjects in the list


def getSubjects(_dirList, _outputLength=-1):
    if not isinstance(_dirList, list):
        print('Not a list')
        return None

    if len(_dirList) < 1:
        print('Empty List')
        return None

    # Look at each file and determine whether or not it is
    # a valid subject.
    _goodSubjs = []
    for _f in _dirList:

        # First Check: File exists
        if not os.path.exists(_f):
            print(
                'getSubjects: Unable to locate subject on filesystem: {}'.format(_f))
            continue

        # Second Check: File is an audio file
        _base = os.path.basename(_f)
        _ext = os.path.splitext(_base)[1]
        if _ext not in SUBJECT_TAGS:
            print(
                'getSubjects: Candidate {} ineligible as a result of extension check. Extension: {}'.format(
                    _f,
                    _ext))
            continue

        # Add the valid subject to the output list
        _goodSubjs.append(_f)

    # Reduce the size of the list if we received a requested size
    if _outputLength > 0:
        dLog('Attempting to truncate output list to {}'.format(_outputLength))
        _goodSubjs = _goodSubjs[:min(_outputLength, len(_goodSubjs))]

    return _goodSubjs

# Accepts a target or list of targets and
# loads the audio data. Returns a matrix
# representing the audio data and the
# sampling rate for each file
# NOTE: These should only be valid targets


def loadAudioData(target_list, sample_start=0, time_steps=1, batch_size=-1):

    _numTimeSteps = int(time_steps)
    _batchSize = int(batch_size)
    _sampStart = int(sample_start)

    if not isinstance(target_list, list):
        print('loadAudioData: Input must be a list. Attempting to convert...')
        temp = []
        temp.append(target_list)
        target_list = temp

    _dataList = []
    _sampList = []
    _count = 0
    for _f in target_list:
        _data = []
        _samp = -1
        try:
            _data, _samp = ad.open_audio(_f)
        except BaseException:
            print(
                'loadAudioData: Failed to load audio data for subject: {}'.format(_f))
            continue

        textLevel('+')

        # Before taking out time steps, we need to
        # throw away the portion before the
        # desired start point in the data
        if _sampStart < len(_data) - 1:
            dLog('Setting sample start point to {}'.format(_sampStart))
            _data = _data[_sampStart:]

        # This way, _numTimeSteps can be set to -1 and the entire audio file
        # will be returned
        if _numTimeSteps > 0 and len(_data) > _numTimeSteps:
            dLog('Truncating to {} time step(s)...'.format(_numTimeSteps))
            _data = _data[:_numTimeSteps]

        # Normalize the data
        # TODO: This needs to be safer
        norm = np.linalg.norm(_data)
    #		_data = _data.dtype('f')/32767
    #	if norm > 0:
    #		dLog( 'Normalizing Data...' )
    #		_data = _data/norm

        # This way _batchSize can be set to negative one and
        # the full list will be returned
        if _batchSize > 0 and _count >= _batchSize:
            break

        dLog('Adding Data to output list...')
        _dataList.append(_data)
        _sampList.append(_samp)
        _count = _count + 1

        textLevel('-')

    _dataList = np.array(_dataList)
    _sampList = np.array(_sampList)

    return _dataList, _sampList


def loadAudioData_wav(
        target_list,
        sample_start=0,
        time_steps=1,
        batch_size=-1,
        norm=False
):

    _numTimeSteps = int(time_steps)
    _batchSize = int(batch_size)
    _sampStart = int(sample_start)

    if not isinstance(target_list, list):
        print('loadAudioData_wav: Input must be a list. Attempting to convert...')
        temp = []
        temp.append(target_list)
        target_list = temp

    _dataList = []
    _sampList = []
    _count = 0
    for _f in target_list:
        _data = []
        _samp = -1
        try:
            _samp, _data = wave.read(_f)
#			dLog( 'Audio Loaded: {}'.format( _data[77336:936736] ) )
        except BaseException:
            print(
                'loadAudioData_wav: Failed to load audio data for subject: {}'.format(_f))
            continue

        textLevel('+')

        # Before taking out time steps, we need to
        # throw away the portion before the
        # desired start point in the data
        if _sampStart < len(_data) - 1:
            dLog(
                'loadAudioData_wav: Setting sample start point to {}'.format(_sampStart))
            _data = _data[_sampStart:]

        # This way, _numTimeSteps can be set to -1 and the entire audio file
        # will be returned
        if _numTimeSteps > 0 and len(_data) > _numTimeSteps:

            dLog('loadAudioData_wav: Slicing audio file into chunks of length {}...'.format(
                _numTimeSteps))
            _index = 0
            _chunks = []
            textLevel('+')
            # Only collect a number of chunks equal to batch_size
            while ((_index + 1) * time_steps) < len(_data):
                if len(_chunks) >= batch_size:
                    break
                # Start gathering slices of the song.
                # These are sub-arrays of _data, their size is TIME_STEPS
                _start = time_steps * _index
                _end = (time_steps * (_index + 1))
                dLog(
                    'Batch#{}: Collecting song chunk from range [{},{}]'.format(
                        int(_index), _start, _end))
                _chunk = np.asarray(_data[_start:_end], dtype='float64')
                _chunk /= 32767
                _chunks.append(_chunk)
                _index += 1
            _data = np.asarray(_chunks)
            textLevel('-')

        dLog('loadAudioData_wav: Adding Data to output list...')
        _dataList.append(_data)
        _sampList.append(_samp)
        _count = _count + 1

        textLevel('-')

    _dataList = np.array(_dataList)
    _sampList = np.array(_sampList)

    return _dataList, _sampList

# TODO: Make this function smarter


def saveAudioData(data, rate, path, denormalize=False):

    # Apparently the write function can't handle the
    # 3d data shape, it wants one array of shape ( samples, channels )
    if len(data.shape) > 2:
        data = data[0]
    path = os.path.abspath(path).replace(' ', '').replace('-', '_')
    rate = int(rate)
    if denormalize:
        data = data * 32767
        data = data.astype('int16')
    dLog('Saving Audio Data...')

    dLog('Ouput Path: {}'.format(path))
    dLog('Sample Rate: {}'.format(rate))
    if isinstance(path, basestring):

        dLog('Single path string, verifying...')
        if not os.path.exists(os.path.dirname(path)):
            print('Parent folder does not exist.')
            return 1
        dLog('Good path.')
    else:
        print('path must be a single file path.')
        return 1

    wave.write(path, rate, data)
