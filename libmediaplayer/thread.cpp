//#include <android/log.h>
#include "thread.h"
#include <stdio.h>

#define TAG "FFMpegThread"

#define __android_log_print(ANDROID_LOG_INFO, TAG, ...) printf(__VA_ARGS__)

Thread::Thread()
{
	pthread_mutex_init(&mLock, NULL);
	pthread_cond_init(&mCondition, NULL);
}

Thread::~Thread()
{
}

void Thread::start()
{
    handleRun(NULL);
}

void Thread::startAsync()
{
    pthread_create(&mThread, NULL, startThread, this);
}

int Thread::wait()
{
	if(!mRunning)
	{
		return 0;
	}
    return pthread_join(mThread, NULL);
}

void Thread::stop()
{
}

void* Thread::startThread(void* ptr)
{
    __android_log_print(ANDROID_LOG_INFO, TAG, "starting thread \n");
	Thread* thread = (Thread *) ptr;
	thread->mRunning = true;
    thread->handleRun(ptr);
	thread->mRunning = false;
	__android_log_print(ANDROID_LOG_INFO, TAG, "thread ended\n");

    return NULL;
}

void Thread::waitOnNotify()
{
	pthread_mutex_lock(&mLock);
	pthread_cond_wait(&mCondition, &mLock);
	pthread_mutex_unlock(&mLock);
}

void Thread::notify()
{
	pthread_mutex_lock(&mLock);
	pthread_cond_signal(&mCondition);
	pthread_mutex_unlock(&mLock);
}

void Thread::handleRun(void* ptr)
{
}
