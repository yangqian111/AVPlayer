//
//  ViewController.m
//  AVPlayer
//
//  Created by 羊谦 on 2017/2/16.
//  Copyright © 2017年 羊谦. All rights reserved.
//

#import "ViewController.h"
#import "MusicManager.h"



@interface ViewController ()<MusicManagerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *play;

@property (nonatomic, readwrite, copy) NSString *current;//当前音乐播放时长
@property (nonatomic, readwrite, copy) NSString *total;//当前音乐总时长
@property (nonatomic, strong) id timeObserver;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) MusicManager *manager;

@end

@implementation ViewController
{
    @private
    BOOL _isPlaying;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [MusicManager manager];
    self.manager.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    if (self.timeObserver) {
        [[MusicManager manager].player removeTimeObserver:self.timeObserver];
    }
}

- (IBAction)play:(id)sender {
    if (_isPlaying) {
        [self.manager pause];
    }else{
        [self.manager prepareItems];
        [self.manager play];
    }
}

- (IBAction)previous:(id)sender {
    
}

- (IBAction)next:(id)sender {
    
}

-(void)playerDidPlay{
    //    //添加播放进度观察者
        __weak typeof(self) weakSelf = self;
        self.timeObserver = [self.manager.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0,1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            float current = CMTimeGetSeconds(time);
            float total = CMTimeGetSeconds(weakSelf.manager.currentItem.duration);
            weakSelf.total = [NSString stringWithFormat:@"%.2f",total];
            weakSelf.current = [NSString stringWithFormat:@"%.f",current];
            weakSelf.label.text = [NSString stringWithFormat:@"%@/%@",weakSelf.current,weakSelf.total];
        }];
    _isPlaying = YES;
    [self.play setTitle:@"暂停" forState:UIControlStateNormal];
}

-(void)playerDidPause{
    _isPlaying = NO;
    [self.play setTitle:@"开始播放" forState:UIControlStateNormal];
    [self.manager.player removeTimeObserver:self.timeObserver];
}

@end
