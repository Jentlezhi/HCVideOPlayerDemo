//
//  HCVideoPlayer.m
//  HCVideOPlayerDemo
//
//  Created by Jentle on 15/6/5.
//  Copyright © 2015年 Jentle. All rights reserved.
//

#import "HCVideoPlayer.h"
#import "AppDelegate.h"
#import <objc/message.h>

#define SCREEN_WIDTH      [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT     [[UIScreen mainScreen] bounds].size.height

@interface HCVideoPlayer()

@property (strong, nonatomic)  AVPlayer *player;
@property (strong, nonatomic)  AVPlayerItem *playerItem;
@property (strong, nonatomic)  UIButton *stateButton;
@property (strong, nonatomic)  UIButton *screenButton;
@property (strong, nonatomic)  UIButton *closeButton;
@property (strong, nonatomic)  UILabel *timeLabel;
@property (strong, nonatomic)  id playbackTimeObserver;
@property (strong, nonatomic)  UISlider *videoSlider;
@property (strong, nonatomic)  UIProgressView *videoProgress;
@property (strong, nonatomic)  UIView *viewBottomTools;
@property (strong, nonatomic)  AppDelegate *appDelegate;
@property (copy, nonatomic)    NSString *urlString;
@property (copy, nonatomic)    NSString *totalTime;
@property (strong, nonatomic)  NSDateFormatter *dateFormatter;

@end

@implementation HCVideoPlayer

+ (instancetype)shareMangerWithFrame:(CGRect)rect{
    static HCVideoPlayer *manager = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        manager = [[HCVideoPlayer alloc] initWithFrame:rect];
    });
    
    return manager;
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [self initComponents];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initComponents];
        
    }
    
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)orientChange:(NSNotification *)noti{
    if (self.isFullScreen) {
        self.frame = self.appDelegate.window.bounds;
    }
    [self setFrameWithFullOpen];
    
}

- (void)initComponents{
    self.viewBottomTools = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-44, self.width, 44)];
    [self addSubview:self.viewBottomTools];
    
    
    self.videoProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(64, self.viewBottomTools.height-15, self.width-128, 5)];
    [self.viewBottomTools addSubview:self.videoProgress];
    self.videoSlider = [[UISlider alloc] initWithFrame:self.videoProgress.frame];
    self.videoSlider.transform = CGAffineTransformMakeScale(0.5, 0.5);
    self.videoSlider.left = self.videoProgress.left;
    self.videoSlider.width = self.videoProgress.width;
    [self.viewBottomTools addSubview:self.videoSlider];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    self.stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stateButton.frame = CGRectMake(10, 0, 44, 44);
    [self.stateButton setImage:[UIImage imageNamed:@"HCVideoPlayer.bundle/list_btn_smallplay"] forState:UIControlStateNormal];
    [self.stateButton setImage:[UIImage imageNamed:@"HCVideoPlayer.bundle/list_btn_smallstop"] forState:UIControlStateSelected];
    
    [self.stateButton addTarget:self action:@selector(playWithVideo:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewBottomTools addSubview:self.stateButton];
    
    
    
    self.screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.screenButton.frame = CGRectMake(self.width-54, 0, 44, 44);
    [self.screenButton setImage:[UIImage imageNamed:@"HCVideoPlayer.bundle/list_btn_quanping"]forState:UIControlStateNormal];
    
    [self.screenButton addTarget:self action:@selector(openFullScreenWithSender:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.viewBottomTools addSubview:self.screenButton];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.videoSlider.bottom-5, 100, 20)];
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    [self.viewBottomTools addSubview:_timeLabel];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(5, 5, 44, 44);
    [self.closeButton setImage:[UIImage imageNamed:@"HCVideoPlayer.bundle/nav_close"]forState:UIControlStateNormal];
    self.closeButton.tag = 10;
    [self.closeButton addTarget:self action:@selector(openFullScreenWithSender:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:self.closeButton];
    self.closeButton.hidden = YES;
    
    
    [self setFrameWithFullOpen];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self addGestureRecognizer:tap];
    
    [self tap];
    
}

- (void)openFullScreenWithSender:(UIButton *)sender{

    if (self.superView == nil)return;
    
    if (_isFullScreen){
        self.isFullScreen = NO;
        self.appDelegate.allowAutoFullScreen = NO;
        self.backgroundColor = [UIColor clearColor];
        self.frame = self.superView.bounds;
        [self removeFromSuperview];
        [self.superView addSubview:self];
    }
    else
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        self.frame = window.bounds;
        self.backgroundColor = [UIColor blackColor];
        [window addSubview:self];
        self.isFullScreen = YES;
        self.appDelegate.allowAutoFullScreen = YES;
        
    }
    self.closeButton.hidden = !self.isFullScreen;
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val;// = UIInterfaceOrientationLandscapeRight;
        if (self.isFullScreen) {
            val = UIInterfaceOrientationLandscapeRight;
        }
        else
            val = UIInterfaceOrientationPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    
    
    if (sender.tag == 10) {
        [self stop];
    }
    [self setFrameWithFullOpen];
}

