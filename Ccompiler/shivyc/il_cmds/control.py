"""IL commands for labels, jumps, and function calls."""

import shivyc.asm_cmds as asm_cmds
import shivyc.spots as spots
from shivyc.il_cmds.base import ILCommand
from shivyc.spots import LiteralSpot, RegSpot, MemSpot


class Label(ILCommand):
    """Label - Analogous to an ASM label."""

    def __init__(self, label): # noqa D102
        """The label argument is an string label name unique to this label."""
        self.label = label

    def inputs(self): # noqa D102
        return []

    def outputs(self): # noqa D102
        return []

    def label_name(self):  # noqa D102
        return self.label

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        asm_code.add(asm_cmds.Label(self.label))


class Jump(ILCommand):
    """Jumps unconditionally to a label."""

    def __init__(self, label): # noqa D102
        self.label = label

    def inputs(self): # noqa D102
        return []

    def outputs(self): # noqa D102
        return []

    def targets(self): # noqa D102
        return [self.label]

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        asm_code.add(asm_cmds.Jump(self.label))


class _GeneralJump(ILCommand):
    """General class for jumping to a label based on condition."""
    asm_cmd = None

    def __init__(self, cond, label): # noqa D102
        self.cond = cond
        self.label = label

    def inputs(self): # noqa D102
        return [self.cond]

    def outputs(self): # noqa D102
        return []

    def targets(self): # noqa D102
        return [self.label]

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        size = None

        r12_spot = spots.RegSpot("r12")
        r13_spot = spots.RegSpot("r13")
        self.move(spotmap[self.cond], r12_spot, asm_code)

        asm_code.add(asm_cmds.Cmp(r12_spot, LiteralSpot(0), size))

        asm_code.add(self.command(RegSpot("r0"), r12_spot, LiteralSpot(2)))
        #not bgt r12 r0 2 -> bge r0 r12 2
        #not bge r12 r0 2 -> bgt r0 r12 2

        #not beq r12 r0 2 -> bne r0 r12 2
        #not bne r12 r0 2 -> beq r0 r12 2

        asm_code.add(asm_cmds.Jump(self.label))

# NOTE:
# these comparisons are inverted, because in b332 asm we jump to offset 2 to skip the jump to label
# confusing, so think hard on this!

class JumpZero(_GeneralJump):
    """Jumps to a label if given condition is zero."""

    command = asm_cmds.Bne


class JumpNotZero(_GeneralJump):
    """Jumps to a label if given condition is not zero."""

    command = asm_cmds.Beq


class Return(ILCommand):
    """RETURN - returns the given value from function.

    If arg is None, then returns from the function without putting any value
    in the return register.
    """

    def __init__(self, arg=None): # noqa D102
        # arg must already be cast to return type
        self.arg = arg

    def inputs(self): # noqa D102
        return [self.arg]

    def outputs(self): # noqa D102
        return []

    def clobber(self):  # noqa D102
        return [spots.RAX]

    def abs_spot_pref(self):  # noqa D102
        return {self.arg: [spots.RAX]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        
        # move return value to return register
        if self.arg and spotmap[self.arg] != spots.RAX:    
            self.move(spotmap[self.arg], spots.RAX, asm_code)            

        # return sequence
        asm_code.add(asm_cmds.Mov(spots.RSP, spots.RBP))       
        asm_code.add(asm_cmds.Read(spots.RSP, spots.RBP))
        asm_code.add(asm_cmds.Add(spots.RSP, spots.LiteralSpot(1)))
        asm_code.add(asm_cmds.Read(spots.RSP, spots.RegSpot("r12")))
        asm_code.add(asm_cmds.Add(spots.RSP, spots.LiteralSpot(1)))
        asm_code.add(asm_cmds.Jumpr(spots.LiteralSpot(4), spots.RegSpot("r12")))


class Call(ILCommand):
    """Call a given function.

    func - Pointer to function
    args - Arguments of the function, in left-to-right order. Must match the
    parameter types the function expects.
    ret - If function has non-void return type, IL value to save the return
    value. Its type must match the function return value.
    """

    arg_regs = [spots.RDI, spots.RSI, spots.RDX, spots.RCX, spots.R8, spots.R9]

    def __init__(self, func, args, ret): # noqa D102
        self.func = func
        self.args = args
        self.ret = ret
        self.void_return = self.func.ctype.arg.ret.is_void()

        if len(self.args) > len(self.arg_regs):
            raise NotImplementedError("too many arguments")

    def inputs(self): # noqa D102
        return [self.func] + self.args

    def outputs(self): # noqa D102
        return [] if self.void_return else [self.ret]

    def clobber(self): # noqa D102
        # All caller-saved registers are clobbered by function call
        return [spots.RAX, spots.RCX, spots.RDX, spots.RSI, spots.RDI,
                spots.R8, spots.R9, spots.R10, spots.R11]

    def abs_spot_pref(self): # noqa D102
        prefs = {} if self.void_return else {self.ret: [spots.RAX]}
        for arg, reg in zip(self.args, self.arg_regs):
            prefs[arg] = [reg]

        return prefs

    def abs_spot_conf(self): # noqa D102
        # We don't want the function pointer to be in the same register as
        # an argument will be placed into.
        return {self.func: self.arg_regs[0:len(self.args)]}

    def indir_write(self): # noqa D102
        return self.args

    def indir_read(self): # noqa D102
        return self.args

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        func_spot = spotmap[self.func]

        func_size = self.func.ctype.size
        ret_size = self.func.ctype.arg.ret.size

        # Check if function pointer spot will be clobbered by moving the
        # arguments into the correct registers.
        if spotmap[self.func] in self.arg_regs[0:len(self.args)]:
            # Get a register which isn't one of the unallowed registers.
            r = get_reg([], self.arg_regs[0:len(self.args)])
            self.move(spotmap[self.func], r, asm_code)
            func_spot = r


        for arg, reg in zip(self.args, self.arg_regs):
            if spotmap[arg] == reg:
                continue

            self.move(spotmap[arg], reg, asm_code)


        self.move(func_spot, spots.RegSpot("r13"), asm_code)

        asm_code.add(asm_cmds.SavPC(spots.RegSpot("r12")))
        asm_code.add(asm_cmds.Sub(spots.RegSpot("rsp"), spots.LiteralSpot(1)))
        asm_code.add(asm_cmds.Write(spots.RegSpot("rsp"), spots.RegSpot("r12")))
        asm_code.add(asm_cmds.Jumpr(spots.LiteralSpot(0), spots.RegSpot("r13")))

        if not self.void_return and spotmap[self.ret] != spots.RAX:
            self.move(spots.RAX, spotmap[self.ret], asm_code)
            