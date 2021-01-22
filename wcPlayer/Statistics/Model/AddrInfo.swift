//
//  AddrInfo.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/08/11.
//  Copyright © 2020 서상민. All rights reserved.
//

import Foundation

/// 주소 정보
struct AddrInfo {
    let videoInfo: String = "https://api.wecandeo.com/v1/new/player/video.json"
    let videoData: String = "https://api.wecandeo.com/v1/player/stats/info.json"
    let playLog: String = "https://couscous.acs.wecandeo.io/play/api/videoPlays"
    let sectionLog: String = "https://couscous.acs.wecandeo.io/video/api/videoSections"
    let cuePointLog: String = "https://couscous.acs.wecandeo.io/video/api/videoCuePoints"
    
    let liveInfo: String = "https://api.wecandeo.com/live/new/player/info.json"    
    let liveData: String = "https://api.wecandeo.com/live/player/stats/info.json"
    let liveLog: String = "https://couscous.wecandeo.com/api/liveWatches"
}

struct Response<Element: Decodable>: Decodable {
    var statsInfo: Element?
    var VideoDetail: VideoDetail?
}

struct ErrorInfo: Codable {
    var errorCode: String
    var errorMessage: String
}
