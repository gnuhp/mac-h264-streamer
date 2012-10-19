//
//  InMemoryAudioFile.h
//  AiBallRecorder
//
//  Created by NxComm on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioFile.h>
#include <sys/time.h>


// One buffer can only be used to store read OR write data but not BOTH

@interface InMemoryAudioFile : NSObject {
	int iReadPosition;

	
	NSMutableData* iAudioBuffer;
}

//Playback 
//gets the next packet from the buffer, returns -1 if we have reached the end of the buffer
-(UInt32)getNextPacket;
-(void) writePCM:(unsigned char*)pcm length:(int)length;

//Record
- (void) storePCMFrames_byte : (void *) frame_buffers withLen:(int) len_in_byte;

- (void) storePCMFrames : (UInt16*) frame_buffers withLen:(int) len_in_uint16;

- (int) readBytesPCM: (NSMutableData* ) out_buffer withLength: (int) len;

//reset the index to the start of the file
-(void)reset;
-(int)length;
-(void) flush;


@end
