%{
    #include <string>
    #include <iostream>

    using namespace std;
    //#define DEBUG
    #define YYSTYPE string

    #include "pyparser.tab.h"
    
    extern YYLTYPE yylloc;
    #define YY_USER_INIT yylloc.first_line=1;
    
    int currentIndent = 0;
    int countIndent(string);
    string skip_message(string _ch);
    void skip_comments();
    char projectIndent;
    bool isStartIndentSet = false;
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
defined         "and"|"elif"|"global"|"or"|"assert"|"else"|"if"|"except"|"pass"|"break"|"print"|"exec"|"in"|"raise"|"continue"|"finally"|"is"|"return"|"for"|"lambda"|"try"|"del"|"not"|"while"
quote1          "\'"[^'\\]*"\'"
quote2          "\""[^"\\]*"\""

%%
\n\r|\r\n|\n|\r yylloc.first_line++; /* skip empty line */
"#"             skip_comments(); yylloc.first_line++; /* skip comment */
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
\"\"\"          skip_message((string)("\"\"\"")); /* skip messages in triple double quotes */
\'\'\'          skip_message((string)("\'\'\'")); /* skip messages in triple single quotes */
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

string skip_message(string _ch){
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

        if ("\n\r" == ch || "\r\n" == ch || "\n" == ch || "\r" == ch)
            yylloc.first_line++;
    }

}

void skip_comments(){
    string ch;
    for(;;ch = yyinput()) {
        if ("\n\r" == ch || "\r\n" == ch || "\n" == ch || "\r" == ch)
            break;
    }
}
