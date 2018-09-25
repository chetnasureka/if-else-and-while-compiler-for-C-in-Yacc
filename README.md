# If-Else-While-Compiler-in-C
Simulation of Front end phase of C compiler involving If-Else and While constructs in C.</br>
This includes:</br>
1) Lexical Analysis- Entering into Input Table.</br>
2) Syntactic Analysis- Creation of Abstract Syntax Tree.</br>
3) Semantic Analysis- Verifying Type compatability and Intermediate Code.</br>
4) Machine Independent Code Optimization- Constant Folding, Common SubExpression Elimination.</br>

To Run Program:</br>
1) Place all files in the same directory.</br>
2) lex lexer.l</br>
3) yacc -d -v parser.y</br>
4) gcc y.tab.c -ll </br>
5) ./a.out<input.txt</br>

Here lexer.l is the lexical analyzer, yacc -d -v parser.y runs parser.y written in YACC and -d creates y.tab.h and -v creates y.output( debugger for parser).
