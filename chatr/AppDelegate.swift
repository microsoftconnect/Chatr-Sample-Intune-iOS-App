//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let enrollmentDelegate = EnrollmentDelegateClass.init()
    let policyDelegate = PolicyDelegateClass.init()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let storyboard: UIStoryboard = UIStoryboard(name:"Main", bundle: Bundle.main)
        
        //check for enrolled account
        let currentUser = IntuneMAMEnrollmentManager.instance().enrolledAccount()
        if nil != currentUser && !currentUser!.isEmpty {
            //if an account is enrolled, skip over login page to main page
            //Do this by setting the main chat page to the rootViewController
            let mainPage = storyboard.instantiateViewController(withIdentifier: "ChatPage")
            self.window?.rootViewController = mainPage
        } else{
            //if not logged in, set the login page to the rootViewController
            let loginPage = storyboard.instantiateViewController(withIdentifier: "LoginPage")
            self.window?.rootViewController = loginPage
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        //Set the delegate of the IntuneMAMPolicyManager to an instance of the PolicyDelegateClass
        IntuneMAMPolicyManager.instance().delegate = self.policyDelegate
        
        //Set the delegate of the IntuneMAMEnrollmentManager to an instance of the EnrollmentDelegateClass
        IntuneMAMEnrollmentManager.instance().delegate = self.enrollmentDelegate
        
        return true
    }

}

