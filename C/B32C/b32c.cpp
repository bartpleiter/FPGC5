/* B32C
* C compiler for my B32(2) CPU
* Based on the ShivyC compiler (https://github.com/ShivamSarodia/ShivyC) by Shivam Sarodia.
* Many modifications are made to compile to my CPU's assembly and this is a C++ version.
*/

/*
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
*/

#include <iostream>
#include <algorithm>
#include <vector>
#include <fstream>
#include <string>
#include "asm_cmd.cpp"
#include "compare.cpp"
#include "errors.cpp"
#include "lexer.cpp"
#include "parser_utils.cpp"
#include "tokens.cpp"
#include "asm_gen.cpp"
#include "control.cpp"
#include "expression.cpp"
#include "preproc.cpp"
#include "tree_utils.cpp"
#include "ctypes.cpp"
#include "expr_nodes.cpp"
#include "math.cpp"
#include "spots.cpp"
#include "value.cpp"
#include "declaration.cpp"
#include "il_gen.cpp"
#include "nodes.cpp"
#include "statement.cpp"
#include "base.cpp"
#include "decl_nodes.cpp"
#include "InputParser.cpp"
#include "parser.cpp"
#include "token_kinds.cpp"


using namespace std;


void test()
{
}

void process_file(string filename, bool bdos, bool os)
{
    ifstream ifs(filename);
    if (!ifs.good())
    {
        cout << "Error: could not open file\n";
        return;
    }
    string fileContent( (istreambuf_iterator<char>(ifs) ),
                       (istreambuf_iterator<char>()    ) );

    //cout << fileContent;
}

int main(int argc, char* argv[])
{
    test();

    InputParser input(argc, argv);

    bool bdos = input.cmdOptionExists("--bdos");
    bool os = input.cmdOptionExists("--os");
    string filename = input.getFirstCfile();

    if (filename != "")
    {
        process_file(filename, bdos, os);
    }
    else
    {
        cout << "Error: missing .c input file\n";
    }

    return 0;
}


