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
        IntuneMAMDiagnosticConsole.display(inDarkMode: false)
    }
    
    override func viewDidLoad() {
        self.backButton.setImage(#imageLiteral(resourceName: "backarrow.png"), for: UIControl.State.normal)
        self.backButton.imageView!.contentMode = .scaleAspectFit
    }
}
