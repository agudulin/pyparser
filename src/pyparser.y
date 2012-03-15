%{
    #include <string>
    #include <iostream>
    #include <stack>

    using namespace std;
    #define DEBUG
    #define YYSTYPE string

    typedef pair <string, int> meta_data;
    typedef stack <meta_data> meta_stack;

    static meta_stack class_st;
    static meta_stack func_st;
    
    // remove all instructions (meta data -> string) from stack 
    // with largest indent than current instruction has
    static void clean_stack( meta_stack& stack, int indent );

    int yylex(void);
    void yyerror(const char *str) {
        #ifdef DEBUG
            //cout << str << endl;
        #endif
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
     | input calls_chain
     | input error
;

/* CLASS */
class_def: CLASS classname inheritance COLON suite
    {
        int indent = @1.last_column;
        meta_data new_class($2, indent);

        clean_stack( class_st, indent );
        class_st.push( new_class );

        #ifdef DEBUG
            cout //<< "[" << indent << "] "  
                 << @$.first_line
                 << " >> CLASS: " 
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
              string fnc_name = $2;
              int indent = @1.last_column;
              
              clean_stack( class_st, indent );
              meta_stack tmp_class_st(class_st);

              while (!tmp_class_st.empty())
              {
                  fnc_name = tmp_class_st.top().first + "." + fnc_name;
                  tmp_class_st.pop();
              }

              // replace fnc_name for $2 for less information 
              //   about function location
              meta_data new_func(fnc_name, indent);
              clean_stack( func_st, indent );
              func_st.push( new_func );

              #ifdef DEBUG
                  cout //<< "[" << indent << "] " 
                       << @$.first_line << " >> FUNC:  " 
                       << fnc_name      << "("
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
calls_chain: func_call
             {
                 cout //<< "[" << @$.last_column << "] " 
                      << @$.first_line << " >> CALL:  " 
                      << $$            << endl;
             }
           | calls_chain DOT func_call
             {
                 $$ += $2 + $3;
                 cout //<< "[" << @$.last_column << "] " 
                      << @$.first_line << " >> CALL:  " 
                      << $$            << endl;
             }
;
func_call: dotted_name func_call_params
           {
              string call_name = $1;
              // if func_call_params are in more than 1 line
              //   then indent can be unexpected
              //   but @1 determines it correctly
              int indent = @1.last_column;

              clean_stack( func_st, indent );
              meta_stack tmp_func_st(func_st);

              while (!tmp_func_st.empty())
              {
                  call_name = tmp_func_st.top().first + "." + call_name;
                  tmp_func_st.pop();
              }

              $$ = call_name + $2;
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

static void clean_stack( meta_stack& stack, int indent )
{
    while(!stack.empty())
    {
        if( indent > stack.top().second )
            break;
        stack.pop();
    }
}

int main()
{
    return yyparse();
}
