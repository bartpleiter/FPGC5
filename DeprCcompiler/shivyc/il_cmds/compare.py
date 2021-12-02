"""IL commands for comparisons."""

import shivyc.asm_cmds as asm_cmds
from shivyc.il_cmds.base import ILCommand
from shivyc.spots import RegSpot, MemSpot, LiteralSpot
import shivyc.spots as spots


class _GeneralCmp(ILCommand):
    """_GeneralCmp - base class for the comparison commands.
    """
    signed_cmp_cmd = None
    unsigned_cmp_cmd = None
    reverse_less_cmd = False

    def __init__(self, output, arg1, arg2): # noqa D102
        self.output = output
        self.arg1 = arg1
        self.arg2 = arg2

    def inputs(self): # noqa D102
        return [self.arg1, self.arg2]

    def outputs(self): # noqa D102
        return [self.output]

    def rel_spot_conf(self):  # noqa D102
        return {self.output: [self.arg1, self.arg2]}

    def cmp_command(self):
        ctype = self.arg1.ctype
        if ctype.is_pointer() or (ctype.is_integral() and not ctype.signed):
            return self.unsigned_cmp_cmd
        else:
            return self.signed_cmp_cmd

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102

        arg1_spot = spotmap[self.arg1]
        arg2_spot = spotmap[self.arg2]
        output_spot = spotmap[self.output]
        r12_spot = spots.RegSpot("r12")
        r13_spot = spots.RegSpot("r13")
        label = asm_code.get_label()

        # this stays here until I removed size from all functions
        size = None

        # start with setting the output reg to 1, in case of success
        asm_code.add(asm_cmds.Load(LiteralSpot(1), output_spot, size))

        self.move(arg1_spot, r12_spot, asm_code)
        self.move(arg2_spot, r13_spot, asm_code)

        # swap args when using less than instructions (to convert to gte's)
        if self.reverse_less_cmd:
            asm_code.add(self.cmp_command()(r12_spot, r13_spot, LiteralSpot(2)))
        else:
            asm_code.add(self.cmp_command()(r13_spot, r12_spot, LiteralSpot(2)))
        #not bgt r12 r0 2 -> bge r0 r12 2
        #not bge r12 r0 2 -> bgt r0 r12 2

        #not beq r12 r0 2 -> bne r0 r12 2
        #not bne r12 r0 2 -> beq r0 r12 2

        asm_code.add(asm_cmds.Jump(label))

        # in case the comparison was unsuccessful, set output reg to 0
        asm_code.add(asm_cmds.Load(LiteralSpot(0), output_spot, size))

        asm_code.add(asm_cmds.Label(label))


# NOTE:
# these comparisons are inverted, because in b332 asm we jump to offset 2 to skip the jump to label
# confusing, so think hard on this!
# I probably did some double negations tho

class NotEqualCmp(_GeneralCmp):
    signed_cmp_cmd = asm_cmds.Beq
    unsigned_cmp_cmd = asm_cmds.Beq
    reverse_less_cmd = False


class EqualCmp(_GeneralCmp):
    signed_cmp_cmd = asm_cmds.Bne
    unsigned_cmp_cmd = asm_cmds.Bne


class LessCmp(_GeneralCmp):
    signed_cmp_cmd = asm_cmds.Bge
    unsigned_cmp_cmd = asm_cmds.Bge
    reverse_less_cmd = True


class GreaterCmp(_GeneralCmp):
    signed_cmp_cmd = asm_cmds.Bge
    unsigned_cmp_cmd = asm_cmds.Bge
    reverse_less_cmd = False


class LessOrEqCmp(_GeneralCmp):
    signed_cmp_cmd = asm_cmds.Bgt
    unsigned_cmp_cmd = asm_cmds.Bgt
    reverse_less_cmd = True


class GreaterOrEqCmp(_GeneralCmp):
    signed_cmp_cmd = asm_cmds.Bgt
    unsigned_cmp_cmd = asm_cmds.Bgt
    reverse_less_cmd = False
