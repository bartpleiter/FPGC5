"""IL commands for mathematical operations."""

import shivyc.asm_cmds as asm_cmds
import shivyc.spots as spots
from shivyc.il_cmds.base import ILCommand
from shivyc.errors import CompilerError


class _BasicMath(ILCommand):
    """Base class for basic math operations in the form: arg1 (operation) arg2 -> output."""

    # The ASM instruction to generate for this command. Override this value
    # in subclasses.
    Inst = None

    def __init__(self, output, arg1, arg2): # noqa D102
        self.output = output
        self.arg1 = arg1
        self.arg2 = arg2

    def inputs(self): # noqa D102
        return [self.arg1, self.arg2]

    def outputs(self): # noqa D102
        return [self.output]

    def rel_spot_pref(self): # noqa D102
        return {self.output: [self.arg1, self.arg2]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        """Make the ASM for the operation"""
        size = None

        arg1_spot = spotmap[self.arg1]
        arg2_spot = spotmap[self.arg2]
        output_spot = spotmap[self.output]
        r12_spot = spots.RegSpot("r12")
        r13_spot = spots.RegSpot("r13")

        """
        Both arguments are moved to r12 and r13, to make sure they become regspots
        Operation will be done on these two regs, with the result always in r12
        Then, depending on output_spot being a reg or mem (lit should not be possible), a move or write will be added
        """

        self.move(arg1_spot, r12_spot, asm_code)
        self.move(arg2_spot, r13_spot, asm_code)

        asm_code.add(self.Inst(r12_spot, r13_spot, size))

        # output
        if isinstance(output_spot, spots.RegSpot):
            asm_code.add(asm_cmds.Mov(output_spot, r12_spot, size))

        elif isinstance(output_spot, spots.MemSpot):
            asm_code.add(asm_cmds.Write(output_spot, r12_spot, size))




class Add(_BasicMath):
    """Adds arg1 and arg2, then saves to output.
    """
    Inst = asm_cmds.Add


class Subtr(_BasicMath):
    """Subtracts arg1 and arg2 (arg1 - arg2), then saves to output.
    """
    Inst = asm_cmds.Sub


class Mult(_BasicMath):
    """Multiplies arg1 and arg2, then saves to output.
    """
    Inst = asm_cmds.Mult

class RBitShift(_BasicMath):
    """Right bitwise shift operator for IL value.
    Shifts each bit in IL value left operand to the right by position
    indicated by right operand."""

    Inst = asm_cmds.Shiftr


class LBitShift(_BasicMath):
    """Left bitwise shift operator for IL value.
    Shifts each bit in IL value left operand to the left by position
    indicated by right operand."""

    Inst = asm_cmds.Shiftl


class And(_BasicMath):
    """Bitwise AND"""

    Inst = asm_cmds.And


class Or(_BasicMath):
    """Bitwise OR"""

    Inst = asm_cmds.Or

class Xor(_BasicMath):
    """Bitwise XOR"""

    Inst = asm_cmds.Xor





class _NegNot(ILCommand):
    """Base class for NEG and NOT."""

    def __init__(self, output, arg):  # noqa D102
        self.output = output
        self.arg = arg

    def inputs(self):  # noqa D102
        return [self.arg]

    def outputs(self):  # noqa D102
        return [self.output]

    def rel_spot_pref(self):  # noqa D102
        return {self.output: [self.arg]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        size = self.arg.ctype.size

        output_spot = spotmap[self.output]
        arg_spot = spotmap[self.arg]

        r12_spot = spots.RegSpot("r12")

        self.move(arg_spot, r12_spot, asm_code)
        asm_code.add(asm_cmds.Not(r12_spot, size))
        self.move(r12_spot, output_spot, asm_code)

class Neg(_NegNot):
    # for B322 we just do a not
    """"""


class Not(_NegNot):
    # for B322 we just do a not
    """"""



class _DivMod(ILCommand):
    """Base class for ILCommand Div and Mod."""

    # since there is currently no division and mod implemented in the assembler and hardware,
    # we raise an error

    def __init__(self, output, arg1, arg2):
        err = "division and modulo are not supported"
        # TODO: find a way to add rule number here
        raise CompilerError(err)


class Div(_DivMod):
    """
    Placeholder for division until supported
    """


class Mod(_DivMod):
    """
    Placeholder for division until supported
    """