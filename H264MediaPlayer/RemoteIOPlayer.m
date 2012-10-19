//
//  RemoteIOPlayer.m
//  AiBallRecorder
//
//  Created by NxComm on 1/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//20110801: phung: add AudioInput recording part 

#import "RemoteIOPlayer.h"
#include <AudioUnit/AudioUnit.h>

#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVFoundation.h>

#define kOutputBus 0
#define kInputBus 1

@implementation RemoteIOPlayer

@synthesize inMemoryAudioFile;
@synthesize recordedAudioFile;

@synthesize recording_now, play_now;
@synthesize  recordEnabled;
@synthesize audioFormatR;
@synthesize  audioUnit ;

@synthesize sampleRate, channels;

-(id) init
{
    self = [super init  ]; 
    
    
    recordEnabled = FALSE;
    recording_now = FALSE; 
    play_now = FALSE;
    sampleRate = 8000.00; 
    channels = 2; 
    
    return self; 
}

-(OSStatus)start{
	
	OSStatus status = AudioOutputUnitStart(audioUnit);
	return status;
}

-(OSStatus)stop{
	OSStatus status = AudioOutputUnitStop(audioUnit);
	return status;
}

-(void)cleanUp{
#if DBG_AUDIO
	 fclose(fp);
#endif 

	AudioUnitUninitialize(audioUnit);
}


/* Parameters on entry to this function are :-
 
 *inRefCon - used to store whatever you want, can use it to pass in a reference to an objectiveC class
			 i do this below to get at the InMemoryAudioFile object, the line below :
				callbackStruct.inputProcRefCon = self;
			 in the initialiseAudio method sets this to "self" (i.e. this instantiation of RemoteIOPlayer).
			 This is a way to bridge between objectiveC and the straight C callback mechanism, another way
			 would be to use an "evil" global variable by just specifying one in theis file and setting it
			 to point to inMemoryAudiofile whenever it is set.
 
 *inTimeStamp - the sample time stamp, can use it to find out sample time (the sound card time), or the host time
 
 inBusnumber - the audio bus number, we are only using 1 so it is always 0 
 
 inNumberFrames - the number of frames we need to fill. In this example, because of the way audioformat is
				  initialised below, a frame is a 32 bit number, comprised of two signed 16 bit samples.
 
 *ioData - holds information about the number of audio buffers we need to fill as well as the audio buffers themselves */
static OSStatus playbackCallback(void *inRefCon, 
								 AudioUnitRenderActionFlags *ioActionFlags, 
								 const AudioTimeStamp *inTimeStamp, 
								 UInt32 inBusNumber, 
								 UInt32 inNumberFrames, 
								 AudioBufferList *ioData) {  
	

	
	//get a copy of the objectiveC class "self" we need this to get the next sample to fill the buffer
	RemoteIOPlayer *remoteIOplayer = (RemoteIOPlayer *)inRefCon;
	
	
	if ( (remoteIOplayer.inMemoryAudioFile == nil)  ||
        (remoteIOplayer.play_now == FALSE) )
	{
		
		return noErr;
	}
	//NSLog(@"player ref  %p #buffs %d" ,remoteIOplayer, ioData->mNumberBuffers);
	
	//loop through all the buffers that need to be filled
	for (int i = 0 ; i < ioData->mNumberBuffers; i++){
		//get the buffer to be filled
		AudioBuffer buffer = ioData->mBuffers[i];
		
		//if needed we can get the number of bytes that will fill the buffer using
		// int numberOfSamples = ioData->mBuffers[i].mDataByteSize;
		
		//get the buffer and point to it as an UInt32 (as we will be filling it with 32 bit samples)
		//if we wanted we could grab it as a 16 bit and put in the samples for left and right seperately
		//but the loop below would be for(j = 0; j < inNumberFrames * 2; j++) as each frame is a 32 bit number
		UInt32 *frameBuffer = buffer.mData;
		
		
		//NSLog(@"playback frames %d mDataBye:%d" ,inNumberFrames, buffer.mDataByteSize);
		
		//loop through the buffer and fill the frames
		for (int j = 0; j < inNumberFrames; j++){
			// get NextPacket returns a 32 bit value, one frame.
			frameBuffer[j] = [[remoteIOplayer inMemoryAudioFile] getNextPacket];
			
#if DBG_AUDIO
			/* DBG : save this data to a file to playback later */
			fwrite(&frameBuffer[j],4, 1, fp);
#endif 	
		}
	}
	//dodgy return :)
    return noErr;
}

