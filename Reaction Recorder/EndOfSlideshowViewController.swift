//
//  EndOfSlideshowViewController.swift
//  Reaction Recorder
//
//  Created by Jordan Fraughton on 8/22/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreLocation

class EndOfSlideshowViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Actions
    
    @IBAction func exitButtonTapped(_ sender: Any) {
        print("Exit button tapped")

        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is PhotosAlbumsCollectionViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func uploadButtonTapped(_ sender: Any) {
        uploadButton.isHidden = true
        uploadSpod.startAnimating()
        saveWithImages()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exitButton.isHidden = true
        location = getLocation()
    }

    func getLocation() -> CLLocation? {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingHeading()
        location = locationManager.location
        
        return location
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
    
        // I switched the naturalSize width and height because they were displaying in landscape. This way the video is portrait.
        
        let size = videoTrack.naturalSize
        
        // Video Layer
        
        let videoLayer = CALayer()
        videoLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.height, height: size.width)
        parentLayer.addSublayer(videoLayer)
      
        // Image Layer
        
        Album.shared.startTimesForSegments()
        
        for i in 0..<album.count {
            
            let image: UIImage = Album.shared.fullAlbum[i]
            let imageLayer = CALayer()
            if i == 0 {
                imageLayer.beginTime = Double(0)
            } else {
                imageLayer.beginTime = Double(Album.shared.startTimes[i])
            }
            
            imageLayer.duration = Double(Album.shared.timesArray[i])
            imageLayer.contents = image.cgImage
            imageLayer.frame = CGRect(x: 10, y:10, width: 250, height: 250)
            parentLayer.addSublayer(imageLayer)
            
        }
        
        // Location Layer
        
        let latitudeText = CATextLayer()
        if let lat = location?.coordinate.latitude {
            latitudeText.string = "Lat: \(lat)"
            latitudeText.font = UIFont(name: "Helvetica", size: 35)
            latitudeText.alignmentMode = kCAAlignmentLeft
            latitudeText.frame = CGRect(x: 10, y: size.width - 150, width: size.width, height: size.height / 6)
        }
        
        let longitudeText = CATextLayer()
        if let long = location?.coordinate.longitude {
            longitudeText.string = "Long: \(long)"
            longitudeText.font = UIFont(name: "Helvetica", size: 35)
            longitudeText.alignmentMode = kCAAlignmentLeft
            longitudeText.frame = CGRect(x: 10, y: size.width - 200, width: size.width, height: size.height / 6)
        }
        
        // Parent Layer
        
        parentLayer.addSublayer(latitudeText)
        parentLayer.addSublayer(longitudeText)
        
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
        
        // Setting the render size and frame duration
        
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
                print("success")
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
            PhotoManager().saveVideoToUserLibrary(fileUrl: assetExport.outputURL!, location: self.location) { (success, error) in
                if success {
                    print("File saved to photos")
                    self.finishedSaving = true
                } else {
                    print("File not saved to photos")
                }
            }

        })
        
        while assetExport.progress != 1.0  {
            // do nothing
        }
        print("While loop exit")
        updateViews()
    }
    
    // MARK: Helpers 
    
    func fileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMddyyhhmmss"
        return formatter.string(from: Date()) + ".mp4"
    }
    
    func updateViews() {
        exitButton.isHidden = false
        uploadButton.isHidden = true
        uploadSpod.isHidden = true
    }

    // MARK: Properties
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var uploadSpod: UIActivityIndicatorView!
    
    var exitButtonOn = false
    var spodOff = false
    let locationManager = CLLocationManager()
    var locationDegrees: Double = 0.0
    var location: CLLocation?
    var finishedSaving: Bool = false
    let album = Album.shared.fullAlbum
    var fileLocation: URL?
    var newUrl: URL?
}
