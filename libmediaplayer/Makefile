#
CC=g++
#INCLUDES=`pkg-config --cflags libavcodec libavformat libavutil libswscale sdl`
INCLUDES= -I./include 
#
# -Wno-unused is to get rid of lots of warnings from within OpenCV source.
# I can't really do much more about them.
#
CFLAGS=-Wall -ggdb $(INCLUDES) -Wno-write-strings -Wno-unused -D__STDC_CONSTANT_MACROS \
	   -DCONFIG_AVFILTER #-DCONFIG_AVDEVICE 

LDFLAGS= -L/usr/local/lib -lswresample -lavfilter -lavcodec -lavformat -lavutil -lswscale \
		 -lm -lz -lpthread #-lpostproc 

SRC= main.cpp  packetqueue.cpp \
    output.cpp \
    mediaplayer.cpp \
    decoder.cpp \
    decoder_audio.cpp \
    decoder_video.cpp \
    thread.cpp

OBJ= $(patsubst %.cpp,obj/%.o,$(SRC))

TARGET= bin/libmediaplayer.a
#
# This is here to prevent Make from deleting secondary files.
#
.SECONDARY:
	

#
# $< is the first dependency in the dependency list
# $@ is the target name
#
#all: dirs $(addprefix bin/, $(EXE)) tags
all: dirs  $(OBJ)   $(TARGET)

dirs:
	mkdir -p obj
	mkdir -p bin

tags: *.c
	ctags *.c


bin/mediaplayer: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS) $(INCLUDES) $(LDFLAGS)



obj/%.o : %.cpp
	$(CC) $(CFLAGS) -c $< -o $@ 

$(TARGET) : $(OBJ)
	ar rcs $(TARGET) $(OBJ)

clean:
	rm -f obj/*
	rm -f bin/*
	rm -f tags
