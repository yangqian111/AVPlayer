//
//  MusicManager.h
//  AVPlayer
//
//  Created by 羊谦 on 2017/2/16.
//  Copyright © 2017年 羊谦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol MusicManagerDelegate <NSObject>

@optional
- (void)playerDidPlay;

- (void)playerDidPause;

@end



@interface MusicManager : NSObject

@property (nonatomic, readonly, copy) NSString *current;//当前音乐播放时长
@property (nonatomic, readonly, copy) NSString *total;//当前音乐总时长
@property (nonatomic, readonly, strong) AVPlayerItem *currentItem;//当前的音乐信息
@property (nonatomic, readonly, strong) AVQueuePlayer *player;//播放器
@property (nonatomic, weak) id<MusicManagerDelegate> delegate;

+ (instancetype)manager;

//播放
- (void)play;

//暂停
- (void)pause;

//下一首
- (void)next;

//准备歌曲
- (void)prepareItems;

@end
