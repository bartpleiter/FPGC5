"""IL commands for setting/reading values and getting value addresses."""

import shivyc.asm_cmds as asm_cmds
import shivyc.ctypes as ctypes
import shivyc.spots as spots
from shivyc.il_cmds.base import ILCommand
from shivyc.spots import RegSpot, MemSpot, LiteralSpot


class _ValueCmd(ILCommand):
    """Abstract base class for value commands.

    This class defines a helper function for moving data from one location
    to another.
    """

    


class LoadArg(ILCommand):
    """Loads a function argument value into an IL value.

    output is the IL value to load the function argument value into,
    and arg_num is the index of the argument to load. For example,
    at the start of the body of the following function:

       int func(int a, int b);

    the following two LoadArg commands would be appropriate

       LoadArg(a, 0)
       LoadArg(b, 1)

    in order to load the first function argument into the variable a and
    the second function argument into the variable b.
    """
    arg_regs = [spots.RDI, spots.RSI, spots.RDX, spots.RCX, spots.R8, spots.R9]

    def __init__(self, output, arg_num):
        self.output = output
        self.arg_reg = self.arg_regs[arg_num]

    def inputs(self):
        return []

    def outputs(self):
        return [self.output]

    def clobber(self):
        return [self.arg_reg]

    def abs_spot_pref(self):
        return {self.output: [self.arg_reg]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):
        if spotmap[self.output] == self.arg_reg:
            return
        else:
            self.move(self.arg_reg, spotmap[self.output], asm_code)


class Set(_ValueCmd):
    """SET - sets output IL value to arg IL value.

    SET converts between all scalar types, so the output and arg IL values
    need not have the same type if both are scalar types. If either one is
    a struct type, the other must be the same struct type.
    """
    def __init__(self, output, arg): # noqa D102
        self.output = output
        self.arg = arg

    def inputs(self): # noqa D102
        return [self.arg]

    def outputs(self): # noqa D102
        return [self.output]

    def rel_spot_pref(self): # noqa D102
        if self.output.ctype.weak_compat(ctypes.bool_t):
            return {}
        else:
            return {self.output: [self.arg]}

    def rel_spot_conf(self):
        if self.output.ctype.weak_compat(ctypes.bool_t):
            return {self.output: [self.arg]}
        else:
            return {}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code): # noqa D102
        if spotmap[self.arg] == spotmap[self.output]:
            return

        self.move(spotmap[self.arg], spotmap[self.output], asm_code)



