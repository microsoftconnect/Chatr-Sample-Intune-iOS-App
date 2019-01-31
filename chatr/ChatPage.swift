//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//
//  Code for sidebar implementation adopted from: https://youtu.be/GOSIz7JbZMA by Yogesh Patel
//  Code for alert message adopted from: https://www.simplifiedios.net/ios-show-alert-using-uialertcontroller/ by Belal Khan
//  Code for print adopted from: https://stackoverflow.com/questions/32403634/airprint-contents-of-a-uiview answer by Jody Heavener
//  Other inspiration: https://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift responses by EI Captain v2.0 and Dharmesh Kheni
//
//

import UIKit

// global variable used for saving conversations
var conversation:[(sender:String, message:NSAttributedString)] = []

class ChatPage: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // variable used to keep track of whether the send button is already displayed
    var alreadyDisplayedSendButton = false
    
    // variables used for creating the sidebar
    @IBOutlet weak var sideBarTable: UITableView!
    var isMenu:Bool = false                                         // variable that indicates if the menu is being  displayed
    let sideBarFeatures = ["Save","Print", "About us","Settings", "Log out"]   // the options on the sidebar
    let sideBarImg = [#imageLiteral(resourceName: "save"),#imageLiteral(resourceName: "print"),#imageLiteral(resourceName: "information"),#imageLiteral(resourceName: "settings"),#imageLiteral(resourceName: "profile")]                                  // images for the sidebar options
    
    
    // variables used for chat
    @IBOutlet weak var typedChatView: UITextView!
    @IBOutlet weak var chatTable: UITableView!
    
    // variables used for printing
    @IBOutlet var wholePageView: UIView!
    
    // variable to display user name on top of the chat page, default set to 'Chatr'
    // Onpage load: updated to be user's first name based on targetted app config
    @IBOutlet weak var userFirstName: UITextField!
    
    // variable to move textfield for keyboard actions
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    //variable to reference the position and dimensions of the top bar
    @IBOutlet weak var topBarView: UIView!
    
    /*!
        Button action triggered when send button is pressed on chat page
     
        Empties out the text field, creates a new view with the message and triggers a response.
     
        This function also stores the message in the keychain using the KeychainManager
     */
    @IBAction func sendChat(_ sender: UIButton) {
        //First format the string appropriately
        let align = NSMutableParagraphStyle()
        align.alignment = .right
        let fromMessage = NSMutableAttributedString(string: typedChatView.text!, attributes: [.paragraphStyle: align])
        
        //Only take action if there is text in the message
        if fromMessage.length != 0 {
            //Reset the entry field
            typedChatView.text = ""
            
            //When any message is sent, delete any draft message in the keychain
            KeychainManager.deleteDraftMessage(forUser: ObjCUtils.getSignedInUser()!)
            displayChatMessage(message: fromMessage)
            
            //Add the message to the stored messages in the keychain
            KeychainManager.storeSentMessage(sentMessage: fromMessage.string, forUser: ObjCUtils.getSignedInUser())
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
        replyChat()
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
            
            displayChatMessage(message: fromMessage)
        }
    }
    
    /*
     Function used to save a drafted message in the message entry field.
     If a draft message is present, then it will be saved to the keychain using the KeychainManager class.
    */
    @objc public func saveDraftedMessage(){
        if let currentUser = ObjCUtils.getSignedInUser() {
            //Save any draft message to the keychain using the KeychainManager class
            KeychainManager.storeDraftMessage(draftMessage: typedChatView.text!, forUser: currentUser)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prevent the display of empty cells at the bottom of the sidebar menu by adding a zero height table footer view
        sideBarTable.tableFooterView = UIView(frame: CGRect(x:0, y:0, width: 0, height: 0))
        sideBarTable.tableFooterView?.isHidden = true
        sideBarTable.backgroundColor = UIColor.clear
        
        //ensures self-sizing sidebar table view cells
        //the sidebar table view will use Auto Layout constraints and the cell's contents to determine each cell's height
        sideBarTable.estimatedRowHeight = 40
        sideBarTable.rowHeight = UITableView.automaticDimension
        
        // when the view is loaded, hide the sidebar table
        sideBarTable.isHidden = true
        isMenu = false
        
        // round the corners of the chat view
        typedChatView.layer.cornerRadius = 10
        
        // change user's group name on top of the chat page, one of the app config settings
        userFirstName.text = ObjCUtils.getUserGroupName()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        //Check the keychain for chat messages and drafted messages to load into the view
        let currentUser: String = ObjCUtils.getSignedInUser()!
        if let messageArray: [String] = KeychainManager.getSentMessages(forUser: currentUser){
            //If messages are present, populate the screen with them
            self.populateChatScreen(messageArray: messageArray)
        }
        let draftMessage: String? = KeychainManager.getDraftedMessage(forUser: currentUser)
        if draftMessage != nil{
            //If a draft message is present, add it to the message entry bar
            typedChatView.text = draftMessage!
        }
        
        //Add an observer to save any drafted message when the app terminates
        NotificationCenter.default.addObserver(self, selector: #selector(ChatPage.saveDraftedMessage), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    //programmatically create send button after Auto Layout lays out the main view and subviews
    override func viewDidLayoutSubviews() {
        //ensures a new send button is not added every time a message is sent in the chat
        if !alreadyDisplayedSendButton {
            
            let sendButton = UIButton(frame: CGRect(x: typedChatView.frame.origin.x + typedChatView.frame.width + 4, y: typedChatView.frame.origin.y - 4, width: 57, height: 39))
            sendButton.backgroundColor = .clear
            sendButton.setTitle("SEND", for: .normal)
            sendButton.addTarget(self, action: #selector (sendChat), for: .touchUpInside)
            
            self.view.addSubview(sendButton)
            
            alreadyDisplayedSendButton = true
        }
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
        }
    }
    
    //hide the keyboard when the user taps the return key
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
        }
        return true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == sideBarTable {          // this is the sideBar table
            return sideBarFeatures.count
        } else {                                // this is the conversations table
            return conversation.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == sideBarTable {
            let cell:SideBarTableCell = tableView.dequeueReusableCell(withIdentifier: "sideCell") as! SideBarTableCell
            cell.cellImg.image = sideBarImg[indexPath.row]
            cell.cellLbl.text = sideBarFeatures[indexPath.row]
            return cell
        } else {
            let sendMessageCell:chatTableViewCell = chatTable.dequeueReusableCell(withIdentifier: "chatCell") as! chatTableViewCell
            
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
        sideBarTable.isHidden = false
        
        if !isMenu {
            // reveal sideBar menu
            isMenu = true
            sideBarTable.frame = CGRect(x: 0, y: topBarView.frame.height + topBarView.frame.origin.y, width: 0, height: 301)
            UIView.setAnimationDuration(0.15)
            UIView.setAnimationDelegate(self)
            UIView.beginAnimations("sideBarAnimation", context: nil)
            sideBarTable.frame = CGRect(x: 0, y: topBarView.frame.height + topBarView.frame.origin.y, width: 176, height: 301)
            UIView.commitAnimations()
        }
        else {
            hideSideBarMenu()
        }
    }
    
    /*!
        Hides the sidebar menu
     */
    func hideSideBarMenu() {
        // hide sideBar menu
        sideBarTable.isHidden = true
        isMenu = false
        sideBarTable.frame = CGRect(x: 0, y: topBarView.frame.height + topBarView.frame.origin.y, width: 176, height: 301)
        UIView.setAnimationDuration(0.15)
        UIView.setAnimationDelegate(self)
        UIView.beginAnimations("sideBarAnimation", context: nil)
        sideBarTable.frame = CGRect(x: 0, y: topBarView.frame.height + topBarView.frame.origin.y, width: 0, height: 301)
        UIView.commitAnimations()
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
        if tableView == sideBarTable {
            let sideBarOption = SideBarOptions(rawValue: indexPath.row)
            // Complete an action based on the item pressed on the sidebar
            switch sideBarOption {
            case .save?:
                // Check if save is allowed by policy
                if ObjCUtils.isSaveToLocalDriveAllowed() {
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
                    printConvo()
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
                //Log out user
                ObjCUtils.logout()
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
        hideSideBarMenu() // hide the side bar before you move on
        
        //Provide basic information about print job
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfo.OutputType.general
        printInfo.jobName = "Print Chat Page"

        //Initialize a controller to handle the print
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        //Convert the current view to the image that will be printed
        printController.printingItem = wholePageView.toImage()
        //Present the print UI to the user
        printController.present(animated: true, completionHandler: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //When the view disappears, clear the chat page as it will be reloaded when the page is displayed again.
        self.clearChatPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Save the draft message if there is one present
        saveDraftedMessage()
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
            newFormat.append(element.0)
            newFormat.append(": ")
            newFormat.append((element.1).string)
            newFormat.append("\n")
        }
        return newFormat
    }
    
    //return the URL of the file in the document directory
    func fileURL(fileName: String) -> URL {
        let url: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url.appendingPathComponent(fileName).appendingPathExtension("txt")
    }
    
    //write the conversation text to the file in the document directory
    func writeFile(fileContent: String, fileName: String) {
        //let url = self.fileURL(fileName: fileName)
        let url: URL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        do {
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
