cd ./src
bison -d pyparser.y --verbose && flex lexer.l && g++ -c lex.yy.c pyparser.tab.c && g++ -o parser lex.yy.o pyparser.tab.o -ll -ly && echo ">> OK"
rm lex.yy.* pyparser.output pyparser.tab.*