//
//  Live.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/08/11.
//  Copyright © 2020 서상민. All rights reserved.
//

import Foundation

struct LiveStatsInfo: Codable {
    
    /// 이벤트 명
    var e: String?
    
    /// gid
    var gid: Int?
    
    /// 채널 아이디
    var chid: Int?
    
    /// 방송 아이디
    var bid: Int?
    
    /// 방송 이벤트 아이디
    var beid: Int?
    
    /// uniqued 아이디
    var uid: String?
    
    /// 플레이어 아이디
    var plid: Int?
    
    /// 레퍼러
    var ref: String?
    
    /// 플레시 버전
    var fv: String?

    /// 에러정보
    var errorInfo: ErrorInfo?
}
