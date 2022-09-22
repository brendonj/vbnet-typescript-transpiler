lexer grammar vbnetLexer;

ACTION: 'Action';
AS: 'As';
BYVAL: 'ByVal';
DICTIONARY: 'Dictionary';
END: 'End';
ENUM: 'Enum';
FUNC: 'Func';
FUNCTION: 'Function';
INTERFACE: 'Interface';
INTERFACE_JUNK: '<InterfaceType(ComInterfaceType.InterfaceIsIDispatch)>';
LIST: 'List';
NOTHING: 'Nothing';
OF: 'Of';
OPTIONAL: 'Optional';
PROPERTY: 'Property';
PUBLIC: 'Public';
READONLY: 'ReadOnly';
SUB: 'Sub';
QUEUE: 'Queue';

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

//IDENT_NONDIGIT
//    : [a-zA-Z_]
//    ;

IDENTIFIER
    : [a-zA-Z_][a-zA-Z0-9_.]*
    ;

COMMENT
    : '\'' ~[\n]* '\n' -> skip
    ;

WHITESPACE
    : [ \t\r\n] -> skip
    ;
