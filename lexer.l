%{
    #include <string>
    #include <iostream>

    using namespace std;
    #define YYSTYPE string

    #include "pyparser.tab.h"
%}

identifier      [_a-zA-Z][_a-zA-Z0-9]*
comment         "#".*
quote1          "\'"[^'\\]*"\'"
quote2          "\""[^"\\]*"\""

%%
and|elif|global|or|assert|else|if|except|pass|break|import|print|exec|in|raise|continue|finally|is|return|for|lambda|try|del|from|not|while yylval = yytext; return DEFINED;
class           yylval = yytext; return CLASS;

":"             yylval = yytext; return COLON;
"."             yylval = yytext; return DOT;
"("             yylval = yytext; return LBRACE;
")"             yylval = yytext; return RBRACE;

{identifier}    yylval = yytext; return ID;
{comment}       ; /* skip comment */

{quote1}        ; /* skip messages in single quotes */
{quote2}        ; /* skip messages in double quotes */

[ \t]+          ; /* skip whitespaces */
\n\r|\r\n|\n|\r ; /* skip new line */
.               yylval = yytext; return OTHER;
%%