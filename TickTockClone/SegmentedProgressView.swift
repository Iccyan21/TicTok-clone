//
//  SegmentedProgressView.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/28.
//

import UIKit

class SegmentedProgressView: UIView {
    
    required init(width: CGFloat) {
        self.width = width
        super.init(frame: CGRect.zero)
        handleDrawPaths()
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let width: CGFloat
    var aPath: UIBezierPath = UIBezierPath()
    var segments = [UIView]()
    var segmentPoints = [CGFloat]()
    
    let shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(red: 14/255, green: 173/255, blue: 255/255, alpha: 1.0).cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.strokeEnd = 0
        shapeLayer.lineCap = .round
        return shapeLayer
    }()
    
    fileprivate let trackLayer: CAShapeLayer = {
        let trackerLayer = CAShapeLayer()
        trackerLayer.strokeColor = UIColor.white.withAlphaComponent(0.2).cgColor
        trackerLayer.lineWidth = 6
        trackerLayer.strokeEnd = 1
        trackerLayer.lineCap = .round
        return trackerLayer
        
    }()
    
    fileprivate func handleDrawPaths() {
        aPath.move(to: CGPoint(x: 0.0, y: 0.0))
        aPath.addLine(to: CGPoint(x: width, y: 0.0))
        aPath.move(to: CGPoint(x: 0.0, y: 0.0))
        aPath.close()
        handleSetupTrackLayer()
        handleSetupShapeLayer()
    }
    
    fileprivate func handleSetupTrackLayer() {
        trackLayer.path = aPath.cgPath
        layer.addSublayer(trackLayer)
    }
    
    fileprivate func handleSetupShapeLayer() {
        shapeLayer.path = aPath.cgPath
        layer.addSublayer(shapeLayer)
    }
    
    func setProgress(_ progress: CGFloat) {
        shapeLayer.strokeEnd = progress
    }
    
    func pauseProgress() {
        let newSegment = handleCreateSegment()
        addSubview(newSegment)
        newSegment.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -3).isActive = true
        segments.append(newSegment)
        segmentPoints.append(shapeLayer.strokeEnd)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.handlePositionSegment(newSegment: newSegment)
        }
        
    }
    
    func handleCreateSegment() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 4).isActive = true
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        return view
    }
    
    func handlePositionSegment(newSegment: UIView) {
        let positionPath = CGPoint(x: shapeLayer.strokeEnd * frame.width, y: 0)
        newSegment.constraintToLeft(paddingLeft: positionPath.x)
        newSegment.backgroundColor = UIColor.white
        print("segments:", segments.count)
        
    }

    func handleRemoveLastSegment() {
        segments.last?.removeFromSuperview()
        segmentPoints.removeLast()
        segments.removeLast()
        shapeLayer.strokeEnd = segmentPoints.last ?? 0
        print("segments:", segments.count)
    }
}
extension UIView {
    func constraintToLeft(paddingLeft: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        if let left = superview?.leftAnchor {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
    }
}
