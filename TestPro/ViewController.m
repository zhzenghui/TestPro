//
//  ViewController.m
//  TestPro
//
//  Created by xy on 15/9/25.
//  Copyright © 2015年 wcsn. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@end

@implementation ViewController

#pragma mark - view cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self still];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - video

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

@end
