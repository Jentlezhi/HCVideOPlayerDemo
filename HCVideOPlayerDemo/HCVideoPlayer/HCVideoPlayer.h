//
//  HCVideoPlayer.h
//  HCVideOPlayerDemo
//
//  Created by Jentle on 15/6/5.
//  Copyright © 2015年 Jentle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HCVideoPlayer : UIView
/** 播放器父视图 */
@property (nonatomic,strong) UIView *superView;
/** 是否播放状态 */
@property (nonatomic,assign, getter=isPlayed) BOOL played;
/** 是否全屏状态 */
@property (nonatomic,assign) BOOL isFullScreen;

+ (instancetype)shareMangerWithFrame:(CGRect)rect;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)initPayerWithUrl:(NSString *)url;

- (void)playWithVideo:(id)sender;

- (void)stop;

@end

@interface UIView (Extend)

@property (nonatomic, assign) CGSize  size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@end

@interface AppDelegate (Extend)

@property(assign, nonatomic)BOOL allowAutoFullScreen;

@end
