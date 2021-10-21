#include <iostream>
#include <algorithm>
#include <vector>
#include <string>

using namespace std;


/*Classes for representing tokens.

A TokenKind instance represents one of the kinds of tokens recognized (see
token_kinds.cpp). A Token instance represents a token as produced by the lexer.

*/

class TokenKind{
    /*
    Class representing the various known kinds of tokens.

    Ex: +, -, ), return, int

    There are also token kind instances for each of 'identifier' and
    'number'. See token_kinds.cpp for a list of token_kinds defined.

    text_repr (str) - The token's representation in text, if it has a fixed
    representation.
    */

    public:
        string text_repr = "";

        TokenKind(string text_repr, vector<TokenKind> &kinds) { // Constructor with parameters
            this->text_repr = text_repr;
            kinds.push_back(*this);

        }

    


};

/*ostream &operator<<(ostream &out, const TokenKind &tk)
    {
        return out << tk.text_repr;
    }
    */

class Token{
    /*
    Single unit element of the input as produced by the tokenizer.

    kind (TokenKind) - Kind of this token.

    content - Additional content about some tokens. 
                For number tokens, this stores the number itself.
                For identifiers, this stores the identifier name.
                For string, stores a list of its characters.
    rep (str) - The string representation of this token.
        If not provided, the content parameter is used.
    r (Range) - Range of positions that this token covers.
    */

    //TODO
};