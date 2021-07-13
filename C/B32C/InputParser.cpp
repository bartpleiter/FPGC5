#include <iostream>
#include <algorithm>
#include <vector>

using namespace std;

class InputParser{
    public:
        InputParser (int &argc, char **argv)
        {
            for (int i=1; i < argc; ++i)
                this->tokens.push_back(string(argv[i]));
        }

        const string& getCmdOption(const string &option) const
        {
            vector<string>::const_iterator itr;
            itr =  find(this->tokens.begin(), this->tokens.end(), option);
            if (itr != this->tokens.end() && ++itr != this->tokens.end())
            {
                return *itr;
            }
            static const string empty_string("");
            return empty_string;
        }

        bool cmdOptionExists(const string &option) const
        {
            return find(this->tokens.begin(), this->tokens.end(), option)
                   != this->tokens.end();
        }

        string getFirstCfile()
        {
            for (int i=0; i < tokens.size(); i++)
                if (tokens[i].length() > 2)
                    if (tokens[i].substr( tokens[i].length() - 2 ) == ".c")
                        return tokens[i];
            return "";
        }
    private:
        vector <string> tokens;
};