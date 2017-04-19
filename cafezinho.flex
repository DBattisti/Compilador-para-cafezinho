%%

%byaccj
%line
%column

%{
  private Parser yyparser;
  private StringBuffer stringBuffer;
  /*linha onde comeca o comentario*/
  int primLinha;

  public void printLexError (){
    System.out.println("<line "+(yyline+1)+" column "+(yycolumn+1)+">");
  }

  public Yylex(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
  }
%}

NL  = \n | \r | \r\n
INTCONST = 0 | [1-9][0-9]*
ID = [:jletter:] [:jletterdigit:]*
Comentario = "/*" [^*] ~"*/" | "/*" "*"+ "/"

%state constString
%state comentario

%%

<YYINITIAL> {
  [ \r|\n|\r\n|\t]  { }
  '.'         { return Parser.CARCONST; }
  "programa"  { return Parser.PROGRAMA; }
  "car"       { return Parser.CAR; }
  "int"       { return Parser.INT; }
  "retorne"   { return Parser.RETORNE; }
  "leia"    	{ return Parser.LEIA; }
  "escreva"   { return Parser.ESCREVA; }
  "novalinha" { return Parser.NOVALINHA; }
  "se"        { return Parser.SE; }
  "entao"    	{ return Parser.ENTAO; }
  "senao"    	{ return Parser.SENAO; }
  "enquanto"  { return Parser.ENQUANTO; }
  "execute"   { return Parser.EXECUTE; }
  \"          { stringBuffer = new StringBuffer();
                yybegin(constString);
              }
  "/*"        { yybegin(comentario); primLinha = yyline; }

  /*Operadores logicos*/
  "ou" { return Parser.OR; }
  "e"  { return Parser.AND; }
  "==" { return Parser.EQEQ; }
  "!=" { return Parser.DIF; }
  "<"  { return Parser.LESS_THAN; }
  ">"  { return Parser.GREATER_THAN; }
  "<=" { return Parser.LESS_THAN_EQ; }
  ">=" { return Parser.GREATER_THAN_EQ; }
  "?"  |
  "!"  { return (int) yycharat(0); }

  /*Operadores aritimeticos*/
  "+" |
  "-" |
  "*" |
  "/" |
  "%" |
  "=" { return (int) yycharat(0); }

  /*Separadores*/
  ";" |
  ":" |
  "," |
  "{" |
  "}" |
  "[" |
  "]" |
  "(" |
  ")" { return (int) yycharat(0); }

  {ID}        { yyparser.yylval = new ParserVal(yytext());
                return Parser.ID;
              }
  {INTCONST}  { yyparser.yylval = new ParserVal(Integer.parseInt(yytext()));
                return Parser.INTCONST;
              }
  {NL}        { return Parser.NOVALINHA; }


  {Comentario}   { /* ignora */ }
}

<constString> {
    \"        { yybegin(YYINITIAL);
                yyparser.yylval = new ParserVal(stringBuffer.toString());
                return Parser.CONSTSTRING;
              }
    .|\\\"    { stringBuffer.append(yytext()); }
    {NL}      { System.err.println("ERRO: CADEIA DE CARACTERES OCUPA MAIS DE UMA LINHA"); printLexError();
                System.exit(0);
              }
    <<EOF>>   { System.err.println("ERRO: CADEIA DE CARACTERES NÃO TERMINA"); printLexError();
                yybegin(YYINITIAL);
              }
}

<comentario> {
    <<EOF>>   { System.err.println("ERRO: COMENTÁRIO NÃO TERMINA"); printLexError(); yybegin(YYINITIAL); }
    [^]			  { }
    "*/"      { yybegin(YYINITIAL); }
}

/* whitespace */
[ \t]+ { }

/* error fallback */
[^]    { System.err.println("ERRO: CARACTERE INVALIDO '"+yytext()+"'"); printLexError(); return -1; }