#ifdef IRABOT_AUDIO_RECORDING_SUPPORT
static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) {
	
		
	RemoteIOPlayer *remoteIOplayer = (RemoteIOPlayer *)inRefCon;

    //NSLog(@"recording ref  %p" ,remoteIOplayer);
    
	if ( (remoteIOplayer.recording_now == FALSE) || 
		 (remoteIOplayer.recordedAudioFile == nil) )
	{
		
		return noErr;
	}

	
    AudioBufferList *bufferList; 
	
	//bufferList = (AudioBufferList *) malloc ( sizeof (AudioBufferList));
	
	//it works
	bufferList = (AudioBufferList *) malloc ( sizeof (AudioBufferList)+ sizeof(AudioBuffer));
	
	bufferList->mNumberBuffers = 1;
	bufferList->mBuffers[0].mNumberChannels = 1;
	bufferList->mBuffers[0].mDataByteSize = inNumberFrames * remoteIOplayer.audioFormatR.mBytesPerFrame	;
	bufferList->mBuffers[0].mData = malloc(inNumberFrames * remoteIOplayer.audioFormatR.mBytesPerFrame);
	

	memset(bufferList->mBuffers[0].mData, 0, inNumberFrames * remoteIOplayer.audioFormatR.mBytesPerFrame );
	
	
    // Then:
    // Obtain recorded samples
	
    OSStatus status;
	
    status = AudioUnitRender(remoteIOplayer.audioUnit, 
                             ioActionFlags, 
                             inTimeStamp, 
                             inBusNumber, 
                             inNumberFrames, 
                             bufferList);
	


	///IT WORKS !!!
	[[remoteIOplayer recordedAudioFile] storePCMFrames_byte: bufferList->mBuffers[0].mData 
											   withLen: (inNumberFrames*remoteIOplayer.audioFormatR.mBytesPerFrame) ];

	
#if 0 //DBG_AUDIO
	/* DBG : save this data to a file to playback later */
	fwrite(bufferList->mBuffers[0].mData, inNumberFrames*2, 1, fp);
#endif 	
	
	free(bufferList->mBuffers[0].mData);
	free(bufferList);

    return noErr;
}
#endif //#ifdef IRABOT_AUDIO_RECORDING_SUPPORT


// Below code is a cut down version (for output only) of the code written by
// Micheal "Code Fighter" Tyson (punch on Mike)
// See http://michael.tyson.id.au/2008/11/04/using-remoteio-audio-unit/ for details
-(void)intialiseAudio
{
	OSStatus status;
	
	
	// Describe audio component
	AudioComponentDescription desc;
	desc.componentType = kAudioUnitType_Output;
	desc.componentSubType = kAudioUnitSubType_RemoteIO;
	desc.componentFlags = 0;
	desc.componentFlagsMask = 0;
	desc.componentManufacturer = kAudioUnitManufacturer_Apple;
	
	// Get component
	AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
	
	// Get audio units
	status = AudioComponentInstanceNew(inputComponent, &audioUnit);
	
	// Enable IO for recording
	UInt32 flag = 1;
	
#ifdef IRABOT_AUDIO_RECORDING_SUPPORT
    if (self.recordEnabled == TRUE)
    {
        status = AudioUnitSetProperty(audioUnit, 
                                      kAudioOutputUnitProperty_EnableIO, 
                                      kAudioUnitScope_Input, 
                                      kInputBus,
                                      &flag, 
                                      sizeof(flag));
    }
#endif

	//disable playback 
	//flag = 0;
	
	// Enable IO for playback
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioOutputUnitProperty_EnableIO, 
								  kAudioUnitScope_Output, 
								  kOutputBus,
								  &flag, 
								  sizeof(flag));
	
	
	
	//Apply format
