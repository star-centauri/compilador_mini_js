%{
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <vector>
#include <map>
#include <algorithm>

using namespace std;

struct Atributos {
  vector<string> v;
};

struct DeclVar {
  int linha;
  int bloco;
  string tipo;
};

#define YYSTYPE Atributos

void erro( string msg );
void print( vector<string> codigo );

vector<string> concatena( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, vector<string> b );
vector<string> operator+( vector<string> a, string b );

string gera_label( string prefixo );
vector<string> resolve_enderecos( vector<string> entrada );
void verifica_se_foi_declarado( );
bool verificar_declaracao( string var );
void add_variaveis(string variavel, string tipo);

bool verifica_duplicada( string var );
void verificar_declaracao_duplicada();

int yylex();
void yyerror( const char* );

int count_aux = 0;
int bloco = 1;
vector<string> auxiliar;
vector<multimap<string, DeclVar>> ts(1);

%}

%nonassoc IFX
%nonassoc ELSE 
%right '='
%right MAIS_EGUAL MENOS_EGUAL
%left OR
%left AND 
%nonassoc '<' '>' EGUAL NOT_EGUAL MAIOR_IGUAL MENOR_IGUAL 
%left '+' '-'
%left '*' '/' '%'
%right '^'
%nonassoc UMINUS


// Tokens
%token ID INT DOUBLE STRING BOOL EMPTY_OBJ EMPTY_ARRAY 
%token IF ELSE WHILE FOR LET VAR CONST
%token MAIS_EGUAL MENOS_EGUAL VEZES_EGUAL DIVISAO_EGUAL
%token OR AND EGUAL NOT_EGUAL MAIOR_IGUAL MENOR_IGUAL MAIS_MAIS MENOS_MENOS

%start S

%%

S : CMDs {
            verifica_se_foi_declarado( ); 
            verificar_declaracao_duplicada(); 
            print( resolve_enderecos($1.v) ); 
         }
  ;

CMDs : CMD CMDs     { $$.v = $1.v + $2.v; }
     |              { $$.v = auxiliar; }
     ;
     
CMD : CMD_DECLARACOES  { $$.v = $1.v; }
    | CMD_FOR          { $$.v = $1.v; }
    | CMD_IF           { $$.v = $1.v; }
    | CMD_WHILE        { $$.v = $1.v; }
    | '{' CMD_LIST '}' { $$.v = $2.v; bloco++; }
    ;
    
CMD_LIST : CMD
	 | CMD ';'
         | CMD_LIST CMD     { $$.v = $1.v + $2.v; }
         | CMD_LIST ';' CMD { $$.v = $1.v + $3.v; }
	 ;
    
CMD_DECLARACOES : CMD_ATRIB { $$.v = $1.v + "^"; }
                | CMD_ATRIB_2 { $$.v = $1.v + "^"; }
                | LET CMD_MULT_DECLARACAO_LET { $$.v = $2.v; }
                | VAR CMD_MULT_DECLARACAO_VAR { $$.v = $2.v; }
                | CONST CMD_MULT_DECLARACAO_CONST { $$.v = $2.v; }
                ; 
                
CMD_MULT_DECLARACAO_LET : CMD_DECLARACAO ',' CMD_MULT_DECLARACAO_LET { $$.v = $1.v + $3.v; add_variaveis($1.v[0], "let"); }
                        | CMD_DECLARACAO { $$.v = $1.v; add_variaveis($1.v[0], "let"); }
                        ;
                        
CMD_MULT_DECLARACAO_VAR : CMD_DECLARACAO ',' CMD_MULT_DECLARACAO_VAR { $$.v = $1.v + $3.v; }
                        | CMD_DECLARACAO
                        ;  
                        
CMD_MULT_DECLARACAO_CONST : CMD_DECLARACAO ',' CMD_MULT_DECLARACAO_CONST { $$.v = $1.v + $3.v; }
                          | CMD_DECLARACAO
                          ;               
                          
CMD_DECLARACAO : ID '=' CMD_RVALUE { $$.v = $1.v + "&" + $1.v + $3.v + "=" + "^"; }
               | ID                { $$.v = $1.v + "&";}
               ;
                

CMD_ATRIB : ID '=' CMD_RVALUE { $$.v = $1.v + $3.v + "="; add_variaveis($1.v[0], "*"); }
          | CMD_LVALUE_PROP '=' CMD_RVALUE { $$.v = $1.v + $3.v + "[=]"; }
          ;
          
CMD_ATRIB_2 : ID MAIS_EGUAL CMD_ATRIB_2 { $$.v = $1.v + $1.v + "@" + $3.v + "+" + "="; }
            | CMD_LVALUE_PROP MAIS_EGUAL CMD_ATRIB_2 { $$.v = $1.v + $1.v + "[@]" + $3.v + "+" + "[=]"; }
            | CMD_RVALUE
            ;
            
