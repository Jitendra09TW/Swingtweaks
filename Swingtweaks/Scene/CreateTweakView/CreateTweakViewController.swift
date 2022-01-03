//
//  CreateTweakViewController.swift
//  Swingtweaks
//
//  Created by Lokesh Patil on 09/12/21.
//

import UIKit
import AVFoundation
import AVKit
import Foundation
import QuickLook
import Photos
import VideoEditor

struct Constants {
    static let colors: [UIColor?] = [.black,.white,.red,.orange,.yellow,
                                     .green,.blue,.purple,.brown,.gray,nil]
}
class CreateTweakViewController: UIViewController {
    
    @IBOutlet weak var videoView:UIView!
    @IBOutlet weak var btnBack:UIButton!
    @IBOutlet weak var btnPlay:UIButton!
    @IBOutlet weak var btnPencil:UIButton!
    @IBOutlet weak var btnZoom:UIButton!
    @IBOutlet weak var ViewSpeed:UIView!
    @IBOutlet weak var btnSave:UIButton!
    @IBOutlet weak var btnSpeed:UIButton!
    @IBOutlet weak var btnColor:UIButton!
    @IBOutlet weak var btnEraser:UIButton!
    @IBOutlet weak var btnRecord:UIButton!
    @IBOutlet weak var btnCircle:UIButton!
    @IBOutlet weak var btnSquare:UIButton!
    @IBOutlet weak var imgFrames:UIImageView!
    @IBOutlet weak var btnSpeedHalf:UIButton!
    @IBOutlet weak var btnSpeedNormal:UIButton!
    @IBOutlet weak var btnSpeedOneEight:UIButton!
    @IBOutlet weak var btnSpeedOneFourth:UIButton!
    @IBOutlet weak var btnAnnotationShapes:UIButton!
    @IBOutlet weak var btnPlayAudioRecord:UIButton!
    @IBOutlet weak var btnDrawLine:UIButton!
    
    var videoUrl: URL?
    var playerVedioRate:Float = 1.0
    var player: AVPlayer?
    var playerController: AVPlayerViewController?
    var recorder: AGAudioRecorder = AGAudioRecorder(withFileName: "TempFile")
    var playerPauseTime:Float64 = 0.0
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    //  Tools Editors
    var totalVideoDuration = Float()
    var totalFramesPerSeconds = Float()
    var getCurrentFramePause = Float()
    var totalFPS = Float()
    var allVideoframes:[UIImage] = []
    var assetsGenerator:AVAssetImageGenerator!
    //Tools Setup
    lazy var drawingView: DrawsanaView = {
        let drawingView = DrawsanaView()
        return drawingView
    }()
    let strokeWidths: [CGFloat] = [5,10,20]
    var strokeWidthIndex = 0
    lazy var selectionTool = { return SelectionTool(delegate: self) }()
    lazy var tools: [DrawingTool] = { return [
        PenTool(),
        EllipseTool(),
        RectTool(),
        EraserTool(),
        LineTool(),
        selectionTool
    ] }()
    private let addOverlayEditor = addOverlayImageLibrary()
  
    var isToolsAdded : Bool = false
    var isRecordingAdded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUp()
        recorder.delegate = self
        DispatchQueue.main.async {
            self.getTotalFramesCount(videoUrl: self.videoUrl!)
        }
        btnSave.isUserInteractionEnabled = false
    }
}

extension CreateTweakViewController{
    private func SetUp() {
        // self.playLocalVideo()
        [btnBack, btnPlay, btnSpeed, btnRecord, btnPencil, btnCircle, btnSquare, btnAnnotationShapes, btnZoom, btnColor, btnEraser, btnSpeedHalf, btnSpeedNormal, btnSpeedOneFourth, btnSpeedOneEight, btnPlayAudioRecord, btnSave, btnDrawLine].forEach {
            $0?.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        }
        player?.addObserver(self, forKeyPath: "rate", options: [], context: nil)
        player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        playerController?.showsPlaybackControls = true
        // Show topView
        playerController?.hidesBottomBarWhenPushed = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartVideo),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.player?.currentItem)
        // Manage video player
        guard let newurl =  videoUrl else {
            return
        }
        setVideo(url: newurl)
        
    }
    
    @objc func restartVideo() {
        player?.pause()
        player?.currentItem?.seek(to: CMTime.zero, completionHandler: { _ in
            self.player?.pause()
            self.player?.rate = self.playerVedioRate
            self.ViewSpeed.isHidden = true
        })
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate", let player = object as? AVPlayer {
            if player.rate == 1 {
                print("Playing")
            } else {
                print("Paused")
            }
        }
    }
    private func removePlayer() {
        player?.pause()
        player = nil
        playerController?.player?.pause()
        playerController?.player = nil
        if let view = playerController?.view {
            videoView.willRemoveSubview(view)
        }
        playerController?.view.removeFromSuperview()
        playerController = nil
    }
    private func setVideo(url: URL) {
        removePlayer()
        player = AVPlayer(url: url)
        playerController = AVPlayerViewController()
        playerController?.player = player
        player?.allowsExternalPlayback = true
        player?.usesExternalPlaybackWhileExternalScreenIsActive = true
        self.videoView.addSubview((playerController?.view)!)
        playerController?.view.frame = CGRect(x: 0, y: 0, width: self.videoView.bounds.width, height: self.videoView.bounds.height)
        player?.currentItem?.audioTimePitchAlgorithm = .timeDomain
        
    }
}

