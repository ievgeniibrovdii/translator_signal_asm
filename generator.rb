require "./tables"
require "./parser"
require "./memoryBytes"

$data_seg = ''
$proc_identifier = []
$key = []
$count_proc_identifier = 0
$count_var_identifier = 0
$count_type_identifier = 0
$wrong_identifier = []
$var_identifier = []
$type_identifier = []

class CodeGenerator

  def initialize(tree)
    return @tree = tree
  end

  def type_proc(node)
    if node.val == "attribute"
      ident = node.leaves[0].val
      $type_identifier.push(ident)
      $count_type_identifier  += 1
    end

    for i in (0..((node.leaves).length - 1))
      type_proc(node.leaves[i])
    end
    return $type_identifier
  end

  def var_proc(node)

    if node.val == "variable-identifier"
  		ident = node.leaves[0].leaves[0].val
  		if ($proc_identifier.include? ident or $var_identifier.include? ident)
  			$wrong_identifier.push(ident)
        #puts "\nERROR: This identifier " + ident + " already exist!\n"
      end
  		$var_identifier.push(ident)
      $count_var_identifier  += 1
    end

    for i in (0..((node.leaves).length - 1))
  		var_proc(node.leaves[i])
    end
  	return $var_identifier
  end


  def compile

    for i in (0..((@tree.root.leaves[0].leaves).length - 1))
      if @tree.root.leaves[0].leaves[i].val ==  "procedure-identifier"
  			ident = @tree.root.leaves[0].leaves[i].leaves[0].leaves[0].val
  			if $proc_identifier.include? ident
  				$wrong_identifier.push(ident)
        end
  			$proc_identifier.push(ident)
      end

  		if (@tree.root.leaves[0].leaves[i].val == "PROGRAM" or @tree.root.leaves[0].leaves[i].val == "PROCEDURE")
  			$key.push(@tree.root.leaves[0].leaves[i].val)
      end
    end

    for i in (0..((@tree.root.leaves).length - 1))
      if @tree.root.leaves[i].val ==  "procedure-identifier"
        ident = @tree.root.leaves[i].leaves[0].leaves[0].val
        if $proc_identifier.include? ident
          $wrong_identifier.push(ident)
        end
        $proc_identifier.push(ident)
      end

      if (@tree.root.leaves[i].val == "PROGRAM" or @tree.root.leaves[i].val == "PROCEDURE")
        $key.push(@tree.root.leaves[i].val)
      end
    end

  	$var_identifier = var_proc(@tree.root)
    $type_identifier = type_proc(@tree.root)
  	print("\n\n====================ASM===CODE=========================")
    print_data_seg
    generator(@tree.root)

  end


  def generator(node)

  	if node.val =="block"
  		tmp = ''
  		#tmp += $proc_identifier[$count_proc_identifier]
  		tmp += "\n code SEGMENT\n"
  		if (node.parent_element.leaves[2].leaves[0].val == "BEGIN")
  			tmp += "begin\n"
        tmp += " code ENDS\nend begin\n"
        $count_proc_identifier += 1
        puts tmp
      end
    elsif node.val == "PROCEDURE"
      tmp = "\n"
      if ($key[$count_proc_identifier] == "PROCEDURE")
          ident = $proc_identifier[$count_proc_identifier]
          if $wrong_identifier.include? ident
            tmp += $proc_identifier[$count_proc_identifier]
            puts tmp
            puts 'ERROR: This identifier already exists!'
            exit()
          end
          tmp += ident
          tmp += " PROC\n"
        end

    		ident = $proc_identifier[$count_proc_identifier]
    		if $wrong_identifier.include? ident
    			tmp += $proc_identifier[$count_proc_identifier]
    			puts tmp
    			puts 'ERROR: This identifier already exist!'
    			exit()
        end

        tmp += "\tpush	ebp\n"
        tmp += "\tmov	ebp, esp\n"
        tmp += "\txor	eax, eax\n"
        tmp += "\tmov	esp, ebp\n"
        tmp += "\tpop	ebp\n"
        tmp += "\tret   \n"
        tmp += $proc_identifier[$count_proc_identifier]
        tmp += " ENDP\n"
        $count_proc_identifier += 1
    		puts tmp

    elsif (node.val == "declaration")
      		#$data_seg = "\ndata SEGMENT"
      		count = 8
      		(0..((node.leaves[0].leaves).length - 1)).each do |i|
      			if (node.leaves[0].leaves[i].val != ',')
      				if (node.leaves[0].leaves[0].val == "identifier")
                $data_seg += "\t"
      					if $wrong_identifier.include? $var_identifier[$count_var_identifier]
                  #$data_seg += $var_identifier[$count_var_identifier]
      						#puts $data_seg
      						puts 'ERROR: This identifier already exist!'
      						exit()
                end

                $data_seg += count.to_s
      					count += 4
              end
            end
      			#i+=1
          end

          $data_seg += "\ndata ENDS\n"
    end

    for i in (0..((node.leaves).length - 1))
  		generator(node.leaves[i])
    end

  # genetator func ends
  end

  def print_data_seg
    tmp = "\ndata SEGMENT"
    (0..($var_identifier.length-1)).each do |i|
      tmp += "\n\t"

      numberType = check($type_identifier[i])
      if numberType != "ERROR!"
        tmp += $var_identifier[i]
        tmp += "\t" + numberType + "\t"
        tmp += checkType(numberType)
      else
        tmp += "\n  " + numberType + " Identifier " + $var_identifier[i] + " has no type!\n "
        puts tmp
        exit()
      end
    end

    if $wrong_identifier != [] and $wrong_identifier != nil
      tmp += "\n ERROR! Identifier " + $wrong_identifier.to_s + " already exists!\n"
      puts tmp
      exit()
    end

    if $var_identifier.count != $type_identifier.count
      tmp += "\nTYPE ERROR! More types than identifiers!"
      puts tmp
      exit()
    end
    tmp += "\ndata ENDS"
    puts tmp

    #(0..($var_identifier.length-1)).each do |i|
    #  if $wrong_identifier != [] and $wrong_identifier[i] != nil
    #    puts "\n ERROR! Identifier " + $wrong_identifier[i].to_s + " already exists!\n"
    #  end
    #end
  end
#class ends
end
