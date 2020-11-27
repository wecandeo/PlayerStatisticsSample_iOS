//
//  LiveViewController.swift
//  wcPlayer
//
//  Created by 서상민 on 2020/08/11.
//  Copyright © 2020 서상민. All rights reserved.
//

import UIKit
import WecandeoSDK

class LiveViewController: UIViewController {
    
    @IBOutlet weak var playNstop: UIButton!
    
    private let player = WCPlayer()
    
    private let liveKey = "Live 영상 Video Key"
    private var isReady = false
    private var played = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        LiveStatistics.default.fetchInfo(self.liveKey) { (code) in
            switch code {
            case .NotStarted:
                DispatchQueue.main.async {
                    let msg = LiveStatistics.default.statsInfo?.errorInfo?.errorMessage ?? ""
                    let alert = UIAlertController(title: "Information", message: msg, preferredStyle: .alert)
                    let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                    alert.addAction(confirm)
                    self.present(alert, animated: true, completion: nil)
                }
            case .None:
                LiveStatistics.default.fetchDetail(self.liveKey) { (addr) in
                    DispatchQueue.main.async {
                        self.initWCDPlayer(addr)
                    }
                }
            }
        }
    }
    
    @IBAction func playNstop(_ sender: UIButton) {
        if player.isPlaying() {
            // playing
            sender.setTitle("Play", for: .normal)
            
            LiveStatistics.default.stStop()
            self.played = false
            player.pause()
        } else {
            // stop
            sender.setTitle("Stop", for: .normal)
            
            LiveStatistics.default.stPlay()
            self.played = true
            player.play()
        }
    }
}

//MARK: - Private
extension LiveViewController {
    
    private func initWCDPlayer(_ url: String) {
        player.delegate = self
        guard let control = player.setPlayerControl(url) else { fatalError() }
        control.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(control.view)
        
        control.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        control.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        control.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        control.view.heightAnchor.constraint(equalTo: control.view.widthAnchor, multiplier: 0.5625).isActive = true
    }
}

//MARK: - WCPlayerDelegate
extension LiveViewController: WCPlayerDelegate {
    func didPlayerItemStatusReadyToPlay() {
        if self.isReady {
            return
        }
        
        self.isReady = true
        
        DispatchQueue.main.async {
            self.playNstop.setTitle("Play", for: .normal)
        }
    }
    
    func didPlayerItemStatusCompleted() {
        LiveStatistics.default.stStop()
    }
    
    func playerTimeObserver(_ time: CMTime) {
        let current = Int(CMTimeGetSeconds(time))
        debugPrint("[Ing] time: \(current)")
        
        if current % 5 == 0 && current > 0 {
            if self.played {
                LiveStatistics.default.stPlaying()
            }
        }
    }
}
