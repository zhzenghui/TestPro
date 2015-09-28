//
//  ViewController.m
//  TestPro
//
//  Created by xy on 15/9/25.
//  Copyright © 2015年 wcsn. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SCRecorder.h"

#import <Photos/PHPhotoLibrary.h>



@interface ViewController ()
{
    UIView *v;
}

@property(nonatomic, strong) AVPlayerItem *playerItem ;
@property(nonatomic, strong) AVPlayer *avplay;
@end

@implementation ViewController

#pragma mark - view cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    


    
    v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    v.backgroundColor = [UIColor redColor];
    [self.view addSubview:v];
    
    [self palyTwoItem];
    
 }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


NSString *kTracksKey		= @"tracks";
NSString *kStatusKey		= @"status";
NSString *kRateKey			= @"rate";
NSString *kPlayableKey		= @"playable";
NSString *kCurrentItemKey	= @"currentItem";
NSString *kTimedMetadataKey	= @"currentItem.timedMetadata";
#pragma mark - video

- (void)palyTwoItem {
    
    
    NSURL *url = [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?vid=193000335&type=flv&ts=1443403928&keyframe=0&ep=ciaQGU2NVccC7SvZjj8bMX3idyINXP8D9R%2BFgdFhBdQmSe6%2F&sid=044340392886612fa03e2&token=2160&ctype=12&ev=1&oip=1981419708"];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    NSArray *requestedKeys = [NSArray arrayWithObjects:kTracksKey, kPlayableKey, nil];
    
    /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async( dispatch_get_main_queue(),
                        ^{
                            /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */

                            NSLog(@"%i", asset.tracks.count);
                            self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                            
                            
                        });
     }];
}


#pragma mark - video


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (context) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
//                           [self syncUI];
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.avplay seekToTime:kCMTimeZero];
}

//
- (void)loadM3u {

    
    NSURL *url = [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?vid=193000335&type=flv&ts=1443403928&keyframe=0&ep=ciaQGU2NVccC7SvZjj8bMX3idyINXP8D9R%2BFgdFhBdQmSe6%2F&sid=044340392886612fa03e2&token=2160&ctype=12&ev=1&oip=1981419708"];

    
    
    
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *avplay =  [AVPlayer playerWithPlayerItem:self.playerItem];
    
    [avplay replaceCurrentItemWithPlayerItem:self.playerItem];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:[self.avplay currentItem]];
    
    
    
    AVPlayerLayer *apl = [[AVPlayerLayer alloc] init];
    apl.player = avplay;
    apl.frame = v.layer.bounds;
    [v.layer addSublayer: apl] ;
    [avplay play];
}

//
- (void)loadM3uInfo {
    
    NSURL *url = [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?vid=193000335&type=flv&ts=1443403928&keyframe=0&ep=ciaQGU2NVccC7SvZjj8bMX3idyINXP8D9R%2BFgdFhBdQmSe6%2F&sid=044340392886612fa03e2&token=2160&ctype=12&ev=1&oip=1981419708"];

    NSDictionary *options = @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES };

    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:options];
    
    
    NSLog(@"%i", asset.tracks.count);
    

    NSArray *keys = @[@"duration"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^() {
        
        NSError *error = nil;
        AVKeyValueStatus tracksStatus = [asset statusOfValueForKey:@"duration" error:&error];
        switch (tracksStatus) {
            case AVKeyValueStatusLoading:
                NSLog(@"loading");
//                [self updateUserInterfaceForDuration];
                break;
            case AVKeyValueStatusFailed:
                NSLog(@"load failed ");
                //                [self reportError:error forAsset:asset];
                break;
            case AVKeyValueStatusLoaded:
                NSLog(@"loaded");
                //                [self reportError:error forAsset:asset];
                break;
            case AVKeyValueStatusCancelled:
                NSLog(@"loading cancel ");
                // Do whatever is appropriate for cancelation.
                break;
        }
    }];

    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
        AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        // Implementation continues...
        Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
        CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
        NSError *error;
        CMTime actualTime;
        
        CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
        
        if (halfWayImage != NULL) {
            
            NSString *actualTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, actualTime));
            NSString *requestedTimeString = (NSString *)CFBridgingRelease(CMTimeCopyDescription(NULL, midpoint));
            NSLog(@"Got halfWayImage: Asked for %@, got %@", requestedTimeString, actualTimeString);
            
            // Do something interesting with the image.
            CGImageRelease(halfWayImage);
            
            
            //
            UIImage *image = [[UIImage alloc] initWithCGImage:halfWayImage];
            
            self.view.backgroundColor = [UIColor colorWithPatternImage:image];
        }

    }
}


