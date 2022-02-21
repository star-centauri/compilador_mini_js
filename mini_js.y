 %{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <map>

using namespace std;

struct Atributos {
  vector<string> v;
};

#define YYSTYPE Atributos

void erro( string msg );
void print( vector<string> codigo );

vector<string> concatena( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, string b );

string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );

int yylex();
void yyerror( const char* );

vector<string> auxiliar;

%}

%right '='
%right MAIS_EGUAL MENOS_EGUAL
%left OR
%left AND 
%nonassoc '<' '>' EGUAL NOT_EGUAL MAIOR_IGUAL MENOR_IGUAL 
%left '+' '-'
%left '*' '/' '%'
%nonassoc UMINUS
%right '^'


// Tokens
%token ID INT DOUBLE STRING BOOL EMPTY_OBJ EMPTY_ARRAY 
%token IF ELSE WHILE FOR LET VAR CONST
%token MAIS_EGUAL MENOS_EGUAL VEZES_EGUAL DIVISAO_EGUAL
%token OR AND EGUAL NOT_EGUAL MAIOR_IGUAL MENOR_IGUAL MAIS_MAIS MENOS_MENOS

%start S

%%

S : CMDs { print( resolve_enderecos($1.v) ); }
  ;

CMDs : CMD ';' CMDs { $$.v = $1.v + $3.v; }
     | CMD CMDs { $$.v = $1.v + $2.v; }
     | { $$.v = auxiliar; }
     ;
     
CMD : CMD_DECLARACOES {$$.v = $1.v; }
    | CMD_FOR { $$.v = $1.v; }
    | CMD_IF { $$.v = $1.v; }
    | CMD_WHILE { $$.v = $1.v; }
    | '{' CMD_LIST '}' { $$.v = $2.v; }
    ;
    
CMD_LIST : CMD
         | CMD_LIST CMD { $$.v = $1.v + $2.v; }
         | CMD_LIST ';' CMD { $$.v = $1.v + $3.v; }
	 ;
    
CMD_DECLARACOES : CMD_ATRIB { $$.v = $1.v + "^"; }
                | CMD_ATRIB_2 { $$.v = $1.v + "^"; }
                | LET CMD_MULT_DECLARACAO { $$.v = $2.v; }
                | VAR CMD_MULT_DECLARACAO { $$.v = $2.v; }
                | CONST CMD_MULT_DECLARACAO { $$.v = $2.v; }
                ; 
                
CMD_MULT_DECLARACAO : CMD_DECLARACAO ',' CMD_MULT_DECLARACAO { $$.v = $1.v + $3.v; }
                    | CMD_DECLARACAO
                    ;
                
CMD_DECLARACAO : ID '=' CMD_RVALUE { $$.v = $1.v + "&" + $1.v + $3.v + "=" + "^"; }
               | ID                { $$.v = $1.v + "&"; }
               ;

CMD_ATRIB : ID '=' CMD_ATRIB { $$.v = $1.v + $3.v + "="; }
          | CMD_LVALUE_PROP '=' CMD_RVALUE { $$.v = $1.v + $3.v + "[=]"; }
          | CMD_RVALUE
          ;
          
CMD_ATRIB_2 : ID MAIS_EGUAL CMD_ATRIB_2 { $$.v = $1.v + $1.v + "@" + $3.v + "+" + "="; }
            | CMD_RVALUE
            ;
            
CMD_LVALUE_PROP : ID '.' ID         { $$.v = $1.v + "@" + $3.v; }
		 | ID '[' STRING ']' { $$.v = $1.v + "@" + $3.v; }
		 | ID '[' INT ']'    { $$.v = $1.v + "@" + $3.v; }
		 | ID '[' DOUBLE ']' { $$.v = $1.v + "@" + $3.v; }
		 ;

CMD_RVALUE : ID { $$.v = $1.v + "@"; }
           | ID '.' ID         { $$.v = $1.v + "@" + $3.v + "[@]"; }
           | ID '[' STRING ']' { $$.v = $1.v + "@" + $3.v + "[@]"; }
           | ID '[' INT ']'    { $$.v = $1.v + "@" + $3.v + "[@]"; }
           | ID '[' DOUBLE ']' { $$.v = $1.v + "@" + $3.v + "[@]"; }
           | CMD_RVALUE '^' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE '<' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE EGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE NOT_EGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE MENOR_IGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE MAIOR_IGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
	   | '!' CMD_RVALUE                    { $$.v = "!" + $2.v; } // DANDO ERROR
           | CMD_RVALUE AND CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE OR CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | ID MAIS_MAIS             { $$.v = $1.v + "@" + "1" + $2.v; }
           | ID MENOS_MENOS           { $$.v = $1.v + "@" + "1" + $2.v; }           
           | CMD_RVALUE '*' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE '+' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE '-' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE '/' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE '>' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE '%' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | INT 
           | DOUBLE 
           | STRING 
           | BOOL 
           | '-' CMD_RVALUE %prec UMINUS { $$.v = $1.v + $2.v; }
           | EMPTY_OBJ
           | EMPTY_ARRAY
           | '(' CMD_RVALUE ')' { $$.v = $2.v; }
           ;
           
CMD_FOR : FOR '(' CMD ';' CMD_RVALUE ';' CMD_RVALUE ')' CMD;

CMD_IF : IF '(' CMD_RVALUE ')' CMD { 
                                              string endif = gera_label("end_if");
                                              $$.v = $3.v + "!" + endif + "?" + 
                                                     $5.v + (":" + endif); 
                                            }
       | IF '(' CMD_RVALUE ')' CMD ELSE CMD {
       						          string then = gera_label("then");
       						          string endif = gera_label("end_if");
       						          $$.v = $3.v + then + "?" 
       						                 + $7.v + endif + "#" 
       						                 + (":" + then)
       						                 + $5.v + (":" + endif); 
                                                              }
       ;
           
CMD_WHILE : WHILE '(' CMD_RVALUE ')' CMD {
                                                    string endwhile = gera_label("end_while");
					             $$.v = $3.v + "!" + endwhile 
					             + "?" + $5.v + (":" + endwhile);
                                                  }
          ;
           
%%

#include "lex.yy.c"

vector<string> concatena( vector<string> a, vector<string> b ) {
  a.insert( a.end(), b.begin(), b.end() );
  return a;
}

vector<string> operator+( vector<string> a, vector<string> b ) {
  return concatena( a, b );
}

vector<string> operator+( vector<string> a, string b ) {
  a.push_back( b );
  return a;
}

string gera_label( string prefixo ) {
  static int n = 0;
  return prefixo + "_" + to_string( ++n ) + ":";
}

vector<string> resolve_enderecos( vector<string> entrada ) {
  map<string,int> label;
  vector<string> saida;
  for( int i = 0; i < entrada.size(); i++ ) 
    if( entrada[i][0] == ':' ) 
        label[entrada[i].substr(1)] = saida.size();
    else
      saida.push_back( entrada[i] );
  
  for( int i = 0; i < saida.size(); i++ ) 
    if( label.count( saida[i] ) > 0 )
        saida[i] = to_string(label[saida[i]]);
    
  return saida;
}

void yyerror( const char* msg ) {
   puts( msg ); 
   printf( "Proximo a: %s\n", yytext );
   exit( 1 );
}

void print( vector<string> codigo ) {
  for (int i = 0; i < codigo.size(); i++) {
    cout << codigo[i] << " ";
  } 
  
  cout << "." << endl;
}

int main() {
  yyparse();
  cout << endl;
}
