%{

int linha = 1;
int coluna = 1;
int ultimo_token = -1;

%}

D   [0-9]
L   [A-Za-z_]
ID  {L}({L}|{D})*
NUM {D}+
WS  [ \n\r\t]

%%

"\n" { linha++; coluna = 1; }
"\n"/{WS}*({ID}|{NUM}){WS}* { linha++; coluna = 1;
                              if( ultimo_token != ';' ) {
                                ultimo_token = ';';
                                return ';';
                              } 
                            }
 {ID} { coluna += strlen(yytext);
        yylval = yytext;
        ultimo_token = ID;
        return ID;
      }
 {NUM} { coluna += strlen(yytext);
        yylval = yytext;
        ultimo_token = NUM;
        return NUM;
      }
 . { coluna += strlen(yytext);
     yylval = yytext;
     ultimo_token = yytext[0];
     return yytext[0];
    }

%%
