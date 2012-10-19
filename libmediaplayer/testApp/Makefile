#
CC=g++
#INCLUDES=`pkg-config --cflags libavcodec libavformat libavutil libswscale sdl`
INCLUDES= -I/home/phung/workspace_c/test_sdl/libmediaplayer/include 
#
# -Wno-unused is to get rid of lots of warnings from within OpenCV source.
# I can't really do much more about them.
#
CFLAGS=-Wall -ggdb $(INCLUDES) -Wno-write-strings -Wno-unused -D__STDC_CONSTANT_MACROS 

# NOTE: -lavcodec appears twice --- THIS IS COMPULSARY ---
#       -lavfilter before -lswresample --- also compulsary -- 
LDFLAGS= -L../bin -lmediaplayer -L/usr/local/lib \
		 -lavfilter -lswresample -lavcodec -lavformat -lavcodec -lavutil -lswscale \
		 -lm -lz -lpthread 
SRC= main.cpp 
OBJ= $(patsubst %.cpp,%.o,$(SRC))

TARGET= testApp
#
# This is here to prevent Make from deleting secondary files.
#
.SECONDARY:
	

#
# $< is the first dependency in the dependency list
# $@ is the target name
#
all:    $(TARGET)

dirs:
	mkdir -p obj
	mkdir -p bin

tags: *.c
	ctags *.c


bin/mediaplayer: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(INCLUDES) $(LDFLAGS)



%.o : %.cpp
	$(CC) $(CFLAGS) -c $< -o $@ 

$(TARGET) : $(OBJ)
	$(CC) -o $@  $^ $(CFLAGS) $(INCLUDES) $(LDFLAGS)

clean:
	rm $(TARGET)
	rm *.o
