//
//  VodViewController.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/07/03.
//  Copyright © 2020 서상민. All rights reserved.
//

import UIKit
import WecandeoSDK

class VodViewController: UIViewController {

    @IBOutlet weak var playNpause: UIButton!
    @IBOutlet weak var seek: UISlider!
    @IBOutlet weak var seekLabel: UILabel!
    
    private let player = WCPlayer()
    private let videoKey = "Vod 영상의 Video Key"
    
    private var isReady = false //영상재생 준비여부
    private var movingSeekbar = false //seekbar 이동여부
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        player.delegate = self
        
        VodStatistics.default.fetchDetail(videoKey) { (detail, isDRM) in
            guard let d = detail, let url = d.videoUrl else { fatalError() }
            
            DispatchQueue.main.async {
                let control = isDRM ?
                    self.drmPlayer(gid: String(d.PlayerType.gid), pId: "DRM 영상의 배포패키지 Id", vId: String(d.videoInfo.id!)) :
                    self.nonDRMPlayer(url)
                control!.view.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(control!.view)
                
                control!.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
                control!.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
                control!.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
                control!.view.heightAnchor.constraint(equalTo: control!.view.widthAnchor, multiplier: 0.5625).isActive = true
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.player.isPlaying() {
            self.playNpause(self.playNpause)
        }
    }
    
    @IBAction func playNpause(_ sender: UIButton) {
        DispatchQueue.main.async {
            if self.player.isPlaying() {
                self.playNpause.setTitle("Play", for: .normal)
                self.player.pause()
                
                VodStatistics.default.stPause(self.player.currentTime())
            } else {
                self.playNpause.setTitle("Pause", for: .normal)
                self.player.play()
                
                VodStatistics.default.stPlay(self.player.duration())
            }
        }
    }
    
    @IBAction func seek(_ sender: UISlider) {
        self.movingSeekbar = true
        
        if self.player.isPlaying() {
            self.player.pause()
        }
        
        let duration = CMTimeGetSeconds(self.player.duration())
        let elapsedTime = duration * Float64(sender.value)
        self.playTimer(CMTimeMakeWithSeconds(elapsedTime, preferredTimescale: Int32(NSEC_PER_SEC)))
        
        self.player.moveSeek(elapsedTime) { (finished) in
            if finished {
                if !self.player.isPlaying() {
                    self.player.play()
                }
                
                VodStatistics.default.moveSeek(elapsedTime)
            }
        }
    }
    
    @IBAction func fullscreen(_ sender: UIButton) {
        player.changedFullScreen()
    }
}

//MARK: - Private
extension VodViewController {
    
    private func drmPlayer(gid: String, pId: String, vId: String) -> PlayerController? {
        let scretKey = WCScretKey()
        guard let hmac = scretKey.hmac(withGid: gid,
                                       scretKey: "WecandeoDRM scretKey",
                                       client: "hmac 추가할 문자열") else
        { return nil }
        guard let control = player.setPlayerControlWithGid(gid, packageId: pId, videoId: vId, videoKey: videoKey, hMac: hmac) else { return nil }
        return control
    }
    
    private func nonDRMPlayer(_ url: String) -> PlayerController? {
        return player.setPlayerControl(url)
    }
    
    /// second -> 타이머 형식의 문자열 반환
    /// - Parameter t: second (초)
    /// - Returns: 타이머 형식의 문자열
    private func convertTimer(_ t: Int) -> String {
        let hour = Int(t / 3600)
        let min = Int(t % 3600 / 60)
        let sec = Int(t % 3600 % 60)
        
        if hour == 0 {
            return String(format: "%02ld:%02ld", min, sec)
        } else {
            return String(format: "%02ld:%02ld:%02ld", hour, min, sec)
        }
    }
    
    private func duration() -> Int {
        return Int(CMTimeGetSeconds(self.player.duration()))
    }
    
    private func playTimer(_ time: CMTime) {
        let current = Int(CMTimeGetSeconds(time))
        VodStatistics.default.stShowCuepoint(current)
        
        let strCurrent = self.convertTimer(current)
        let strDuration = self.convertTimer(self.duration())
        self.seekLabel.text = String(format: "%@ / %@", strCurrent, strDuration)
        //debugPrint("===> \(self.seekLabel.text!)")
        
        self.seek.maximumValue = 1
        self.seek.value = Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(self.player.duration()))
    }
    
    private func readyPlay() {
        self.isReady = true
        
        DispatchQueue.main.async {
            self.playNpause.setTitle("Play", for: .normal)
            self.player.pause()
            
            let timer = CMTimeMakeWithSeconds(0, preferredTimescale: Int32(NSEC_PER_SEC))
            self.playTimer(timer)
        }
    }
}

//MARK: - WCPlayerDelegate
extension VodViewController: WCPlayerDelegate {
    
    func didPlayerItemStatusReadyToPlay() {

        if self.isReady {
            self.movingSeekbar = false
            return
        }
        
        VodStatistics.default.fetchInfo(self.videoKey) {
            VodStatistics.default.loadPlayer {
                VodStatistics.default.completionStatistics {
                    self.readyPlay()
                }
            }
        }
    }
    
    func didPlayerItemStatusCompleted() {
        VodStatistics.default.stStop(self.player.currentTime())
    }
    
    func playerTimeObserver(_ time: CMTime) {
        let statsInfo = VodStatistics.default.statsInfo
        let current = Int(CMTimeGetSeconds(time))
        
        let start = statsInfo?.det ?? 0
        let interval = current <= 60 ? 5 : 10
        
        if current - start >= interval {
            if !self.movingSeekbar {
                VodStatistics.default.stPlaying(start, current)
            }
        }
        
        let fCur = CMTimeGetSeconds(time)
        let fDuration = CMTimeGetSeconds(self.player.duration())
        let per = Int((fCur / fDuration) * 100)
        if per % 10 == 0 && per > 0 {
            VodStatistics.default.scPlay(per, version: String(format: "WCD_SDK_%@", String(WecandeoSDKVersionNumber)))
        } else {
            VodStatistics.default.sendSection = false
        }
        
        self.playTimer(time)
    }
}
