%{
    #include <string>
    #include <iostream>

    using namespace std;
    #define DEBUG
    #define YYSTYPE string

    string className  = "";
    string funcName   = "";
    string funcParams = "";
    string classInheritance = "";
    
    int yylex(void);
    void yyerror(const char *str) {
        printf("%s\n", str);
    }
    int main();
%}

%token CLASS DEFINED COLON DOT LBRACE RBRACE ID OTHER DEF COMMA

%%
input: /* empty */
     | input class_def
     | input func_def
     | input other_token
;

/* CLASS */
class_def: CLASS classname inheritance COLON suite
    {
        className = $2;
        #ifdef DEBUG
            cout << "Class: " << className
                 << ": child to: " << classInheritance << endl;
        #endif
    }
;
classname: ID 
           {
               $$ = $1;
           }
;
inheritance: /* empty */
           | LBRACE class_args_list RBRACE
;
class_args_list: /* empty */
               | class_arg
                 {
                     classInheritance = $1;
                 }
;
class_arg: ID
         | class_arg COMMA
           {
               $$ += $2;
           }
         | class_arg ID
           {
               $$ += $2;
           }
;
/* end of CLASS */

/* FUNCTION */
func_def: DEF funcname parameters COLON suite
          {
              #ifdef DEBUG
                  cout << "Function: " << funcName
                       << "(" << funcParams << ")" << endl;
              #endif
              funcParams = "";
          }
;
funcname: ID
          {
              funcName = $1;
          }
;
parameters: LBRACE func_args_list RBRACE
;
func_args_list: /* empty */
              | func_arg
                {
                    funcParams = $1;
                }
;
func_arg: ID
        | func_arg OTHER
          {
              $$ += $2;
          }
        | func_arg COMMA
          {
              $$ += $2;
          }
        | func_arg ID
          {
              $$ += $2;
          }
/* end of FUNCTION */

suite:
;

other_token: DEFINED
           | COLON
           | DOT
           | ID
           | OTHER
           | COMMA
           | LBRACE
           | RBRACE
;
%%

int main()
{
    return yyparse();
}