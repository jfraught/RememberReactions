//
//  SettingsTableViewController.swift
//  Reaction Recorder
//
//  Created by Jordan Fraughton on 8/17/17.
//  Copyright © 2017 Jordan Fraughton. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    // MARK: - Actions
    
    @IBAction func stepperWasTouched(_ sender: UIStepper) {
        stepCount = Int(sender.value)
        stepperCountLabel.text = String(stepCount)
        Settings.shared.timerCount = stepCount
        UserDefaults.standard.set(Settings.shared.timerCount, forKey: "stepCount")
    }
    
    @IBAction func recordingLabelSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "recordingLabel")
    }
    
    @IBAction func soundSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "soundOnLabel")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Stepper
        
        secondsStepper.value = Double(Settings.shared.timerCount)
        if let stepCountValue = UserDefaults.standard.value(forKey: "stepCount") as? Int {
            stepperCountLabel.text = "\(stepCountValue)"
            Settings.shared.timerCount = stepCountValue
        }
        
        // Is recording
        
        if let recordLabelValue = UserDefaults.standard.value(forKey: "recordingLabel") as? Bool {
            if recordLabelValue == true {
                recordingShownSwitch.isOn = true
            } else {
               recordingShownSwitch.isOn = false
            }
        }
        
        // Sound on
        
        if let soundLabelValue = UserDefaults.standard.value(forKey: "soundOnLabel") as? Bool {
            if soundLabelValue == true {
                recordWithSoundSwitch.isOn = true
            } else {
                recordWithSoundSwitch.isOn = false 
            }
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    // MARK: - Properties
    @IBOutlet weak var secondsStepper: UIStepper!
    @IBOutlet weak var stepperCountLabel: UILabel!
    @IBOutlet weak var recordingShownSwitch: UISwitch!
    @IBOutlet weak var recordWithSoundSwitch: UISwitch!
    
    var stepCount: Int = 1
}
