import antlr4

from vbnetLexer import vbnetLexer
from vbnetParser import vbnetParser
from vbnetParserListener import vbnetParserListener
from vbnetParserVisitor import vbnetParserVisitor

# antlr4 -Dlanguage=Python3 -visitor vbnetLexer.g4 vbnetParser.g4
# cat foo | python3 vbnet.py | js-beautify

class vbnetPrintVisitor(vbnetParserVisitor):
    def defaultResult(self):
        return []

    def aggregateResult(self, aggregate, nextResult):
        if nextResult:
            aggregate.extend(nextResult)
            #aggregate.append(nextResult)
        return aggregate

    def visitEnumDeclaration(self, ctx):
        print("enum %s {" % (ctx.IDENTIFIER().getText()))
        #members = self.visit(ctx.enumMember())
        members = self.visitChildren(ctx)
        #members = []
        #for i in ctx.enumMember():
        #    members += self.visit(i)
        print(",".join(members))
        print("}")

    def visitEnumMember(self, ctx):
        return ["%s" % ctx.IDENTIFIER().getText()]

    # FUNCTION IDENTIFIER OPENPAREN parameterList? CLOSEPAREN AS typeName
    def visitInterfaceFunction(self, ctx):
        identifier = ctx.IDENTIFIER().getText()
        #params = self.visitChildren(ctx)
        params = self.visit(ctx.parameterList())
        returnType = ctx.typeName().getText()
        print("%s(%s): %s" % (identifier, ", ".join(params), returnType))

    # parameterModifier* IDENTIFIER AS typeName ( EQUALS simpleExpression )?
    def visitParameter(self, ctx):
        modifiers = ctx.parameterModifier()
        optional = "?" if any([x.OPTIONAL() for x in modifiers]) else ""
        return ["%s%s: %s" % (
            ctx.IDENTIFIER().getText(),
            optional,
            self.visit(ctx.typeName()))
        ]

    def visitSimpleType(self, ctx):
        return ctx.IDENTIFIER().getText()

    def visitArrayType(self, ctx):
        return "%s[]" % ctx.typeName().getText()

    def visitMapType(self, ctx):
        return "Map<%s, %s>" % (
            ctx.typeName(0).getText(),
            ctx.typeName(1).getText())


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
            optional = False
            for m in i.parameterModifier():
                try:
                    if m.OPTIONAL():
                        optional = True
                        break
                except AttributeError:
                    pass

            param = "%s%s: %s" % (
                i.IDENTIFIER().getText(),
                "?" if optional else "",
                typeNameFix(i.typeName()))
            params.append(param)
        print(", ".join(params), end="")

    # XXX try adding attributes to node that I can print later on? -- no
    # XXX try checking parent and then printing if it's a func/prop declaration?
# XXX -- parameters can print themselves! but what about commas/// :(
# XXX visitor vs listener -- if I don't have to explicitly do every node?
# XXX labelling the rules to have different listener functions?
# XXX or add attributes to the listener class
    def enterParameter(self, ctx):
        print(ctx.parent)


def typeNameFix(t):
    if t.LIST() or t.QUEUE():
        return "%s[]" % (t.typeName(0).getText())
    if t.DICTIONARY() or t.ACTION():
        return "Map<%s, %s>" % (
            t.typeName(0).getText(),
            t.typeName(1).getText())
    return t.IDENTIFIER().getText()


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

    result = vbnetPrintVisitor().visit(tree)
    print(result)

    #listener = vbnetPrintListener()
    #walker = antlr4.ParseTreeWalker()
    #walker.walk(listener, tree)


if __name__ == "__main__":
    main()
