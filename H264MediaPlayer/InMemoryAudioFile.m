//
//  InMemoryAudioFile.m
//  AiBallRecorder
//
//  Created by NxComm on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InMemoryAudioFile.h"

@implementation InMemoryAudioFile

//overide init method
- (id)init 
{ 
    [super init]; 
	iAudioBuffer = [[NSMutableData alloc] init];

	return self;
}




- (void)dealloc {
	//release the AudioBuffer
	[iAudioBuffer release];
    [super dealloc];
}

-(void)reset{
	iReadPosition = 0;
}

-(int) length
{
	return [iAudioBuffer length];
	
}

#pragma mark ----------
#pragma mark Playback  functions 

//gets the next packet from the buffer, if we have reached the end of the buffer return 0
-(UInt32)getNextPacket{	
	@synchronized(iAudioBuffer) {
		// if we reach the end of buffer, return 0
		if(iReadPosition >= [iAudioBuffer length] - 1) {
			return 0;
		}
		
		// truncate the buffer to discard played data
		if(iReadPosition > 16 * 1024) {
			NSRange range = {0, iReadPosition};
			[iAudioBuffer replaceBytesInRange:range withBytes:NULL length:0];
			iReadPosition = 0;
		}
		
		short* ptr = [iAudioBuffer bytes];
		short val = ptr[iReadPosition/2];	
		
		iReadPosition += 2;
		
		/***
		{
		 // Amplify the audio
		 long processed_val;
		 
		 processed_val = val;
		 processed_val = processed_val<< 2; // 4x
		 
		 if (processed_val <= 32767 && processed_val >= -32768) {
		 val = processed_val;
		 } else if (processed_val > 32767) {
		 val = 32767;
		 } else if (processed_val < -32768) {
		 val = -32768;
		 }
			
		}
		 ***/	
		
		
		UInt32 ret = (val | (val << 16));
		
		//NSLog(@"%x ", val);
		return ret;
	}
}


-(void) writePCM:(unsigned char*)pcm length:(int)length
{
	
	@synchronized(iAudioBuffer) {
		[iAudioBuffer appendBytes:pcm length:length];
	}
}

#pragma mark ----------
#pragma mark Recording functions 


- (void) storePCMFrames_byte : (void *) frame_buffers withLen:(int) len_in_byte
{
	
	@synchronized(iAudioBuffer) {
		
		[iAudioBuffer appendBytes:frame_buffers length:len_in_byte];
	}
	
	
}


/* Return 1 1010 Byte-Block to sender
   caller can then encode this PCM data to ADPCM for usage 
 
   NOTE: caller has to check len of the out_buffer before proceeding
         since if there is no data, len will be set to 0
 */

//#define ONE_BLOCK 1010

- (int) readBytesPCM: (NSMutableData* ) out_buffer withLength: (int) len
{
	
	int buflen = 0;
	
	if (out_buffer == nil)
	{
		NSLog(@"out_buffer not initialized!!!");
		return -1;
	}
	
	@synchronized(iAudioBuffer) {
		/*  we return whatever we have
		*/
		if( ([iAudioBuffer length] - iReadPosition)  < len) 
		{
			buflen  = [iAudioBuffer length] - iReadPosition;
			
		}
		else 
		{
			buflen = len;
		}

		//NSLog(@">>>: %d", ([iAudioBuffer length] - iReadPosition));
	
		

		//TODO:truncate the buffer to discard played data
		if(iReadPosition > 16 * 1024) { //1s data
			NSRange range = {0, iReadPosition};
			[iAudioBuffer replaceBytesInRange:range withBytes:NULL length:0];
			iReadPosition = 0;
		}
		
		NSRange buffer_range = {0, buflen};
		NSRange iAudioBuffer_range = {iReadPosition, buflen};
		
		[out_buffer setLength:buflen];
		//zeroing it
		[out_buffer resetBytesInRange:buffer_range];

		/* copy data 
		 */
		[out_buffer replaceBytesInRange:buffer_range 
							  withBytes:[[iAudioBuffer subdataWithRange:iAudioBuffer_range] bytes]];
		
		/* point to the first unread data bytes */
		iReadPosition += buflen;
		//NSLog(@"left: %d returnlen:%d",[iAudioBuffer length] - iReadPosition, buflen);

	}
	
out:
	return buflen;

	
}

- (void) flush
{
	int current_len = [iAudioBuffer length];
	NSRange whole_buff = {0, current_len};
	[iAudioBuffer replaceBytesInRange:whole_buff withBytes:NULL length:0];
	iReadPosition = 0;
}

@end
