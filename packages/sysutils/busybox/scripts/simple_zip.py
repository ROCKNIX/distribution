#!/usr/bin/env python

# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2026-present Team LibreELEC (https://libreelec.tv)


import argparse
import os
import shutil
import sys


def CreateZipFile(file_path):
    '''Create a zip file from a directory or a single file.'''
    file_output = args.file.removesuffix('.zip')
    if os.path.isdir(file_path):
        if args.junk:
            shutil.make_archive(base_name=file_output, format='zip', root_dir=file_path)
        else:
            dir_path = f'{os.path.basename(file_path)}/' if file_path.startswith('/') else f'{os.getcwd()}/'
            base_path = file_path.removeprefix(dir_path) if file_path.startswith('/') else file_path
            shutil.make_archive(base_name=file_output, format='zip', root_dir=dir_path, base_dir=base_path)
        return
    elif os.path.isfile(file_path):
        if args.junk:
            base_path = os.path.basename(file_path)
            dir_path = file_path.removesuffix(base_path)
        else:
            dir_path = f'{os.path.dirname(file_path)}/' if file_path.startswith('/') else f'{os.getcwd()}/'
            base_path = file_path.removeprefix(dir_path) if file_path.startswith('/') else file_path
        shutil.make_archive(base_name=file_output, format='zip', root_dir=dir_path, base_dir=base_path)
        return


if __name__ == '__main__':
    # Parse CLI arguments
    parser = argparse.ArgumentParser(description='Simple zip file maker.', argument_default=False)

    # Switches
    parser.add_argument('-f', '--file', required=True, action='store', \
                        help='name of zip file to create')
    parser.add_argument('-i', '--input', required=True, action='store', \
                        help='directory the zip file is created from')
    parser.add_argument('-j', '--junk', action='store_true', \
                        help='junk (do not record) directory names')
    parser.add_argument('-v', '--verbose', action='store_true', \
                        help='verbose messages')
    args = parser.parse_args()


    # Sanity check
    if os.path.exists(args.file):
        print(f'Error: File already exists: {args.file}')
        sys.exit(1)
    if not os.path.exists(args.input):
        print(f'Error: Input not found: {args.input}')
        sys.exit(1)


    CreateZipFile(args.input)
    if args.verbose and os.path.isfile(args.file):
        print(f'Created zip file: {args.file}')