// MARK:- Button Action
extension CreateTweakViewController {
    
    @objc func buttonPressed(_ sender: UIButton) {
        switch  sender {
        case btnBack:
            self.navigationController?.popViewController(animated: true)
        case btnPlay:
            self.playAction()
        case btnSpeed:
            self.speedAction()
        case btnRecord :
            self.recordAction()
        case btnPencil:
            self.saveInitialSetup()
            self.lineAction()
        case btnDrawLine:
            self.saveInitialSetup()
            drawLineAction()
        case btnCircle:
            self.saveInitialSetup()
            self.circleAction()
        case btnSquare:
            self.saveInitialSetup()
            self.rectangleAction()
        case btnAnnotationShapes:
            self.AnnotationShapesAction()
        case btnZoom:
            self.zoomAction()
        case btnColor:
            self.colorAction()
        case btnEraser:
            self.eraserAction()
        case btnSpeedHalf:
            speedSelectionAction(speedretio:2, speed: 1/2)
        case btnSpeedNormal:
            speedSelectionAction(speedretio:1, speed: 1/1)
        case btnSpeedOneFourth:
            speedSelectionAction(speedretio:4, speed: 1/4)
        case btnSpeedOneEight:
            speedSelectionAction(speedretio:8, speed: 1/8)
        case btnPlayAudioRecord:
            recorder.doPlay()
        case btnSave:
         // self.mergeRecordedAudio()
            self.saveOverlayViewWithVideo()
         //self.createVideoWithImageArray()
        default:
            break
        }
    }
    func saveInitialSetup() {
        self.isToolsAdded = true
        btnSave.isUserInteractionEnabled = true
        btnSave.backgroundColor = .blue
    }
    private func playAction() {
        if isPlaying {
            player?.pause()
            self.btnPlay.isSelected = false
        }
        else {
            player?.play()
            player?.rate = playerVedioRate
            self.btnPlay.isSelected = true
        }
    }
    
    private func speedAction() {
        ViewSpeed.isHidden = false
    }
    private func recordAction() {
        self.isRecordingAdded = true
        btnSave.isUserInteractionEnabled = true
        btnSave.backgroundColor = .blue
        player?.pause()
        getCurrentFramesOnPause()
        print(playerPauseTime)
        getCurrentFrames()
        recorder.doRecord()
    }
    private func lineAction() {
        self.toolsSetup(toolIndex: 0)
    }
    private func circleAction() {
        self.toolsSetup(toolIndex: 1)
    }
    private func rectangleAction() {
        self.toolsSetup(toolIndex: 2)
    }
    private func AnnotationShapesAction() {
        self.toolsSetup(toolIndex: 5)
    }
    private func zoomAction() {
        print("zoomAction")
    }
    private func colorAction() {
        print("colorAction")
    }
    private func eraserAction() {
        self.toolsSetup(toolIndex: 3)
    }
    private func drawLineAction() {
        self.toolsSetup(toolIndex: 4)
    }
    private func speedSelectionAction(speedretio:Int,speed:Float) {
        playerVedioRate = speed
        player?.rate = playerVedioRate
        ViewSpeed.isHidden = true
        btnSpeed.setTitle("1/\(speedretio)", for: .normal)
    }
    
