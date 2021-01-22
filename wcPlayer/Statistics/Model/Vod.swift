//
//  Vod.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/07/27.
//  Copyright © 2020 서상민. All rights reserved.
//

import Foundation

struct VodStatsInfo: Codable {

    /// 이벤트 명
    var e: String?
    
    /// gid
    var gid: Int
    
    /// 패키지 아이디
    var pid: Int
    
    /// 비디오 아이디
    var vid: Int
    
    /// 플레이어 아이디
    var plid: Int
    
    /// 큐포인트 아이디
    var cpid: Int?
    
    /// 레퍼러
    var ref: String?
        
    /// 현재시간 (format: yyyyMMddhhmmss)
    var cs: String?
    
    /// 사용자 구분값
    var uid: String?
    
    /// 영상전체시간(초)
    var dtt: Int?
    
    /// 재생구간(초) 시작
    var dst: Int?
    
    /// 재생구간(초) 종료
    var det: Int?
    
    /// 재생구간(%) 0 - 100
    var section: Int?
    
    /// 플레시 버전
    var fv: String?
    
    /// SDK 버전
    var ver: String?
    
    /// 에러정보
    var errorInfo: ErrorInfo?
}

struct CuePoint: Decodable {
    
    /// 큐포인트 아이디
    var cpId: Int
    
    /// 시작시간 (초)
    var start: Int
    
    /// 종료시간 (초)
    var end: Int
    
    enum CodingKeys: String, CodingKey {
        case cpId = "cue_point_id"
        case start = "start_duration", end = "end_duration"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.cpId = try container.decode(Int.self, forKey: .cpId)
        
        let s = try container.decode(String.self, forKey: .start)
        self.start = Int(s)!
        
        let e = try container.decode(String.self, forKey: .end)
        self.end = Int(e)!
    }
}

enum VideoType: String, Decodable {
    /// 일반 영상
    case NONE
    
    /// DRM 영상
    case WIDEVINE_DRM
}

struct VideoInfo: Decodable {
    /// video Id
    var id: Int?
    
    /// 영상 종류
    var opt: VideoType?
}

struct PlayerType: Decodable {
    /// gid
    var gid: Int
}

struct VideoDetail: Decodable {
    /// Cue Point 목록
    var CuePointList: [CuePoint?]?
    
    /// 재생 URL
    var videoUrl: String?
    
    /// Player Type
    var PlayerType: PlayerType
    
    /// 영상 정보
    var videoInfo: VideoInfo
}
