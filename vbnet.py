import antlr4

from vbnetLexer import vbnetLexer
from vbnetParser import vbnetParser
from vbnetParserListener import vbnetParserListener

# antlr4 -Dlanguage=Python3 vbnetLexer.g4 vbnetParser.g4
# cat vbnet | python3 vbnet.py | js-beautify

class vbnetPrintListener(vbnetParserListener):
    def enterEnumDeclaration(self, ctx):
        print("enum %s {" % (ctx.IDENTIFIER().getText()))
        for i in ctx.enumMember():
            print("%s," % i.getText())
        print("}")

    def enterInterfaceDeclaration(self, ctx):
        print("interface %s {" % (ctx.IDENTIFIER().getText()))

    def exitInterfaceDeclaration(self, ctx):
        print("}")

    def enterInterfaceProperty(self, ctx):
        print("%s%s: %s" % (
                    "readonly " if ctx.propertyModifier() else "",
                    ctx.IDENTIFIER().getText(),
                    ctx.typeName().getText()))

    def enterInterfaceFunction(self, ctx):
        print("%s(" % (ctx.IDENTIFIER().getText()), end="")

    def exitInterfaceFunction(self, ctx):
        print("): %s" % (ctx.typeName().getText()))

    def enterInterfaceSub(self, ctx):
        print("%s(" % (ctx.IDENTIFIER().getText()), end="")

    def exitInterfaceSub(self, ctx):
        print(")")

    def enterParameterList(self, ctx):
        params = []
        for i in ctx.parameter():
            param = "%s: %s" % (
                i.IDENTIFIER().getText(),
                i.typeName().getText())
            params.append(param)
        print(", ".join(params), end="")

def main():
    lexer = vbnetLexer(antlr4.StdinStream())
    stream = antlr4.CommonTokenStream(lexer)

    debugLexer = False
    if debugLexer:
        stream.fill()
        for token in stream.tokens:
            if token.text != '<EOF>':
                print("%s: %s" % (token.text,
                    vbnetLexer.symbolicNames[token.type]))

    parser = vbnetParser(stream)
    tree = parser.start()

    listener = vbnetPrintListener()
    walker = antlr4.ParseTreeWalker()
    walker.walk(listener, tree)


if __name__ == "__main__":
    main()
