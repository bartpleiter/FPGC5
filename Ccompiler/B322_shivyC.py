#!/usr/bin/env python3

"""
Main executable for C compiler.
This compiler is a modified version of the ShivyC compiler (C to x86_64 compiler, written in Python, see https://github.com/ShivamSarodia/ShivyC) by Shivam Sarodia.
It is modified by me (b4rt-dev) to output B322 assembly instead of x86_64 assembly.
New features are/will be added as well, compared to the original version.
For more info see the documentation (when it is written properly :P) on https://www.b4rt.nl/fpgc4 (or the github for the .md files)
"""

"""
Currently the compiler is still a bit of a mess after converting the output stage to output B322 assembly.
There are things like the size parameter of registers/instructions that still have to be removed, and most things are still ad hac
Not all cases are tested yet, since I do not have test cases written for everything yet, so for example divisions will result in x86_64 ish assembly that will not compile by the B322 assembler.
"""

"""
The MIT License (MIT)

Copyright (c) 2016 Shivam Sarodia
Copyright (c) 2020 b4rt-dev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

"""
TODO:
* rename all shivyc to B322C
* multiple big clean-up and reimplementation passes
* good tests
"""

import argparse
import pathlib
import platform
import subprocess
import sys
import pprint

import shivyc.lexer as lexer
import shivyc.preproc as preproc

from shivyc.errors import error_collector, CompilerError
from shivyc.parser.parser import parse
from shivyc.il_gen import ILCode, SymbolTable, Context
from shivyc.asm_gen import ASMCode, ASMGen


def main():
    """Run the main compiler script."""

    asm = ""

    arguments = get_arguments()

    # supports compiling one .c file only
    if len(arguments.files) != 1:
        print("Expected 1 input file, got", str(len(arguments.files)), "instead")
        return -1

    # compile the file
    asm = process_file(arguments.files[0], arguments)

    # print complete assembly to stdout on success
    if asm:
        print(asm)

    # show all errors
    error_collector.show()

    # return with code
    if len(error_collector.issues) == 0:
        sys.exit(0)
    
    else:
        sys.exit(-1)
    
    return 0


def process_file(file, args):
    """Process single file into assembly code and return the code as string."""
    #print("processing file: ", file)
    if file[-2:] == ".c":
        return process_c_file(file, args)
    else:
        err = f"unknown file type: '{file}'"
        error_collector.add(CompilerError(err))
        return None


def process_c_file(file, args):
    """Compile a C file into assembly code and return the code as string."""
    code = read_file(file)
    if not error_collector.ok():
        return None

    token_list, defineDict = lexer.tokenize(code, file)
    if not error_collector.ok():
        return None

    token_list = preproc.process(token_list, file, defineDict)
    if not error_collector.ok():
        return None

    #print("token_list:\n", token_list)

    # If parse() can salvage the input into a parse tree, it may emit an
    # ast_root even when there are errors saved to the error_collector. In this
    # case, we still want to continue the compiler stages.
    ast_root = parse(token_list)

    if not ast_root:
        return None

    il_code = ILCode()

    symbol_table = SymbolTable()
    ast_root.make_il(il_code, symbol_table, Context())
    if not error_collector.ok():
        return None

    asm_code = ASMCode()

    # This is the part we mostly want to modify to generate B322 ASM code instead of x86_64 ASM code
    ASMGen(il_code, symbol_table, asm_code, args).make_asm()
    asm_source = asm_code.full_code(args.bdos, args.os)
    #print("asm_source:\n", asm_source)
    if not error_collector.ok():
        return None

    
    return asm_source


def get_arguments():
    """Get the command-line arguments.

    This function sets up the argument parser. Returns a tuple containing
    an object storing the argument values and a list of the file names
    provided on command line.
    """
    desc = """Compile C files into B332 Assembly. Option flags starting
    with `-z` are primarily for debugging or diagnostic purposes."""
    parser = argparse.ArgumentParser(
        description=desc, usage="B322C [-h] [options] files...")

    # Files to compile
    parser.add_argument("files", metavar="files", nargs='+')

    # Compile for BDOS
    parser.add_argument("--bdos", dest="bdos", action="store_true")

    # Compile as OS
    parser.add_argument("--os", dest="os", action="store_true")

    # Boolean flag for whether to print register allocator performance info
    parser.add_argument("-z-reg-alloc-perf",
                        help="display register allocator performance info",
                        dest="show_reg_alloc_perf", action="store_true")

    return parser.parse_args()


def read_file(file):
    """Return the contents of the given file."""
    try:
        with open(file) as c_file:
            return c_file.read()
    except IOError as e:
        descrip = f"could not read file: '{file}'"
        error_collector.add(CompilerError(descrip))


def write_asm(asm_source, asm_filename):
    """Save the given assembly source to disk at asm_filename.

    asm_source (str) - Full assembly source code.
    asm_filename (str) - Filename to which to save the generated assembly.

    """
    try:
        with open(asm_filename, "w") as s_file:
            s_file.write(asm_source)
    except IOError:
        descrip = f"could not write output file '{asm_filename}'"
        error_collector.add(CompilerError(descrip))

if __name__ == "__main__":
    sys.exit(main())
