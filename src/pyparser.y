%{
    #include <string>
    #include <iostream>

    using namespace std;
    #define DEBUG
    #define YYSTYPE string
    
    int yylex(void);
    void yyerror(const char *str) {
        printf("%s\n", str);
    }
    int main();
%}

%token CLASS DEFINED COLON DOT LBRACE RBRACE ID OTHER DEF COMMA STAR

%%
input: /* empty */
     | input class_def
     | input func_def
     //| input func_call
     | input other_token
;

/* CLASS */
class_def: CLASS classname inheritance COLON suite
    {
        #ifdef DEBUG
            cout << "Class: "      << $2
                 << ": child to: " << $3 
                 << endl;
        #endif
    }
;
classname: ID
           {
               $$ = $1;
           }
;
inheritance: /* empty */
             {
                 $$ = "";
             }
           | LBRACE class_args_list RBRACE
             {
                 $$ = $2;
             }
;
class_args_list: /* empty */
                 {
                     $$ = "";
                 }
               | class_arg
                 {
                     $$ = $1;
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
         | class_arg DOT
           {
               $$ += $2;
           }
;
/* end of CLASS */

/* FUNCTION */
func_def: DEF funcname LBRACE func_args_list RBRACE COLON suite
          {
              #ifdef DEBUG
                  cout << "Function: " << $2
                       << "("          << $4 
                       << ")"          << endl;
              #endif
          }
;
funcname: ID
          {
              $$ = $1;
          }
;
func_args_list: /* empty */
                {
                    $$ = "";
                }
              | func_arg
                {
                    $$ = $1;
                }
;
func_arg: ID
        | star_arg
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
        | func_arg star_arg
          {
              $$ += $2;
          }
;
star_arg: STAR ID
          {
              $$ = $1 + $2;
          }
        | STAR STAR ID
          {
              $$ = $1 + $2 + $3;
          }
;
/* end of FUNCTION */

suite:
;

/* FUNCTION CALL 
func_call: ID LBRACE call_params RBRACE
           {
               cout << "Function \"" << $1  << "\" is called with params ("
                    << $3            << ")" << endl;
           }
;
call_params: /* empty *
             {
                 $$ = "";
             }
           | call_param
             {
                 $$ = $1;
             }
;
call_param: other_token
          | func_call
          | call_param func_call
            {
                $$ += $2;
            }
          | call_param OTHER
            {
                $$ += $2;
            }
          | call_param COMMA
            {
                $$ += $2;
            }
          | call_param ID
            {
                $$ += $2;
            }
          | call_param DOT
            {
                $$ += $2;
            }
          | call_param DEFINED
            {
                $$ += $2;
            }
          | call_param star_arg
            {
                $$ += $2;
            }
;
/* end of FUNCTION CALL */

other_token: DEFINED
           | COLON
           | DOT
           | ID
           | OTHER
           | COMMA
           | STAR
           | LBRACE
           | RBRACE
;
%%

int main()
{
    return yyparse();
}