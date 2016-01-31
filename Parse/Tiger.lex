package Parse;
import ErrorMsg.ErrorMsg;

%%

%implements Lexer
%function nextToken
%type java_cup.runtime.Symbol
%char

%{
private void newline() {
  errorMsg.newline(yychar);
}

private void err(int pos, String s) {
  errorMsg.error(pos,s);
}

private void err(String s) {
  err(yychar,s);
}

private java_cup.runtime.Symbol tok(int kind) {
    return tok(kind, null);
}

private java_cup.runtime.Symbol tok(int kind, Object value) {
    return new java_cup.runtime.Symbol(kind, yychar, yychar+yylength(), value);
}

private ErrorMsg errorMsg;

Yylex(java.io.InputStream s, ErrorMsg e) {
  this(s);
  errorMsg=e;
}

private int commentDepth = 0;

private StringBuffer buffer;

%}

%eofval{
	{
    //state is stored in variable yy_lexical_state, states are declared as final int STATENAME
    if(yy_lexical_state==COMMENT)
      err("Reached end of file with unterminated comment, proceeding anyway.");
    if(yy_lexical_state==STRING)
      err("Reached end of file with unterminated string, tossing unfinished string \""+ buffer.toString() + "\"");
	  return tok(sym.EOF, null);
  }
%eofval}

%state COMMENT
%state STRING

ALPHA=[A-Za-z]
DIGIT=[0-9]
WHITE_SPACE_CHAR=[\ \t\b\012]
STRING_TEXT=(\\\"|[^\n\"]|\\{WHITE_SPACE_CHAR}+\\)*
COMMENT_TEXT=([^/*\n]|[^*\n]"/"[^*\n]|[^/\n]"*"[^/\n]|"*"[^/\n]|"/"[^*\n])*

%%
<YYINITIAL> {WHITE_SPACE_CHAR}	{}
<YYINITIAL> \n	{newline();}
<YYINITIAL> ","	{return tok(sym.COMMA, null);}
<YYINITIAL> ":" {return tok(sym.COLON, null);}
<YYINITIAL> "." {return tok(sym.DOT, null);}
<YYINITIAL> "/" {return tok(sym.DIVIDE, null);}
<YYINITIAL> "-" {return tok(sym.MINUS, null);}
<YYINITIAL> "+" {return tok(sym.PLUS, null);}
<YYINITIAL> "*" {return tok(sym.TIMES, null);}
<YYINITIAL> ">" {return tok(sym.GT, null);}
<YYINITIAL> "<" {return tok(sym.LT, null);}
<YYINITIAL> "<=" {return tok(sym.LE, null);}
<YYINITIAL> ">=" {return tok(sym.GE, null);}
<YYINITIAL> "<>" {return tok(sym.NEQ, null);}
<YYINITIAL> "(" {return tok(sym.LPAREN, null);}
<YYINITIAL> ")" {return tok(sym.RPAREN, null);}
<YYINITIAL> ";" {return tok(sym.SEMICOLON, null);}
<YYINITIAL> "[" {return tok(sym.LBRACK, null);}
<YYINITIAL> "]" {return tok(sym.RBRACK, null);}
<YYINITIAL> "{" {return tok(sym.LBRACE, null);}
<YYINITIAL> "}" {return tok(sym.RBRACE, null);}
<YYINITIAL> "&" {return tok(sym.AND, null);}
<YYINITIAL> "|" {return tok(sym.OR, null);}
<YYINITIAL> "=" {return tok(sym.EQ, null);}
<YYINITIAL> ":=" {return tok(sym.ASSIGN, null);}

<YYINITIAL> "while" {return tok(sym.WHILE, null);}
<YYINITIAL> "for" {return tok(sym.FOR, null);}
<YYINITIAL> "to" {return tok(sym.TO, null);}
<YYINITIAL> "break" {return tok(sym.BREAK, null);}
<YYINITIAL> "let" {return tok(sym.LET, null);}
<YYINITIAL> "in" {return tok(sym.IN, null);}
<YYINITIAL> "end" {return tok(sym.END, null);}
<YYINITIAL> "function" {return tok(sym.FUNCTION, null);}
<YYINITIAL> "var" {return tok(sym.VAR, null);}
<YYINITIAL> "type" {return tok(sym.TYPE, null);}
<YYINITIAL> "array" {return tok(sym.ARRAY, null);}
<YYINITIAL> "if" {return tok(sym.IF, null);}
<YYINITIAL> "then" {return tok(sym.THEN, null);}
<YYINITIAL> "else" {return tok(sym.ELSE, null);}
<YYINITIAL> "do" {return tok(sym.DO, null);}
<YYINITIAL> "of" {return tok(sym.OF, null);}
<YYINITIAL> "nil" {return tok(sym.NIL, null);}

<YYINITIAL> [0-9]+ {
  return tok(sym.INT, Integer.parseInt(yytext()));
}

<YYINITIAL> {ALPHA}({ALPHA}|{DIGIT}|_)* {
  return tok(sym.ID, yytext());
}

<YYINITIAL> \" {
  //Found open quote, begin parsing string
  yybegin(STRING);
  buffer = new StringBuffer();
}

<STRING> {STRING_TEXT} {
  //regexp example for normal text
  //I don't like that I don't understand the STRING_TEXT regexp
  buffer.append(yytext());
}

<STRING> \\ {
  //escaped character, eat next character and append its translated meaning
  buffer.append("??")
}

<STRING> \" {
  //Found ending quote
  return tok(sym.STRING, buffer.toString());
  //can you null things in java? probably...
  buffer = null;
  yybegin(YYINITIAL);
}

<YYINITIAL> "/*" {
  yybegin(COMMENT);
  commentDepth++;
}

<COMMENT> {COMMENT_TEXT} {}
<COMMENT> "/*" {commentDepth++;}
<COMMENT> "*/" {
  commentDepth--;
  if(commentDepth==0)
    yybegin(YYINITIAL);
  if(commentDepth<0)
    err("Uhh we're in negative comments now, something went really wrong.");
}

. {
  err("Illegal character: " + yytext() + "(code: " + (int)(yytext().charAt(0)) + ")");
}
