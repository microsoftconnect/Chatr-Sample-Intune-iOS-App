//
//  AboutUsPage.swift
//  chatr
//
//  Created by Mesert Kebed on 7/2/18.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

import UIKit

class AboutUsPage: UIViewController, UITextViewDelegate{

    @IBOutlet weak var aboutUsText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let developerGuide: [NSAttributedStringKey : Any] = [.link: NSURL(string: "https://docs.microsoft.com/en-us/intune/app-sdk-ios")!, .foregroundColor: UIColor.blue]
        
        let text = NSMutableAttributedString(string: "Chatr was built to demonstrate the integration of line-of-business apps with Microsoft Intune's iOS MAM SDK. Chatr is a messaging application that allows users to save and print their conversation transcript. \n \nMore information about the SDK is available here.")
        
        text.setAttributes(developerGuide, range: NSMakeRange(256, 4))
        
        self.aboutUsText.delegate = self
        self.aboutUsText.attributedText = text
        self.aboutUsText.isUserInteractionEnabled = true
        self.aboutUsText.isEditable = false
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
