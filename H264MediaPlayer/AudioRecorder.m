//
//  rabotAudioRecoder.m
//  rabot
//
//  Created by Kelvin on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioRecorder.h"


@implementation AudioRecorder
@synthesize inMemoryAudioFile;
@synthesize player;
- (id) init
{
	iInitialFlag = 1;
	//inMemoryAudioFile = [[InMemoryAudioFile alloc]init];
//	[inMemoryAudioFile reset];
	
	//iInitialFlag = 0;
    
    player = nil; 
    self = [super init]; 
	return self;
}


- (void)dealloc {
	if(inMemoryAudioFile != nil) {
		[inMemoryAudioFile release];
	}
    [player release];
	[super dealloc];
}

- (void) startRecord
{
	if(iInitialFlag == 1)
	{
		inMemoryAudioFile = [[InMemoryAudioFile alloc]init];
		[player setRecordedAudioFile:inMemoryAudioFile];
		
		iInitialFlag = 0;
	}
	[inMemoryAudioFile reset];
	
    if (self.player != nil)
    {
               
        [self.player setRecording_now:TRUE];
    }
}

- (void) stopRecord
{
	//Delete all data in buffer; 
	[inMemoryAudioFile flush];
	
    if (self.player != nil)
    {
        
        [self.player setRecording_now:FALSE];
    }
	
}

@end