#pragma mark - video

// 视频改版设置信息

- (void)videoExport {
    
    //Export the avcompostion track to destination path
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
    NSString *dstPath = [documentsDirectory stringByAppendingString:@"/sample_audio.mp4"];
    NSURL *dstURL = [NSURL fileURLWithPath:dstPath];

    
    
    
    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"m4v"];
    NSURL *url = [NSURL fileURLWithPath:movpath];
  
//    NSURL *url = [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?vid=193000335&type=flv&ts=1443403928&keyframe=0&ep=ciaQGU2NVccC7SvZjj8bMX3idyINXP8D9R%2BFgdFhBdQmSe6%2F&sid=044340392886612fa03e2&token=2160&ctype=12&ev=1&oip=1981419708"];


    AVAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    SCAssetExportSession *assetExportSession = [[SCAssetExportSession alloc] initWithAsset:asset];
    assetExportSession.outputUrl = dstURL;
    assetExportSession.outputFileType = AVFileType3GPP;
//    assetExportSession.videoConfiguration.filter = [SCFilter filterWithCIFilterName:@"CIPhotoEffectInstant"];
    assetExportSession.videoConfiguration.preset = SCPresetMediumQuality;
    assetExportSession.audioConfiguration.preset = SCPresetLowQuality;
    [assetExportSession exportAsynchronouslyWithCompletionHandler: ^{
        if (assetExportSession.error == nil) {
            // We have our video and/or audio file
            NSLog(@"export success");
        } else {
            // Something bad happened
            NSLog(@"somehtin bad happened");
        }
    }];
}

// 获取视频长度
- (void)getFileSizeForUrl:(NSString *)urlString {
    
    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:movpath];
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:url options:nil];

    CMTime time = [videoAsset duration];
    int seconds = ceil(time.value/time.timescale);
    
    
    NSLog(@"%i", seconds  );
}
// 获取视频的大小
- (void)getSizeForUrl:(NSString *)url {
    
    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"mp4"];
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: movpath error: NULL];
    unsigned long long result = [attrs fileSize];
    
    NSLog(@"%.2f", result / (1024.0 * 1024.0) );
    NSLog(@"%.2f", result / (1000.0 * 1000.0) );
}

// 获取视频分辨率
- (void)getNaturalSizeForUrl:(NSString *)url {
    
    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"mp4"];
    
    NSFileManager *man = [NSFileManager defaultManager];
    NSDictionary *attrs = [man attributesOfItemAtPath: movpath error: NULL];
    unsigned long long result = [attrs fileSize];
    
    NSLog(@"%.2f", result / (1000.0 * 1000.0) );
}


- (void)getVideoInfo {
    
    
//    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"mp4"];
    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"m4v"];
//    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"122" ofType:@"mov"];

    NSURL *url = [NSURL fileURLWithPath:movpath];
    
//    NSURL *url = [NSURL URLWithString:@"http://v.youku.com/v_show/id_XNzcyMDAxMzQw.html"];
    
//    NSURL *url = [NSURL URLWithString:@"http://pl.youku.com/playlist/m3u8?vid=193000335&type=flv&ts=1443403928&keyframe=0&ep=ciaQGU2NVccC7SvZjj8bMX3idyINXP8D9R%2BFgdFhBdQmSe6%2F&sid=044340392886612fa03e2&token=2160&ctype=12&ev=1&oip=1981419708"];
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    

    
    
    // 1 - Get media type
