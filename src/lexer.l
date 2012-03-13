%{
    #include <string>
    #include <iostream>

    using namespace std;
    //#define DEBUG
    #define YYSTYPE string

    #include "pyparser.tab.h"
    
    extern YYLTYPE yylloc;
    #define YY_USER_INIT yylloc.first_line=1;
    #define SPACES_PER_INDENT 4
    
    int indentLevel = 0;
    int countIndent(string);
    string skipMessage(string _ch);
    void skipComments();
    char projectIndent;
    bool isStartIndentSet = false;
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
defined         "and"|"elif"|"global"|"or"|"assert"|"else"|"if"|"except"|"pass"|"break"|"print"|"exec"|"in"|"raise"|"continue"|"finally"|"is"|"return"|"for"|"lambda"|"try"|"del"|"not"|"while"
quote1          "\'"[^'\\]*"\'"
quote2          "\""[^"\\]*"\""

%%
\n\r|\r\n|\n|\r {
                    /* skip empty line */
                    yylloc.first_line++;
                    yylloc.last_column = 0;
                }
"#"             {
                    /* skip comment */
                    skipComments();
                    yylloc.first_line++; 
                }
{defined}       {
                    yylval = yytext;
                    #ifdef DEBUG 
                        cout << yytext << endl;
                    #endif
                    return DEFINED;
                }
^[ ]*"class"    {
                    yyleng -= 5;
                    #ifdef DEBUG
                        if (0 != yyleng % SPACES_PER_INDENT){
                            cout << "Bad Indent" << endl;
                        }
                    #endif
                    yylloc.last_column = yyleng / SPACES_PER_INDENT;
                    yylval = yytext;
                    return CLASS;
                }
^[\t]*"class"   {
                    yylloc.last_column = yyleng - 5;
                    yylval = yytext;
                    return CLASS;
                }
^[ ]*"def"      {
                    yyleng -= 3;
                    #ifdef DEBUG
                        if (0 != yyleng % SPACES_PER_INDENT){
                            cout << "Bad Indent" << endl;
                        }
                    #endif
                    yylloc.last_column = yyleng / SPACES_PER_INDENT;
                    yylval = yytext;
                    return DEF;
                }
^[\t]*"def"     {
                    yylloc.last_column = yyleng - 3;
                    yylval = yytext;
                    return DEF;
                }
^[\t]+          {
                    yylloc.last_column = yyleng;
                    //return INDENT;
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
\"\"\"          skipMessage((string)("\"\"\"")); /* skip messages in triple double quotes */
\'\'\'          skipMessage((string)("\'\'\'")); /* skip messages in triple single quotes */
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
    /*if(projectIndent != str[0])
        #ifdef DEBUG
            cout << "WTF :( TABS and SPACES are in one file" << endl;
        #endif*/
    return str.size();
}

string skipMessage(string _ch){
    string ch;
    string str = _ch;
    _ch = _ch[0];
    bool skip = false;
    int count = 1;
    for(;;ch = yyinput()) {
        str += ch;
        if (ch == _ch){
            if (count == 3)
                return str;
            else count++;
        } else
            count = 1;

        if ("\n" == ch || "\r" == ch)
            yylloc.first_line++;
    }
}

void skipComments(){
    for(char ch = yyinput();;ch = yyinput()) {
        if ('\0' == ch || '\n' == ch || '\r' == ch)
            break;
    }
}