- (void)setFrameWithFullOpen{
    
    self.viewBottomTools.frame = CGRectMake(0, self.height-44, self.width, 44);
    self.screenButton.frame = CGRectMake(self.width-44, 0, 44, 44);
    self.stateButton.frame = CGRectMake(0, 0, 44, 44);
    self.videoProgress.frame = CGRectMake(54, self.viewBottomTools.height-25, self.width-108, 5);
    self.videoProgress.centerY = self.viewBottomTools.height/2.f;
    self.videoSlider.frame = self.videoProgress.frame;
    _timeLabel.right = self.videoSlider.right;
    
}

- (void)tap{
    if (self.viewBottomTools.hidden) {
        self.viewBottomTools.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.viewBottomTools.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.viewBottomTools.alpha = 0;
        } completion:^(BOOL finished) {
            self.viewBottomTools.hidden = YES;
            
        }];
        
    }
    
    
}

- (void)initPayerWithUrl:(NSString *)url{
    if ([url isEqualToString:self.urlString] && self.player) {
        return;
    }
    
    self.urlString = url;
    if (self.player != nil ) {
        [self.player pause];
        [self removeObserver];
        self.player = nil;
        self.played = NO;
    }
    
    if (self.player == nil) {
        [self removeObserver];
        
        NSURL *videoUrl = [NSURL URLWithString:self.urlString];
        self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
        
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.stateButton.enabled = NO;
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    }
}

- (void)playWithVideo:(id)sender {
    
    if (!_played) {
        [self.player play];
        
    } else {
        [self.player pause];
        
    }
    _played = !_played;
    self.stateButton.selected = !self.stateButton.selected;
    
    
}
#pragma mark 暂停播放
-(void)stop;
{
    [self.player pause];
    _played = NO;
    
}


- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
        [weakSelf.videoSlider setValue:currentSecond animated:YES];
        NSString *timeString = [weakSelf convertTime:currentSecond];
        weakSelf.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,weakSelf.totalTime];
    }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            self.stateButton.enabled = YES;
            CMTime duration = self.playerItem.duration;
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;
            _totalTime = [self convertTime:totalSecond];
            [self customVideoSlider:duration];
            [self monitoringPlayback:self.playerItem];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration = _playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    return result;
}

- (void)customVideoSlider:(CMTime)duration {
    self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}



- (void)videoSlierChangeValue:(UISlider *)sender {
    CMTime changedTime = CMTimeMakeWithSeconds(sender.value, 1);
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        weakSelf.stateButton.selected = NO;
    }];
    
}

- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.videoSlider setValue:currentSecond animated:YES];
}


- (void)moviePlayDidEnd:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.videoSlider setValue:0.0 animated:YES];
        weakSelf.stateButton.selected = YES;
    }];
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [[self dateFormatter] stringFromDate:d];
    return showtimeNew;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
    }
    return _dateFormatter;
}

- (void)dealloc {
    [self removeObserver];
}

-(void)removeObserver{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.player removeTimeObserver:self.playbackTimeObserver];
}

@end


@implementation UIView (Extend)

/**
 *  size的setter和getter方法
 */
-(void)setSize:(CGSize)aSize{
    CGRect newframe = self.frame;
    newframe.size = aSize;
    self.frame = newframe;
}

- (CGSize)size{
    return self.frame.size;
}
/**
 *  origin的setter和getter方法
 */
- (void)setOrigin:(CGPoint)aOrigin{
    CGRect newframe = self.frame;
    newframe.origin = aOrigin;
    self.frame = newframe;
}

- (CGPoint)origin{
    return self.frame.origin;
}
/**
 *  width的setter和getter方法
 */
-(void)setWidth:(CGFloat)aWidth{
    CGRect newframe = self.frame;
    newframe.size.width = aWidth;
    self.frame = newframe;
}

- (CGFloat)width{
    return self.frame.size.width;
}

/**
 *  height的setter和getter方法
 */

- (void)setHeight:(CGFloat)aHeight{
    CGRect newframe = self.frame;
    newframe.size.height = aHeight;
    self.frame = newframe;
}

- (CGFloat)height{
    return self.frame.size.height;
}

/**
 *  x的setter和getter方法
 */

- (void)setX:(CGFloat)aX{
    CGRect newframe = self.frame;
    newframe.origin.x = aX;
    self.frame = newframe;
}

-(CGFloat)x{
    return self.frame.origin.x;
}

/**
 *  y的setter和getter方法
 */
- (void)setY:(CGFloat)aY{
    CGRect newframe = self.frame;
    newframe.origin.y = aY;
    self.frame = newframe;
}

- (CGFloat)y{
    return self.frame.origin.y;
}

/**
 *  centerX的setter和getter方法
 */

- (void)setCenterX:(CGFloat)centerX{
    
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX{
    return self.center.x;
}

/**
 *  centerY的setter和getter方法
 */
- (void)setCenterY:(CGFloat)centerY{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

-(CGFloat)centerY{
    return self.center.y;
}

/**
 *  left的setter和getter方法
 */
- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

/**
 *  right的setter和getter方法
 */
- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

/**
 *  top的setter和getter方法
 */
- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

/**
 *  bottom的setter和getter方法
 */
- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

@end

@implementation AppDelegate (Extend)

- (void)setAllowAutoFullScreen:(BOOL)allowAutoFullScreen{
    objc_setAssociatedObject(self, @"allowAutoFullScreen", @(allowAutoFullScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)allowAutoFullScreen{
    return objc_getAssociatedObject(self, @"allowAutoFullScreen");
}

@end

