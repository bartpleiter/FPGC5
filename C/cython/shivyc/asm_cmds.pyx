"""This module defines and implements classes representing assembly commands.

Actually using base classes would be a good thing to do in the future

"""

import shivyc.spots as spots

class _B322Base2Command:
    """Base class for a command with 2 args

    """

    name = None

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        return s


class Load(_B322Base2Command): name = "load32"



class ASMline:
    "Print line of ASM code"

    def __init__(self, line):
        self.line = line

    def __str__(self):
        return "\t" + self.line



class Write:
    name = None

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1
        self.arg2 = arg2
        self.size = size

    def __str__(self):


        s = ""
        if not isinstance(self.arg1, spots.MemSpot):
            s += "\twrite"

            s += " " + "0"
            if self.arg1:
                s += " " + str(self.arg1.asm_str(self.size))
            if self.arg2:
                s += " " + self.arg2.asm_str(self.size)

        else:
            if type(self.arg1.base) == str:
                s += "\taddr2reg Label_" + self.arg1.base + " r7\n\twrite"

                if isinstance(self.arg1.count, spots.LiteralSpot):
                    s += " " + str(self.arg1.offset + (self.arg1.chunk * self.arg1.count.value))
                else:
                    s += " " + str(self.arg1.offset)
                if self.arg1:
                    s += " r7"
                if self.arg2:
                    s += " " + self.arg2.asm_str(self.size)

            else:
                s += "\twrite"

                if isinstance(self.arg1.count, spots.LiteralSpot):
                    s += " " + str(self.arg1.offset + (self.arg1.chunk * self.arg1.count.value))
                else:
                    s += " " + str(self.arg1.offset)
                if self.arg1:
                    s += " " + str(self.arg1.base)
                if self.arg2:
                    s += " " + self.arg2.asm_str(self.size)
        return s


class Read:
    name = None

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1
        self.arg2 = arg2
        self.size = size

    def __str__(self):
        s = ""
        if not isinstance(self.arg1, spots.MemSpot):
            s += "\tread"

            s += " " + "0"
            if self.arg1:
                s += " " + str(self.arg1.asm_str(self.size))
            if self.arg2:
                s += " " + self.arg2.asm_str(self.size)

        else:
            if type(self.arg1.base) == str:
                s += "\taddr2reg Label_" + self.arg1.base + " r7\n\tread"

                if isinstance(self.arg1.count, spots.LiteralSpot):
                    s += " " + str(self.arg1.offset + (self.arg1.chunk * self.arg1.count.value))
                else:
                    s += " " + str(self.arg1.offset)
                if self.arg1:
                    s += " r7"
                if self.arg2:
                    s += " " + self.arg2.asm_str(self.size)

            else:
                s += "\tread"

                if isinstance(self.arg1.count, spots.LiteralSpot):
                    s += " " + str(self.arg1.offset + (self.arg1.chunk * self.arg1.count.value))
                else:
                    s += " " + str(self.arg1.offset)
                if self.arg1:
                    s += " " + str(self.arg1.base)
                if self.arg2:
                    s += " " + self.arg2.asm_str(self.size)

        return s


class Mov:
    "move by using logical or with zero (r0)"
    name = None

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size)
        self.arg2 = arg2.asm_str(size)
        self.size = size

    def __str__(self):
        s = "\tor"
        if self.arg1:
            s += " r0"
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s


class Lea:
    """Class for lea command."""


    def __init__(self, dest, source):  # noqa: D102
        self.dest = dest
        self.source = source

    def __str__(self):  # noqa: D102
        offset = int(self.source.offset + (self.source.chunk * self.source.count.value))
        dstring = self.dest.asm_str(0)

        if offset >= 0:
            # do add
            return ("\tadd " + str(self.source.base) + " " + str(offset) + " " + dstring)
        else:
            #do sub
            return ("\tsub " + str(self.source.base) + " " + str(abs(offset)) + " " + dstring + " ;lea")



class Add:
    name = "add"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s



class Sub:
    name = "sub"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s



class Mult:
    name = "mult"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size)
        self.arg2 = arg2.asm_str(size)

    def __str__(self):
        s = "\t" + self.name
        s += " " + self.arg1
        s += " " + self.arg2
        s += " " + self.arg1
        return s


