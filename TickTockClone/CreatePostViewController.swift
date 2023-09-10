//
//  CreatePostViewController.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/25.
//

import UIKit
import AVFoundation

class CreatePostViewController: UIViewController {

    @IBOutlet weak var canselButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var captureButtonRingView: UIView!
    
    @IBOutlet weak var flipCameraLabel: UILabel!
    @IBOutlet weak var fileCameraButton: UIButton!
    @IBOutlet weak var speedButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var beautyButton: UIButton!
    @IBOutlet weak var BuatyLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var flashBUtton: UIButton!
    @IBOutlet weak var efeectsButton: UIButton!
    @IBOutlet weak var flashLabel: UILabel!
    @IBOutlet weak var gallaryButton: UIButton!
    @IBOutlet weak var TimerCountsLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var soundsView: UIView!
    let photoFileOutput = AVCapturePhotoOutput()
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outPutURL: URL!
    var currentCameraDivice: AVCaptureDevice?
    var thumbnailImage: UIImage?
    var recordedClips = [VideoClips]()
    var isRecording = false
    var videoDurationOfLastClip =  0
    var recordingTimer: Timer?
    var currentMaxRecordingDuration: Int = 15 {
        didSet {
            TimerCountsLabel.text = "\(currentMaxRecordingDuration)s"
        }
    }
    var total_RecordTime_In_Secs = 0
    var total_RecordTime_In_Minutes = 0
    lazy var segmentedProgressView = SegmentedProgressView(width: view.frame.width - 17.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if setupCaptureSession(){
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
        
        
        setupView()

    }
    
    // Tabbarを消す処理
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func caputureButtonDidTapeed(_ sender: Any) {
        handleDidTapRecord()
    }
    
    func handleDidTapRecord() {
        if movieOutput.isRecording == false {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    
    func setupView() {
        fileCameraButton.setTitle("", for: .normal)
        canselButton.setTitle("", for: .normal)
        captureButton.setTitle("", for: .normal)
        speedButton.setTitle("", for: .normal)
        beautyButton.setTitle("", for: .normal)
        filterButton.setTitle("", for: .normal)
        timerButton.setTitle("", for: .normal)
        flashBUtton.setTitle("", for: .normal)
        efeectsButton.setTitle("", for: .normal)
        gallaryButton.setTitle("", for: .normal)
        saveButton.setTitle("", for: .normal)
        discardButton.setTitle("", for: .normal)
        captureButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
        captureButton.layer.cornerRadius = 68/2
        captureButtonRingView.layer.borderColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 0.5).cgColor
        captureButtonRingView.layer.borderWidth = 6
        captureButtonRingView.layer.cornerRadius = 85/2
        
        TimerCountsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        TimerCountsLabel.layer.cornerRadius = 15
        TimerCountsLabel.layer.borderColor = UIColor.white.cgColor
        TimerCountsLabel.layer.borderWidth = 1.8
        TimerCountsLabel.clipsToBounds = true
        
        soundsView.layer.cornerRadius = 12
        saveButton.layer.cornerRadius = 17
        saveButton.backgroundColor = UIColor(red: 254/255, green: 44/255, blue: 85/255, alpha: 1.0)
        saveButton.alpha = 0
        discardButton.alpha = 0
        
        view.addSubview(segmentedProgressView)
        segmentedProgressView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        segmentedProgressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedProgressView.widthAnchor.constraint(equalToConstant: view.frame.width - 17.5).isActive = true
        segmentedProgressView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        segmentedProgressView.translatesAutoresizingMaskIntoConstraints = false
        
 
        [self.captureButton,self.captureButtonRingView,self.canselButton,self.fileCameraButton,self.flipCameraLabel,self.speedLabel,self.speedButton,self.beautyButton,self.BuatyLabel,self.filterLabel,self.filterButton,self.timerLabel,self.timerButton,self.gallaryButton,self.efeectsButton,self.soundsView,self.TimerCountsLabel,self.saveButton,self.discardButton].forEach { subView in
            subView?.layer.zPosition = 1
        }
        
    }
    
    func setupCaptureSession() -> Bool {
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup inputs
        if let captureVideoDevice = AVCaptureDevice.default(for: AVMediaType.video),
           let captureAudioDevice = AVCaptureDevice.default(for: AVMediaType.audio){
            do {
                let inputVideo = try AVCaptureDeviceInput(device: captureVideoDevice)
                let inputAudio = try AVCaptureDeviceInput(device: captureAudioDevice)
                
                if captureSession.canAddInput(inputVideo){
                    captureSession.addInput(inputVideo)
                    activeInput = inputVideo
                }
                if captureSession.canAddInput(inputAudio){
                    captureSession.addInput(inputAudio)
                }
                
                if captureSession.canAddOutput(movieOutput){
                    captureSession.addOutput(movieOutput)
                }
                
            } catch let error {
                print("Could not setup camera input:", error)
                return false
            }
        }
        // 2 setup outputs
        if captureSession.canAddOutput(photoFileOutput){
            captureSession.addOutput(photoFileOutput)
        }
        // 3 setup output previews
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return true
        
    }
    @IBAction func flipBUttonDidTapped(_ sender: Any) {
        captureSession.beginConfiguration()
        
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        let newCameraDevice = currentInput?.device.position == .back ? getDeviceFront(postion: .front) : getDeviceBack(postion: .back)
        
        let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                captureSession.removeInput(input)
            }
        }
        if captureSession.inputs.isEmpty {
            captureSession.addInput(newVideoInput!)
            activeInput = newVideoInput
        }
        
        if let microphone = AVCaptureDevice.default(for: .audio){
            do {
                let micInput = try AVCaptureDeviceInput(device: microphone)
                if captureSession.canAddInput(micInput){
                    captureSession.addInput(micInput)
                }
            } catch let micInputError {
                print("Error setting device audio input\(micInputError)")
            }
        }
           
        
        captureSession.commitConfiguration()
        
    }
    func getDeviceFront(postion: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }
    func getDeviceBack(postion: AVCaptureDevice.Position) -> AVCaptureDevice? {
        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    @IBAction func handleDissmiss(_ sender: Any) {
        tabBarController?.selectedIndex = 0
        
    }
    
    
    
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    
    func startRecording() {
        if movieOutput.isRecording == false {
            guard let connection = movieOutput.connection(with: .video) else {return}
            if connection.isVideoOrientationSupported {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                let device = activeInput.device
                if device.isSmoothAutoFocusSupported {
                    do {
                        try device.lockForConfiguration()
                        device.isSmoothAutoFocusEnabled = false
                        device.unlockForConfiguration()
                    } catch {
                        print("Error setting configuration:\(error)")
                    }
                }
                outPutURL = tempURL()
                movieOutput.startRecording(to: outPutURL, recordingDelegate: self)
                handleAnimeteRecordButton()
                
            }
        }
    }
    func stopRecording() {
        print("movieOutput.isRecording: \(movieOutput.isRecording)")
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
            handleAnimeteRecordButton()
            stopTimer()
            segmentedProgressView.pauseProgress()
            print("STOP THE COUNT")
            
        }
    }
    
    
    @IBAction func saveButtonDidTapped(_ sender: Any) {
        let previewVC = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "PreviewCapturedViewController",creator: { coder -> PreviewCapturedViewController? in
            PreviewCapturedViewController(coder: coder, recordedClips: self.recordedClips)
        })
        previewVC.viewWillDenitRestartVideoSession = {[weak self] in
            guard let self = self else {return}
            if self.setupCaptureSession() {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
        navigationController?.pushViewController(previewVC, animated: true)
        
    }
    
    
    @IBAction func discardButtonDidTapped(_ sender: Any) {
        let alertVC = UIAlertController(title:"Discard the last clip?",message: nil,preferredStyle: .alert)
        let discardAction = UIAlertAction(title:"Discard", style: .default){ [weak self] (_) in
            self?.handleDioscardLastRecordedClip()
        }
        let keepAction = UIAlertAction(title: "Keep", style: .cancel){ (_) in
            
        }
        alertVC.addAction(discardAction)
        alertVC.addAction(keepAction)
        present(alertVC,animated: true)
    }
    func handleDioscardLastRecordedClip(){
        print("discard")
        outPutURL = nil
        thumbnailImage = nil
        recordedClips.removeLast()
        handleResetAllVisibilityToIdendity()
        handleSetNewOutputURLAndThumbnailImage()
        segmentedProgressView.handleRemoveLastSegment()
        
        if  recordedClips.isEmpty == true {
            self.handleResetTimersAndProgressViewToZero()
        } else if recordedClips.isEmpty == false {
            self.handleCalculateDurationLeft()
        }
        
    }
    func handleCalculateDurationLeft() {
        let timeToDiscard = videoDurationOfLastClip
        let currentCombineTime = total_RecordTime_In_Secs
        let newVideoDuration = currentCombineTime - timeToDiscard
        total_RecordTime_In_Secs = newVideoDuration
        let countDownSec: Int = Int(currentMaxRecordingDuration) - total_RecordTime_In_Secs / 10
        TimerCountsLabel.text = "\(countDownSec)"
    }
    
    
    func handleSetNewOutputURLAndThumbnailImage() {
        outPutURL = recordedClips.last?.videoUrl
        let currentUrl: URL? = outPutURL
        guard let currentUrlUnwrappend = currentUrl else {return}
        guard let generatedThumbnailImage = generateVideoThumbanail(withfile: currentUrlUnwrappend) else {return}
        if currentCameraDivice?.position == .front {
            thumbnailImage = didTakePicture(generatedThumbnailImage, to: .upMirrored)
        } else {
            thumbnailImage = generatedThumbnailImage
        }
    }
    
    
    
    
    func handleAnimeteRecordButton() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,options: .curveEaseIn, animations: { [weak self] in
            
            guard let self = self else {return}
            
            if self.isRecording == false {
                self.captureButton.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.captureButton.layer.cornerRadius = 5
                self.captureButtonRingView.transform = CGAffineTransform(scaleX: 1.7, y: 1.7)
                
                self.saveButton.alpha = 0
                self.discardButton.alpha = 0
                
                [self.gallaryButton,self.efeectsButton,self.soundsView].forEach { subView in
                    subView?.isHidden = true
                }
                
            } else {
                self.captureButton.transform = CGAffineTransform.identity
                self.captureButton.layer.cornerRadius = 68/2
                self.captureButtonRingView.transform = CGAffineTransform.identity
                
                self.handleResetAllVisibilityToIdendity()
            }
        }) {[weak self] onComplete in
            guard let self = self else {return}
            self.isRecording = !self.isRecording
        }
    }
    func handleResetAllVisibilityToIdendity() {
        
        if recordedClips.isEmpty == true {
            [self.gallaryButton,self.efeectsButton,self.soundsView].forEach { subView in
                subView?.isHidden = false
            }
            saveButton.alpha = 0
            discardButton.alpha = 0
            print("recordedClips:", "is Empty")
        } else {
            [self.gallaryButton,self.efeectsButton,self.soundsView].forEach { subView in
                subView?.isHidden = true
            }
            saveButton.alpha = 1
            discardButton.alpha = 1
            print("recordedClips:", "is not isEmpty")
        }
       
        
        
    }
    
    
}

