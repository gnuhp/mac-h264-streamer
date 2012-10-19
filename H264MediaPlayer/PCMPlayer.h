//
//  PCMPlayer.h
//  AiBallRecorder
//
//  Created by NxComm on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "PublicDefine.h"
#import "AudioRecorder.h"
#import "RemoteIOPlayer.h"


@class AudioRecorder;

@interface PCMPlayer : NSObject {
	int iReadyToPlay;

	RemoteIOPlayer *player;
	InMemoryAudioFile *inMemoryAudioFile;
	
	AudioRecorder * recorder;
}

@property (nonatomic, retain) RemoteIOPlayer *player;
@property (nonatomic, retain) AudioRecorder * recorder;
@property (nonatomic, retain) InMemoryAudioFile *inMemoryAudioFile;



- (id) initWithSampleRate:(float) sampleRate andChannels:(int) channel;

- (void) Play: (BOOL) recordEnabled;
//-(void) Play;
- (void) Stop;
- (void) WritePCM:(unsigned char*)pcm length:(int)length;




@end
