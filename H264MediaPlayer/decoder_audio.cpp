//#include <android/log.h>
#include "decoder_audio.h"

#define TAG "FFMpegAudioDecoder"

#define __android_log_print(ANDROID_LOG_INFO, TAG, ...) printf(__VA_ARGS__)
DecoderAudio::DecoderAudio(AVStream* stream) : IDecoder(stream)
{
}

DecoderAudio::~DecoderAudio()
{
}



bool DecoderAudio::prepare()
{
    mSamplesSize = AVCODEC_MAX_AUDIO_FRAME_SIZE;
    mSamples = (int16_t *) av_malloc(mSamplesSize);
    if(mSamples == NULL) {
    	return false;
    }
 
    
    if(encodeToPcm_init() <0)
    {
        return false; 
    }
    
    return true;
}

bool DecoderAudio::process(AVPacket *packet)
{
    int size = 0;
    
    int got_frame; 
    AVFrame mFrame; 
    int ret = avcodec_decode_audio4(mStream->codec,&mFrame, &got_frame, packet); 
    
    
    AVCodecContext *avctx = mStream->codec;
    
    if (ret >= 0 && got_frame) {
        int ch, plane_size;
        int planar = av_sample_fmt_is_planar(avctx->sample_fmt);
        int data_size = av_samples_get_buffer_size(&plane_size, avctx->channels,
                                                   mFrame.nb_samples,
                                                   avctx->sample_fmt, 1);
        if (mSamplesSize < data_size) {
            __android_log_print(ANDROID_LOG_INFO, TAG,"output buffer size is too small for "
                                "the current frame (%d < %d)\n", mSamplesSize, data_size);
            return AVERROR(EINVAL);
        }
        
        memcpy(mSamples, mFrame.extended_data[0], plane_size);
        
        if (planar && avctx->channels > 1) {
            uint8_t *out = ((uint8_t *)mSamples) + plane_size;
            for (ch = 1; ch < avctx->channels; ch++) {
                memcpy(out, mFrame.extended_data[ch], plane_size);
                out += plane_size;
            }
        }
        size = data_size;
        
        //call handler for posting buffer to os audio driver
        if (avctx->codec->id == CODEC_ID_PCM_S16LE)
        {
           onDecode(mSamples, size);
        }
        else
        {
            encodeToPcm(mSamples, size); 
        }
        
    }
    else
    {
        size = 0;
    }
    
    return true;
}

bool DecoderAudio::decode(void* ptr)
{
    AVPacket        pPacket;

    __android_log_print(ANDROID_LOG_INFO, TAG, "decoding audio");

    while(mRunning)
    {
        if(mQueue->get(&pPacket, true) < 0)
        {
            mRunning = false;
            continue;
        }
        if(!process(&pPacket))
        {
           // mRunning = false;
             //continue;
        }
        // Free the packet that was allocated by av_read_frame
        av_free_packet(&pPacket);
    }

    __android_log_print(ANDROID_LOG_INFO, TAG, "decoding audio ended");

    // Free audio samples buffer
    av_free(mSamples);
    return true;
}


//Prepare the context & codec for PCM encoding
int DecoderAudio::encodeToPcm_init()
{
    AVCodecContext *avctx = mStream->codec;
    
    pcm_codec = NULL; 
    pcm_c = NULL; 
    
    /* find the PCM_ encoder */
    pcm_codec = avcodec_find_encoder(CODEC_ID_PCM_S16LE);
    if (!pcm_codec) {
        __android_log_print(ANDROID_LOG_INFO, TAG, "Encode to pcm init: cant'find pcm codec ");
        return -1 ; 
    }   
    
    pcm_c = avcodec_alloc_context3(pcm_codec);
    
    /* put sample parameters */
    pcm_c->sample_rate = avctx->sample_rate;
    pcm_c->channels = avctx->channels ;
    pcm_c->sample_fmt = AV_SAMPLE_FMT_S16;
    
    /* open it */
    if (avcodec_open(pcm_c, pcm_codec) < 0) {
        __android_log_print(ANDROID_LOG_INFO, TAG, "Encode error open context ");
        return -2; 
        
    }
    
    
    return 0; 
    
}

void DecoderAudio::encodeToPcm(int16_t * adpcm_buffer, int len)
{
    int out_size = -1; 
    
    int outbuf_size = len;
    uint8_t *  outbuf = (uint8_t *) malloc(outbuf_size);
    
    
    //__android_log_print(ANDROID_LOG_INFO, TAG, "encode 01\n" );
    
    out_size = avcodec_encode_audio(pcm_c, outbuf, outbuf_size, adpcm_buffer); 
    
    if (outbuf_size >0)
    {
        onDecode( (int16_t*)outbuf, out_size);
    }
    
    
    free(outbuf); 
}
