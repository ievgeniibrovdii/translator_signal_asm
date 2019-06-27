require "./tables"

class LexicalAnalyzer

  def lexer(file_name)
    spaces = [32, 13, 10, 9, 11, 12]
    digits = (48..57).to_a
    symbols = (65..90).to_a
    delimiters = ($SIMPLE_SEPARATORS_DIC.keys).to_a
    key_words = ($KEY_WORDS_DIC.keys).to_a
    email = ($EMAIL_DIC.keys).to_a

    word = ''
    @lex_list = []
    counter_identificators = 1001
    counter_email = 2001
    counter_digits = 501
    @line_counter = 1

    file = File.open(file_name, "r")

    while ch = file.getc do
      if ch == "\n"
          @line_counter += 1
      end

      if  spaces.include? ch.ord
        next

      elsif delimiters.include? ch
        word = ch
        if ch == '('
          ch = file.getc
              if ch == '*'
                  flag = 0
                  ch = file.getc
                  while ch
                      if ch == '*'
                          ch = file.getc
                          if ch == ')'
                             ch = file.getc
                             flag = 1
                             break
                          end
                      else
                          ch = file.getc
                      end
                      if ch == "\n"
                          @line_counter += 1
                      end
                  end
                  if flag == 0
                      puts "ERROR: Unclosed comment at line " + @line_counter.to_s
                      lex_list = []
                      break
                  end
              else
                @lex_list.push($SIMPLE_SEPARATORS_DIC[word])
                word = ''
              end
        else
          @lex_list.push($SIMPLE_SEPARATORS_DIC[word])
          word = ''
        end

      elsif digits.include? ch.ord
          word += ch
          ch = file.getc
          while ch and digits.include? ch
            word += ch
            ch = file.getc
          end
          if $DIGITS_DIC.keys().include? word
            puts word
            @lex_list.push($DIGITS_DIC[word])
            word = ''
          else
            $DIGITS_DIC[line] = counter_digits
            puts word
            @lex_list.push(counter_digits)
            counter_digits += 1
            word = ''
          end

      elsif symbols.include? ch.ord
            word = ''
            word += ch
            ch = file.getc
            while ch and ( symbols.include? ch.ord or digits.include? ch.ord ) and ch != "@"
              word += ch
              ch = file.getc
            end

            if ch == "@"
              word += ch
              ch = file.getc
              if ch == "."
                word += ch
                puts "Error lexem email " + word
                next
              end
              while ch and symbols.include? ch.ord and ch != "."
                word += ch
                ch = file.getc
              end

              if ch == "."
                word += ch
                ch = file.getc
                #if !(symbols.include? ch)
                #  word += ch
                #  puts "Error lexem email " + word
                #  next
                #end
                while ch and symbols.include? ch.ord
                  word += ch
                  ch = file.getc
                end
                if $EMAIL_DIC.keys().include? word
                  puts word
                  @lex_list.push($EMAIL_DIC[word])
                  word = ''
                else
                  $EMAIL_DIC[word] = counter_email
                  @lex_list.push(counter_email)
                  counter_email += 1
                  word = ''
                  next
                end
              end
            end

            if word != ''
              if word.length > 1 and key_words.to_s.include? word
                puts word
                @lex_list.push($KEY_WORDS_DIC[word])
                word = ''
              else
                if $IDENTIFICATORS_DIC.keys().include? word
                  puts word
                  @lex_list.push($IDENTIFICATORS_DIC[word])
                  word = ''
                else
                  $IDENTIFICATORS_DIC[word] = counter_identificators
                  puts word
                  @lex_list.push(counter_identificators)
                  counter_identificators += 1
                  word = ''
                end
              end
            end
            if ch == "\n"
                @line_counter += 1
            end
            if delimiters.include? ch
              word = ch
              if ch == '('
                ch = file.getc
                    if ch == '*'
                        flag = 0
                        ch = file.getc
                        while ch
                            if ch == '*'
                                ch = file.getc
                                if ch == ')'
                                   ch = file.getc
                                   flag = 1
                                   break
                                end
                            else
                                ch = file.getc
                            end
                            if ch == "\n"
                                @line_counter += 1
                            end
                        end
                        if flag == 0
                            puts "ERROR: Unclosed comment!"
                            lex_list=[]
                            break
                        end
                    else
                      @lex_list.push($SIMPLE_SEPARATORS_DIC[word])
                        word = ''
                    end
              else
                @lex_list.push($SIMPLE_SEPARATORS_DIC[word])
                word = ''
              end
            end

      else
        print "invalid " + ch + " "
        puts "Lexical error (invalid symbol) in line " + @line_counter.to_s
        word = ''
        ch = file.getc
        break
      end
    end

    file.close
    return @lex_list
  end

  def printing
    puts
    puts "lines number = " + @line_counter.to_s
    puts "lexem list = " + @lex_list.to_s
  end
end
