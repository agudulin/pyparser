%{
    #include <string>
    #include <iostream>
    #include <map>
    #include <stack>

    using namespace std;
    #define DEBUG
    #define YYSTYPE string

    stack <map <string, int> > st;
    
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
     | input calls_chain
     | input error
;

/* CLASS */
class_def: CLASS classname inheritance COLON suite
    {
        int indent = @$.last_column;
        map <string, int> cl_new;
        cl_new[$2] = indent;

        if (!st.empty()) {
            map <string, int> cl_def = st.top();

            if (cl_def.begin()->second < indent){
                st.push(cl_new);

            } else if (cl_def.begin()->second == indent){
                st.pop();
                st.push(cl_new);

            } else {
                while (!st.empty())
                {
                    cl_def = st.top();
                    if (cl_def.begin()->second >= indent){
                        st.pop();
                    } else {
                        break;
                    }
                }
                st.push(cl_new);
            }
        } else {
            st.push(cl_new);
        }

        #ifdef DEBUG
            /*if (!st.empty()){
                cout << " <> STACK_TOP: " << st.top().begin()->first << endl;
            } else {
                cout << " <> STACK_EMPTY" << endl;
            }*/
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
              int indent = @1.last_column;
              string fnc_name = $2;
              stack <map <string, int> > tmp_st;
              while (!st.empty())
              {
                  while (!st.empty() && st.top().begin()->second >= indent){
                      st.pop();
                  }
                  if (!st.empty()){
                      fnc_name = st.top().begin()->first + "." + fnc_name;
                      tmp_st.push(st.top());
                      st.pop();
                  }
              }
              while(!tmp_st.empty())
              {
                  st.push(tmp_st.top());
                  tmp_st.pop();
              }

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