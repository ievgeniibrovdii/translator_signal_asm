$KEY_WORDS_DIC = {"PROGRAM" => 401, "BEGIN" => 402, "END" => 403, "PROCEDURE" => 404,
            "SIGNAL" => 405, "COMPLEX" => 406, "INTEGER" => 407, "FLOAT" => 408,
            "BLOCKFLOAT" => 409, "EXT" => 410, "WHILE" => 411, "DO" => 412 }
$SIMPLE_SEPARATORS_DIC = {";" => 59, "." => 46, ":" => 58, "," => 44, "(" => 40, ")" => 41}
$IDENTIFICATORS_DIC = {}
$DIGITS_DIC = {}
$EMAIL_DIC = {}

def printTables
  puts
  puts "Key words = " + $KEY_WORDS_DIC.to_s
  puts "Separators = " + $SIMPLE_SEPARATORS_DIC.to_s
  puts "My identifiers = " + $IDENTIFICATORS_DIC.to_s
  puts "My digits = " + $DIGITS_DIC.to_s
  puts "My emails = " + $EMAIL_DIC.to_s
  puts
end
