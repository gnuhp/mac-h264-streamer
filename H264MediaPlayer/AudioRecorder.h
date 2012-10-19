//
//  rabotAudioRecoder.h
//  rabot
//
//  Created by Kelvin on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InMemoryAudioFile.h"
#import "RemoteIOPlayer.h"

//Ref: http://atastypixel.com/blog/using-remoteio-audio-unit/

@interface AudioRecorder : NSObject {
	
	RemoteIOPlayer *player;
	InMemoryAudioFile *inMemoryAudioFile;
	int iInitialFlag;
}

@property (nonatomic, retain) RemoteIOPlayer *player;
@property (nonatomic, retain) InMemoryAudioFile *inMemoryAudioFile;


- (void) startRecord;
- (void) stopRecord;


@end
