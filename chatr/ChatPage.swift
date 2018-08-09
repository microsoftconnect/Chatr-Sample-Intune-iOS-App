//
//  Chat Page.swift
//  chatr
//
//  Code for sidebar implementation adopted from: https://youtu.be/GOSIz7JbZMA by Yogesh Patel
//  Other inspiration: https://stackoverflow.com/questions/31870206/how-to-insert-new-cell-into-uitableview-in-swift responses by EI Captain v2.0 and Dharmesh Kheni
//
//  Created by Mesert Kebed on 6/29/18.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

import UIKit

// global variable used for saving conversations
var conversation:[(sender:String, message:NSAttributedString)] = []

class ChatPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // variables used for creating the sidebar
    @IBOutlet weak var sideBarView: UIView!
    @IBOutlet weak var sideBarTable: UITableView!
    var isMenu:Bool = false                                         // variable that indiates if the menu is being  displayed
    var sideBarFeatures = ["Save","Print", "About us", "Log out"]   // the options on the sidebar
    var sideBarImg = [#imageLiteral(resourceName: "save"),#imageLiteral(resourceName: "print"),#imageLiteral(resourceName: "information"),#imageLiteral(resourceName: "profile")]                                  // images for the sidebar options
    
    
    // variables used for chat
    @IBOutlet weak var typedChat: UITextField!
    @IBOutlet weak var chatTable: UITableView!
    
    // variables used for printing
    @IBOutlet var wholePageView: UIView!
    
    /*!
        Button action triggered when send button is pressed on chat page
     
        Empties out the text field and creates a new view with the message.
     */
    @IBAction func sendChat(_ sender: UIButton) {
        
        let align = NSMutableParagraphStyle()
        align.alignment = .right
        
        let fromMessage = NSMutableAttributedString(string: typedChat.text!, attributes: [.paragraphStyle: align])
        typedChat.text = ""
        conversation.append((sender: "from", message: fromMessage))
        
        // update the message board to include the update
        self.chatTable.beginUpdates()
        self.chatTable.insertRows(at: [IndexPath.init(row: conversation.count-1, section: 0)], with: .automatic)
        self.chatTable.endUpdates()
        
        // send the reply
        replyChat()
    }
    
    
    func replyChat() {
        
        let developerGuide: [NSAttributedStringKey : Any] = [.link: NSURL(string: "https://docs.microsoft.com/en-us/intune/app-sdk-ios")!, .foregroundColor: UIColor.blue]
        let faqPage: [NSAttributedStringKey : Any] = [.link : NSURL(string: "https://docs.microsoft.com/en-us/intune/app-sdk-ios#faqs")!, .foregroundColor: UIColor.blue]
        
        let align = NSMutableParagraphStyle()
        align.alignment = .left
        
        let replyMessage = NSMutableAttributedString(string: "Please refer to our documentation and read our faq page for any outstanding concerns. \nThank you.", attributes: [.paragraphStyle: align])
        
        
        
        replyMessage.setAttributes(developerGuide, range: NSMakeRange(20, 13))
        replyMessage.setAttributes(faqPage, range: NSMakeRange(47, 3))
        
        
        conversation.append((sender: "to", message: replyMessage))
        
        //update the message board to include the reply
        self.chatTable.beginUpdates()
        self.chatTable.insertRows(at: [IndexPath.init(row: conversation.count-1, section: 0)], with: .automatic)
        self.chatTable.endUpdates()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // when the view is loaded, hide the sidebar table
        sideBarView.isHidden = true
        sideBarTable.backgroundColor = UIColor.groupTableViewBackground
        isMenu = false
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
            isMenu = true
            sideBarView.frame = CGRect(x: 0, y: 64, width: 0, height: 233)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 0, height: 233)
            UIView.setAnimationDuration(0.15)
            UIView.setAnimationDelegate(self)
            UIView.beginAnimations("sideBarAnimation", context: nil)
            sideBarView.frame = CGRect(x: 0, y: 64, width: 269, height: 233)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 269, height: 233)
            UIView.commitAnimations()
        } else {
            sideBarView.isHidden = true
            sideBarTable.isHidden = true
            isMenu = false
            sideBarView.frame = CGRect(x: 0, y: 64, width: 187, height: 214)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 187, height: 214)
            UIView.setAnimationDuration(0.15)
            UIView.setAnimationDelegate(self)
            UIView.beginAnimations("sideBarAnimation", context: nil)
            sideBarView.frame = CGRect(x: 0, y: 64, width: 0, height: 214)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 0, height: 214)
            UIView.commitAnimations()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sideBarTable {
            // complete an action based on the item pressed on the sidebar
            // insert similar logic here to assign a view to a new option, the indexPath refers to the items in sideBarFeatures
            if indexPath.row == 1 {
                print()
            } else if indexPath.row == 2 {
                let aboutUs:AboutUsPage = self.storyboard?.instantiateViewController(withIdentifier: "aboutPage") as! AboutUsPage
                present(aboutUs, animated:true, completion: nil)
            }
        }
    }
    
    func print() {
        // code logic modified from answer by Jody Heavener @ https://stackoverflow.com/questions/32403634/airprint-contents-of-a-uiview
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Print chat page"

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
