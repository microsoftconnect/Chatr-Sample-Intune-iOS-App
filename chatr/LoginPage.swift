//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

class LoginPage: UIViewController {
    /*
     Button action triggered when user presses the log in button
     
     Sends the user through the Intune Authentication flow for logging in.
     Triggers the "homePage" segue if login is successful; raises an alert if there is an error.
    */
    @IBAction func logInBtn(_ sender: Any) {
        //Set the delegate of the IntuneMAMEnrollmentManager as an instance of the EnrollmentDelegateClass to check the status of attempted enrollments. Also initialize this class with the current view controller
        //This is done on launch, but here it is done again to give the delegate the current view controller
        let enrollmentDelegate = EnrollmentDelegateClass.init(viewController: self)
        IntuneMAMEnrollmentManager.instance().delegate = enrollmentDelegate
        
        //Login the user through the Intune sign in flow. EnrollmentDelegateClass will handle the outcome of this.
        IntuneMAMEnrollmentManager.instance().loginAndEnrollAccount(nil)
    }
}