class AddrOf(ILCommand):
    """Gets address of given variable.

    `output` must have type pointer to the type of `var`.

    """

    def __init__(self, output, var):  # noqa D102
        self.output = output
        self.var = var

    def inputs(self):  # noqa D102
        return [self.var]

    def outputs(self):  # noqa D102
        return [self.output]

    def references(self):  # noqa D102
        return {self.output: [self.var]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102
        r = get_reg([spotmap[self.output]])

        #print(home_spots[self.var].__dict__)
        #print(self.var.ctype)
        #print(type(home_spots[self.var].base))
        
        # if function label (most likely)
        #print(type(self.var.ctype))
        if isinstance(self.var.ctype, ctypes.FunctionCType):
            asm_code.add(asm_cmds.Addr2Reg(home_spots[self.var], r))

        # when getting integer data from stack
        elif isinstance(self.var.ctype, ctypes.IntegerCType):
            asm_code.add(asm_cmds.Read(home_spots[self.var], r))

        # when we are working with a memspot with a string as base, we probably have a label
        elif isinstance(home_spots[self.var], spots.MemSpot) and isinstance(home_spots[self.var].base, str):
            asm_code.add(asm_cmds.Addr2Reg(home_spots[self.var], r))
            
        # default to use a read instruction over an addr2reg instruction
        else:
            #asm_code.add(asm_cmds.Read(home_spots[self.var], r))
            self.move(home_spots[self.var], r, asm_code)
            #asm_code.add(asm_cmds.Addr2Reg(home_spots[self.var], r))

        

        if r != spotmap[self.output]:
            #print("help (addrOf)")
            size = self.output.ctype.size

            #asm_code.add(asm_cmds.Mov(spotmap[self.output], r, size))

            #_ValueCmd.move_data(self, spotmap[self.output], r, size, None, asm_code)
            self.move(r, spotmap[self.output], asm_code)


class ASMcode(ILCommand):
    """Places inline ASM code.

    """

    def __init__(self, code):  # noqa D102
        self.code = code

    def inputs(self):  # noqa D102
        return []

    def outputs(self):  # noqa D102
        return []

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102
        # here we parse the asm code string into asm code lines
        # then we add each line to asm_code

        codeList = self.code[5:-3].split(";")
        codeList = [code.split("//", 1)[0] for code in codeList]
        codeList = [code.strip() for code in codeList]
        codeList = list(filter(None, codeList))
        
        for line in codeList:
            asm_code.add(asm_cmds.ASMline(line))


class ReadAt(_ValueCmd):
    """Reads value at given address.

    `addr` must have type pointer to the type of `output`

    """

    def __init__(self, output, addr):  # noqa D102
        self.output = output
        self.addr = addr

    def inputs(self):  # noqa D102
        return [self.addr]

    def outputs(self):  # noqa D102
        return [self.output]

    def indir_read(self):  # noqa D102
        return [self.addr]

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102
        addr_spot = spotmap[self.addr]
        output_spot = spotmap[self.output]


        addr_r = get_reg([], [output_spot])
        self.move(addr_spot, addr_r, asm_code)

        indir_spot = MemSpot(addr_r)

        self.move(indir_spot, output_spot, asm_code)
        

class SetAt(_ValueCmd):
    """Sets value at given address.

    `addr` must have type pointer to the type of `val`

    """

    def __init__(self, addr, val):  # noqa D102
        self.addr = addr
        self.val = val

    def inputs(self):  # noqa D102
        return [self.addr, self.val]

    def outputs(self):  # noqa D102
        return []

    def indir_write(self):  # noqa D102
        return [self.addr]

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102
        addr_spot = spotmap[self.addr]
        value_spot = spotmap[self.val]

        addr_r = get_reg([], [value_spot])
        self.move(addr_spot, addr_r, asm_code)

        indir_spot = MemSpot(addr_r)

        self.move(value_spot, indir_spot, asm_code)


class _RelCommand(_ValueCmd):
    """Parent class for the relative commands."""

    def __init__(self, val, base, chunk, count):  # noqa D102
        self.val = val
        self.base = base
        self.chunk = chunk
        self.count = count

        # Keep track of which registers have been used from a call to
        # get_reg so we don't accidentally reuse them.
        self._used_regs = []

    def get_rel_spot(self, spotmap, get_reg, asm_code):
        """Get a relative spot for the relative value."""

        # If there's no count, we only need to shift by the chunk
        if not self.count:
            return spotmap[self.base].shift(self.chunk)

        # If there is a count in a literal spot, we're good to go. Also,
        # if count is already in a register, we're good to go by just using
        # that register for the count. (Because we require the count be 32-
        # or 64-bit, we know the full register stores exactly the value of
        # count).
        if (isinstance(spotmap[self.count], LiteralSpot) or
             isinstance(spotmap[self.count], RegSpot)):
            return spotmap[self.base].shift(self.chunk, spotmap[self.count])

        # Otherwise, move count to a register.
        r = get_reg([], [spotmap[self.val]] + self._used_regs)
        self._used_regs.append(r)

        count_size = self.count.ctype.size
        #asm_code.add(asm_cmds.Mov(r, spotmap[self.count], count_size))
        self.move(spotmap[self.count], r, asm_code)

        return spotmap[self.base].shift(self.chunk, r)

    def get_reg_spot(self, reg_val, spotmap, get_reg):
        """Get a register or literal spot for self.reg_val."""

        if (isinstance(spotmap[reg_val], LiteralSpot) or
             isinstance(spotmap[reg_val], RegSpot)):
            return spotmap[reg_val]

        val_spot = get_reg([], [spotmap[self.count]] + self._used_regs)
        self._used_regs.append(val_spot)
        return val_spot


class SetRel(_RelCommand):
    """Sets value relative to given object.

    val - ILValue representing the value to set at given location.

    base - ILValue representing the base object. Note this is the base
    object itself, not the address of the base object.

    chunk - A Python integer representing the size of each chunk of offset
    (see below for a more clear explanation)

    count - If provided, a 64-bit integral ILValue representing the
    number of chunks of offset. If this value is provided, then `chunk`
    must be in {1, 2, 4, 8}.

    In summary, if `count` is provided, then the address of the object
    represented by this LValue is:

        &base + chunk * count

    and if `count` is not provided, the address is just

        &base + chunk
    """

    def __init__(self, val, base, chunk=0, count=None):  # noqa D102
        super().__init__(val, base, chunk, count)
        self.val = val

    def inputs(self):  # noqa D102
        if self.count:
            return [self.val, self.base, self.count]
        else:
            return [self.base, self.val]

    def outputs(self):  # noqa D102
        return []

    def references(self):  # noqa D102
        return {None: [self.base]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102
        if not isinstance(spotmap[self.base], MemSpot):
            raise NotImplementedError("expected base in memory spot")

        rel_spot = self.get_rel_spot(spotmap, get_reg, asm_code)
        reg = self.get_reg_spot(self.val, spotmap, get_reg)

        val_size = self.val.ctype.size
        #self.move_data(rel_spot, spotmap[self.val], val_size, reg, asm_code)
        self.move(spotmap[self.val], rel_spot, asm_code)


class AddrRel(_RelCommand):
    """Gets the address of a location relative to a given object.

    For further documentation, see SetRel.

    """
    def __init__(self, output, base, chunk=0, count=None):  # noqa D102
        super().__init__(output, base, chunk, count)
        self.output = output

    def inputs(self):  # noqa D102
        return [self.base, self.count] if self.count else [self.base]

    def outputs(self):  # noqa D102
        return [self.output]

    def references(self):  # noqa D102
        return {self.output: [self.base]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102
        if not isinstance(spotmap[self.base], MemSpot):
            raise NotImplementedError("expected base in memory spot")

        rel_spot = self.get_rel_spot(spotmap, get_reg, asm_code)
        out_spot = self.get_reg_spot(self.output, spotmap, get_reg)
        asm_code.add(asm_cmds.Lea(out_spot, rel_spot))

        if out_spot != spotmap[self.output]:
            #asm_code.add(asm_cmds.Mov(spotmap[self.output], out_spot, 1))
            self.move(out_spot, spotmap[self.output], asm_code)


class ReadRel(_RelCommand):
    """Reads the value at a location relative to a given object.

    For further documentation, see SetRel.

    """

    def __init__(self, output, base, chunk=0, count=None):  # noqa D102
        super().__init__(output, base, chunk, count)
        self.output = output

    def inputs(self):  # noqa D102
        return [self.base, self.count] if self.count else [self.base]

    def outputs(self):  # noqa D102
        return [self.output]

    def references(self):  # noqa D102
        return {None: [self.base]}

    def make_asm(self, spotmap, home_spots, get_reg, asm_code):  # noqa D102
        if not isinstance(spotmap[self.base], MemSpot):
            raise NotImplementedError("expected base in memory spot")

        rel_spot = self.get_rel_spot(spotmap, get_reg, asm_code)
        reg = self.get_reg_spot(self.output, spotmap, get_reg)

        out_size = self.output.ctype.size
        #self.move_data(spotmap[self.output], rel_spot, out_size, reg, asm_code)
        self.move(rel_spot, spotmap[self.output], asm_code)
