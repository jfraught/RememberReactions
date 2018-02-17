//
//  Settings.swift
//  Reaction Recorder
//
//  Created by Jordan Fraughton on 8/18/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import Foundation

class Settings {

    // MARK: - Properties
    static let shared = Settings()

    var timerCount: Int
    var soundOn: Bool
    var isRecordingLabel: Bool
    
    init() {
        
        // Timer
        if let timerCountValue = UserDefaults.standard.value(forKey: "stepCount") as? Int {
            timerCount = timerCountValue
        } else {
            timerCount = 1
        }
        
        // Record Label
        if let recordLabelValue = UserDefaults.standard.value(forKey: "recordingLabel") as? Bool {
            if recordLabelValue == false {
                isRecordingLabel = false
            } else {
                isRecordingLabel = true 
            }
        } else {
            isRecordingLabel = true
        }
        
        // Sound Label
        if let soundLabelvalue = UserDefaults.standard.value(forKey: "soundOnLabel") as? Bool {
            if soundLabelvalue == false {
                soundOn = false
            } else {
                soundOn = true
            }
        } else {
            soundOn = true
        }
    }
}
