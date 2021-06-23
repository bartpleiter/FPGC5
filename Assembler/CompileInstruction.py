'''
Library for compiling single instructions
'''

#converts string to int
#string can by binary, decimal or hex
def getNumber(word, allowNeg=False):
    value = 0
    #check for binary number
    if len(word) > 2 and word[:2] == '0b':
        try:
            value = int(word, 2)
        except ValueError:
            raise ValueError(str(word) + " is not a valid binary number")

    #check for hex number
    elif len(word) > 2 and word[:2] == '0x':
        try:
            value = int(word, 16)
        except ValueError:
            raise ValueError(str(word) + " is not a valid hex number")

    #check for decimal number
    else:
        try:
            value = int(word, 10)
        except ValueError:
            raise ValueError(str(word) + " is not a valid decimal number")

    #check for negative numbers
    if value < 0 and not allowNeg:
        raise ValueError(str(word) + " is a negative number (which are not allowed)")

    if allowNeg:

        if value < 0:
            return abs(value), True
        else:
            return value, False
    return value


#converts string to int, representing the register
#string must be in format: rx
#where x is a number between 0 and 15 (including 0 and 15)
def getReg(word):
    value = 0
    
    #check if first char starts with an r
    if word[0].lower() == 'r':
        #check for rbp and rsp (rbp == r14, rsp == r15)
        if word.lower() == "rbp":
            return 14
        if word.lower() == "rsp":
            return 15

        #parse number after r
        try:
            value = int(word[1:], 10)
        except ValueError:
            raise ValueError("Register" + str(word) + " is not a valid register")
    else:
        raise ValueError("Register " + str(word) + " does not start with 'r'")

    if value < 0 or value > 15:
        raise ValueError("Register " + str(word) + " is not a valid register")

    return value

#checks if the given value fits in the given number of bits
def CheckFitsInBits(value, bits):
    if not (value.bit_length() <= bits):
        raise ValueError("Value " + str(value) + " does not fit in " + str(bits) + " bits")

"""
------------------LINE COMPILING FUNCTIONS---------------------
"""

#compiles halt instruction
#should have 0 arguments
def compileHalt(line):
    if len(line) != 1:
        raise Exception("Incorrect number of arguments. Expected 0, but got " + str(len(line)-1))

    return "11111111111111111111111111111111 //Halt"


