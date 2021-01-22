//
//  PlayerController.h
//  play
//
//  Created by scenapps-labs on 2017. 4. 19..
//  Copyright © 2017년 scenappsm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;
@class MediaResource;

@protocol PlayerControllerDelegate

- (void)didPlayerItemStatusReadyToPlay;
- (void)didPlayerItemStatusCompleted;
- (void)playerTimeObserver:(CMTime)time;

@end

@interface PlayerController : UIViewController

@property (assign, nonatomic) BOOL isDismissed;
@property (weak, nonatomic) id<PlayerControllerDelegate> delegate;

@property (strong, setter=setPlayer:, getter=player) AVPlayer *player;
@property (strong) AVPlayerItem *playerItem;
@property (strong, nonatomic) NSString* videoUrl;

- (instancetype)initWithMediaResource:(MediaResource *)mediaResource;
- (BOOL)isPlay;
- (void)changedFullScreen;
- (CMTime)duration;
- (void)moveSeek:(Float64)sec completionHandler:(void (^)(BOOL finished))completionHandler;
- (void)setVideoGravity:(AVLayerVideoGravity)gravity;
- (AVLayerVideoGravity)getVideoGravity;

@end

