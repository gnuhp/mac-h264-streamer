#include "../mediaplayer.h"
#include <stdio.h>
#include <unistd.h> 

int main (int argc, char ** argv)
{

    printf("Test mediaplay built on ffmpeg 0.10.3\n"); 



    MediaPlayer* mp = new MediaPlayer(); 

    //const char * testFile = "/home/phung/Downloads/ffmpeg_test_data/cam1_dump.flv";
    //const char * testFile = "rtmp://112.213.86.13:1935/live/cam1.stream";
    const char * testFile = "rtmp://192.168.5.106:1935/flvplayback/live";
    status_t status; 
    


    status = mp->setDataSource(testFile); 

    printf("setDataSource return: %d\n", status);

    if (status != NO_ERROR) // NOT OK
    {

        printf("setDataSource error: %d\n", status); 
        exit(1);
    }



    // Prepare the player 

    status=  mp->prepare(); 

    printf("prepare return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {

        printf("prepare() error: %d\n", status); 
        exit(1);
    }

    // Play anyhow

    status=  mp->start(); 

    printf("start() return: %d\n", status);
    if (status != NO_ERROR) // NOT OK
    {

        printf("start() error: %d\n", status); 
        exit(1);
    }

    // sleep some time to see if the thread is really working 

    bool exit = false; 
    int input; 
    while (exit == false)
    {
        sleep (10); 

        //wake up and ask user 
        printf ("Do you want to exit? enter 1 to exit"); 
        scanf("%d",&input); 

        if ( input == 1)
        {
            break;  
        }

        printf ("Continue.. "); 
    }

    mp->stop(); 

    printf ("Exiting...\n "); 

    /////









    return 0; 
}
