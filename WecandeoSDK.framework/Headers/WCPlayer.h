//
//  WCPlayer.h
//  WecandeoSDK
//
//  Created by mgoon on 2017. 12. 14..
//  Copyright © 2017년 ScenappsM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class PlayerController;

@protocol WCPlayerDelegate

- (void)didPlayerItemStatusReadyToPlay;
- (void)didPlayerItemStatusCompleted;
- (void)playerTimeObserver:(CMTime) time;

@end

@interface WCPlayer : NSObject 

@property (weak, nonatomic) id<WCPlayerDelegate> delegate;

/// playerController 객체 조회 (DRM)
///
/// @param gId
///     WecandeoDRM gid
/// @param pId
///     packageId
/// @param vId
///     videoId
/// @param videoKey
///     videoKey
/// @param hMac
///     생성된 hmac 문자열
///
/// @Note "videopack.wecandeo.com"에서 배포패키지 > 동영상 상세정보 "packageId", "videoId", "videoKey" 조회
- (PlayerController *)setPlayerControlWithGid:(NSString *)gId packageId:(NSString *)pId videoId:(NSString *)vId videoKey:(NSString *)videoKey hMac:(NSString *)hMac;

/// playerController 객체 조회 (Non DRM)
/// @param videoUrl
///     videoUrl
- (PlayerController *)setPlayerControl:(NSString *) videoUrl;

- (void)didPlayerItemStatusReadyToPlay;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
- (void)backwawrd:(CGFloat)sec;
- (void)forwawrd:(CGFloat)sec;
- (BOOL)isMute;
- (void)mute;
- (void)unMute;
- (CGFloat)getVolume;
- (void)setVolume:(CGFloat)volume;
- (void)changedFullScreen;
- (CMTime)duration;
- (CMTime)currentTime;
- (void)moveSeek:(Float64)sec completionHandler:(void (^)(BOOL finished))completionHandler;

@end
