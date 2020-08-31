//
//  VodStatistics.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/08/10.
//  Copyright © 2020 서상민. All rights reserved.
//

import Foundation
import AVFoundation

class VodStatistics {
    
    static let `default` = VodStatistics()
    
    var statsInfo: VodStatsInfo?
    var cuePoints: [CuePoint?]?
    
    var sendSection = false //section 전송여부
    var bSection = 0 //이전 Section 값
    
    /// 영상 상세정보 조회
    /// - Parameters:
    ///   - videoKey: videoKey
    ///   - completion: closure
    func fetchDetail(_ videoKey: String, completion: @escaping (_ detail: VideoDetail?, _ isDRM: Bool) -> Void) {
        let info = RequestInfo(url: AddrInfo().videoInfo, method: .GET, body: ["k": videoKey, "dev": "2"])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] fetch video detail")
            
            self.cuePoints = res?.VideoDetail?.CuePointList
            if let d = res?.VideoDetail {
                let opt = d.videoInfo.opt                
                completion(d, opt == .WIDEVINE_DRM)
            } else {
                completion(nil, false)
            }
        }
    }
    
    /// 영상 통계정보 조회
    /// - Parameters:
    ///   - videoKey: videoKey
    ///   - completion: closure
    func fetchInfo(_ videoKey: String, completion: @escaping () -> Void) {
        let info = RequestInfo(url: AddrInfo().videoData, method: .GET, body: ["k": videoKey])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] fetch vod information")
            
            self.statsInfo = res?.statsInfo
            
            self.statsInfo?.errorInfo = nil
            self.statsInfo?.e = "pl"
            
            let ref = String(format: "https://%@", Bundle.main.bundleIdentifier!)
            self.statsInfo?.ref = ref.data(using: .utf8)?.base64EncodedString()
            self.statsInfo?.fv = "0.0.0"
            completion()
        }
    }
    
    /// 플레이어 로드 시
    /// - Parameter completion: closure
    func loadPlayer(completion: @escaping () -> Void) {
        let info = RequestInfo(url: AddrInfo().playLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] load player")
            
            self.statsInfo?.e = "sr"
            completion()
        }
    }
    
    /// 통계 전송 준비완료 시
    /// - Parameter completion: closure
    func completionStatistics(completion: @escaping () -> Void) {
        let info = RequestInfo(url: AddrInfo().playLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] ready to send statistics")
            completion()
        }
    }
    
    /// 재생구간 이동
    /// - Parameter elapsedTime: 선택된 시간
    func moveSeek(_ elapsedTime: Double) {
        let start = self.statsInfo?.dst ?? 0
        
        self.statsInfo?.e = "vk"
        self.statsInfo?.dst = start
        self.statsInfo?.det = Int(elapsedTime)
        
        let info = RequestInfo(url: AddrInfo().playLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            if let s = self.statsInfo?.dst, let e = self.statsInfo?.det {
                debugPrint("[Done] move seek (\(s):\(e))")
            }
        }
    }
    
    /// 재생구간
    /// - Parameters:
    ///   - section: 재생 구간(%) (1 ~. 100)
    ///   - version: 버전정보
    func scPlay(_ section: Int, version: String) {
        if self.sendSection {
            return
        }
        
        if self.bSection == section {
            return
        }
        
        self.bSection = section
        self.statsInfo?.e = nil
        self.statsInfo?.section = section
        self.statsInfo?.ver = version
        
        let info = RequestInfo(url: AddrInfo().sectionLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] section (\(section))")
            self.sendSection = true
        }
    }
    
    /// 재생통계
    /// - Parameter duration: 영상 전체시간
    func stPlay(_ duration: CMTime) {
        self.statsInfo?.e = "vs"
        self.statsInfo?.dtt = Int(CMTimeGetSeconds(duration))
        
        let info = RequestInfo(url: AddrInfo().playLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] send play")
        }
    }
    
    /// 일시정지 통계
    /// - Parameter current: 현재시간
    func stPause(_ current: CMTime) {
        let start = self.statsInfo?.dst ?? 0
        
        self.statsInfo?.e = "vp"
        self.statsInfo?.dst = start
        self.statsInfo?.det = Int(CMTimeGetSeconds(current))
        
        let info = RequestInfo(url: AddrInfo().playLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            let s = self.statsInfo!.dst!
            let e = self.statsInfo!.det!
            
            debugPrint("[Done] send pause (\(s):\(e))")
        }
    }
    
    /// 재생 중 통계
    /// - Parameters:
    ///   - start: 재생구간(초) 시작
    ///   - end: 재생구간(초) 종료
    func stPlaying(_ start: Int, _ end: Int) {
        self.statsInfo?.e = "vi"
        self.statsInfo?.dst = start
        self.statsInfo?.det = end
        
        let info = RequestInfo(url: AddrInfo().playLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            self.statsInfo?.dst = end
            
            debugPrint("[Ing] send playing (\(start):\(end))")
        }
    }
    
    /// 정지 통계
    /// - Parameter current: 현재 시간
    func stStop(_ current: CMTime) {
        let s = self.statsInfo?.det
        let e = Int(CMTimeGetSeconds(current))
        
        self.statsInfo?.e = "vt"
        self.statsInfo?.dst = s
        self.statsInfo?.det = e
        
        let info = RequestInfo(url: AddrInfo().playLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] play completed")
        }
    }
    
    /// CuePoint 노출 통계
    /// - Parameter current: 현재 시간
    func stShowCuepoint(_ current: Int) {
        guard let cues = self.cuePoints?.filter({ $0?.start == current }), !cues.isEmpty else { return }
        cues.forEach({
            let s = $0?.start
            
            self.statsInfo?.e = "cv"
            self.statsInfo?.cpid = $0?.cpId
            
            let info = RequestInfo(url: AddrInfo().cuePointLog, method: .GET, body: ["data": self.encodeData()])
            APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
                debugPrint("[Done] Show Cuepoint (\(s!))")
            }
        })
    }
    
    /// CuePoint 클릭 통계
    /// - Parameter cpId: Cue Point Id
    func stClickCuepoint(_ cpId: Int) {
        self.statsInfo?.e = "cc"
        self.statsInfo?.cpid = cpId
        
        let info = RequestInfo(url: AddrInfo().cuePointLog, method: .GET, body: ["data": self.encodeData()])
        APIStatistics.default.fetchData(info) { (res: Response<VodStatsInfo>?) in
            debugPrint("[Done] Click Cuepoint")
        }
    }
    
}

extension VodStatistics {
    
    func encodeData() -> String? {
        let encoder = try! JSONEncoder().encode(self.statsInfo)
        return String(data: encoder, encoding: .utf8)
    }    
}
