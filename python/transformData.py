#!/usr/bin/python
import numpy as np
import umbraUtil as umb

#


def padTrainingData(input_list, desired_width=2500):
    umb.dLog('PadTrainingData: Padding Width: ' + str(desired_width))

    umb.textLevel(2)
    if not isinstance(input_list, np.ndarray):
        umb.dLog('Input List is not a numpy array')
        input_list = np.array(input_list)

    if isinstance(input_list[0], list):
        umb.dLog(
            'padTrainingData: Input array contains lists as its elements. Converting to numpy arrays...')
        # Fancy short-hand notation for converting all the lists into
        # numpy arrays
        input_list = [np.array(_el, dtype='F') for _el in input_list]

    if len(input_list) < 1:
        umb.dLog('padTrainingData: Input list length is less than 1')
        return 1

    _padRows = False
    if isinstance(input_list[0], np.ndarray):
        umb.dLog(
            'padTrainingData: Input list is an array of arrays. Padding each row to ' +
            str(desired_width))
        _padRows = True

    _output = []
    umb.textLevel(3)

    # Applay the pad to each row
    if _padRows:
        umb.dLog('Padding List\'s Member  Rows...')

        umb.textLevel(4)
        for _ent in input_list:
            _dataPad = (desired_width - _ent.size)
            umb.dLog('Entry Size = ' + str(_ent.size))
            umb.dLog('DataPad Calculated: <<' + str(_dataPad) + '>>')

            if _dataPad < 0:
                umb.dLog(
                    'padTrainingData: Negative data pad not allowed: <<' +
                    str(_dataPad) +
                    '>>. Skipping')
                continue
            _ePad = np.pad(_ent, (0, _dataPad), 'constant')
            _output.append(_ePad)
    else:

        # Apply the pad to the whole list
        umb.textLevel(3)
        umb.dLog('Padding Input List as a whole...')

        umb.textLevel(4)
        _dataPad = (desired_width - input_list.size)
        umb.dLog('Entry Size = ' + str(input_list.size))
        umb.dLog('DataPad Calculated: <<' + str(_dataPad) + '>>')

        if _dataPad < 0:
            umb.dLog(
                'padTrainingData: Negative data pad not allowed: <<' +
                str(_dataPad) +
                '>>. Skipping')
            return None
        _ePad = np.pad(input_list, (0, _dataPad), 'constant')
        _output = _ePad

    umb.textLevel(2)
    umb.dLog('List Padded Successfully. List Size = ' +
             str(np.array(_output).shape))
    return np.array(_output)


def convertToTrainingData(input_list, input_shape=(50, 50)):
    umb.dLog('ConverTrainingData: Input Shape: ' + str(input_shape))
    umb.textLevel(2)
    if len(input_list) < 1:
        umb.dLog('convertToTrainingData: Input List length is less than 1')
        return 1

    # Apply a pad that will ensure the data will fit the desired shape
    mList = padTrainingData(
        input_list, desired_width=(
            input_shape[0] * input_shape[1]))
    if mList is None:
        umb.dLog('convertToTrainingData: Failed to retrieve padded data list.')
        return 1

    _output = []
    _normList = []

    umb.textLevel(3)
    if isinstance(mList[0], np.ndarray):
        umb.dLog('Converting list element by element...')
        for _ent in mList:
            try:
                if not isinstance(_ent, np.ndarray):
                    umb.dLog(
                        'Entry is not in the form of a numpy array. Reforming...')
                    _ent = np.array(_ent)
                _entRS = np.reshape(_ent, input_shape)

                # Normalize the data
                _entNorm = np.linalg.norm(_entRS)
                _norm = np.full(input_shape, 0.011)  # Placeholder element
                if _entNorm > 0:
                    _norm = _entRS / _entNorm

                _output.append(_norm)
                _normList.append(_entNorm)
            except BaseException:
                umb.dLog(
                    'Failed to reshape data. Input Shape = ' +
                    str(input_shape) +
                    '.')

        _output = np.array(_output)
    else:
        umb.dLog('Converting list as a whole...')
        _listRS = np.reshape(mList, (1, input_shape[0], input_shape[1]))
        _listNorm = np.linalg.norm(_listRS)
        _normList.append(_listNorm)
        _output = _listRS / _listNorm

    _normList = np.array(_normList)
    umb.textLevel(1)
    umb.dLog(
        'List successfully converted to training data: Data Shape = ' + str(_output.shape))
    umb.dLog('Norm List: ' + str(_normList))
    return (_output, _normList)


def denormalizeTrainingData_text_exp(input_list):

    _tAntiVar = input_list + _tVar.min()
    _tDenorm = _tAntiVar * 63
    return _tDenorm


def processAudioData(raw_audio_matrix, input_shape=(1, 2),
                     data_type='float32'):
    if not isinstance(raw_audio_matrix, np.ndarray):
        print('Input must be valid audio data as a numpy array')

    if len(input_shape) > 2:
        print('Input shape should be 2d, and it should in most cases be (1,2), which is default')

    _a = raw_audio_matrix
    _a = np.reshape(_a, (len(_a), 1, 2)).astype(data_type)
    _aN = np.linalg.norm(_a)
    _aOut = _a / _aN
    return _aOut
