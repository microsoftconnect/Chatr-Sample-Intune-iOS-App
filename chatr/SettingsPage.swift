//
//  SettingsPage.swift
//  chatr
//
//  Created by Wilson Spearman on 1/9/19.
//  Copyright © 2019 Microsoft Intune. All rights reserved.
//

import UIKit

class SettingsPage: UIViewController {
    @IBOutlet weak var displayConsoleButton: UIButton!
    
    //Listener for diagnostic console button
    @IBAction func displayConsoleTapped(_ sender: Any) {
        //when button is tapped, display console
        displayConsole()
    }

    func displayConsole(){
        //use objectiveC function to call the necessary Intune method
        ObjCUtils.displayConsole()
    }
}
