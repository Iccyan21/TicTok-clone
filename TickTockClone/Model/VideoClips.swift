//
//  VideoClips.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/26.
//

import UIKit
import AVKit

struct VideoClips: Equatable {
    let videoUrl: URL
    let cameraPostion: AVCaptureDevice.Position
    
    init(videoUrl: URL, cameraPostion: AVCaptureDevice.Position?){
        self.videoUrl = videoUrl
        self.cameraPostion = cameraPostion ?? .back
        
    }
    static func == (lhs: VideoClips, rhs: VideoClips) -> Bool {
        return lhs.videoUrl == rhs.videoUrl && lhs.cameraPostion == rhs.cameraPostion
    }
    
}
