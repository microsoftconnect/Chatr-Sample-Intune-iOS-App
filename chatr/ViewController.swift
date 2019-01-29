//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /*!
     Button action triggered when user presses the log in button
     
     Sends the user through the Intune Authentication flow for logging in.
     Triggers the "homePage" segue if login is successful; raises an alert if there is an error.
    */
    @IBAction func logInBtn(_ sender: Any) {
        ObjCUtils.login(self)
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

