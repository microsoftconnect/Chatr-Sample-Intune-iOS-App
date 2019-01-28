//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//
import UIKit

class SettingsPage: UIViewController {
    @IBOutlet weak var displayConsoleButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    //Listener for diagnostic console button
    @IBAction func displayConsoleTapped(_ sender: Any) {
        //when button is tapped, display console
        displayConsole()
    }

    func displayConsole(){
        //use Objective-C function to call the necessary Intune method
        ObjCUtils.displayConsole()
    }
    
    override func viewDidLoad() {
        self.backButton.setImage(#imageLiteral(resourceName: "backarrow.png"), for: UIControlState.normal)
        self.backButton.imageView!.contentMode = .scaleAspectFit
    }
}