//    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
//    
//    // 2 - Dismiss image picker
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 3 - Handle video selection
        //  NSLog(@"track = %@",[videoAsset tracksWithMediaType:AVMediaTypeAudio]);
        
        NSArray *trackArray = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
//        if(!trackArray.count){
//            NSLog(@"Track returns empty array for mediatype AVMediaTypeAudio");
//            return;
//        }
//        
        AVAssetTrack *srcAssetTrack = [trackArray  objectAtIndex:0];
    
    CGSize mediaSize = srcAssetTrack.naturalSize;
    NSLog(@"videoAsset.duration.value: %lld", videoAsset.duration.value);
    NSLog(@"%@", NSStringFromCGSize( mediaSize));
    NSLog(@"trackArray.count: %i", trackArray.count);
    NSLog(@"srcAssetTrack.trackID: %i", srcAssetTrack.trackID);
    NSLog(@"srcAssetTrack.segments.count: %i", srcAssetTrack.segments.count);

    NSLog(@"srcAssetTrack.naturalTimeScale: %i", srcAssetTrack.naturalTimeScale);
    NSLog(@"srcAssetTrack.metadata: %@", srcAssetTrack.metadata);

    
//
//        //Extract time range
//        CMTimeRange timeRange = srcAssetTrack.timeRange;
//        NSError *err = nil;
//        if(NO == [dstCompositionTrack insertTimeRange:timeRange ofTrack:srcAssetTrack atTime:kCMTimeZero error:&err]){
//            NSLog(@"Failed to insert audio from the video to mutable avcomposition track");
//            return;
//        }
//        //Export the avcompostion track to destination path
//        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0];
//        NSString *dstPath = [documentsDirectory stringByAppendingString:@"/sample_audio.m4a"];
//        NSURL *dstURL = [NSURL fileURLWithPath:dstPath];
    
        
        //Remove if any file already exists
        
}

- (void)saveImage:(UIImage *)image {
}


- (void)still {
    
    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:movpath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    NSError *error;
    CMTime actualTime;
    
    
    CMTime currentTime = CMTimeMakeWithSeconds(1, 600);

    CGImageRef currentImage = [imageGenerator copyCGImageAtTime:currentTime
                                                     actualTime:&actualTime
                                                          error:&error];
    
    if (!error) {
        UIImage *image = [[UIImage alloc] initWithCGImage:currentImage];
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    }
}


- (void)export {
    
    
    NSString *movpath =[[NSBundle mainBundle] pathForResource:@"1938" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:movpath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    
    NSError *outError;

    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:asset error:&outError];
    
    
    AVAsset *localAsset = assetReader.asset;
//    // Get the audio track to read.
//    AVAssetTrack *audioTrack = [[localAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//    // Decompression settings for Linear PCM
//    NSDictionary *decompressionAudioSettings = @{ AVFormatIDKey : [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM] };
//    // Create the output with the audio track and decompression settings.
//    AVAssetReaderOutput *trackOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:decompressionAudioSettings];
//    // Add the output to the reader if possible.
//    if ([assetReader canAddOutput:trackOutput])
//        [assetReader addOutput:trackOutput];
    
    
    

    AVVideoComposition *videoComposition =  [AVVideoComposition videoCompositionWithPropertiesOfAsset:localAsset];
    // Assumes assetReader was initialized with an AVComposition.
    AVComposition *composition = (AVComposition *)assetReader.asset;
    // Get the video tracks to read.
    NSArray *videoTracks = [composition tracksWithMediaType:AVMediaTypeVideo];
    // Decompression settings for ARGB.
    NSDictionary *decompressionVideoSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB], (id)kCVPixelBufferIOSurfacePropertiesKey : [NSDictionary dictionary] };
    // Create the video composition output with the video tracks and decompression setttings.
    AVAssetReaderVideoCompositionOutput *videoCompositionOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:decompressionVideoSettings];
    // Associate the video composition used to composite the video tracks being read with the output.
    videoCompositionOutput.videoComposition = videoComposition;

    // Add the output to the reader if possible.
    if ([assetReader canAddOutput:videoCompositionOutput])
        [assetReader addOutput:videoCompositionOutput];

    
}



@end