CMD_LVALUE_PROP : CMD_RVALUE '.' ID         { $$.v = $1.v + $3.v; }
		| CMD_RVALUE '[' CMD_ATRIB ']' { $$.v = $1.v + $3.v; }
		| CMD_RVALUE '[' CMD_RVALUE ']' { $$.v = $1.v + $3.v; }
		;

CMD_RVALUE : ID { $$.v = $1.v + "@"; }
           | CMD_RVALUE '^' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE '<' CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE EGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE NOT_EGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE MENOR_IGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE MAIOR_IGUAL CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE AND CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | CMD_RVALUE OR CMD_RVALUE { $$.v = $1.v + $3.v + $2.v; }
           | ID MAIS_MAIS             { $$.v = $1.v + $1.v + "@" + "1" + "+" + "="; }
           | ID MENOS_MENOS           { $$.v = $1.v + $1.v + "@" + "1" + "-" + "="; }           
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
           | '-' CMD_RVALUE %prec UMINUS { $$.v = auxiliar + "0" + $2.v + $1.v; }
           | EMPTY_OBJ
           | EMPTY_ARRAY
           | '(' CMD_RVALUE ')' { $$.v = $2.v; }
           | CMD_LVALUE_PROP { $$.v = $1.v + "[@]"; }
           ;
           
CMD_FOR : FOR '(' CMD ';' CMD_RVALUE ';' CMD ')' CMD {
                                                string endfor = gera_label("end_for");
                                                string thenfor = gera_label("then_for");
                                                $$.v = $3.v + (":" + thenfor) + $5.v + "!" + endfor
                                                        + "?" + $9.v + "^" + thenfor  + "#" + (":" + endfor);
                                             }
        ;

CMD_IF : IF '(' CMD_RVALUE ')' CMD %prec IFX { 
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
                                            string condicao = gera_label("cond_while");
				             $$.v = auxiliar + condicao + $3.v + "!" + endwhile 
				             		      + "?" + (":" + condicao) 
				             		      + "#" + $5.v + (":" + endwhile);
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

bool verificar_declaracao( string var ) {
   for (auto i : ts) {
     for (auto j : i) {
       if ( j.first == var && j.second.tipo == "let") {
          return true;  
       }
       
       if ( j.first == var && j.second.tipo == "var") {
          return true;  
       }
       
       if ( j.first == var && j.second.tipo == "const") {
          return true;  
       }
     } 
   }
   
   return false;
}

void verifica_se_foi_declarado( ) {
   bool declarado = true;
   
   for (auto i : ts) {
     for (auto j : i) {
       //cout << j.first << " " << j.second.linha << j.second.tipo << endl;
       if ( j.second.tipo == "*" ) {
          declarado = verificar_declaracao( j.first );
          
          if (declarado == false) {
             string msg = "a variável '" + j.first + "' não foi declarada.";
      	     erro(msg);
          }
       }
     } 
   }
}

void add_variaveis(string variavel, string tipo) {
  multimap<string, DeclVar> decl;
  count_aux = linha;
  //cout << linha << variavel << endl;
  
  struct DeclVar declvar;
  declvar.linha = count_aux;
  declvar.tipo = tipo;
  declvar.bloco = bloco;
  
  decl.insert(pair<string, DeclVar>(variavel, declvar));
  ts.push_back(decl);
}

bool verifica_duplicada( string var ) {
   int count = 0;
   
   for (auto i : ts) {
     for (auto j : i) {
       if ( j.first == var && j.second.tipo == "let") {
          count++;
       }
     } 
   }
   
   if (count > 1) return true;
   else return false;
}

void verificar_declaracao_duplicada() {
   bool duplicado = false;
   
   for (auto i : ts) {
     for (auto j : i) {
       //cout << j.first << " " << j.second.linha << j.second.tipo << endl;
       duplicado = verifica_duplicada( j.first );   
       if ( duplicado ) {
         string msg = "a variável '" + j.first + "' já foi declarada na linha " + to_string(j.second.linha) + ".";
      	 erro(msg);
       }
     } 
   }
}

void erro( string msg ) {
  cout << msg << endl;
  exit( 1 );
}

void print( vector<string> codigo ) {
  for (int i = 0; i < codigo.size(); i++) {
    cout << codigo[i] << " ";
  } 
  
  cout << "." << endl;
}

void yyerror( const char* msg ) {
   puts( msg ); 
   printf( "Proximo a: %s\n", yytext );
   exit( 1 );
}

int main() {
  yyparse();
  cout << endl;
}
