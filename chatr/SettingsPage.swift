//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import IntuneMAMSwift

class SettingsPage: UIViewController {
    @IBOutlet weak var displayConsoleButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        self.backButton.setImage(#imageLiteral(resourceName: "backarrow.png"), for: UIControl.State.normal)
        self.backButton.imageView!.contentMode = .scaleAspectFit
        self.backButton.addTarget(self, action: #selector (self.dismiss), for: .touchUpInside)
    }
    
    //Listener for diagnostic console button
    @IBAction func displayConsoleTapped(_ sender: Any) {
        //when button is tapped, display console
        IntuneMAMDiagnosticConsole.display()
    }

    //Button action triggered when back button is pressed on the settings page
    //Dismisses the view.
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
