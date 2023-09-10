//
//  PreviewCapturedViewController.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/28.
//

import UIKit
import AVKit

class PreviewCapturedViewController: UIViewController {
    
    var currenlyPlayingVideoClip: VideoClips
    let recordedClips: [VideoClips]
    var viewWillDenitRestartVideoSession: (() -> Void)?
    var player: AVPlayer = AVPlayer()
    var playerLayer: AVPlayerLayer = AVPlayerLayer()
    var urlsForVida: [URL] = [] {
        didSet {
            print("outputURLunwrapeend", urlsForVida)
        }
    }
    var hideStatusBar: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    
    @IBOutlet weak var thumbnailimageView: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        handleStarPlayingFirstClip()
        hideStatusBar = true

        recordedClips.forEach{ clip in
            urlsForVida.append(clip.videoUrl)
        }
        print("\(recordedClips.count)")
    }
    
    // Tabbarを消す処理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
        player.play()
        hideStatusBar = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
        player.pause()
        
    }
    
    deinit {
        print("PreviewCaptureVideoVC was deineted")
        (viewWillDenitRestartVideoSession)?()
    }
    
    
    init?(coder: NSCoder, recordedClips: [VideoClips]) {
        self.currenlyPlayingVideoClip = recordedClips.first!
        self.recordedClips = recordedClips
        super.init(coder: coder)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func handleStarPlayingFirstClip(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            guard let firstClip = self.recordedClips.first else {return}
            self.currenlyPlayingVideoClip = firstClip
            self.setupPlayerView(with: firstClip)
        }
    }
    
    func setupView() {
        nextButton.layer.cornerRadius = 2
        nextButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 88/255, alpha: 1.0)
    }
    
    
    func setupPlayerView(with videoClip: VideoClips){
        let player = AVPlayer(url: videoClip.videoUrl)
        let playerLayer = AVPlayerLayer(player: player)
        self.player = player
        self.playerLayer = playerLayer
        playerLayer.frame = thumbnailimageView.frame
        self.player = player
        self.playerLayer = playerLayer
        thumbnailimageView.layer.insertSublayer(playerLayer, at: 3)
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerItemDipPlayEndTime(notification: )), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        handleMirrorPlayer(cameraPosition: videoClip.cameraPostion)
    }
    func removePeriodicTimeObserver() {
        player.replaceCurrentItem(with: nil)
        playerLayer.removeFromSuperlayer()
    }
    
    @objc func avPlayerItemDipPlayEndTime(notification: Notification){
        if let currentIndex = recordedClips.firstIndex(of: currenlyPlayingVideoClip) {
            let nextIndex = currentIndex + 1
            if nextIndex > recordedClips.count - 1 {
                removePeriodicTimeObserver()
                guard let firstClip = recordedClips.first else {return}
                setupPlayerView(with: firstClip)
                currenlyPlayingVideoClip = firstClip
            } else {
                for (index,clip) in recordedClips.enumerated() {
                    if index == nextIndex{
                        removePeriodicTimeObserver()
                        setupPlayerView(with: clip)
                        currenlyPlayingVideoClip = clip
                    }
                }
            }
        }
    }
    
    func handleMirrorPlayer(cameraPosition: AVCaptureDevice.Position){
        if cameraPosition == .front {
            thumbnailimageView.transform = CGAffineTransform(scaleX: -1, y: -1)
        } else {
            thumbnailimageView.transform = .identity
        }
    }
    
    
    @IBAction func canselButtonDidTapped(_ sender: Any) {
        hideStatusBar = true
        navigationController?.popViewController(animated: true)
    }
    
    func handleMergeClips() {
        VideoCompositionWriter().mergeMultlipleVideo(urls: urlsForVida){ success, outputURL in
            if success {
                guard let outputURLunwrapped = outputURL else {return}
                print("outputURLunwrapped:", outputURLunwrapped)
                
                DispatchQueue.main.async {
                    let player = AVPlayer(url: outputURLunwrapped)
                    let vc = AVPlayerViewController()
                    vc.player = player
                    
                    self.present(vc,animated: true){
                        vc.player?.play()
                    }
                }
            }
        }
    }
    
    
    @IBAction func nextButtonDidTapped(_ sender: Any) {
        handleMergeClips()
        hideStatusBar = false
        
        let shareVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "SharePostViewController",creator: {coder -> SharePostViewController? in
            SharePostViewController(coder: coder, videoUrl: self.currenlyPlayingVideoClip.videoUrl)
        })
        shareVC.selectedPhoto = thumbnailimageView.image
        navigationController?.pushViewController(shareVC, animated: true)
        return
    }
}
