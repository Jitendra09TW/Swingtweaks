

import UIKit
import AVFoundation

class addOverlayImageLibrary {
    func editVideo(fromVideoAt videoURL: URL, drawImage: UIImage,drawingReact: CGRect,
                   videoReact: CGRect, onComplete: @escaping (URL?) -> Void) {
    let asset = AVURLAsset(url: videoURL)
    let composition = AVMutableComposition()
    
    guard let compositionTrack = composition.addMutableTrack(
        withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
      let assetTrack = asset.tracks(withMediaType: .video).first
      else {
        print("Something is wrong with the asset.")
        onComplete(nil)
        return
    }
    do {
      let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
      try compositionTrack.insertTimeRange(timeRange, of: assetTrack, at: .zero)
      
      if let audioAssetTrack = asset.tracks(withMediaType: .audio).first,
        let compositionAudioTrack = composition.addMutableTrack(
          withMediaType: .audio,preferredTrackID: kCMPersistentTrackID_Invalid) {
        try compositionAudioTrack.insertTimeRange(timeRange,of: audioAssetTrack, at: .zero)
      }
    } catch {
      print(error)
      onComplete(nil)
      return
    }
    
    compositionTrack.preferredTransform = assetTrack.preferredTransform
    let videoInfo = orientation(from: assetTrack.preferredTransform)
        print("VideoInfo",videoInfo.orientation.rawValue)
    let videoSize: CGSize
//    if videoInfo.isPortrait {
//      videoSize = CGSize(
//        width: assetTrack.naturalSize.width,
//        height: assetTrack.naturalSize.height)
//    } else {
//      videoSize = assetTrack.naturalSize
//    }
    videoSize = assetTrack.naturalSize
    let videoLayer = CALayer()
    print("videoSizeeeee",videoSize)
    let overlayLayer = CALayer()
   	 overlayLayer.frame = CGRect(origin: .zero, size: videoSize)
   // overlayLayer.frame = CGRect(x: 0,y: 0,
                                 // width: videoReact.width,height: videoReact.height)
   // overlayLayer.backgroundColor = UIColor.red.cgColor
    overlayLayer.contentsGravity = .resizeAspectFill
    overlayLayer.isGeometryFlipped = false
    print("overlayLayerFrame",overlayLayer.frame)
    
    videoLayer.frame = CGRect(origin: .zero, size: videoSize)
    //videoLayer.frame = CGRect(x: 0,y: 0,
                             // width: videoSize.width,height: videoSize.height)
    print("VideoLayerFrame",videoLayer.frame)
    videoLayer.contentsGravity = .resizeAspectFill
    videoLayer.isGeometryFlipped = false
    videoLayer.backgroundColor = UIColor.blue.cgColor
    addImage(to: overlayLayer, videoFrames: videoSize, drawImage: drawImage)
    
    let outputLayer = CALayer()
    outputLayer.frame = CGRect(origin: .zero, size: videoSize)
    outputLayer.addSublayer(videoLayer)
    outputLayer.addSublayer(overlayLayer)
    //outputLayer.backgroundColor = UIColor.purple.cgColor
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = videoSize
    videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    videoComposition.animationTool =
        AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer,
                                            in: outputLayer)
    
    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
    videoComposition.instructions = [instruction]
    let layerInstruction = compositionLayerInstruction(for: compositionTrack,
                                                       assetTrack: assetTrack)
    instruction.layerInstructions = [layerInstruction]
    
    guard let export = AVAssetExportSession(
      asset: composition,
      presetName: AVAssetExportPresetHighestQuality)
      else {
        print("Cannot create export session.")
        onComplete(nil)
        return
    }

    let videoName = UUID().uuidString
    let exportURL = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(videoName)
      .appendingPathExtension("mov")
    
    export.videoComposition = videoComposition
    export.outputFileType = .mov
    export.outputURL = exportURL
    
    export.exportAsynchronously {
      DispatchQueue.main.async {
        switch export.status {
        case .completed:
          onComplete(exportURL)
        default:
          print("Something went wrong during export.")
          print(export.error ?? "unknown error")
          onComplete(nil)
          break
        }
      }
    }
  }
  
    private func addImage(to layer: CALayer, videoFrames: CGSize, drawImage: UIImage) {
        let image = drawImage
        let imageLayer = CALayer()
        let width = videoFrames.width
        let height = videoFrames.height
        imageLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        print("imgeFramesss", imageLayer.frame)
        imageLayer.contentsGravity = .resizeAspectFill
        imageLayer.isGeometryFlipped = false
        imageLayer.contents = image.cgImage
        layer.addSublayer(imageLayer)
    }

  private func orientation(from transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
    var assetOrientation = UIImage.Orientation.up
    var isPortrait = false
    if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
      assetOrientation = .right
      isPortrait = true
    } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
      assetOrientation = .left
      isPortrait = true
    } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
      assetOrientation = .up
    } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
      assetOrientation = .down
    }
    
    return (assetOrientation, isPortrait)
  }
  
  private func compositionLayerInstruction(for track: AVCompositionTrack, assetTrack: AVAssetTrack) -> AVMutableVideoCompositionLayerInstruction {
    let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let transform = assetTrack.preferredTransform
    
    instruction.setTransform(transform, at: .zero)
    
    return instruction
  }
  
  private func addConfetti(to layer: CALayer) {
    let images: [UIImage] = (0...5).map { UIImage(named: "confetti\($0)")! }
    let colors: [UIColor] = [.systemGreen, .systemRed, .systemBlue, .systemPink, .systemOrange, .systemPurple, .systemYellow]
    let cells: [CAEmitterCell] = (0...16).map { _ in
      let cell = CAEmitterCell()
      cell.contents = images.randomElement()?.cgImage
      cell.birthRate = 3
      cell.lifetime = 12
      cell.lifetimeRange = 0
      cell.velocity = CGFloat.random(in: 100...200)
      cell.velocityRange = 0
      cell.emissionLongitude = 0
      cell.emissionRange = 0.8
      cell.spin = 4
      cell.color = colors.randomElement()?.cgColor
      cell.scale = CGFloat.random(in: 0.2...0.8)
      return cell
    }
    
    let emitter = CAEmitterLayer()
    emitter.emitterPosition = CGPoint(x: layer.frame.size.width / 2, y: layer.frame.size.height + 5)
    emitter.emitterShape = .line
    emitter.emitterSize = CGSize(width: layer.frame.size.width, height: 2)
    emitter.emitterCells = cells
    
    layer.addSublayer(emitter)
  }
}
