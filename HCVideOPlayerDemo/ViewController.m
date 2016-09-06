//
//  ViewController.m
//  HCVideOPlayerDemo
//
//  Created by Jentle on 16/9/6.
//  Copyright © 2016年 Jentle. All rights reserved.
//

#import "ViewController.h"
#import "HCVideoPlayer.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //加载视频播放器
    NSString *urlStr = @"http://7xt9dm.com2.z0.glb.qiniucdn.com/lpNHSVMrVtNOO85mNNJxWGZVbCzR";
    UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width/2.f)];
    superView.backgroundColor = [UIColor blackColor];
    superView.center = self.view.center;
    [self.view addSubview:superView];
    
    
    HCVideoPlayer *videoPlayer = [HCVideoPlayer shareMangerWithFrame:superView.bounds];
    [videoPlayer initPayerWithUrl:urlStr];
    videoPlayer.superView = superView;
    [superView addSubview:videoPlayer];
}


@end