class Shiftl:
    name = "shiftl"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s


class Shiftr:
    name = "shiftr"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s


class And:
    name = "and"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s


class Or:
    name = "or"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s


class Xor:
    name = "xor"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + self.arg1
        return s


class Not:
    name = "not"

    def __init__(self, arg1=None, size=None):
        self.arg1 = arg1.asm_str(size)

    def __str__(self):
        s = "\t" + self.name
        s += " " + self.arg1
        s += " " + self.arg1
        return s


class Cmp:
    name = "sub"

    def __init__(self, arg1=None, arg2=None, size=None):
        self.arg1 = arg1.asm_str(size) if arg1 else None
        self.arg2 = arg2.asm_str(size) if arg2 else None
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        if self.arg1:
            s += " " + self.arg1
        if self.arg2:
            s += " " + self.arg2
        if self.arg1:
            s += " " + spots.RegSpot("r12").asm_str(self.size)
        return s

class Bge:
    name = "bge"

    def __init__(self, arg1=None, arg2=None, arg3=None):
        self.arg1 = arg1.asm_str(0)
        self.arg2 = arg2.asm_str(0)
        self.arg3 = arg3.asm_str(0)

    def __str__(self):
        s = "\t" + self.name
        s += " " + self.arg1
        s += " " + self.arg2
        s += " " + self.arg3
        return s

class Bgt:
    name = "bgt"

    def __init__(self, arg1=None, arg2=None, arg3=None):
        self.arg1 = arg1.asm_str(0)
        self.arg2 = arg2.asm_str(0)
        self.arg3 = arg3.asm_str(0)

    def __str__(self):
        s = "\t" + self.name
        s += " " + self.arg1
        s += " " + self.arg2
        s += " " + self.arg3
        return s

class Bne:
    name = "bne"

    def __init__(self, arg1=None, arg2=None, arg3=None):
        self.arg1 = arg1.asm_str(0)
        self.arg2 = arg2.asm_str(0)
        self.arg3 = arg3.asm_str(0)

    def __str__(self):
        s = "\t" + self.name
        s += " " + self.arg1
        s += " " + self.arg2
        s += " " + self.arg3
        return s

class Beq:
    name = "beq"

    def __init__(self, arg1=None, arg2=None, arg3=None):
        self.arg1 = arg1.asm_str(0)
        self.arg2 = arg2.asm_str(0)
        self.arg3 = arg3.asm_str(0)

    def __str__(self):
        s = "\t" + self.name
        s += " " + self.arg1
        s += " " + self.arg2
        s += " " + self.arg3
        return s

class Addr2Reg:
    """Class for addr2reg command."""

    name = "addr2reg"

    def __init__(self, dest, source):  # noqa: D102
        self.dest = dest
        self.source = source

    def __str__(self):  # noqa: D102
        return ("\t" + self.name + " Label_" + self.dest.asm_str(0) + " "
                "" + self.source.asm_str(0))

class SavPC:
    """Class for savpc command."""

    name = "savpc"

    def __init__(self, dest):  # noqa: D102
        self.dest = dest

    def __str__(self):  # noqa: D102
        return ("\t" + self.name + " " + self.dest.asm_str(0))



class Jumpr:

    name = "jumpr"

    def __init__(self, offset=None, dest=None, size=None):
        self.offset = offset.asm_str(size)
        self.dest = dest.asm_str(size)
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        s += " " + self.offset
        s += " " + self.dest
        return s

class Jump:

    name = "jump"

    def __init__(self, dest=None, size=None):
        self.dest = dest
        self.size = size

    def __str__(self):
        s = "\t" + self.name
        s += " Label_" + self.dest
        return s


class Comment:
    """Class for comments."""

    def __init__(self, msg):  # noqa: D102
        self.msg = msg

    def __str__(self):  # noqa: D102
        return "\t; " + self.msg


class Label:
    """Class for label."""

    def __init__(self, label):  # noqa: D102
        self.label = label

    def __str__(self):  # noqa: D102
        return "Label_" + self.label + ":"
