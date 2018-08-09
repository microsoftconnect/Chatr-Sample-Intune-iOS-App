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
     Button action triggered when user presses the log in button
     
     Sends the user through the ADAL Authentication flow for logging in.
     Triggers the "homePage" segue if login is successful; raises an alert if there is an error.
    */
    @IBAction func logInBtn(_ sender: Any) {
        ObjCUtils.getToken(self)
    }
    
    /*!
     Button action triggered when user presses the log out button
     
     Removes all of the token access for users of the app.
     */
    @IBAction func logOutBtn(_ sender: Any) {
        ObjCUtils.removeAppTokens()
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

