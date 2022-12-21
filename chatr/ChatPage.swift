//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import IntuneMAMSwift

// global variable used for saving conversations
var conversation:[(sender:String, message:NSAttributedString)] = []

class ChatPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // variable used to keep track of whether the send button is already displayed
    var alreadyDisplayedSendButton = false
    
    //variable for the currently enrolled user
    var currentUser: String!
    
    // variables used for creating the sidebar
    @IBOutlet weak var sideBarTable: UITableView!
    var isMenu:Bool = false                                         // variable that indicates if the menu is being  displayed
    let sideBarFeatures = ["Save","Print", "About us","Settings", "Log out"]   // the options on the sidebar
    let sideBarImg = [#imageLiteral(resourceName: "save"),#imageLiteral(resourceName: "print"),#imageLiteral(resourceName: "information"),#imageLiteral(resourceName: "settings"),#imageLiteral(resourceName: "profile")]                                  // images for the sidebar options
    var menuWidthConstraint: NSLayoutConstraint!                   // Contraint to animate the menu
    
    // variables used for chat
    @IBOutlet weak var typedChatView: UITextView!
    @IBOutlet weak var chatTable: UITableView!
    
    // variables used for printing
    @IBOutlet var wholePageView: UIView!
    
    // variable to display group name on top of the chat page, default set to 'Chatr'
    // Onpage load: updated to be user's group name based on targeted app config
    @IBOutlet weak var groupName: UITextField!
    
    // variable to move textfield for keyboard actions
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    //variable to reference the position and dimensions of the top bar
    @IBOutlet weak var topBarView: UIView!
    
    //variable to store initial save by policy permissions
    var isSaveAllowed = Bool()
    
    //override the ChatPage View Controller initializer
    required init? (coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        //register for the IntuneMAMAppConfigDidChange notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onIntuneMAMAppConfigDidChange),
                                               name: NSNotification.Name.IntuneMAMAppConfigDidChange,
                                               object: IntuneMAMAppConfigManager.instance())
        
        //register for the IntuneMAMPolicyDidChange notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onIntuneMAMPolicyDidChange),
                                               name: NSNotification.Name.IntuneMAMPolicyDidChange,
                                               object: IntuneMAMPolicyManager.instance())
        
        //Get the current user
        self.currentUser = IntuneMAMEnrollmentManager.instance().enrolledAccount()!
        
        //query the app policy and update the initial save-as policy permissions
        self.isSaveAllowed = self.getSaveStatus()
    }
    
    @objc func onIntuneMAMAppConfigDidChange() {
        //query the app config and update the user name on the top of the chat page
        self.groupName.text = self.getUserGroupName()
    }
    
    @objc func onIntuneMAMPolicyDidChange() {
        self.isSaveAllowed = self.getSaveStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prevent the display of empty cells at the bottom of the sidebar menu by adding a zero height table footer view
        self.sideBarTable.tableFooterView = UIView(frame: CGRect(x:0, y:0, width: 0, height: 0))
        self.sideBarTable.tableFooterView?.isHidden = true
        self.sideBarTable.backgroundColor = UIColor.clear
        
        //ensures self-sizing sidebar table view cells
        //the sidebar table view will use Auto Layout constraints and the cell's contents to determine each cell's height
        self.sideBarTable.estimatedRowHeight = 40
        self.sideBarTable.rowHeight = UITableView.automaticDimension
        
        // when the view is loaded, hide the sidebar table
        self.sideBarTable.isHidden = true
        self.isMenu = false
        
        // round the corners of the chat view
        self.typedChatView.layer.cornerRadius = 10
        
        // change user's group name on top of the chat page, one of the app config settings
        self.groupName.text = self.getUserGroupName()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        //Check the keychain for chat messages and drafted messages to load into the view
        if let messageArray: [String] = KeychainManager.getSentMessages(forUser: self.currentUser){
            //If messages are present, populate the screen with them
            self.populateChatScreen(messageArray: messageArray)
        }
        let draftMessage: String? = KeychainManager.getDraftedMessage(forUser: self.currentUser)
        if nil != draftMessage{
            //If a draft message is present, add it to the message entry bar
            self.typedChatView.text = draftMessage!
        }
        
        //Add an observer to save any drafted message when the app terminates
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveDraftedMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    //programmatically create send button after Auto Layout lays out the main view and subviews
    override func viewDidLayoutSubviews() {
        //ensures a new send button is not added every time a message is sent in the chat
        if !self.alreadyDisplayedSendButton {
            
            let sendButton = UIButton(frame: CGRect(x: self.typedChatView.frame.origin.x + self.typedChatView.frame.width + 4, y: self.typedChatView.frame.origin.y - 4, width: 57, height: 39))
            sendButton.backgroundColor = .clear
            sendButton.setTitle("SEND", for: .normal)
            sendButton.addTarget(self, action: #selector (self.sendChat), for: .touchUpInside)
            
            self.view.addSubview(sendButton)
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            sendButton.bottomAnchor.constraint(equalTo: self.typedChatView.bottomAnchor).isActive = true
            sendButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8).isActive = true
            
            self.alreadyDisplayedSendButton = true
        }
    }
    
    /*!
        Button action triggered when send button is pressed on chat page
     
        Empties out the text field, creates a new view with the message and triggers a response.
     
        This function also stores the message in the keychain using the KeychainManager
     */
    @IBAction func sendChat(_ sender: UIButton) {
        //First format the string appropriately
        let align = NSMutableParagraphStyle()
        align.alignment = .right
        let fromMessage = NSMutableAttributedString(string: self.typedChatView.text!, attributes: [.paragraphStyle: align])
        
        //Only take action if there is text in the message
        if 0 != fromMessage.length {
            //Reset the entry field
            self.typedChatView.text = ""
            //When any message is sent, delete any draft message in the keychain
            _ = KeychainManager.deleteDraftMessage(forUser: self.currentUser)
            self.displayChatMessage(message: fromMessage)
            
            //Add the message to the stored messages in the keychain
            KeychainManager.storeSentMessage(sentMessage: fromMessage.string, forUser: self.currentUser)
            //Scroll to the bottom of this message
            self.scrollToBottom(animated: true)
        }
    }
    
    /*
    Helper function that takes a formatted message, displays it on the chat page table, and calls replyChat to add a response message.
    */
    func displayChatMessage(message:NSAttributedString) {
        //Add the message to the data source for the chatTable
        conversation.append((sender: "from", message: message))
            
        //Update the message board to include the new message
        self.chatTable.beginUpdates()
        self.chatTable.insertRows(at: [IndexPath.init(row: conversation.count-1, section: 0)], with: .automatic)
        self.chatTable.endUpdates()
            
        // send the reply
        self.replyChat()
    }
    
   /*!
        Creates a response message with links to the documentation and adds it to the chat view.
        Called each time a message is sent.
    */ 
    func replyChat() {
        
        //create reply message
        let developerGuide: [NSAttributedString.Key : Any] = [.link: NSURL(string: "https://docs.microsoft.com/intune/app-sdk-ios")!, .foregroundColor: UIColor.blue]
        let faqPage: [NSAttributedString.Key : Any] = [.link : NSURL(string: "https://docs.microsoft.com/intune/app-sdk-ios#faqs")!, .foregroundColor: UIColor.blue]
        
        let align = NSMutableParagraphStyle()
        align.alignment = .left
        
        let replyMessage = NSMutableAttributedString(string: "Please refer to our documentation and read our faq page for any outstanding concerns. \nThank you.", attributes: [.paragraphStyle: align])
        replyMessage.setAttributes(developerGuide, range: NSMakeRange(20, 13))
        replyMessage.setAttributes(faqPage, range: NSMakeRange(47, 3))
        
        // add it to the conversation list
        conversation.append((sender: "to", message: replyMessage))
        
        //update the message board to include the reply
        self.chatTable.beginUpdates()
        self.chatTable.insertRows(at: [IndexPath.init(row: conversation.count-1, section: 0)], with: .automatic)
        self.chatTable.endUpdates()
    }
        
    /*
     Function used to clear the chat page messages from the screen
     */
    func clearChatPage(){
        //First clears the array that is a data source for the chat table
        conversation.removeAll()
        //Then realoads the chat table with the empty data source
        self.chatTable.reloadData()
    }
    
    /*
     Function used to display a group of messages on the chat page.
     @param messageArray: the array of messages to display
    */
    public func populateChatScreen(messageArray: [String]){
        for message in messageArray{
            //For every string from the message array, format it and display it
            let align = NSMutableParagraphStyle()
            align.alignment = .right
            let fromMessage = NSMutableAttributedString.init(string: message, attributes: [.paragraphStyle: align])
            
            self.displayChatMessage(message: fromMessage)
        }
    }
    
    /*
     Function used to save a drafted message in the message entry field.
     If a draft message is present, then it will be saved to the keychain using the KeychainManager class.
    */
    @objc public func saveDraftedMessage(){
        //Save any draft message to the keychain using the KeychainManager class
        KeychainManager.storeDraftMessage(draftMessage: typedChatView.text!, forUser: self.currentUser)
    }
    
    //Scrolls to the bottom of the table view
    func scrollToBottom(animated: Bool) {
        if self.chatTable.numberOfRows(inSection: 0) > 0 {
            let index = IndexPath(row: self.chatTable.numberOfRows(inSection: 0)-1, section: 0)
            self.chatTable.scrollToRow(at: index, at: .bottom, animated: animated)
        }
    }
    
    func getUserGroupName() -> String{
        // Get the GroupName value for the user - key value pairing set in the portal
		let groupNameKey = "GroupName"
        let data = IntuneMAMAppConfigManager.instance().appConfig(forIdentity: self.currentUser)
        
        // If there are no conflicts for that key, find the value associated with the key
        if !data.hasConflict(groupNameKey){
            if let groupName = data.stringValue(forKey: groupNameKey, queryType: IntuneMAMStringQueryType.any){
                return groupName
            }
        } else {
            // Resolve the conflict by taking the max value
            return data.stringValue(forKey: groupNameKey, queryType: IntuneMAMStringQueryType.max)!
        }
        return "Chatr" // Default, if no GroupName value is set
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 10.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = (endFrame?.size.height)! + 10.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
            
            if (endFrame?.size.height)! > 0.0 {
                //Scroll to the bottom of the message table if the keyboard is appearing
                self.scrollToBottom(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.sideBarTable {          // this is the sideBar table
            return self.sideBarFeatures.count
        } else {                                // this is the conversations table
            return conversation.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.sideBarTable {
            let cell:SideBarTableCell = tableView.dequeueReusableCell(withIdentifier: "sideCell") as! SideBarTableCell
            cell.cellImg.image = sideBarImg[indexPath.row]
            cell.cellLbl.text = sideBarFeatures[indexPath.row]
            return cell
        } else {
            let sendMessageCell = self.chatTable.dequeueReusableCell(withIdentifier: "chatCell") as! ChatTableViewCell
            
            sendMessageCell.messageView.attributedText = conversation[indexPath.row].message
            
            return sendMessageCell
        }
    }
    
    /*
        Button action triggered when the the Chatr logo button on the top left is clicked
     
        Reveals/hides the sideBar menu when the button is pressed depending on the state
            - If the menu was hidden when the button is pressed, then it will reveal the menu and vise versa.
     */
    @IBAction func sideBarMenu(_ sender: Any) {
        self.sideBarTable.isHidden = false
        
        if !isMenu {
            // reveal sideBar menu
            self.isMenu = true
            self.sideBarTable.frame = CGRect(x: 0, y: topBarView.frame.height + topBarView.frame.origin.y, width: 0, height: 341)
            self.menuWidthConstraint = self.sideBarTable.widthAnchor.constraint(equalToConstant: 176)
            self.sideBarTable.addConstraint(self.menuWidthConstraint)

            UIView.animate(withDuration: 0.15) {
                self.sideBarTable.frame = CGRect(x: 0, y: self.topBarView.frame.height + self.topBarView.frame.origin.y, width: 176, height: 341);
            }
        }
        else {
            self.hideSideBarMenu()
        }
    }
    
    /*!
        Hides the sidebar menu
     */
    func hideSideBarMenu() {
        self.isMenu = false
        self.sideBarTable.frame = CGRect(x: 0, y: topBarView.frame.height + topBarView.frame.origin.y, width: 176, height: 341)
        self.sideBarTable.removeConstraint(self.menuWidthConstraint)

        UIView.animate(withDuration: 0.15, animations: {
            self.sideBarTable.frame = CGRect(x: 0, y: self.topBarView.frame.height + self.topBarView.frame.origin.y, width: 0, height: 341);
        }) { (_ : Bool) in
            self.sideBarTable.isHidden = true
        }
    }
    
    //Enumeration that defines options within the side bar menu
    enum SideBarOptions: Int{
        case save = 0
        case print
        case aboutUs
        case settings
        case logout
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.sideBarTable {
            self.hideSideBarMenu()
            let sideBarOption = SideBarOptions(rawValue: indexPath.row)
            // Complete an action based on the item pressed on the sidebar
            switch sideBarOption {
            case .save?:
                // Check if save is allowed by policy
                if self.isSaveAllowed {
                    //Save the conversation and present success alert to user
                    self.saveConversation(fileName: "savedConversation", conversation: conversation)
                    
                    let alert = UIAlertController(title: "Conversation Saved",
                                                  message: "Your conversation has been successfully saved to your device.",
                                                  preferredStyle: .alert)
                    let closeAlert = UIAlertAction(title: "OK",
                                                   style: .default,
                                                   handler: nil)
                    alert.addAction(closeAlert)
                    present(alert, animated: true, completion: nil)
                }
                else {
                    // Alert the user that saving is disabled
                    let alert = UIAlertController(title: "Save Disabled",
                                                  message: "Saving conversations to local storage has been disabled by your IT admin.",
                                                  preferredStyle: .alert)
                    let closeAlert = UIAlertAction(title: "OK",
                                                   style: .default,
                                                   handler: nil)
                    alert.addAction(closeAlert)
                    present(alert, animated: true, completion: nil)
                }
            case .print?:
                //Check if printing is currently available
                //NOTE: While the Intune SDK can prevent printing, this is not the only reason that printing could be unavailable
                if UIPrintInteractionController.isPrintingAvailable{
                    //If printing is available, print the conversation
                    self.printConvo()
                } else {
                    // Alert the user that saving is unavailable
                    let alert = UIAlertController(title: "Printing Unavailable",
                                                  message: "Printing conversations is currently unavailable on this device.",
                                                  preferredStyle: .alert)
                    let closeAlert = UIAlertAction(title: "OK",
                                                   style: .default,
                                                   handler: nil)
                    alert.addAction(closeAlert)
                    present(alert, animated: true, completion: nil)
                }
                
            case .aboutUs?:
                //Display the about us page
                let aboutUs:AboutUsPage = self.storyboard?.instantiateViewController(withIdentifier: "aboutPage") as! AboutUsPage
                present(aboutUs, animated:true, completion: nil)
            case .settings?:
                //Display the settings page
                let settings:SettingsPage = self.storyboard?.instantiateViewController(withIdentifier: "settingsPage") as! SettingsPage
                present(settings, animated:true, completion: nil)
            case .logout?:
                //To log out user, deregister the user from the SDK and initate a selective wipe of the app
                //In the EnrollmentDelegate, the unenrollRequestWithStatus block is executed, and includes logic to wipe tokens on unenrollment
                IntuneMAMEnrollmentManager.instance().deRegisterAndUnenrollAccount(self.currentUser, withWipe: true)
			case .none:
				return;
			}
        }
    }
    
    /*!
        Presents the user with a print preview of the chat page.
        Called by the side bar table
    */
    func printConvo() {
        //Provide basic information about print job
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = "Print Chat Page"

        //Initialize a controller to handle the print
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        //Convert the current view to the image that will be printed
        printController.printingItem = self.wholePageView.toImage()
        //Present the print UI to the user
        printController.present(animated: true, completionHandler: nil)
    }
        
    func getSaveStatus() -> Bool {
        let policy = IntuneMAMPolicyManager.instance().policy(forIdentity: self.currentUser)
        if (nil == policy || (policy?.isSaveToAllowed(for: IntuneMAMSaveLocation.localDrive, withAccountName: self.currentUser))!){
            return true
        } else {
            return false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Save the draft message if there is one present
        self.saveDraftedMessage()
    }
    
    //Saves the conversation as a text file in the document directory of the application.
    func saveConversation(fileName: String, conversation: [(sender: String, message: NSAttributedString)]) {
        let newFormat = self.reformatConversation(conversation: conversation)
        self.writeFile(fileContent: newFormat, fileName: fileName)
    }
    
    //convert the array of (sender, message) tuples to a single string that represents the entire conversation
    func reformatConversation(conversation: [(sender: String, message: NSAttributedString)]) -> String {
        var newFormat = ""
        for element in conversation {
            newFormat.append(element.sender)
            newFormat.append(": ")
            newFormat.append((element.message).string)
            newFormat.append("\n")
        }
        return newFormat
    }
    
    //write the conversation text to the file in the document directory
    func writeFile(fileContent: String, fileName: String) {
        do {
            let url: URL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            try fileContent.write(to: url.appendingPathComponent(fileName).appendingPathExtension("txt"), atomically: true, encoding: .utf8)
        }catch let error {
            print("Error saving file: " + error.localizedDescription)
        }
    }
}

extension UIView {
    // converts a UIView to an image
    // used in the print() function for ChatPage
    func toImage() -> UIImage {
        // code logic modified from answer by Jody Heavener @ https://stackoverflow.com/questions/32403634/airprint-contents-of-a-uiview
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
