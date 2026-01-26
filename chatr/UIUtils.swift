//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import UIKit

class UIUtils{
    
    class func getCurrentViewController() -> UIViewController{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var topController = appDelegate.window?.rootViewController
        
        if (nil != topController) {
            var presentedViewController = topController!.presentedViewController
            //Loop until there are no more view controllers to go to
            while (nil != presentedViewController){
                topController = presentedViewController
                presentedViewController = topController!.presentedViewController
            }
        }
        //Return the final view controller
        return topController!
    }
}