    func replaceFramesOnIndex() {
        for index in 0..<self.allVideoframes.count {
            if index % 3 == 0 {
                self.allVideoframes.remove(at: index)
                self.allVideoframes.insert(#imageLiteral(resourceName: "ImageNew"), at: index)
            }
        }
        print(self.allVideoframes)
        for index in 0..<self.allVideoframes.count {
            if index % 3 == 0 {
                let newImg = self.allVideoframes[index]
                print(newImg)
            }
        }
    }
    
    private func getFrame(fromTime:Float64) {
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:1)
        let image:CGImage
        do {
            try image = self.assetsGenerator.copyCGImage(at:time, actualTime:nil)
        } catch {
            return
        }
        self.allVideoframes.append(UIImage(cgImage:image))
    }
    func getCurrentFramesOnPause() {
        let pauseTime = (self.player?.currentTime())
        let paueseDuration = CMTimeGetSeconds(pauseTime!)
        self.getCurrentFramePause = self.totalFPS * Float(paueseDuration)
        playerPauseTime = paueseDuration
        print("PauseFrames", self.getCurrentFramePause)
    }
    func getTotalFramesCount(videoUrl: URL) {
        let asset = AVURLAsset(url: videoUrl, options: nil)
        let tracks = asset.tracks(withMediaType: .video)
        if let framePerSeconds = tracks.first?.nominalFrameRate {
          print("FramePerSeconds", framePerSeconds)
          self.totalFPS = framePerSeconds
           let totalSeconds = CMTimeGetSeconds(asset.duration)
            self.totalVideoDuration = Float(totalSeconds)
            print("TotalDurationSeconds :: \(self.totalVideoDuration)")
            self.totalFramesPerSeconds = Float(totalSeconds) * framePerSeconds
            print("Total frames", self.totalFramesPerSeconds)
            self.createVideoFromFrames(videoUrl: videoUrl)
        }
      }
    
    func getCurrentFrames() {
        if let videoLocalURL =  Bundle.main.url(forResource: "videoApp", withExtension: "mp4")
        {
            let asset = AVAsset(url: videoLocalURL)
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = self.player?.currentTime()
            do {
                let img = try assetImgGenerate.copyCGImage(at: time!, actualTime: nil)
                self.imgFrames.image = UIImage(cgImage: img)
            } catch {
                print("Img error")
            }
        }
    }
}
extension CreateTweakViewController {
  func toolsSetup(toolIndex: Int) {
    view.addSubview(drawingView)
    Drawing.debugSerialization = true
    drawingView.set(tool: tools[toolIndex])
    drawingView.backgroundColor = .clear
    drawingView.userSettings.strokeColor = Constants.colors.first!
    drawingView.userSettings.fillColor = Constants.colors.last!
    drawingView.userSettings.strokeWidth = strokeWidths[strokeWidthIndex]
    drawingView.userSettings.fontName = "Marker Felt"
    drawingView.translatesAutoresizingMaskIntoConstraints = false
    drawingView.applyConstraints { $0.width(self.videoView.frame.width).leading(self.videoView.frame.minX).height(self.videoView.frame.height).trailing(self.videoView.frame.minY).top(100).bottom(-100) }
  }
}

extension CreateTweakViewController: SelectionToolDelegate {
 // When a shape is double-tapped by the selection tool, and it's text,
 func selectionToolDidTapOnAlreadySelectedShape(_ shape: ShapeSelectable) {
  if shape as? TextShape != nil {
   // drawingView.set(tool: textTool, shape: shape)
  } else {
   drawingView.toolSettings.selectedShape = nil
  }
 }
}

// Tools delegates
extension CreateTweakViewController: ColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidPick(colorIndex: Int, color: UIColor?, identifier: String) {
        switch identifier {
        case "stroke":
            drawingView.userSettings.strokeColor = color
        case "fill":
            drawingView.userSettings.fillColor = color
        default: break;
        }
        dismiss(animated: true, completion: nil)
    }
}

private extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}


