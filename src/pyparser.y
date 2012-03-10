%{
    #include <string>
    #include <iostream>

    using namespace std;
    #define DEBUG
    #define YYSTYPE string
    
    int yylex(void);
    void yyerror(const char *str) {
        #ifdef DEBUG
            //cout << str << endl;
        #endif
    }
    int main();
%}

%token CLASS DEFINED COLON DOT LBRACE RBRACE ID OTHER DEF COMMA STAR MESSAGE INDENT
%start input

%left RBRACE
%left LBRACE

%%
input: /* empty */
     | input class_def
     | input func_def
     | input call
     | input error
;

/* CLASS */
class_def: CLASS classname inheritance COLON suite
    {
        #ifdef DEBUG
            cout << "[" << @$.last_column << "] "  << @$.first_line
                 << ">>> ClassDef: class " 
                 << $2            << "("
                 << $3            << ")"
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
                  cout << "[" << @$.last_column << "] " << @$.first_line << ">> FuncDef: function " 
                       << $2            << "("
                       << $4            << ")"
                       << endl;
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
call: calls_chain
      {
          cout << "[" << @$.last_column << "] " << @$.first_line << ">>> Call: function " 
               << $$            << endl;
      }
;
calls_chain: func_call
           | calls_chain DOT func_call
             {
                 $$ += $2 + $3;
             }
;
func_call: dotted_name func_call_params
           {
              $$ = $1 + $2;
           }
;
dotted_name: ID
           | dotted_name DOT ID
             {
                 $$ += $2 + $3;
             }
;
func_call_params: LBRACE RBRACE
                  {
                      $$ = $1 + $2;
                  }
                | LBRACE call_params RBRACE
                  {
                      $$ = $1 + $2 + $3;
                  }
;
call_params: OTHER
           | DEFINED
           | MESSAGE
           | dotted_name
           | STAR
           | calls_chain
           | func_call_params
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
           | call_params calls_chain
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
           | call_params func_call_params
             {
                 $$ += $2;
             }
;
/* end of FUNCTION CALL */
/*
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
;*/
%%

int main()
{
    return yyparse();
}