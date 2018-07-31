//
//  ViewController.swift
//  chatr
//
//  Created by Mesert Kebed on 6/20/18.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /*!
     @param button action triggered when user presses the log in button
     Sends the user through the ADAL Authentication flow for logging in
    */
    @IBAction func logInBtn(_ sender: Any) {
        ObjCUtils.getToken(self)
    }
    
    @IBAction func logOutBtn(_ sender: Any) {
        ObjCUtils.removeToken(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

