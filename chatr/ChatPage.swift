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
let savedConvo = UserDefaults.init()

class ChatPage: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // variables used for creating the sidebar
    @IBOutlet weak var sideBarView: UIView!
    @IBOutlet weak var sideBarTable: UITableView!
    var isMenu:Bool = false                                         // variable that indiates if the menu is being  displayed
    let sideBarFeatures = ["Save","Print", "About us","Settings", "Log out"]   // the options on the sidebar
    let sideBarImg = [#imageLiteral(resourceName: "save"),#imageLiteral(resourceName: "print"),#imageLiteral(resourceName: "information"),#imageLiteral(resourceName: "profile"),#imageLiteral(resourceName: "profile")]                                  // images for the sidebar options
    
    
    // variables used for chat
    @IBOutlet weak var typedChat: UITextField!
    @IBOutlet weak var chatTable: UITableView!
    
    // variables used for printing
    @IBOutlet var wholePageView: UIView!
    
    // variable to display user name on top of the chat page, default set to 'Chatr'
    // Onpage load: updated to be user's first name based on targetted app config
    @IBOutlet weak var userFirstName: UITextField!
    
    // variable to move textfield for keyboard actions
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    /*!
        Button action triggered when send button is pressed on chat page
     
        Empties out the text field, creates a new view with the message and triggers a response.
     
        This function also stores the message in they keychain using the KeychainManager
     */
    @IBAction func sendChat(_ sender: UIButton) {
        //First format the string appropriately
        let align = NSMutableParagraphStyle()
        align.alignment = .right
        let fromMessage = NSMutableAttributedString(string: typedChat.text!, attributes: [.paragraphStyle: align])
        
        //Only take action if there is text in the message
        if fromMessage.length != 0 {
            //Reset the entry field
            typedChat.text = ""
            
            //When any message is sent, delete any current entries in the keychain for draft messages
            KeychainManager.deleteItemForUser(user: ObjCUtils.getSignedInUser()! as NSString, key: "draftMessage")
            displayChatMessage(message: fromMessage)
            
            //Add the message to the stored messages in the keychain
            let messageArray = NSMutableArray.init(object: fromMessage.string as NSString)
            KeychainManager.addMessage(messages: messageArray, user:ObjCUtils.getSignedInUser() as NSString, key:"messages")
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
        let developerGuide: [NSAttributedStringKey : Any] = [.link: NSURL(string: "https://docs.microsoft.com/en-us/intune/app-sdk-ios")!, .foregroundColor: UIColor.blue]
        let faqPage: [NSAttributedStringKey : Any] = [.link : NSURL(string: "https://docs.microsoft.com/en-us/intune/app-sdk-ios#faqs")!, .foregroundColor: UIColor.blue]
        
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
    public func populateChatScreen(messageArray: NSMutableArray){
        for message in (messageArray as NSMutableArray as! [NSString]){
            //For every string from the message array, format it and display it
            let align = NSMutableParagraphStyle()
            align.alignment = .right
            let fromMessage = NSMutableAttributedString.init(string: message as String, attributes: [.paragraphStyle: align])
            
            displayChatMessage(message: fromMessage)
        }
    }
    
    /*
     Function used to check for a drafted message in the message entry bar. If a draft message is present, return it within an array.
     If no draft message is present, return nil.
    */
    @objc public func getDraftedMessageArray()->NSMutableArray?{
        if typedChat.text?.count != 0{
            let draftMessageArray = NSMutableArray.init(object: typedChat.text! as NSString)
            return draftMessageArray
        } else{
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // when the view is loaded, hide the sidebar table
        sideBarView.isHidden = true
        sideBarTable.backgroundColor = UIColor.groupTableViewBackground
        isMenu = false
        
        // change user's group name on top of the chat page, one of the app config settings
        userFirstName.text = ObjCUtils.getUserGroupName()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        //Check the keychain for chat messages and drafted messages to load into the view
        let currentUser = ObjCUtils.getSignedInUser()! as NSString
        if let messageArray: NSMutableArray = KeychainManager.getCurrentItem(user: currentUser, key:"messages"){
            //If messages are present, populate the screen with them
            self.populateChatScreen(messageArray: messageArray)
        }
        let draftMessageArray = KeychainManager.getCurrentItem(user: currentUser, key: "draftMessage")
        if draftMessageArray != nil{
            //If a draft message is present, add it to the message entry bar
            for message in (draftMessageArray! as NSMutableArray as! [String]){
                typedChat.text = message
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
            //sendMessageCell.sizeToFit()
            // TODO: Alter the size of the cell to match dimensions of the text
            //     
            return sendMessageCell
        }
    }
    
    /*
        Button action triggered when the the Chatr logo button on the top left is clicked
     
        Reveals/hides the sideBar menu when the button is pressed depending on the state
            - If the menu was hidden when the button is pressed, then it will reveal the menu and vise versa.
     */
    @IBAction func sideBarMenu(_ sender: Any) {
        sideBarView.isHidden = false
        sideBarTable.isHidden = false
        self.view.bringSubview(toFront: sideBarView)
        
        if !isMenu {
            // reveal sideBar menu
            isMenu = true
            sideBarView.frame = CGRect(x: 0, y: 71, width: 0, height: 203)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 0, height: 203)
            UIView.setAnimationDuration(0.15)
            UIView.setAnimationDelegate(self)
            UIView.beginAnimations("sideBarAnimation", context: nil)
            sideBarView.frame = CGRect(x: 0, y: 71, width: 112.33, height: 203)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 112.33, height: 203)
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
        sideBarView.isHidden = true
        sideBarTable.isHidden = true
        isMenu = false
        sideBarView.frame = CGRect(x: 0, y: 71, width: 112.33, height: 203)
        sideBarTable.frame = CGRect(x: 0, y: 0, width: 112.33, height: 203)
        UIView.setAnimationDuration(0.15)
        UIView.setAnimationDelegate(self)
        UIView.beginAnimations("sideBarAnimation", context: nil)
        sideBarView.frame = CGRect(x: 0, y: 71, width: 0, height: 203)
        sideBarTable.frame = CGRect(x: 0, y: 0, width: 0, height: 203)
        UIView.commitAnimations()
    }
    
    /*!
        Actions within the side bar menu.
        0 -> Save page  
        1 -> Print page
        2 -> Open About us page
        3 -> Log out
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sideBarTable {
            // complete an action based on the item pressed on the sidebar
            // insert similar logic here to assign a view to a new option, the indexPath refers to the items in sideBarFeatures
            if indexPath.row == 0 {
                // check if save is allowed by policy
                if ObjCUtils.isSaveToLocalDriveAllowed() {
                    //save the conversation and present success alert to user
                    savedConvo.set(conversation, forKey: "savedConversation ")
                    let alert = UIAlertController(title: "Conversation Saved",
                                                  message: "Your conversation has been successfully saved to your device.",
                                                  preferredStyle: .alert)
                    let closeAlert = UIAlertAction(title: "Ok",
                                                   style: .default,
                                                   handler: nil)
                    alert.addAction(closeAlert)
                    present(alert, animated: true, completion: nil)
                }
                else {
                    // alert the user that Save is disabled by APP
                    let alert = UIAlertController(title: "Save Disabled",
                                                  message: "Saving conversations to local storage has been disabled by your IT admin.",
                                                  preferredStyle: .alert)
                    let closeAlert = UIAlertAction(title: "Ok",
                                                   style: .default,
                                                   handler: nil)
                    alert.addAction(closeAlert)
                    present(alert, animated: true, completion: nil)
                }
            } else if indexPath.row == 1 {
                // print conversation
                printConvo()
            } else if indexPath.row == 2 {
                // about us
                let aboutUs:AboutUsPage = self.storyboard?.instantiateViewController(withIdentifier: "aboutPage") as! AboutUsPage
                present(aboutUs, animated:true, completion: nil)
            } else if indexPath.row == 3 {
                // settings page
                let settings:SettingsPage = self.storyboard?.instantiateViewController(withIdentifier: "settingsPage") as! SettingsPage
                present(settings, animated:true, completion: nil)
            } else if indexPath.row == 4 {
                // log out
                ObjCUtils.logout()
            }
        }
    }
    
    
    /*!
        Presents the user with a print preview of the chat page.
        Called by the side bar table
    */
    func printConvo() {
        hideSideBarMenu() // hide the side bar before you move on
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Print Chat Page"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = wholePageView.toImage()
        printController.present(animated: true, completionHandler: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //When the view disappears, clear the chat page as it will be reloaded when the page is displayed again.
        self.clearChatPage()

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //If the view is disappearing, check for a draft message to save
        if let currentUser = ObjCUtils.getSignedInUser() {
            if let draftMessageArray = self.getDraftedMessageArray() {
                //If a draft message is present, then save it using the KeychainManager class
                KeychainManager.addMessage(messages: draftMessageArray, user: currentUser as NSString, key: "draftMessage")
            }
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
