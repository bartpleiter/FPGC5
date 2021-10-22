cdef class ErrorCollector:

    cdef public list issues

    # using cdef for speed is useless, but it is a good test
    cdef bint _ok(self)

error_collector = ErrorCollector()

cdef class Position:
   
    cdef public str file
    cdef public int line
    cdef public int col
    cdef public str full_line

cdef class Range:
    
    cdef public Position start
    cdef public Position end

cdef class CompilerError(Exception):
   
    cdef public str descrip
    cdef public Range range
    cdef public bint warning
