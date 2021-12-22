//
//  VideoUltilities.swift
//
//  Created by Le Ngoc Giang on 4/13/16.
//  Copyright © 2016 gianglengoc. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary
import UIKit

class VideoUltilities: NSObject {
  
  static let sharedInstance = VideoUltilities()
  
  // MARK: Public methods
  
  
  func removeAudioFromVideo(videoURL: NSURL, completion: (NSURL?, NSError?) -> Void) -> Void {

    let fileManager = FileManager.default

    let composition = AVMutableComposition()
    
    let sourceAsset = AVURLAsset(url: videoURL as URL)
    
    let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)

    let sourceVideoTrack: AVAssetTrack = sourceAsset.tracks(withMediaType: AVMediaType.video)[0]
      
    let x = CMTimeRangeMake(start: CMTime.zero, duration: sourceAsset.duration)
      
    try! compositionVideoTrack?.insertTimeRange(x, of: sourceVideoTrack, at: CMTime.zero)
      
      let exportPath : NSString = NSString(format: "%@%@", NSTemporaryDirectory(), "removeAudio.mov")
      
    let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
      
    if(fileManager.fileExists(atPath: exportPath as String)) {
        
        try! fileManager.removeItem(at: exportUrl as URL)
      }
      
      let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
    exporter!.outputURL = exportUrl as URL;
    exporter!.outputFileType = AVFileType.mov
  
    
    print("url \(exporter?.outputURL)")
//      exporter?.exportAsynchronouslyWithCompletionHandler({
//        dispatch_async(dispatch_get_main_queue(), {
//
//          completion(exporter?.outputURL, nil)
//        })
//
//      })
  }
  
 
  
  func mergeAudioToVideo(souceAudioPath: String, souceVideoPath: String, completion:(NSURL?, NSError?) -> Void) -> Void {
    
    let fileManager = FileManager.default
    
    let composition = AVMutableComposition()
    
    let videoAsset = AVURLAsset(url: NSURL(fileURLWithPath: souceVideoPath) as URL)
    
    let audioAsset = AVURLAsset(url: NSURL(fileURLWithPath: souceAudioPath) as URL)
    
    let audioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    try! audioTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: audioAsset.tracks(withMediaType: AVMediaType.audio)[0], at: CMTime.zero)
    
    let composedTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    try! composedTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoAsset.tracks(withMediaType: AVMediaType.video)[0], at: CMTime.zero)
    
    let exportPath : NSString = NSString(format: "%@%@", NSTemporaryDirectory(), "mergeVideo.mov")
    
    let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
    
    if(fileManager.fileExists(atPath: exportPath as String)) {
      
        try! fileManager.removeItem(at: exportUrl as URL)
    }
    
    let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
    
    exporter!.outputURL = exportUrl as URL
    
    exporter!.outputFileType = AVFileType.mov
    
    exporter?.exportAsynchronously(completionHandler: {
        let stringURL = exportUrl.absoluteString?.replacingOccurrences(of: "file://", with: "")
        let URL = NSURL(string: stringURL ?? "")
        print("URL with new audio \(URL)" )
//      dispatch_async(dispatch_get_main_queue(), {
//
//        let stringURL = exportUrl.absoluteString.stringByReplacingOccurrencesOfString("file://", withString: "")
//
//        let URL = NSURL(string: stringURL)
//
//        completion(URL, nil)
//      })
    })
  }
  
  
  func getDurationFromFilePath(sourcePath: String) -> Float64 {
    
    let asset = AVURLAsset(url: NSURL(fileURLWithPath: sourcePath) as URL)
    
    let fileDuration = asset.duration
    
    return CMTimeGetSeconds(fileDuration)
    
  }
  
}