#compiles read instruction
#should have 3 arguments
#arg1 should be a positive number that is within 12 bits unsigned
#arg2 should be a valid register
#arg3 should be a valid register
def compileRead(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int, neg = getNumber(line[1], True)

    negsString = ""
    if neg:
        negsString = "1"
    else:
        negsString = "0"

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    areg = format(arg2Int, '04b')

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    instruction = "1110" + const16 + areg + "00" + negsString + "0" + dreg + " //Read at address in " + line[2] + " with offset " + line[1] + " to " + line[3]

    return instruction


#compiles write instruction
#should have 3 arguments
#arg1 should be a positive number that is within 12 bits unsigned
#arg2 should be a valid register
#arg3 should be a valid register
def compileWrite(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int, neg = getNumber(line[1], True)

    negsString = ""
    if neg:
        negsString = "1"
    else:
        negsString = "0"

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    areg = format(arg2Int, '04b')

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    breg = format(arg3Int, '04b')

    #create instruction
    instruction = "1101" + const16 + areg + breg + "000" + negsString + " //Write value in " + line[3] + " to address in " + line[2] + " with offset " + line[1]

    return instruction


#compiles copy instruction
#should have 3 arguments
#arg1 should be a positive number that is within 12 bits unsigned
#arg2 should be a valid register
#arg3 should be a valid register
def compileCopy(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int, neg = getNumber(line[1], True)

    negsString = ""
    if neg:
        negsString = "1"
    else:
        negsString = "0"

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    areg = format(arg2Int, '04b')

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    breg = format(arg3Int, '04b')

    #create instruction
    instruction = "1100" + const16 + areg + breg + "000" + negsString + " //Copy from address in " + line[2] + " to address in " + line[3] + " with offset " + line[1]

    return instruction


#compiles push instruction
#should have 1 argument
def compilePush(line):
    if len(line) != 2:
        raise Exception("Incorrect number of arguments. Expected 1, but got " + str(len(line)-1))

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    breg = format(arg1Int, '04b')

    #create instruction
    instruction = "101100000000000000000000" + breg + "0000" + " //Push " + line[1] + " to stack"

    return instruction


#compiles push instruction
#should have 1 argument
def compilePop(line):
    if len(line) != 2:
        raise Exception("Incorrect number of arguments. Expected 1, but got " + str(len(line)-1))

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    dreg = format(arg1Int, '04b')

    #create instruction
    instruction = "1010000000000000000000000000" + dreg + " //Pop from stack to " + line[1]

    return instruction



#compiles jump instruction
#should have 1 argument or a label
#arg1 should be a positive number that is within 27 bits unsigned
def compileJump(line):
    if len(line) != 2:
        raise Exception("Incorrect number of arguments. Expected 1, but got " + str(len(line)-1))

    instruction = ""
    ARG1isAlabel = False


    try:
        getNumber(line[1])
        ARG1isAlabel = False
    except:
        ARG1isAlabel = True


    #if no label is given
    if not ARG1isAlabel:

        #convert arg1 to number
        arg1Int = getNumber(line[1])

        #convert arg1 to binary
        CheckFitsInBits(arg1Int, 27)
        const27 = format(arg1Int, '027b')

        #create instruction
        instruction = "1001" + const27 + "0" + " //Jump to constant address " + line[1]

    #if a label is given, process it later
    else:
        instruction = " ".join(line)

    return instruction


#compiles jump instruction to offset
#should have 1 argument
#arg1 should be a positive number that is within 20 bits unsigned
def compileJumpo(line):
    if len(line) != 2:
        raise Exception("Incorrect number of arguments. Expected 1, but got " + str(len(line)-1))

    instruction = ""
    

    #convert arg1 to number
    arg1Int = getNumber(line[1])

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 27)
    const27 = format(arg1Int, '027b')

    #create instruction
    instruction = "1001" + const27 + "1" + " //Jump to offset address " + line[1]

    return instruction


#compiles jump instruction to reg with offset
#should have 2 arguments
#arg1 should be a positive number that is within 16 bits unsigned
#arg2 should be a reg
def compileJumpr(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    instruction = ""
    
    #convert arg1 to number
    arg1Int = getNumber(line[1])

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    breg = format(arg2Int, '04b')

    #create instruction
    instruction = "1000" + const16 + "0000" + breg + "000" + "0" + " //Jump to reg " + line[2] + " with offset " + line[1]

    return instruction


#compiles jump instruction to offset in reg with offset
#should have 2 arguments
#arg1 should be a positive number that is within 16 bits unsigned
#arg2 should be a reg
def compileJumpro(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    instruction = ""
    
    #convert arg1 to number
    arg1Int = getNumber(line[1])

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    breg = format(arg2Int, '04b')

    #create instruction
    instruction = "1000" + const16 + "0000" + breg + "000" + "1" + " //Jump to offset in reg " + line[2] + " with offset " + line[1]

    return instruction


#compiles load instruction
#should have 2 arguments
#arg1 should be a positive number that is within 16 bits unsigned
#arg2 should be a valid register
def compileLoad(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getNumber(line[1])

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    dreg = format(arg2Int, '04b')

    #create instruction
    instruction = "0111" + const16 + "000" + "0" + "0000" + dreg + " //Set " + line[2] + " to " + line[1]

    return instruction


#compiles loadhi instruction
#should have 2 arguments
#arg1 should be a positive number that is within 16 bits unsigned
#arg2 should be a valid register
def compileLoadhi(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getNumber(line[1])

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    dreg = format(arg2Int, '04b')

    #create instruction
    instruction = "0111" + const16 + "000" + "1" + "0000" + dreg + " //Set highest 16 bits of " + line[2] + " to " + line[1]

    return instruction


#compiles beq instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should be a valid register
#arg3 should be a positive number that is within 16 bits unsigned
def compileBeq(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg1 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    breg = format(arg2Int, '04b')

    arg3Int = 0

    #convert arg3 to number
    arg3Int = getNumber(line[3])

    #convert arg3 to binary
    CheckFitsInBits(arg3Int, 16)
    const16 = format(arg3Int, '016b')

    #create instruction
    instruction = "0110" + const16 + areg + breg + "0000" + " //If " + line[1] + " == " + line[2] + ", then jump to offset " + line[3]

    return instruction


#compiles bne instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should be a valid register
#arg3 should be a positive number that is within 16 bits unsigned
def compileBne(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg1 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    breg = format(arg2Int, '04b')

    arg3Int = 0

    #convert arg3 to number
    arg3Int = getNumber(line[3])

    #convert arg3 to binary
    CheckFitsInBits(arg3Int, 16)
    const16 = format(arg3Int, '016b')

    #create instruction
    instruction = "0101" + const16 + areg + breg + "0000" + " //If " + line[1] + " != " + line[2] + ", then jump to offset " + line[3]

    return instruction


#compiles bgt instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should be a valid register
#arg3 should be a positive number that is within 16 bits unsigned
def compileBgt(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg1 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    breg = format(arg2Int, '04b')

    arg3Int = 0

    #convert arg3 to number
    arg3Int = getNumber(line[3])

    #convert arg3 to binary
    CheckFitsInBits(arg3Int, 16)
    const16 = format(arg3Int, '016b')

    #create instruction
    instruction = "0100" + const16 + areg + breg + "0000" + " //If " + line[1] + " > " + line[2] + ", then jump to offset " + line[3]

    return instruction


#compiles bge instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should be a valid register
#arg3 should be a positive number that is within 16 bits unsigned
def compileBge(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg1 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    breg = format(arg2Int, '04b')

    arg3Int = 0

    #convert arg3 to number
    arg3Int = getNumber(line[3])

    #convert arg3 to binary
    CheckFitsInBits(arg3Int, 16)
    const16 = format(arg3Int, '016b')

    #create instruction
    instruction = "0011" + const16 + areg + breg + "0000" + " //If " + line[1] + " >= " + line[2] + ", then jump to offset " + line[3]

    return instruction


#compiles savpc instruction
#should have 1 argument
def compileSavpc(line):
    if len(line) != 2:
        raise Exception("Incorrect number of arguments. Expected 1, but got " + str(len(line)-1))

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    dreg = format(arg1Int, '04b')

    #create instruction
    instruction = "0010000000000000000000000000" + dreg + " //Save PC to " + line[1]

    return instruction


#compiles reti instruction
#should have 0 arguments
def compileReti(line):
    if len(line) != 1:
        raise Exception("Incorrect number of arguments. Expected 0, but got " + str(len(line)-1))

    return "00010000000000000000000000000000 //Return from interrupt"


#compiles or instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileOr(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0000" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " OR " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0000" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " OR " + line[2] + " and write result to " + line[3]

    return instruction


#compiles and instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileAnd(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0001" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " AND " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0001" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " AND " + line[2] + " and write result to " + line[3]

    return instruction

#compiles xor instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileXor(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0010" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " XOR " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0010" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " XOR " + line[2] + " and write result to " + line[3]

    return instruction


#compiles add instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileAdd(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0011" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " + " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0011" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " + " + line[2] + " and write result to " + line[3]

    return instruction


#compiles sub instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileSub(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0100" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " - " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0100" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " - " + line[2] + " and write result to " + line[3]

    return instruction


#compiles shiftl instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileShiftl(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0101" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " << " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0101" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " << " + line[2] + " and write result to " + line[3]

    return instruction


#compiles shiftr instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileShiftr(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0110" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " >> " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0110" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " >> " + line[2] + " and write result to " + line[3]

    return instruction


#compiles mult instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileMult(line):
    if len(line) != 4:
        raise Exception("Incorrect number of arguments. Expected 3, but got " + str(len(line)-1))

    const11 = ""
    arg2Int = 0
    constantEnable = 0
    breg = ""
    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')

    #convert arg2 to number
    if line[2][0].lower() == 'r':   #if arg1 is a register argument
        constantEnable = 0
        arg2Int = getReg(line[2])
    else:                           #arg1 is a constant
        constantEnable = 1
        arg2Int = getNumber(line[2])

    #convert arg2 to binary
    if constantEnable:
        CheckFitsInBits(arg2Int, 11)
        const11 = format(arg2Int, '011b')
    else:
        breg = format(arg2Int, '04b')
        

    #convert arg3 to number
    arg3Int = getReg(line[3])

    #convert arg3 to binary
    dreg = format(arg3Int, '04b')

    #create instruction
    if constantEnable:
        instruction = "0000" + "1" "0111" + const11 + areg + "0000" + dreg + " //Compute " +  line[1] + " * " + line[2] + " and write result to " + line[3]
    else:
        instruction = "0000" + "0" "0111" + "00000000000" + areg + breg + dreg + " //Compute " +  line[1] + " * " + line[2] + " and write result to " + line[3]

    return instruction


#compiles not instruction
#should have 3 arguments
#arg1 should be a valid register
#arg2 should either be a positive number that is within 11 bits unsigned, 
# or a valid register
#arg3 should be a valid register
def compileNot(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    instruction = ""

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg2 to binary
    areg = format(arg1Int, '04b')
       

    #convert arg3 to number
    arg2Int = getReg(line[2])

    #convert arg3 to binary
    dreg = format(arg2Int, '04b')

    instruction = "0000" + "0" "1000" + "00000000000" + areg + "0000" + dreg + " //Compute NOT " +  line[1] + " and write result to " + line[2]

    return instruction



#compiles addr2reg instruction
#should have 2 arguments
#arg 1 should be a valid label
#arg 2 should be a reg
def compileAddr2reg(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    instruction = "loadLabelHigh " + line[1] + " " + line[2]

    #check if register is valid
    getReg(line[2])

    return instruction


#compiles load32 instruction
#should have 2 arguments
#arg 1 should be a number within 32 bits
#arg 2 should be a reg
def compileLoad32(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    const32 = ""

    #convert arg1 to number
    arg1Int = getNumber(line[1])


    #check if it fits in 16 bits, so we can skip the loadhi
    try:
        CheckFitsInBits(arg1Int, 16)
        return compileLoad(line)
    except:
        pass #continue

    #check if it fits in 32 bits
    CheckFitsInBits(arg1Int, 32)

    #convert to 32 bit
    const32 = format(arg1Int, '032b')

    constLow = int(const32[0:16], 2)
    constHigh = int(const32[16:32], 2)

    #create instruction
    instruction = "loadBoth " + str(constLow) + " " + str(constHigh) + " " + line[2]

    return instruction

#compiles compileLoadLabelLow instruction
def compileLoadLabelLow(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getNumber(line[1])

    x = '{0:027b}'.format(arg1Int)

    #x[:11] highest 11 bits
    #x[11:] lowest 16 bits

    arg1Int = getNumber("0b" + x[11:])

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16) #should not be needed
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    dreg = format(arg2Int, '04b')

    #create instruction
    instruction = "0111" + const16 + "000" + "0" + "0000" + dreg + " //Set " + line[2] + " to " + str(arg1Int)

    return instruction


#compiles compileLoadLabelHigh instruction
def compileLoadLabelHigh(line):
    if len(line) != 3:
        raise Exception("Incorrect number of arguments. Expected 2, but got " + str(len(line)-1))

    const16 = ""

    #convert arg1 to number
    arg1Int = getNumber(line[1])

    x = '{0:027b}'.format(arg1Int)

    #x[:11] highest 4 bits
    #x[11:] lowest 16 bits

    arg1Int = getNumber("0b" + x[:11])

    #convert arg1 to binary
    CheckFitsInBits(arg1Int, 16)
    const16 = format(arg1Int, '016b')

    #convert arg2 to number
    arg2Int = getReg(line[2])

    #convert arg2 to binary
    dreg = format(arg2Int, '04b')

    #create instruction
    instruction = "0111" + const16 + "000" + "1" + "0000" + dreg + " //Set highest 16 bits of " + line[2] + " to " + str(arg1Int)

    return instruction


#compiles nop instruction
#should have 0 arguments
def compileNop(line):
    if len(line) != 1:
        raise Exception("Incorrect number of arguments. Expected 0, but got " + str(len(line)-1))

    return "00000000000000000000000000000000 //NOP"

#compiles .dw instruction
def compileDw(line):
    if len(line) < 2:
        raise Exception("Incorrect number of arguments. Expected 1 or more, but got " + str(len(line)-1))
    
    instruction = "data"

    for i in line:
        if i != ".dw":
            number = getNumber(i)
            CheckFitsInBits(number, 32)
            instruction = instruction + " " + '{0:032b}'.format(number)

    return instruction


#compiles .dd instruction
def compileDd(line):
    if len(line) < 2:
        raise Exception("Incorrect number of arguments. Expected 1 or more, but got " + str(len(line)-1))
    
    instruction = "data"

    counter = 1
    for i in line:
        if i != ".dd":
            number = getNumber(i)
            CheckFitsInBits(number, 16)
            if counter < 1:
                counter = counter + 1
                instruction = instruction + "" + '{0:016b}'.format(number)
            else:
                instruction = instruction + " " + '{0:016b}'.format(number)
                counter = 0

    if counter == 0:
        instruction = instruction + "0000000000000000"

    return instruction

#compiles .db instruction
def compileDb(line):
    if len(line) < 2:
        raise Exception("Incorrect number of arguments. Expected 1 or more, but got " + str(len(line)-1))
    
    instruction = "data"

    counter = 3
    for i in line:
        if i != ".db":
            number = getNumber(i)
            CheckFitsInBits(number, 8)
            if counter < 3:
                counter = counter + 1
                instruction = instruction + "" + '{0:08b}'.format(number)
            else:
                instruction = instruction + " " + '{0:08b}'.format(number)
                counter = 0

    if counter == 0:
        instruction = instruction + "000000000000000000000000"
    if counter == 1:
        instruction = instruction + "0000000000000000"
    if counter == 2:
        instruction = instruction + "00000000"

    return instruction

#compiles .ds instruction by converting it to a .db instruction
def compileDs(line):
    if len(line) != 2:
        raise Exception("Incorrect number of arguments. Expected 1, but got " + str(len(line)-1))

    #.db instruction
    dbList = []

    dbList.append(".db")

    # check for " "
    if (line[1][0] == "\"" and line[1][-1] == "\""):
        dbList = dbList + [str(ord(char)) for char in line[1][1:-1]]
        #TODO convert string to ascii list using [ord(char) for char in string]
    else:
        raise Exception("Invalid string: " + line[1])
    
    return compileDb(dbList)


#compiles readintid instruction
#should have 1 argument
#arg1 should be a valid register
def compileReadIntID(line):
    if len(line) != 2:
        raise Exception("Incorrect number of arguments. Expected 1, but got " + str(len(line)-1))

    #convert arg1 to number
    arg1Int = getReg(line[1])

    #convert arg1 to binary
    dreg = format(arg1Int, '04b')

    #create instruction
    instruction = "1110" + "0000000000000000" + "0000" + "0001" + dreg + " //Read interrupt id to " + line[1]

    return instruction


#compile nothing
def compileNothing(line):
    return "ignore"