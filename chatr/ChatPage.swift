//
//  Chat Page.swift
//  chatr
//
//  Created by Mesert Kebed on 6/29/18.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
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
    
    // variable used to keep track of whether the send button is already displayed
    var alreadyDisplayedSendButton = false
    
    // variables used for creating the sidebar
    @IBOutlet weak var sideBarTable: UITableView!
    var isMenu:Bool = false                                         // variable that indicates if the menu is being  displayed
    var sideBarFeatures = ["Save","Print", "About us", "Log out"]   // the options on the sidebar
    var sideBarImg = [#imageLiteral(resourceName: "save"),#imageLiteral(resourceName: "print"),#imageLiteral(resourceName: "information"),#imageLiteral(resourceName: "profile")]                                  // images for the sidebar options
    
    
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
     */
    @IBAction func sendChat(_ sender: UIButton) {
        
        let align = NSMutableParagraphStyle()
        align.alignment = .right
        
        let fromMessage = NSMutableAttributedString(string: typedChatView.text!, attributes: [.paragraphStyle: align])
        typedChatView.text = ""
        conversation.append((sender: "from", message: fromMessage))
        
        // update the message board to include the update
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prevent the display of empty cells at the bottom of the sidebar menu by adding a zero height table footer view
        sideBarTable.tableFooterView = UIView(frame: CGRect(x:0, y:0, width: 0, height: 0))
        sideBarTable.tableFooterView?.isHidden = true
        sideBarTable.backgroundColor = UIColor.clear
        
        //ensures self-sizing sidebar table view cells
        //the sidebar table view will use Auto Layout constraints and the cell's contents to determine each cell's height
        sideBarTable.estimatedRowHeight = 40
        sideBarTable.rowHeight = UITableViewAutomaticDimension
        
        // when the view is loaded, hide the sidebar table
        sideBarTable.isHidden = true
        isMenu = false
        
        // round the corners of the chat view
        typedChatView.layer.cornerRadius = 10
        
        // change user's group name on top of the chat page, one of the app config settings
        userFirstName.text = ObjCUtils.getUserGroupName()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
    }
    
    //programmatically create send button after Auto Layout lays out the main view and subviews
    override func viewDidLayoutSubviews() {
        //ensures a new send button is not added every time a message is sent in the chat
        if alreadyDisplayedSendButton == false {
            
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
                // log out
                ObjCUtils.removeAppTokens()
                performSegue(withIdentifier: "backToHomePage", sender: self)
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
