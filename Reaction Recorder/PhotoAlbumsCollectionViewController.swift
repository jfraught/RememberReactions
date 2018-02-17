//
//  PhotoAlbumsCollectionViewController.swift
//  Reaction Recorder
//
//  Created by Jordan Fraughton on 5/20/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class PhotosAlbumsCollectionViewController: UICollectionViewController, CLLocationManagerDelegate {
    
    // Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        album.fetchFirstImage()
        requestLocationService()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("collectionView")
        print("album.firstImageArray.count = \(album.firstImageArray.count)")
        return album.firstImageArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userCollectionCell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = album.firstImageArray[indexPath.row]
        imageView.layer.cornerRadius = 8.0
        let albumLabel = cell.viewWithTag(2) as! UILabel
        albumLabel.text = album.albumNameArrary[indexPath.row]
        return cell
    }
    
    // MARK: - Navigation 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toStartSlideshow" {
            
            if let slideshowViewController = segue.destination as? StartSlideshowViewController, let selectedCollection = collectionView?.indexPathsForSelectedItems {
                
                let index = selectedCollection
                slideshowViewController.index = index[0].row
                album.index = index[0].row 
            }
        }
    }
    
    // MARK: - Helpers
    
    func requestLocationService() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        print("Requesting service.")
    }
    
    // MARK: - Propeties
    
    @IBOutlet var albumCollectionView: UICollectionView!
    let album = Album.shared
    let locationManager = CLLocationManager()
    var collectionCell: UICollectionViewCell?
}
