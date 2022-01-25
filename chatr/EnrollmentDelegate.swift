//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import IntuneMAMSwift

/*
 This enrollment delegate class can be initialized and set as the enrollment delegate of the IntuneMAMEnrollmentManager
 Doing this will trigger the enrollmentRequestWithStatus method whenever an enrollment is attempted.
 It can also be used to trigger unenrollRequestWithStatus whenever unenrollment is attempted.
 This allows for the app to check if an enrollment was successful
 
 NOTE: A number of other methods are avaliable in the IntuneMAMEnrollmentDelegate. See documentation or header file for more info.
 */
class EnrollmentDelegateClass: NSObject, IntuneMAMEnrollmentDelegate {
    
    var presentingViewController: UIViewController?
    
    override init() {
        super.init()
        self.presentingViewController = nil
    }
    
    /*
     To be able to change the view, the class should be initialzed with the curent view controller. Then this view controller can move to the desired view based on the enrollment success
     
     @param viewController - the view controller this class should use when triggered
     */
    init(viewController : UIViewController){
        super.init()
        self.presentingViewController = viewController
    }
    
    /*
     This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an enrollment is attempted.
     The status parameter is a member of the IntuneMAMEnrollmentStatus class. This object can be used to check for the status of an attempted enrollment
     If successful, logic for enrollment is initiated
     */
    func enrollmentRequest(with status: IntuneMAMEnrollmentStatus) {
        if status.didSucceed{
            //If enrollment was successful, change from the current view (which should have been initialized with the class) to the desired page on the app (in this case ChatPage)
            print("Login successful")
            
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let chatPage = storyboard.instantiateViewController(withIdentifier: "ChatPage")
            if nil != self.presentingViewController {
                self.presentingViewController!.present(chatPage, animated: false, completion: nil)
            } else {
                print("Warning: EnrollmentDelegate initialized without a view controller before attempting enrollment.")
                UIUtils.getCurrentViewController().present(chatPage, animated: false, completion: nil)
            }
            
        } else if IntuneMAMEnrollmentStatusCode.loginCanceled != status.statusCode {
            //In the case of a failure, log failure error status and code
            print("Enrollment result for identity \(status.identity) with status code \(status.statusCode)")
            print("Debug message: \(String(describing: status.errorString))")
            
            //Present the user with an alert asking them to sign in again.
            let alert = UIAlertController(title: "Error Authenticating", message: "There was an error while logging you into your account. Please check your log in credentials and try again.", preferredStyle: .alert)
            let closeAlert = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            alert.addAction(closeAlert)
            if nil != self.presentingViewController {
                    self.presentingViewController!.present(alert, animated: true, completion: nil)
            } else {
                print("Warning: EnrollmentDelegate initialized without a view controller before attempting enrollment.")
                UIUtils.getCurrentViewController().present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /*
     This is a method of the delegate that is triggered when an instance of this class is set as the delegate of the IntuneMAMEnrollmentManager and an unenrollment is attempted.
     The status parameter is a member of the IntuneMAMEnrollmentStatus class. This object can be used to check for the status of an attempted unenrollment.
     Logic for logout/token clearing is initiated here.
     */
    func unenrollRequest(with status: IntuneMAMEnrollmentStatus) {
        //Go back to login page from current view controller
        let presentingViewController = UIUtils.getCurrentViewController()
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let loginPage = storyboard.instantiateViewController(withIdentifier: "LoginPage")
        
        presentingViewController.present(loginPage, animated: true, completion: nil)
        
        if status.didSucceed != true {
            //In the case unenrollment failed, log error
            print("Unenrollment result for identity \(status.identity) with status code \(status.statusCode)")
            print("Debug message: \(String(describing: status.errorString))")
        }
    }
}