extension CreatePostViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo fileURL: URL, from connections: [AVCaptureConnection],error: Error?) {
        if error != nil {
            print("Error reading movie: \(error?.localizedDescription ?? "")")
        } else {
            let urlOfVideoRecorded = outPutURL! as URL
            
            guard let generatedThumbnailImage = generateVideoThumbanail(withfile: urlOfVideoRecorded) else  {return}
            
            
            if currentCameraDivice?.position == .front {
                thumbnailImage = didTakePicture(generatedThumbnailImage, to: .upMirrored)
            } else {
                thumbnailImage = generatedThumbnailImage
            }
        }
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        let newRecordedClip = VideoClips(videoUrl: fileURL, cameraPostion: currentCameraDivice?.position)
        recordedClips.append(newRecordedClip)
        print("recordedClips", recordedClips.count)
        startTimer()
        
    }
    
    
    func didTakePicture(_ picture: UIImage, to orientation: UIImage.Orientation) -> UIImage {
        let flippedImage = UIImage(cgImage: picture.cgImage!, scale: picture.scale,orientation: orientation)
        return flippedImage
    }
    
    
    func generateVideoThumbanail(withfile videoUrl: URL) -> UIImage? {
        let asset = AVAsset(url: videoUrl)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        do {
            let cmTime = CMTimeMake(value: 1, timescale: 60)
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: cmTime, actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let error {
            print(error)
        }
        return nil
    }
}

