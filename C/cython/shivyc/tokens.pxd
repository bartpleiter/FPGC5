from shivyc.errors cimport Range

cdef class TokenKind:

    cdef public str text_repr


cdef class Token:

    cdef public TokenKind kind
    cdef public list content
    cdef public str rep
    cdef public Range r
