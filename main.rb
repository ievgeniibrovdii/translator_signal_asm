require "./lexer"
require "./tables"
require "./parser"
require "./generator"

#programm = LexicalAnalyzer.new
#programm.lexer('test.txt')
#programm.printing
#printTables()

syntax = SyntaxAnalyzer.new
syntax.createLexemList
syntax.createTree
lex_list = syntax.get_lex_list
puts
print "Lexem list = " + lex_list.to_s
puts
tree = syntax.signal_program_proc

generator = CodeGenerator.new(tree)
generator.compile
