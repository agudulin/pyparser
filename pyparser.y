%{
    #include <string>
    #include <iostream>

    using namespace std;
    #define DEBUG
    #define YYSTYPE string

    string className = "";
    
    int yylex(void);
    void yyerror(const char *str) {
        printf("%s\n", str);
    }
    int main();
%}

%token CLASS DEFINED COLON DOT LBRACE RBRACE ID OTHER

%%
input: /* empty */
     | input class_def
     | input other_token
;

classname: ID
            {
                className = $1;
            }
;

expression_list: /* empty */
               | expression
;

expression: ID
            {
                #ifdef DEBUG
                    cout << "Class: "      << className 
                         << ": child to: " << $1 << endl;
                #endif
            }
          | expression OTHER
          | expression ID
           {
                #ifdef DEBUG
                    cout << "Class: "      << className 
                         << ": child to: " << $2 << endl;
                #endif
           }
;

inheritance: /* empty */
           | LBRACE expression_list RBRACE
;

class_def: CLASS classname inheritance COLON suite
    {
        #ifdef DEBUG
        //    cout << "Class: " << className << endl;
        #endif
    }
;

suite:
;

other_token: DEFINED
           | COLON
           | DOT
           | ID
           | OTHER
           | LBRACE
           | RBRACE
;
%%

int main()
{
    return yyparse();
}