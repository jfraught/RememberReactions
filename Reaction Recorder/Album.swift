//
//  Album.swift
//  Reaction Recorder
//
//  Created by Jordan Fraughton on 6/15/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import Foundation
import Photos

class Album {

    init() {
        let fetchedUserCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: PHFetchOptions())
        
        // TODO: - loop through userResults
        for i in 0..<fetchedUserCollections.count {
            let album = fetchedUserCollections.object(at: i)
            let albumAssets = PHAsset.fetchAssets(in: album, options: PHFetchOptions())
            if albumAssets.count > 0 {
                newUserCollections.append(album)
            }
        }
        self.userCollections = fetchedUserCollections
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
    }
    
    // MARK: - Actions
  
    func fetchFirstImage() {

        // Loop through user collections and take the first image of each collection and append it to the array.
        
        if newUserCollections.count > 0 {
            var hasLooped = 0
            
            for i in 0..<newUserCollections.count {
                hasLooped += 1
                let album = newUserCollections[i]
                
                guard let firstImageAsset = PHAsset.fetchAssets(in: album, options: PHFetchOptions()).firstObject else { return }
                guard let albumName = album.localizedTitle else { return }
                albumNameArrary.append(albumName)
                
                imgManager.requestImage(for: firstImageAsset, targetSize: CGSize.init(width: 175, height: 175), contentMode: .default, options: requestOptions, resultHandler:
                    {
                        image, error in
                        
                        if let firstImage = image {
                            self.firstImageArray.append(firstImage)
                        }
                })
                
            }
        }
    }
    
    func fetchFullAlbumWith(index: Int) {
        self.timesArray = []
        // Fetch required album and convert to [UIImage]
        
        let album = newUserCollections[index]
        
        let albumAssets = PHAsset.fetchAssets(in: album, options: PHFetchOptions())
        
        self.fullAlbum = []
        if albumAssets.count > 0 {
        for i in 0..<albumAssets.count {
            
            imgManager.requestImage(for: albumAssets[i], targetSize: .init(width: 1000, height: 1000), contentMode: .aspectFill, options: requestOptions, resultHandler:
                {
                    image, error in
                    
                    if let newImage = image {
                        self.fullAlbum.append(newImage)
                    }
                })
        }
        print("This is the full album.count \(fullAlbum.count)")
        }
    }
    
    func startTimesForSegments() {
        startTimes = [0]
        for i in 0..<timesArray.count {
            if i == 0 {
            } else {
                let startTime: Int = startTimes[i-1] + timesArray[i-1]
                startTimes.append(startTime)
            }
            
        }
    }
    
    // MARK: - Properties
    var index = 0 
    let requestOptions = PHImageRequestOptions()
    static let shared = Album()
    var newUserCollections: [PHAssetCollection] = []
    let userCollections: PHFetchResult<PHAssetCollection>
    var firstImageArray: [UIImage] = []
    var albumNameArrary: [String] = []
    var fullAlbum: [UIImage] = []
    let imgManager = PHImageManager.default()
    let fetchOptions = PHFetchOptions()
    var timesArray: [Int] = []
    var startTimes: [Int] = [0]
    
}
