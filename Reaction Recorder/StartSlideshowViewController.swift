//
//  StartSlideshowViewController.swift
//  Reaction Recorder
//
//  Created by Jordan Fraughton on 6/19/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import UIKit
import AVFoundation

class StartSlideshowViewController: UIViewController {
    @IBOutlet weak var startSlideshowImage: UIImageView!
    @IBOutlet weak var slideshowNameLabel: UILabel!
    
    var index: Int? {
        didSet {
            if isViewLoaded { updateViews() }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        requestCamera()
        requestMicrophone()
    }
    
    private func updateViews() {
        guard let index = index else { return }
        slideshowNameLabel.text = Album.shared.albumNameArrary[index]
        let image = Album.shared.firstImageArray[index]
        startSlideshowImage.image = image
    
    }
    
    // MARK: - Helpers
    
    func requestCamera() {
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                //access granted
            } else {
                
            }
        }
    }
    
    func requestMicrophone() {
        //Microphone
        AVCaptureDevice.requestAccess(for: AVMediaType.audio) { response in
            if response {
                //access granted
                
            } else {
                
            }
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem
    }
}
