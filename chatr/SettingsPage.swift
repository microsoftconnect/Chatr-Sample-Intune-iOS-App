//
//  SettingsPage.swift
//  chatr
//
//  Created by Wilson Spearman on 1/9/19.
//  Copyright © 2019 Microsoft Intune. All rights reserved.
//

import UIKit

class SettingsPage: UIViewController {
    //connection to the switch on the page
    @IBOutlet weak var consoleSwitch: UISwitch!
    //connection to the UIView for the console
    @IBOutlet weak var consoleView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Listener for switch toggle
    @IBAction func switchToggled(_ sender: Any) {
        toggleConsole()
    }
    
    func toggleConsole(){
        if consoleSwitch.isOn {
            consoleView.isHidden = false
            ObjCUtils.displayConsole()
        } else {
            consoleView.isHidden = true
        }
    }
}
