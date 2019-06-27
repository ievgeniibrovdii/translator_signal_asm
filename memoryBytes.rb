def check(signalType)
  case signalType
  when "SIGNAL"
    return "DB"
  when "COMPLEX"
    return "DQ"
  when "INTEGER"
    return "DW"
  when "FLOAT"
    return "DD"
  when "BLOCKFLOAT"
    return "DQ"
  when "EXT"
    return "DB"
  else
    return "ERROR!"
  end
end

def checkType(numberType)
  case numberType
  when "DB"
    return "1"
  when "DQ"
    return "8"
  when "DW"
    return "2"
  when "DD"
    return "4"
  else
    return "0"
  end
end