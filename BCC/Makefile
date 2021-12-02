# the compiler to compile SmallerC with
CC = gcc

# compiler flags:
#  -g    adds debugging information to the executable file
#  -Wall turns on most, but not all, compiler warnings
CFLAGS  = 

# the build target executable:
SOURCE = bcc
TARGET = bccALWAYSRECOMPILE
TARGETNAME = bcc

all: $(TARGET)

$(TARGET): $(SOURCE).c
	$(CC) -o $(TARGETNAME) $(SOURCE).c $(CFLAGS)

clean:
	$(RM) $(TARGETNAME)
