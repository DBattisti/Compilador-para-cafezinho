# only works with the Java extension of yacc:
# byacc/j from http://troi.lincom-asg.com/~rjamison/byacc/

JFLEX  = jflex
BYACCJ = yacc -J
JAVAC  = javac

# targets:

all: Parser.class

run: Parser.class
	java Parser

build: clean Parser.class

clean:
	rm -f *~ *.class *.java

Parser.class: Yylex.java Parser.java
	$(JAVAC) Parser.java

Yylex.java: cafezinho.flex
	$(JFLEX) cafezinho.flex

Parser.java: cafezinho.y
	$(BYACCJ) cafezinho.y
