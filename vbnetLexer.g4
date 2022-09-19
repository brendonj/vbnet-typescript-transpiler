lexer grammar vbnetLexer;

AS: 'As';
END: 'End';
ENUM: 'Enum';
FUNCTION: 'Function';
INTERFACE: 'Interface';
INTERFACE_JUNK: '<InterfaceType(ComInterfaceType.InterfaceIsIDispatch)>';
NOTHING: 'Nothing';
OF: 'Of';
PROPERTY: 'Property';
PUBLIC: 'Public';
READONLY: 'ReadOnly';
SUB: 'Sub';

TRUE: 'True';
FALSE: 'False';

COMMA: ',';
EQUALS: '=';
OPENPAREN: '(';
CLOSEPAREN: ')';
DOUBLEQUOTE: '"';

DIGIT
    : [0-9]
    ;

NUMBER
    : [0-9]+
    ;

STRINGLITERAL
    : '"' STRINGCHARACTER* '"'
    ;

fragment
STRINGCHARACTER
    : ~["\\\r\n]
    ;

IDENT_NONDIGIT
    : [a-zA-Z_]
    ;

IDENTIFIER
    : [a-zA-Z_][a-zA-Z0-9_]+
    ;

WHITESPACE
    : [ \t\r\n] -> skip
    ;
