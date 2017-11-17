//
//  EndOfSlideshowViewController.swift
//  FaceR
//
//  Created by Jordan Fraughton on 8/22/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class EndOfSlideshowViewController: UIViewController {

    // MARK: - Actions
    
    @IBAction func exitButtonTapped(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        print("Button tapped")
        uploadButton.isHidden = true
        uploadSpod.startAnimating()
        saveWithImages()
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exitButton.isHidden = true
        // Do any additional setup after loading the view.
        
    }

    // MARK: Main 
    
    func saveWithImages() {
        
        let composition = AVMutableComposition()
        let asset = AVURLAsset(url: self.fileLocation!)
        
        let track = asset.tracks(withMediaType: AVMediaType.video)
        let videoTrack: AVAssetTrack = track[0] as AVAssetTrack
        let timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        print("This is potrait \(videoTrack.preferredTransform) for the videoTrack")
        
        let compositionVideoTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())!
        
        do {
            try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: kCMTimeZero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
            print("\(compositionVideoTrack.timeRange.duration) compositionVideoTrack")
            
        } catch {
            print(error)
        }
        
        // TODO: use switch to choose to add audio or not.
        if Settings.shared.soundOn == true {
        let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
        
            for audioTrack in asset.tracks(withMediaType: AVMediaType.audio) {
                do {
                    try compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: kCMTimeZero)
                } catch {
                    print(error)
                }
            }
        }
        // Image Layer
        // I switched the naturalSize width and height because they were displaying in landscape. This way the video is portrait.
        
        let size = videoTrack.naturalSize
        
        // Video Layer
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        parentLayer.addSublayer(videoLayer)
        
        Album.shared.startTimesForSegments()
        
        for i in 0..<album.count {
            
            let image: UIImage = Album.shared.fullAlbum[i]
            let imageLayer = CALayer()
            if i == 0 {
                imageLayer.beginTime = Double(0)
           
            } else {
                imageLayer.beginTime = Double(Album.shared.startTimes[i])
            }
            
            print("Start time for image \(i) is \(Album.shared.startTimes[i])")
            imageLayer.duration = Double(Album.shared.timesArray[i])
            imageLayer.contents = image.cgImage
            imageLayer.frame = CGRect(x: 10, y:10, width: 250, height: 250)
            parentLayer.addSublayer(imageLayer)
            
        }
        
        let layerComposition = AVMutableVideoComposition()
        layerComposition.frameDuration = CMTimeMake(1, 30)
        layerComposition.renderSize = size
       
        layerComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration)
        
        let videotrack = composition.tracks(withMediaType: AVMediaType.video)[0] as AVAssetTrack
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videotrack)
        layerInstruction.setTransform(videoTrack.preferredTransform, at: kCMTimeZero)
        
        instruction.layerInstructions = [layerInstruction]
        layerComposition.instructions = [instruction]
        
        //Setting the render size and frame duration
        
        let naturalSizeFirst: CGSize = CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
        let naturalSizeSecond: CGSize = CGSize(width: videotrack.naturalSize.width, height: videotrack.naturalSize.height)
        var renderHeight: CGFloat = 0.0
        var renderWidth: CGFloat = 0.0
        
        if naturalSizeFirst.height > naturalSizeSecond.height {
            renderHeight = naturalSizeFirst.height
                    } else {
            renderHeight = naturalSizeSecond.height
        }
        
        if naturalSizeFirst.width > naturalSizeSecond.width {
            renderWidth = naturalSizeFirst.width
        } else {
            renderWidth = naturalSizeSecond.width
        }
        
        layerComposition.renderSize = CGSize(width: renderHeight, height: renderWidth)
        layerComposition.frameDuration = CMTimeMake(1, 30)
        
        let filePath = NSTemporaryDirectory() + self.fileName()
        let movieUrl = URL(fileURLWithPath: filePath)
        
        guard let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else { return }
        assetExport.videoComposition = layerComposition
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = movieUrl
        assetExport.exportAsynchronously(completionHandler: {
            switch assetExport.status {
            case .completed:
                print (layerComposition)
                print("success")
                PhotoManager().saveVideoToUserLibrary(fileUrl: assetExport.outputURL!) { (success, error) in
                    if success {
                        print("File saved to photos")
                        self.uploadSpod.isHidden = true
                        self.exitButton.isHidden = false
                    } else {
                        print("File not saved to photos")
                    }
                }
                break
            case .cancelled:
                print("cancelled")
                break
            case .exporting:
                print("exporting")
                break
            case .failed:
                print("failed: \(String(describing: assetExport.error))")
                break
            case .unknown:
                print("unknown")
                break
            case .waiting:
                print("waiting")
                break
            }
        })
    }
    
    // MARK: Helpers 
    
    func fileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyhhmmss"
        return formatter.string(from: Date()) + ".mp4"
    }
    
    
   
    
    // MARK: Properties 
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadSpod: UIActivityIndicatorView!
    
    let album = Album.shared.fullAlbum
    var fileLocation: URL?
    var newUrl: URL?
}
