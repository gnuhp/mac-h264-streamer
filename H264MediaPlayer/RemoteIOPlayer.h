//
//  RemoteIOPlayer.h
//  AiBallRecorder
//
//  Created by NxComm on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioUnit/AudioUnit.h>

//#import "PublicDefine.h"
#import "InMemoryAudioFile.h"

@interface RemoteIOPlayer : NSObject 
{
    
    float sampleRate; 
    int channels; 
    
	InMemoryAudioFile *inMemoryAudioFile;	
	InMemoryAudioFile *recordedAudioFile;

	BOOL recordEnabled; 
	
    BOOL recording_now; 
	BOOL play_now;
    
    AudioComponentInstance audioUnit;
    AudioStreamBasicDescription audioFormat;
    AudioStreamBasicDescription audioFormatR;
    


}

//@property (nonatomic, retain)  AudioStreamBasicDescription audioFormat;
@property (nonatomic)  AudioStreamBasicDescription audioFormatR;
@property (nonatomic) AudioComponentInstance audioUnit;

@property (nonatomic, retain) InMemoryAudioFile *inMemoryAudioFile;

@property (nonatomic, retain) InMemoryAudioFile *recordedAudioFile;
@property (nonatomic) BOOL recording_now, play_now, recordEnabled;
@property (nonatomic) int  channels;
@property (nonatomic) float sampleRate;

-(OSStatus)start;
-(OSStatus)stop;
-(void)cleanUp;
-(void)intialiseAudio;

#if DBG_AUDIO
//DBG:
FILE* fp;
#endif 
@end
