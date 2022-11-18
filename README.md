# Simple transpiler for converting vb.net to typescript

Note that this transpiler is incomplete and pretty stupid in places. It should
be enough to generate interfaces and a basic code skeleton, but won't try to
do anything with function bodies. The right way to write a function is quite
different in the two languages and the vb.net source I was working from was
not well written, so it felt like a waste of time trying to get that working
when it was guaranteed to be immediately rewritten.


## Install

Install the antlr packages, and optionally a code formatter:

```
apt-get install antlr4 python3-antlr4 jsbeautifier
```


## Generate Parser

Build the python files:

```
antlr4 -Dlanguage=Python3 -visitor vbnetLexer.g4 vbnetParser.g4
```


## Run

The script reads from stdin and prints to stdout, so you can do things like
pipe it through a formatter. I've been using jsbeautifier to format the code,
though it has some issues with typescript indentation.

```
cat foo | python3 vbnet.py | js-beautify
```
