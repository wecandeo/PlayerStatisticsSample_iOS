//
//  WCScretKey.h
//  WecandeoSDK
//
//  Created by mgoon on 2017. 12. 14..
//  Copyright © 2017년 ScenappsM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WCScretKey : NSObject

/// hmac 문자열 생성
///
/// @param gid
///     WecandeoDRM gid
/// @param scretKey
///     WecandeoDRM scretkey
/// @param client
///     hmac에 추가할 문자열
///
/// @Note
///     "videopack.wecandeo.com"에서 계정관리 > 부가서비스 > WecandeoDRM "gid", "scretKey" 조회
- (NSString *)hmacWithGid:(NSString *)gid scretKey:(NSString *)scretKey client:(NSString *)client;

@end
