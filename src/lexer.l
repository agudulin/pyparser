%{
    #include <string>
    #include <iostream>

    using namespace std;
    #define DEBUG
    #define YYSTYPE string

    #include "pyparser.tab.h"

    int currentIndent = 0;
    int countIndent(string);
    char projectIndent;
    bool isStartIndentSet = false;
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
defined         "and"|"elif"|"global"|"or"|"assert"|"else"|"if"|"except"|"pass"|"break"|"print"|"exec"|"in"|"raise"|"continue"|"finally"|"is"|"return"|"for"|"lambda"|"try"|"del"|"not"|"while"
comment         "#".*
quote1          "\'"[^'\\]*"\'"
quote2          "\""[^"\\]*"\""
quote3_2        "\"\"\""(?:[^"]*|\\["]|["]{1,2}[^"])*"\"\"\""
quote3_1        "\'\'\'"(?:[^']*|\\[']|[']{1,2}[^'])*"\'\'\'"

%%
\n\r|\r\n|\n|\r ; /* skip empty line */
{comment}       ; /* skip comment */
"from"|"import" ;
{defined}       {
                    yylval = yytext;
                    #ifdef DEBUG 
                        cout << yytext << endl;
                    #endif
                    return DEFINED;
                }
^[ \t]+         {
                    if(!isStartIndentSet) {
                        projectIndent = yytext[0];
                        isStartIndentSet = true;
                    }
                    #ifdef DEBUG
                        cout << yytext;
                    #endif
                    int newIndent = countIndent(yytext);
                    if (newIndent > currentIndent) {
                        #ifdef DEBUG
                            cout << "INDENT ->" 
                                 << newIndent-currentIndent << endl;
                        #endif
                        currentIndent = newIndent;
                    } 
                    else if (newIndent < currentIndent) {
                        #ifdef DEBUG
                            cout << "DEDENT <- " 
                                 << currentIndent-newIndent << endl;
                        #endif
                        currentIndent = newIndent;
                   }
                }
class           {
                    yylval = yytext;
                    return CLASS;
                }
def             {
                    yylval = yytext;
                    return DEF;
                }
":"             yylval = yytext; return COLON;
"."             yylval = yytext; return DOT;
","             yylval = yytext; return COMMA;
"("             yylval = yytext; return LBRACE;
")"             yylval = yytext; return RBRACE;
"*"             yylval = yytext; return STAR;

{identifier}    {
                    yylval = yytext; 
                    #ifdef DEBUG 
                        cout << yytext << endl; 
                    #endif
                    return ID;
                }
{quote3_1}      ; /* skip messages in triple single quotes */
{quote3_2}      ; /* skip messages in triple double quotes */
{quote1}        {
                    yylval = yytext;
                    #ifdef DEBUG
                        cout << "MSG: " << yytext << endl;
                    #endif
                    return MESSAGE;
                }
{quote2}        {
                    yylval = yytext;
                    #ifdef DEBUG
                        cout << "MSG: " << yytext << endl;
                    #endif
                    return MESSAGE;
                }

[ \t]+          ; /* skip whitespaces */
.               {
                    yylval = yytext;
                    #ifdef DEBUG 
                        cout << yytext << endl; 
                    #endif
                    return OTHER;
                }
%%

int countIndent(string str)
{
    if(projectIndent != str[0])
        #ifdef DEBUG
            cout << "WTF :( TABS and SPACES are in one file" << endl;
        #endif
    return str.size();
}