//
// Merge videos and Audio
//
extension CreateTweakViewController {
    //
    //Merge OverlayView with video
    //
    func saveOverlayViewWithVideo() {
        LoadingView.lockView()
        if let imgRender = drawingView.render() {
          print("imgrender",imgRender)
            self.addOverlayEditor.editVideo(fromVideoAt: videoUrl!, drawImage: imgRender, drawingReact: self.drawingView.frame, videoReact: self.videoView.frame) { (exportedURL) in
              print("exportedURL", exportedURL)
              guard let newVideoURL = exportedURL else {
                return
              }
                if self.isRecordingAdded == true {
                    self.mergeRecordedAudio(newVideoUrl: newVideoURL)
                }
                else {
                    self.saveVideoToLibrary(exportedURL: newVideoURL)
                }
            }
         }
      }
    //
    // Create video From frames Array
    //
    func createVideoFromFrames(videoUrl: URL) {
          self.allVideoframes = []
          let asset = AVURLAsset(url: (videoUrl as URL), options: nil)
          let videoDuration = asset.duration
          let generator = AVAssetImageGenerator(asset: asset)
          generator.requestedTimeToleranceAfter = CMTime.zero
          generator.requestedTimeToleranceBefore = CMTime.zero
          var frameForTimes = [NSValue]()
          let sampleCounts = Int(self.totalFramesPerSeconds)
          let totalTimeLength = Int(videoDuration.seconds * Double(videoDuration.timescale))
          let step = totalTimeLength / sampleCounts
          for i in 0 ..< sampleCounts {
            let cmTime = CMTimeMake(value: Int64(i * step), timescale: Int32(videoDuration.timescale))
            frameForTimes.append(NSValue(time: cmTime))
          }
          generator.generateCGImagesAsynchronously(forTimes: frameForTimes, completionHandler: {requestedTime, image, actualTime, result, error in
            DispatchQueue.main.async {
              if let image = image {
                print(requestedTime.value, requestedTime.seconds, actualTime.value)
                self.allVideoframes.append(UIImage(cgImage: image))
              }
            }
            print("frames ,\(self.allVideoframes)")
            print("frames count ,\(self.allVideoframes.count)")
          })
//          DispatchQueue.main.asyncAfter(deadline: .now() + 25.0) {
//            print("frames count after 20 sec ,\(self.allVideoframes.count)")
//            self.createVideoWithImageArray()
//          }
       }
    //
    // Merge videos and Audio
    //
    func mergeRecordedAudio(newVideoUrl: URL){
        print("MergeLocalUrl",newVideoUrl)
        let videoAsset = VideoEditor.Asset(localURL: newVideoUrl, volume: 1.0)
        let firstAudioAsset = VideoEditor.Asset(localURL: recorder.fileUrl(), volume: 1,
                                                startTime: CMTime(seconds:  playerPauseTime, preferredTimescale: 1),
                                                duration: CMTime(seconds:  audioDuration(audioFileURL: recorder.fileUrl()), preferredTimescale: 1))
        
        let secondAudioAsset = VideoEditor.Asset(localURL: recorder.fileUrl(), volume: 1,
                                                 startTime: CMTime(seconds: 8,  preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                 duration: CMTime(seconds: 6.0, preferredTimescale: 1))
        
        let videoEditor = VideoEditor()
        videoEditor.merge(video: videoAsset, audios: [firstAudioAsset], progress: {
            progress in
            print(progress)
        }, completion: { result in
            switch result {
            case .success(let videoURL):
                print(videoURL)
                self.saveVideoToLibrary(exportedURL: videoURL)
            case .failure(let error):
                print("RecordingErrorrrr",error)
            }
        })
    }
    
    //
    // audio duration
    //
    func audioDuration(audioFileURL:URL) -> Float64{
        let audioAsset = AVURLAsset.init(url: audioFileURL, options: nil)
        let duration = audioAsset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)
        print("durationInSeconds \(durationInSeconds)")
        return durationInSeconds
    }
}
//
// Recorder Delegates
//
extension CreateTweakViewController: AGAudioRecorderDelegate {
    func agAudioRecorder(_ recorder: AGAudioRecorder, withStates state: AGAudioRecorderState) {
        switch state {
        case .error(let e): debugPrint(e)
        case .Failed(let s): debugPrint(s)
        case .Finish:
            btnRecord.isSelected = false
        case .Recording:
            btnRecord.isSelected = true
        case .Pause:
            btnPlayAudioRecord.isSelected = false
        // playBtn.setTitle("Pause", for: .normal)
        case .Play:
            btnPlayAudioRecord.isSelected = true
        case .Ready:
            print("Recode")
        }
        debugPrint(state)
    }
    
    func agAudioRecorder(_ recorder: AGAudioRecorder, currentTime timeInterval: TimeInterval, formattedString: String) {
        debugPrint(formattedString)
    }
}

extension CreateTweakViewController {
    func createVideoWithImageArray() {
        DispatchQueue.main.async {
            if self.allVideoframes.count > 0 {
                // self.makeMovie(size: self.allVideoframes.first!.size, images: self.allVideoframes)
            }
        }
    }
    func makeMovie(size: CGSize, images: [UIImage]) {
        var settings = RenderSettings()
        settings.size = size
        settings.fps = Double(self.totalFPS)
        let imageAnimator = ImageAnimator(renderSettings: settings) {
            return images
        }
        imageAnimator.render() {
            print("yesMovieCretaed")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showAlertView("Saved", message: "New Video saved in gallery")
            }
        }
    }
}
