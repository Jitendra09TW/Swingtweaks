//
//  AudioViewController.swift
//  Swingtweaks
//
//  Created by Lokesh Patil on 20/12/21.
//

import UIKit
import AVFoundation
import AVKit
import AssetsLibrary
class AudioViewController: UIViewController {
    var mergeAudioURL:URL = URL(string: "")!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func mergeAudioFiles(audioFileUrls: NSMutableArray,completion: @escaping (URL)-> Swift.Void) {

        let composition = AVMutableComposition()

        for i in 0 ..< audioFileUrls.count {

            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())! 

            let asset = AVURLAsset(url: ((audioFileUrls[i] as! Dictionary<String, Any>)["soundURL"] as! URL))

            let track = asset.tracks(withMediaType: AVMediaType.audio)[0]

            let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600), duration: CMTime(seconds: Double((audioFileUrls[i] as! Dictionary<String, Any>)["time"] as! CGFloat), preferredTimescale: track.timeRange.duration.timescale))

            try! compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
        }



        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        self.mergeAudioURL = documentDirectoryURL.appendingPathComponent("audio.m4a")! as URL

        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileType.m4a
        assetExport?.outputURL = mergeAudioURL as URL
       // removeFileAtURLIfExists(url: mergeAudioURL)
        assetExport?.exportAsynchronously(completionHandler:
            {
                switch assetExport!.status
                {
                case AVAssetExportSessionStatus.failed:
                    print("failed \(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.cancelled:
                    print("cancelled \(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.unknown:
                    print("unknown\(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.waiting:
                    print("waiting\(String(describing: assetExport?.error))")
                case AVAssetExportSessionStatus.exporting:
                    print("exporting\(String(describing: assetExport?.error))")
                default:
                    print("-----Merge audio exportation complete.\(self.mergeAudioURL)")

                    completion(self.mergeAudioURL)

                }
        })
    }
    
    
    

}
