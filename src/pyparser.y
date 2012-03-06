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

%token CLASS DEFINED COLON DOT LBRACE RBRACE ID OTHER DEF COMMA STAR MESSAGE
%start input

%left RBRACE
%left LBRACE

%%
input: /* empty */
     | input class_def
     | input func_def
     | input func_call
     | input other_token
;

/* CLASS */
class_def: CLASS classname inheritance COLON suite
    {
        #ifdef DEBUG
            cout << ">>> ClassDef: class " << $2
                 << "("                    << $3
                 << ")"                    << endl;
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
                  cout << ">> FuncDef: function " << $2
                       << "("                     << $4 
                       << ")"                     << endl;
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
func_arg: dotted_name
        | star_arg
        | func_arg OTHER
          {
              $$ += $2;
          }
        | func_arg COMMA
          {
              $$ += $2;
          }
        | func_arg dotted_name
          {
              $$ += $2;
          }
        | func_arg star_arg
          {
              $$ += $2;
          }
        | func_arg MESSAGE
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

/* FUNCTION CALL */
func_call: dotted_name LBRACE call_params RBRACE
           {
              #ifdef DEBUG
                  cout << "> Call: function " << $1
                       << "("                 << $3
                       << ")"                 << endl;
              #endif
           }
;
dotted_name: ID
           | dotted_name DOT ID
             {
                 $$ += $2 + $3;
             }
;
call_params: /* empty */
             {
                 $$ = "";
             }
           | OTHER
           | DEFINED
           | MESSAGE
           | dotted_name
           | STAR
           | func_call
           | call_params DEFINED
             {
                 $$ += $2;
             }
           | call_params MESSAGE
             {
                 $$ += $2;
             }
           | call_params dotted_name
             {
                 $$ += $2;
             }
           | call_params OTHER
             {
                 $$ += $2;
             }
           | call_params func_call
             {
                 $$ += $2;
             }
           | call_params COMMA
             {
                 $$ += $2;
             }
           | call_params COLON
             {
                 $$ += $2;
             }
           | call_params STAR
             {
                 $$ += $2;
             }
           | call_params LBRACE call_params RBRACE
             {
                 $$ += $2 + $3 + $4;
             }
 ;
/* end of FUNCTION CALL */

other_token: dotted_name
           | DEFINED
           | COLON
           | DOT
           | OTHER
           | COMMA
           | STAR
           | MESSAGE
           | LBRACE
           | RBRACE
;
%%

int main()
{
    return yyparse();
}