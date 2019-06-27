require "./lexer"
require "./tables"
require "./tree"

$error_table = {"Wrong delimiter" => -1, "Wrong key_word" => -2, "No such identifier" => -3, "Wrong integer" => -4}
$deep_counter = 0

class SyntaxAnalyzer

  def createLexemList
    return @lex_list = LexicalAnalyzer.new.lexer('test.txt')
  end

  def createTree
    return @tree = Tree.new
  end

  def scan(dictionary, value)
    for key, v in dictionary.each
      if v == value
        return key
      end
    end
  end

  def err(err_number)
    @tree.add(err_number)
    @tree.current_element = @tree.current_element.parent_element
    @tree.print_tree
    puts
    print scan($error_table, err_number)
    exit
  end
  

  def statement_proc(i)
      @tree.add('statement')
      lexem = @lex_list[i]

      if lexem == 411
        @tree.add(scan($KEY_WORDS_DIC, lexem))
        @tree.current_element = @tree.current_element.parent_element
        i+=1
      else
          err(-2)
      end

      i = variable_identifier_proc(i)
      lexem = @lex_list[i]

      if lexem == 412
        @tree.add(scan($KEY_WORDS_DIC, lexem))
        @tree.current_element = @tree.current_element.parent_element
        i+=1
      else
          err(-2)
      end

      i = statement_list_proc(i)
      lexem = @lex_list[i]

      if lexem == 403
          @tree.add(scan($KEY_WORDS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
          
      end
      
      i +=1
      
      if lexem == 59
          @tree.add(scan($KEY_WORDS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
      end
      i +=1
      @tree.current_element = @tree.current_element.parent_element
      return i
  end


  def statement_list_proc(i)
    @tree.add('statement-list')
    lexem = @lex_list[i]

    if lexem == 403
      @tree.add('empty')
      @tree.current_element = @tree.current_element.parent_element
    else
      i = statement_proc(i)
      i = statement_list_proc(i)
    end
    @tree.current_element = @tree.current_element.parent_element
    return i
  end


  def block_proc(i)
      @tree.add('block')
      lexem = @lex_list[i]
      if lexem == 402
          @tree.add(scan($KEY_WORDS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
      else
          err(-2)
      end
      i += 1
      i = statement_list_proc(i)
      lexem = @lex_list[i]

      #if lexem == 59
      #  @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
      #  @tree.current_element = @tree.current_element.parent_element
      #  i += 1
      #else
      #    err(-2)
      #end
      #puts @lex_list[i]
      lexem = @lex_list[i]

      if lexem == 403
          @tree.add(scan($KEY_WORDS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
      else
          err(-2)
      end
      @tree.current_element = @tree.current_element.parent_element
      #@tree.current_element = @tree.current_element.parent_element
      #puts @lex_list[i]
      #i += 1
      #puts @lex_list[i]
      return i;
  end

  def identifier_proc(lexem)
      @tree.add('procedure-identifier')
      @tree.add('identifier')
      if lexem >= 1000
          @tree.add(scan($IDENTIFICATORS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
      else
          err(-3)
      end
      @tree.current_element = @tree.current_element.parent_element
      @tree.current_element = @tree.current_element.parent_element
  end

  def attributes_list_proc(i)
      lexem = @lex_list[i]
      if lexem > 405 and lexem <411
          @tree.add('attribute')
          @tree.add(scan($KEY_WORDS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
          @tree.current_element = @tree.current_element.parent_element
          i += 1
          lexem = @lex_list[i]

      end

      @tree.add('attributes-list')
      $deep_counter += 1

      if lexem != 59
        return attributes_list_proc(i)
      end

      @tree.add('empty')
      @tree.current_element = @tree.current_element.parent_element

      return i
  end

  def variable_identifier_proc(i)
    lexem = @lex_list[i]
    if lexem >= 1000
      @tree.add('variable-identifier')
      @tree.add('identifier')
      @tree.add(scan($IDENTIFICATORS_DIC, lexem))
      @tree.current_element = @tree.current_element.parent_element
      @tree.current_element = @tree.current_element.parent_element
      @tree.current_element = @tree.current_element.parent_element
      i += 1
    else
      err(-1)
    end
    return i
  end

  def identifiers_list_proc(i)
    lexem = @lex_list[i]
    @tree.add('identifiers-list')
    $deep_counter += 1
    if lexem != 44
      @tree.add('empty')
      return i
    else
      @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
      @tree.current_element = @tree.current_element.parent_element
    end
      i+=1

      i = variable_identifier_proc(i)

     return identifiers_list_proc(i)
  end

  def declaration_proc(i)
      @tree.add('declaration')
      lexem = @lex_list[i]

        i = variable_identifier_proc(i)
        i = identifiers_list_proc(i)
        lexem = @lex_list[i]

        if lexem == 58
          while $deep_counter >= 0
            @tree.current_element = @tree.current_element.parent_element
            $deep_counter -= 1
          end
          @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
          i+=1
        else
            err(-1)
        end
        i = attributes_list_proc(i)
        lexem = @lex_list[i]
        if lexem == 59
          while $deep_counter >= 0
            @tree.current_element = @tree.current_element.parent_element
            $deep_counter -= 1
          end
          @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))

          i += 1
        else
            err(-1)
        end

    @tree.current_element = @tree.current_element.parent_element
    @tree.current_element = @tree.current_element.parent_element
    return i
  end

  def declaration_list_proc(i)
      @tree.add('declarations-list')
      lexem = @lex_list[i]
      i = declaration_proc(i)
      lexem = @lex_list[i]


      if lexem > 1000 and lexem < 2000
        declaration_list_proc(i)
      end

      @tree.add('declarations-list')
      @tree.add('empty')
      return i
  end

  def parameters_list_proc(i)
      @tree.add('parameters-list')
      lexem = @lex_list[i]
      if lexem == 40
          @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
      end
      i += 1
      i = declaration_list_proc(i)
      lexem = @lex_list[i]
      if lexem == 41
        @tree.current_element = @tree.current_element.parent_element
        @tree.current_element = @tree.current_element.parent_element
        @tree.current_element = @tree.current_element.parent_element
        @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
        @tree.current_element = @tree.current_element.parent_element
      else
          err(-1)
      end
      @tree.current_element = @tree.current_element.parent_element
      @tree.add('parameters-list')
      @tree.add('empty')
      @tree.current_element = @tree.current_element.parent_element
      @tree.current_element = @tree.current_element.parent_element

      return i
  end


  def program_proc()
      @tree.add('program')
      i = 0
      lexem = @lex_list[i]
      if lexem == 401
          @tree.add(scan($KEY_WORDS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
          i += 1
          lexem = @lex_list[i]
          identifier_proc(lexem)
          i += 1
          lexem = @lex_list[i]
          if lexem == 59
            @tree.current_element = @tree.current_element.parent_element
            @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
            @tree.current_element = @tree.current_element.parent_element
          else
              err(-1)
          end
          i += 1
          i = block_proc(i)
          i += 1
          lexem = @lex_list[i]

          if lexem == 46
              @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
              @tree.current_element = @tree.current_element.parent_element
          else
              err(-1)
          end
          i += 1
          lexem = @lex_list[i]
      end

      if lexem == 404
          @tree.add(scan($KEY_WORDS_DIC, lexem))
          @tree.current_element = @tree.current_element.parent_element
          i += 1
          lexem = @lex_list[i]
          identifier_proc(lexem)
          i += 1
          i = parameters_list_proc(i)
          i += 1
          lexem = @lex_list[i]
          if lexem == 59
              @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
              @tree.current_element = @tree.current_element.parent_element
          else
              err(-1)
          end
          i += 1
          i = block_proc(i)
          i += 1
          lexem = @lex_list[i]

          if lexem == 59
              @tree.add(scan($SIMPLE_SEPARATORS_DIC, lexem))
              @tree.current_element = @tree.current_element.parent_element
          else
              err(-1)
          end
      else
          #err(-2)
      end
  end


  def signal_program_proc
    if @lex_list
          program_proc()
          @tree.print_tree
          puts puts
          puts "Error table = " +  $error_table.to_s
          puts puts
          @tree.listing
    end
      return @tree
  end

  def get_lex_list
    return @lex_list
  end
end
