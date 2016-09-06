#### 视频播放器，支持快进、快退、全屏等。

#####使用示例:
* ###### #import "HCVideoPlayer.h"


#####播放视频:
```
    NSString *urlStr = @"http://7xt9dm.com2.z0.glb.qiniucdn.com/lpNHSVMrVtNOO85mNNJxWGZVbCzR";
    UIView *superView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width/2.f)];
    superView.backgroundColor = [UIColor blackColor];
    superView.center = self.view.center;
    [self.view addSubview:superView];
    
    HCVideoPlayer *videoPlayer = [HCVideoPlayer shareMangerWithFrame:superView.bounds];
    [videoPlayer initPayerWithUrl:urlStr];
    videoPlayer.superView = superView;
    [superView addSubview:videoPlayer];

```
效果演示:

![](HCVideOPlayerDemo.gif)

