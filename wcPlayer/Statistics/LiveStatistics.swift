//
//  LiveStatistics.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/08/11.
//  Copyright © 2020 서상민. All rights reserved.
//

import Foundation

enum LiveErrorCode: String {
    case NotStarted
    case None
}

class LiveStatistics {
    
    static let `default` = LiveStatistics()
    
    var statsInfo: LiveStatsInfo?
    
    /// 영상 정보 조회
    /// - Parameters:
    ///   - videoKey: videoKey
    ///   - completion: closuer
    ///     - addr: m3u8 포함된 주소
    func fetchDetail(_ videoKey: String, completion: @escaping (_ addr: String) -> Void) {
        let info = RequestInfo(url: AddrInfo().liveInfo, method: .GET, body: ["k": videoKey])
        APIStatistics.default.fetchData(info) { (res: Response<LiveStatsInfo>?) in
            debugPrint("[Done] fetch live detail")
            
            if let addr = res?.VideoDetail?.videoUrl {
                completion(addr)
            }
        }
    }
    
    /// 라이브 영상 정보 조회
    /// - Parameters:
    ///   - videoKey: videoKey
    ///   - completion: closuer
    func fetchInfo(_ videoKey: String, completion: @escaping (_ errCode: LiveErrorCode) -> Void) {
        let info = RequestInfo(url: AddrInfo().liveData, method: .GET, body: ["k": videoKey])
        APIStatistics.default.fetchData(info) { (res: Response<LiveStatsInfo>?) in
            debugPrint("[Done] fetch live information")
            
            self.statsInfo = res?.statsInfo
            guard let strErrCode = self.statsInfo?.errorInfo?.errorCode, let errCode =  LiveErrorCode(rawValue: strErrCode) else { return }
            completion(errCode)
        }
    }
    
    /// 재생 시 통계 전송
    func stPlay() {
        self.statsInfo?.e = "ls"
        
        let ref = String(format: "https://%@", Bundle.main.bundleIdentifier!)
        self.statsInfo?.ref = ref.data(using: .utf8)?.base64EncodedString()
        self.statsInfo?.fv = "0.0.0"
        
        let info = RequestInfo(url: AddrInfo().liveLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<LiveStatsInfo>?) in
            debugPrint("[Done] send play")
        }
    }
    
    /// 재생 중 통계 전송
    func stPlaying() {
        self.statsInfo?.e = "li"
        
        let info = RequestInfo(url: AddrInfo().liveLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<LiveStatsInfo>?) in
            debugPrint("[Ing] send playing")
        }
    }
    
    /// 정지 시 통계 전송
    func stStop() {
        self.statsInfo?.e = "lt"
        
        let info = RequestInfo(url: AddrInfo().liveLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<LiveStatsInfo>?) in
            debugPrint("[Done] play completed")
        }
    }
}

extension LiveStatistics {
    
    func encodeData() -> String? {
        let encoder = try! JSONEncoder().encode(self.statsInfo)
        return String(data: encoder, encoding: .utf8)
    }
}
