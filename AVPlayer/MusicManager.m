//
//  MusicManager.m
//  AVPlayer
//
//  Created by 羊谦 on 2017/2/16.
//  Copyright © 2017年 羊谦. All rights reserved.
//

#import "MusicManager.h"

static NSString * const MUSIC_URL1 = @"http://o8bxt3lx0.bkt.clouddn.com/1.mp3";
static NSString *const MUSIC_URL2 = @"http://o8bxt3lx0.bkt.clouddn.com/2.mp3";
static NSString *const MUSIC_URL3 = @"http://o8bxt3lx0.bkt.clouddn.com/3.mp3";
static NSString *const MUSIC_URL4 = @"http://o8bxt3lx0.bkt.clouddn.com/4.mp3";
static NSString *const MUSIC_URL5 = @"http://o8bxt3lx0.bkt.clouddn.com/5.mp3";

@interface MusicManager()

@property (nonatomic, readwrite, strong) AVPlayerItem *currentItem;//当前的音乐信息
@property (nonatomic, readwrite, strong) AVQueuePlayer *player;//播放器
@property (nonatomic, strong) NSMutableArray *playerItems;
@property (nonatomic,strong) NSTimer *checkMusicTimer;//用来检查player是否正在播放队列的最后一首歌曲

@end

@implementation MusicManager

+(instancetype)manager{
    static MusicManager *__magager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __magager = [[MusicManager alloc] init];
    });
    return __magager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //设置可后台播放
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    }
    return self;
}

-(void)dealloc{
    [self.checkMusicTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(AVQueuePlayer *)player{
    if (!_player) {
        _player = [[AVQueuePlayer alloc] initWithItems:self.playerItems];
    }
    return _player;
}

-(NSMutableArray *)playerItems{
    if (!_playerItems) {
        _playerItems = [NSMutableArray array];
    }
    return _playerItems;
}

// 准备歌曲
// 因为需要歌曲循环播放，每次AVQueuePlayer播放完成一首歌曲，就会将其从队列中移除
// 所以我们需要在歌曲最后一首播放完之前重新为AVQueuePlayer创建一个播放队列，这样就能够实现循环播放
//
//
- (void)prepareItems{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *urls = @[MUSIC_URL1,MUSIC_URL2,MUSIC_URL3,MUSIC_URL4,MUSIC_URL5];
    for (NSString *url in urls) {
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
        [items addObject:item];
        [item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    }
    self.playerItems = items;
    for (AVPlayerItem *item in items) {
        if ([self.player canInsertItem:item afterItem:self.player.items.lastObject]) {
            [self.player insertItem:item afterItem:self.player.items.lastObject];
        }
    }
}

-(AVPlayerItem *)currentItem{
    return self.player.currentItem;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSLog(@"缓冲");
        [self play];
    }
}

-(void)play{

    if (self.player.status == AVPlayerStatusReadyToPlay) {
        [self.player play];
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlay)]) {
            [self.delegate playerDidPlay];
        }
        self.checkMusicTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(checkMusic) userInfo:nil repeats:YES];
    }
}

- (void)checkMusic
{
    //当音乐播放完毕的时候,程序也就无法操作了,所以要提前操作
    if (self.player.items.count == 1){
        [self prepareItems];
        [self play];
    }
}

- (void)playbackFinished:(NSNotification *)notice {
    NSLog(@"播放完成");
    [self.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(void)next{
    
}

-(void)pause{
    [self.player pause];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPause)]) {
        [self.delegate playerDidPause];
    }
    [self.checkMusicTimer invalidate];
}


@end
