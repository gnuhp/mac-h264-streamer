#ifndef FFMPEG_OUTPUT_H
#define FFMPEG_OUTPUT_H

#include "Errors.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#import "PCMPlayer.h"



//#define PIX_FMT PIX_FMT_RGB565 //not work
//#define PIX_FMT PIX_FMT_RGB24 //not work

#define PIX_FMT PIX_FMT_RGB32 //work but -- the output video is blueish --

//#define PIX_FMT PIX_FMT_RGB32_1 // similar output


typedef unsigned int uint32_t; 
class Output
{
public:	
	static int					AudioDriver_register();
    static int					AudioDriver_set(int streamType,
												uint32_t sampleRate,
												int format,
												int channels);
    static int					AudioDriver_start();
    static int					AudioDriver_flush();
	static int					AudioDriver_stop();
    static int					AudioDriver_reload();
	static int					AudioDriver_write(void *buffer, int buffer_size);
	static int					AudioDriver_unregister();
	
	static int					VideoDriver_register(UIImageView * videoView);
    static int					VideoDriver_getPixels(int width, int height, void** pixels);
    static int					VideoDriver_updateSurface();
    static int					VideoDriver_unregister();
private:
    static  PCMPlayer * pcmPlayer;
    static UIImageView * videoView; 
    static void * pictureRGB; 
    
    /* credit: http://paulsolt.com/2010/09/ios-converting-uiimage-to-rgba8-bitmaps-and-back/ */
    static UIImage *  convertBitmapRGBA8ToUIImage (unsigned char * buffer, int width , int height );
};

#endif //FFMPEG_DECODER_H
