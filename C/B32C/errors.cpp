#include <iostream>
#include <algorithm>
#include <vector>
#include <unordered_map>

using namespace std;

/*
Objects used for error reporting.

The main executable catches an exception and prints it for the user.
*/

class ErrorCollector{
    /*Class that accumulates all errors and warnings encountered.

    We create a global instance of this class so all parts of the compiler can
    access it and add errors to it. This is kind of janky, but it's much easier
    than passing an instance to every function that could potentially fail.
    */
    public:
        ErrorCollector()
        {
        }
            
};

class Position{
    /*
    Class representing a position in source code.

    file (str) - Name of file in which this position is located.
    line (int) - Line number in file at which this position is located.
    col (int) - Horizontal column at which this position is located
    full_line (str) - Full text of the line containing this position.
    Specifically, full_line[col + 1] should be this position.
    */

    public:
        string file;
        int line;
        int col;
        string full_line;

        Position(string file, int line, int col, string full_line) { // Constructor with parameters
            this->file = file;
            this->line = line;
            this->col = col;
            this->full_line = full_line;
        }

        Position operator+(const Position& position)
        {
            return Position(this->file, this->line, this->col + 1, this->full_line);
        }


};

