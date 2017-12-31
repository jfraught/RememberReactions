//
//  LoadAlbumsViewController.swift
//  FaceR
//
//  Created by Jordan Fraughton on 12/29/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import UIKit
import Photos

class LoadAlbumsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                } else {}
            })
        }
        if photos == .authorized {
            self.performSegue(withIdentifier: "slideshowsSegue", sender: nil)
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        if photos == .authorized {
            self.performSegue(withIdentifier: "slideshowsSegue", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    let photos = PHPhotoLibrary.authorizationStatus()
}
