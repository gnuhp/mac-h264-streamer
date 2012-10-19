//#include <android/log.h>
#include "decoder.h"

#define TAG "FFMpegIDecoder"


#define __android_log_print(ANDROID_LOG_INFO, TAG, ...) printf(__VA_ARGS__)

IDecoder::IDecoder(AVStream* stream)
{
	mQueue = new PacketQueue();
	mStream = stream;
}

IDecoder::~IDecoder()
{
	if(mRunning)
    {
        stop();
    }
	free(mQueue);
	avcodec_close(mStream->codec);
}

void IDecoder::enqueue(AVPacket* packet)
{
	mQueue->put(packet);
}

int IDecoder::packets()
{
	return mQueue->size();
}

void IDecoder::stop()
{
    mQueue->abort();
    __android_log_print(ANDROID_LOG_INFO, TAG, "Decoder STOP \n");
    int ret = -1;
    if((ret = wait()) != 0) {
        __android_log_print(ANDROID_LOG_ERROR, TAG, "Couldn't cancel IDecoder: %i\n", ret);
        return;
    }
}

void IDecoder::handleRun(void* ptr)
{
	if(!prepare())
    {
		__android_log_print(ANDROID_LOG_INFO, TAG, "Couldn't prepare decoder");
        return;
    }
	decode(ptr);
}

bool IDecoder::prepare()
{
    return false;
}

bool IDecoder::process(AVPacket *packet)
{
	return false;
}

bool IDecoder::decode(void* ptr)
{
    return false;
}
