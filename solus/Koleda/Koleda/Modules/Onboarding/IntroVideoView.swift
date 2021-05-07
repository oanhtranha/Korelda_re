//
//  IntroVideoView.swift
//  Koleda
//
//  Created by Oanh tran on 5/27/19.
//  Copyright © 2019 koleda. All rights reserved.
//
import WebKit
import AVFoundation
import UIKit

class IntroVideoView: UIView {
    
    override func awakeFromNib() {
        Style.View.cornerRadius.apply(to: self)
        loadIntroVideo()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.layer.bounds
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name:
            NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func viewWillDisAppear() {
        if isplaying {
            playOrStopVideo()
        }
    }
    
    func viewWillAppear() {
        playOrStopVideo()
    }
    
    // MARK - Private
    private var isplaying: Bool = false
    private var playerLayer: AVPlayerLayer?
    private let player: AVPlayer? = {
//        guard let url = URL(string: AppConstants.introVideoLink) else { return nil }
        guard let path = Bundle.main.path(forResource: "introvideo", ofType:"mp4") else {
            debugPrint("introvideo.mp4 not found")
            return nil
        }
        let asset = AVAsset(url: URL(fileURLWithPath: path))
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        return player
    }()
    
    private func loadIntroVideo() {
        playerLayer = AVPlayerLayer(player: player)
        guard let playerLayer = playerLayer else {
            return
        }
        self.layer.addSublayer(playerLayer)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.position = self.center
        playerLayer.frame = self.bounds
        playerLayer.cornerRadius =  10
        playerLayer.masksToBounds = true
        playerLayer.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func videoDidEnd(notification: NSNotification) {
        isplaying = false
        player?.seek(to: CMTime.zero)
        playOrStopVideo()
    }
    
    private func playOrStopVideo() {
        isplaying ? player?.pause() : player?.play()
        isplaying = !isplaying
        playerLayer?.isHidden = !isplaying
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension IntroVideoView: UIGestureRecognizerDelegate {
    
    @IBAction func handleTap(sender: UIGestureRecognizer) {
      // playOrStopVideo()
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let tapGesture = otherGestureRecognizer as? UITapGestureRecognizer {
            if tapGesture.numberOfTouchesRequired == 1 {
                return true
            }
        }
        return false
    }
}
