#!/usr/bin/python
#
# Name: stripSource.py
# Author: NLeach
# Date: 02/03/2020
# Descripton:
#	Accepts a path or paths to a source file. Reads in the file
#	and parses out all comments and empty lines, then outputs the
#	result to standard out
#
#	Still needs alot of work.
# 	2/10/2020: Still doesn't strip block comments with a leading '*' correctly
import os
import io
import sys
import argparse

parser = argparse.ArgumentParser(
    description='Strip the unneeded lines out of a source file')
parser.add_argument('source', help='The source file to be stripped', nargs='+')
parser.add_argument(
    '-d',
    '--dest',
    help='The destination file that the stripped contents will be written to')
parser.add_argument(
    '-df',
    '--debug-file',
    help='Destination file for debug output')
# parser.add_argument()
# parser.add_argument()
# parser.add_argument()

args = parser.parse_args()
#print( args.source )


def StripCode(_sourcePath):

    # TODO: Just use the current directory if no source given
    if _sourcePath is None:
        print('No source file patth given. Please use option -s ')
        exit(1)
    if not os.path.exists(_sourcePath) or os.path.isdir(_sourcePath):
        print('Not a valid file path')
        exit(1)

    _source = io.open(_sourcePath, 'r')
    _debugOut = None
    if args.debug_file is not None:
        try:
            _debugOut = io.open(args.debug_file, 'r')
        except BaseException:
            if _debugOut is not None:
                print('failed to open debug file: ' + args.debug_file)

    # Character-wise processing of the source file.
    # Its basically a rudimentary lexer, this is the only
    # way i could be sure i wasnt ripping out any code.
    # My regex kung-fu is weak =-<
    _mode = "norm"
    for _line in _source:
        if not _line.strip():
            continue
        for _byte in _line:

            # Forward slashes recieve special processing because
            # they could be the start of a comment, when we want to strip out
            if _byte == '/':

                # We've hit a single forward slash, this could meant
                # a comment is about to start, but too soon to tell...
                if _mode == 'norm':
                    _mode = 'com_start'

                # We've encountered at least 1 previous forward slash,
                # this means we are in a line comment
                elif _mode == 'com_start':
                    _mode = 'line_com'

                # We've encountered at least 1 block comment continuation
                # so we can assume this is the end of the block comment
                elif _mode == 'block_com_cont':
                    _mode = 'block_com_end'
                elif _mode == 'block_com_end':
                    _mode = 'com_start'
                else:
                    _mode = 'norm'

            # Asterisks could be a part of a block comment, need to use
            # a little logic to figure it out
            elif _byte == '*':

                # If we just passed a forward slash, this star means
                # 'block_comment'
                if _mode == 'com_start':
                    _mode = 'block_com'

                # If we are already in a block comment, this is just a
                # continuation line
                elif _mode == 'block_com':
                    _mode = 'block_com_cont'
                else:
                    _mode = 'norm'

            # We need a way for the system to exit 'line_comment' mode, just
            # look for a newline
            elif _byte == '\n':
                if _mode == 'line_com' or _mode == 'com_start':
                    _mode = 'norm'
                if _mode == 'block_com_end':
                    _mode = 'norm'

            # Need to be able to differentiate between single quote and double quote strings
            # Also need to support nested strings
            elif _byte == '\"':
                # Only enter string mode if we are not in a comment
                if _mode == 'norm':
                    _mode = 'string_dub'
                elif _mode == 'string_dub':
                    _mode = 'norm'
                # Nested string case
                elif _mode == 'string_sing':
                    _mode = 'string_nest'

            elif _byte == '\'':
                if _mode == 'norm':
                    _mode = 'string_sing'
                elif _mode == 'string_sing':
                    _mode = 'norm'

                # Nested string case1
                elif _mode == 'string_dub':
                    _mode = 'string_nest'
            # Any other character can be processed normally
            else:
                # If we just hit the end of a block comment then the next
                # char is in normal mode ( What about another comment starting
                # immediately?)
                if _mode == 'block_com_end':
                    _mode = 'norm'

            # Output the state of the parser for each character
            # for debugging
            if _debugOut is not None:
                _debugOut.write(
                    repr(
                        '<CHAR>::' +
                        _byte +
                        '---<MODE>::' +
                        _mode))

            # Aside from the 'normal' characters of the source code,
            # need to also make sure that any 'string' literals get
            # printed out along with the normal text.
            if _mode == 'norm' or 'string' in _mode:
                #				sys.stdout.write('')
                try:
                    sys.stdout.write(_byte)
                except BaseException:
                    if _debugOut is not None:
                        _debugOut.write('Failed to print character.')
        return 0
    # Make sure to close the file streams
    _source.close()
    if _debugOut is not None:
        _debugOut.close()


# TODO: Right now, the script spits all the input files out back into
# 	a single stream, but this can be manipulated by just passing in a single
# 	file at a time.
if args.source is not None and isinstance(args.source, list):

    #print('Working on source list...')

    for _source in args.source:
        StripCode(_source)

else:
    StripCode(args.source)