//:MARK: - RECORDING TIMER

extension CreatePostViewController {
    func startTimer(){
        videoDurationOfLastClip = 0
        stopTimer()
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true,block: { [weak self] _ in
            self?.timerTick()
        })
    }
    
    func timerTick() {
        total_RecordTime_In_Secs += 1
        videoDurationOfLastClip += 1
        
        let time_limit = currentMaxRecordingDuration * 10
        if total_RecordTime_In_Secs == time_limit {
            handleDidTapRecord()
        }
        let startTime = 0
        let trimmedTime: Int = Int(currentMaxRecordingDuration) - startTime
        let positiveOrZero = max(total_RecordTime_In_Secs,0)
        let progress = Float(positiveOrZero) / Float(trimmedTime) / 10
        segmentedProgressView.setProgress(CGFloat(progress))
        let countDownSec: Int = Int(currentMaxRecordingDuration) - total_RecordTime_In_Secs / 10
        TimerCountsLabel.text = "\(countDownSec)s"
    }
    
    func handleResetTimersAndProgressViewToZero() {
        total_RecordTime_In_Secs = 0
        total_RecordTime_In_Minutes = 0
        videoDurationOfLastClip = 0
        stopTimer()
        segmentedProgressView.setProgress(0)
        TimerCountsLabel.text = "\(currentMaxRecordingDuration)"
    }
    
    
    func stopTimer() {
        recordingTimer?.invalidate()
    }
}
