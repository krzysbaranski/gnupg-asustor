#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
ASUSTOR Package Creator with GitHub Actions Environment File Support

This script creates ASUSTOR apkg packages and outputs metadata using the
modern GitHub Actions environment file format instead of the deprecated
set-output command.
"""

import argparse
import os
import sys

# Import the apkg_tools module
from apkg_tools import Apkg

if __name__ == "__main__":
    # create the top-level parser
    parser = argparse.ArgumentParser(description='ASUSTOR package helper.')

    subparsers = parser.add_subparsers(help='sub-commands', dest='command')

    # create the parser for the "create" command
    parser_create = subparsers.add_parser('create', help='create package from folder')
    parser_create.add_argument('folder', help='select a package layout folder to pack')
    parser_create.add_argument('--destination', help='move apk to destination folder')

    # parsing arguments
    args = parser.parse_args()

    # process commands
    apkg = Apkg()

    if args.command == 'create':
        pkg, app_info = apkg.create(args.folder, args.destination)
        if isinstance(pkg, (str, bytes)):
            print("Generated file...")
            
            # Get the GitHub Output environment file path
            github_output = os.environ.get('GITHUB_OUTPUT')
            
            # Prepare output data
            output_data = {
                'apkg-file-name': os.path.basename(pkg),
                'apkg-file-path': os.path.normpath(args.destination + "/" + os.path.basename(pkg)),
                'apkg-app-info-general-package': app_info['general']['package'],
                'apkg-app-info-general-name': app_info['general']['name'],
                'apkg-app-info-general-version': app_info['general']['version'],
                'apkg-app-info-general-developer': app_info['general']['developer'],
                'apkg-app-info-general-maintainer': app_info['general']['maintainer'],
                'apkg-app-info-general-email': app_info['general']['email'],
                'apkg-app-info-general-website': app_info['general']['website'],
                'apkg-app-info-general-architecture': app_info['general']['architecture'],
                'apkg-app-info-general-firmware': app_info['general']['firmware']
            }
            
            # Write outputs using the modern GitHub Actions environment file format
            if github_output:
                with open(github_output, 'a') as f:
                    for key, value in output_data.items():
                        f.write(f"{key}={value}\n")
                        print(f"Set output: {key}={value}")
            else:
                # If not running in GitHub Actions, just print the values
                for key, value in output_data.items():
                    print(f"{key}={value}")
        else:
            print("Error making package")
            sys.exit(1)
