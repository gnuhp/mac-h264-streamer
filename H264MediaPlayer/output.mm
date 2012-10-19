#include <stdio.h>
#include "output.h"


extern "C" {
    
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
    
} // end of extern C


#define LOG_TAG "FFMpegOutput"
#define LOG_LEVEL 10
//#define LOGI(level, ...) if (level <= LOG_LEVEL) {__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__);}
#define LOGI(level, ...) if (level <= LOG_LEVEL) {printf(__VA_ARGS__);}

//-------------------- Audio driver --------------------

PCMPlayer  * Output::pcmPlayer; 
UIImageView * Output::videoView; 
void * Output::pictureRGB;

int Output::AudioDriver_register()
{

    LOGI(9,"Output::AudioDriver_register"); 

   
   
	return 0 ; // not supported 
}

int Output::AudioDriver_unregister()
{
	//return AndroidAudioTrack_unregister();

    LOGI(9,"Output::AudioDriver_unregister"); 
    
    if (pcmPlayer != nil)
	{
		/* kill the audio player */
		[[pcmPlayer player] setPlay_now:FALSE];
		[pcmPlayer Stop];
		[pcmPlayer release];
		pcmPlayer = nil;
	}

    
    return 0; 
}

int Output::AudioDriver_start()
{

    return 0; 
}

int Output::AudioDriver_set(int streamType,
							uint32_t sampleRate,
							int format,
							int channels)
{
    LOGI(9,"Output::AudioDriver_set: str Type: %d, sampleRate: %d, format:%d, channels:%d",
            streamType, sampleRate,format,channels);
    pcmPlayer = [[PCMPlayer alloc] initWithSampleRate:(float)sampleRate andChannels:channels];
   
    [[pcmPlayer player] setPlay_now:FALSE];
    [pcmPlayer Play:FALSE];

    return 0; 
}

int Output::AudioDriver_flush()
{


    //LOGI(9,"Output::AudioDriver_flush"); 
    return 0; 
}

int Output::AudioDriver_stop()
{
    
//    LOGI(9,"Output::AudioDriver_stop"); 
    return 0; 
}

int Output::AudioDriver_reload()
{

    //LOGI(9,"Output::AudioDriver_reload"); 
    return 0; 
}

int Output::AudioDriver_write(void *buffer, int buffer_size)
{

    
    //Start play back 
	[[pcmPlayer player] setPlay_now:TRUE];
	[pcmPlayer WritePCM:(unsigned char *)buffer length:buffer_size];
   
    return buffer_size; 
}

//-------------------- Video driver --------------------

int Output::VideoDriver_register(UIImageView * _vview)
{
    LOGI(9,"Output::VideoDriver_register"); 

    videoView = _vview; 
    
    return 0; 
}


int Output::VideoDriver_unregister()
{

    LOGI(9,"Output::VideoDriver_unregister \n"); 

    videoView = nil; 
    
    return 0; 
}

int Output::VideoDriver_getPixels(int width, int height, void** pixels_out)
{

    LOGI(9,"Output::VideoDriver_getPixels: w:%d, h:%d\n", width, height); 
    //pictureRGB;
    int size;
    
    // Determine required buffer size and allocate buffer
    size = avpicture_get_size(PIX_FMT, width, height);
    
    //size = avpicture_get_size(PIX_FMT_RGB24, width, height);
    pictureRGB  = av_malloc(size);
    if (!pictureRGB)
        return -1;
    
    
    *pixels_out = pictureRGB; 
    
   
    
    return 0; 
}

UIImage *  Output::convertBitmapRGBA8ToUIImage (unsigned char * buffer, int width , int height )
{
    
    
	size_t bufferLength = width * height * sizeof(uint32_t);
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);
	size_t bitsPerComponent = 8;// RGB 32
	size_t bitsPerPixel = 32;
	size_t bytesPerRow = sizeof(uint32_t) * width;
    
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    //CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateWithName();
	if(colorSpaceRef == NULL) {
		NSLog(@"Error allocating color space");
		CGDataProviderRelease(provider);
		return nil;
	}
    
	//CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault ;
   	//CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault |  kCGImageAlphaNoneSkipFirst;
    
    //kCGBitmapByteOrder32Little OR kCGBitmapByteOrder32Big
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little|kCGImageAlphaNoneSkipFirst;

    
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
	CGImageRef iref = CGImageCreate(width, 
                                    height, 
                                    bitsPerComponent, 
                                    bitsPerPixel, 
                                    bytesPerRow,
                                    colorSpaceRef, 
                                    bitmapInfo, 
                                    provider,	// data provider
                                    NULL,		// decode
                                    YES,			// should interpolate
                                    renderingIntent);
    
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
    
	if(pixels == NULL) {
		NSLog(@"Error: Memory not allocated for bitmap");
		CGDataProviderRelease(provider);
		CGColorSpaceRelease(colorSpaceRef);
		CGImageRelease(iref);		
		return nil;
	}
    
	CGContextRef context = CGBitmapContextCreate(pixels, 
                                                 width, 
                                                 height, 
                                                 bitsPerComponent, 
                                                 bytesPerRow, 
                                                 colorSpaceRef, 
                                                 bitmapInfo); 
    
	if(context == NULL) {
		NSLog(@"Error context not created");
		free(pixels);
	}
    
	UIImage *image = nil;
	if(context) {
        
		CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), iref);
        
		CGImageRef imageRef = CGBitmapContextCreateImage(context);
        
		// Support both iPad 3.2 and iPhone 4 Retina displays with the correct scale
		if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
			float scale = [[UIScreen mainScreen] scale];
			image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
		} else {
			image = [UIImage imageWithCGImage:imageRef];
		}
        
		CGImageRelease(imageRef);	
		CGContextRelease(context);	
	}
    
	CGColorSpaceRelease(colorSpaceRef);
	CGImageRelease(iref);
	CGDataProviderRelease(provider);
    
	if(pixels) {
		free(pixels);
	}	
	return image;
}



int Output::VideoDriver_updateSurface()
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    //copy content of pictureRGB to videoView

    
    if (videoView != nil)
    {
        UIImage * img = Output::convertBitmapRGBA8ToUIImage((unsigned char *) pictureRGB, 640, 480);

        [videoView performSelectorOnMainThread:@selector(setImage:)
                                    withObject:img
                                 waitUntilDone:YES];

    }
       
    [pool drain];
    
    return 0; 
}