#ifdef IRABOT_AUDIO_RECORDING_SUPPORT
	if (self.recordEnabled == TRUE)
    {
        // Describe format
        audioFormatR.mSampleRate		= 8000.00; 
        audioFormatR.mFormatID			= kAudioFormatLinearPCM;
        audioFormatR.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked ;
        audioFormatR.mFramesPerPacket	= 1;
        audioFormatR.mChannelsPerFrame	= 1;
        audioFormatR.mBitsPerChannel	= 16;
        audioFormatR.mBytesPerPacket	= 2;
        audioFormatR.mBytesPerFrame		= 2;
        audioFormatR.mReserved		= 0;
        
        status = AudioUnitSetProperty(audioUnit, 
                                      kAudioUnitProperty_StreamFormat, 
                                      kAudioUnitScope_Output, 
                                      kInputBus, 
                                      &audioFormatR, 
                                      sizeof(audioFormatR));
        
        //NSLog(@"1 ret: %d", status);
        
    }
#endif 
	
	// Describe format
	audioFormat.mSampleRate			= sampleRate;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 2;
	audioFormat.mBitsPerChannel		= 16;
	audioFormat.mBytesPerPacket		= 4;
	audioFormat.mBytesPerFrame		= 4;
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_StreamFormat, 
								  kAudioUnitScope_Input, 
								  kOutputBus, 
								  &audioFormat, 
								  sizeof(audioFormat));
	 
	

	// Set input callback
	AURenderCallbackStruct callbackStruct;
#ifdef IRABOT_AUDIO_RECORDING_SUPPORT
    if (self.recordEnabled == TRUE)
    {
        callbackStruct.inputProc = recordingCallback;
        callbackStruct.inputProcRefCon = self;
        status = AudioUnitSetProperty(audioUnit, 
                                      kAudioOutputUnitProperty_SetInputCallback, 
                                      kAudioUnitScope_Global, 
                                      kInputBus, 
                                      &callbackStruct, 
                                      sizeof(callbackStruct));
	}
#endif
	
	// Set up the playback  callback
	//AURenderCallbackStruct callbackStruct;
	callbackStruct.inputProc = playbackCallback;
	//set the reference to "self" this becomes *inRefCon in the playback callback
	callbackStruct.inputProcRefCon = self;
	
	status = AudioUnitSetProperty(audioUnit, 
								  kAudioUnitProperty_SetRenderCallback, 
								  kAudioUnitScope_Global, 
								  kOutputBus,
								  &callbackStruct, 
								  sizeof(callbackStruct));
	
#ifdef IRABOT_AUDIO_RECORDING_SUPPORT
    if (self.recordEnabled == TRUE)
    {
        // Disable buffer allocation for the recorder
        flag = 0;
        status = AudioUnitSetProperty(audioUnit, 
                                      kAudioUnitProperty_ShouldAllocateBuffer,
                                      kAudioUnitScope_Output, 
                                      kInputBus,
                                      &flag, 
                                      sizeof(flag));
    }
#endif 
	
	
	AudioSessionInitialize(NULL, NULL, NULL, nil);
	AudioSessionSetActive(true);
	

	UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord ;    
	/* for Iphone we need to do this to route the audio to speaker */
	status= AudioSessionSetProperty (
							 kAudioSessionProperty_AudioCategory,                        
							 sizeof (sessionCategory),                                   
							 &sessionCategory                                           
							 );
	//NSLog(@"Error: %d", status);
	
	UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker; 
	status = AudioSessionSetProperty (
                                      kAudioSessionProperty_OverrideAudioRoute, 
                                      sizeof (audioRouteOverride), 
                                      &audioRouteOverride);
	//NSLog(@"Error: %d", status);
	
    
	// Initialise
	status = AudioUnitInitialize(audioUnit);
	//
#if DBG_AUDIO

	//DBG : create a file 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    
    NSString *myFilePath = [documentsDirectoryPath stringByAppendingPathComponent:@"data8k_aa.pcm"];
	
	NSLog(@"file: %@", myFilePath);
	
	// just return here
	UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"filepath" 
													 message:myFilePath 
													delegate:self
										   cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
	[alert show];
	[alert release];
    
    fp = fopen([myFilePath cString], "wb");
    
#endif
}






@end
