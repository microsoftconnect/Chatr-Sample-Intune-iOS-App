//
//  Chat Page.swift
//  chatr
//
//  SideBar Implementation guidance: https://youtu.be/GOSIz7JbZMA by Yogesh Patel
//
//  Created by Mesert Kebed on 6/29/18.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

import UIKit

// global variables used for saving conversations
var conversation = [(String)]()

class ChatPage: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // variables used for creating the sidebar
    @IBOutlet weak var sideBarView: UIView!
    @IBOutlet weak var sideBarTable: UITableView!
    var isMenu:Bool = false                                         // variable that indiates if the menu is being  displayed
    var sideBarFeatures = ["Save","Print", "About us", "Log out"]   // the options on the sidebar
    var sideBarImg = [#imageLiteral(resourceName: "save"),#imageLiteral(resourceName: "print"),#imageLiteral(resourceName: "information"),#imageLiteral(resourceName: "profile")]                                  // images for the sidebar options
    
    // variables used for chat
    @IBOutlet weak var typedChat: UITextField!
    @IBOutlet weak var chatView: UIStackView!
    
    
    
    /*
     * triggered when send button is pressed on chat page
     * empties out the text field and creates a new view with the message filled in.
     * Messages should appear on the right side of the page
     */
    @IBAction func sendChat(_ sender: UIButton) {
        
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
        return sideBarFeatures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SideBarTableCell = tableView.dequeueReusableCell(withIdentifier: "sideCell") as! SideBarTableCell
        cell.cellImg.image = sideBarImg[indexPath.row]
        cell.cellLbl.text = sideBarFeatures[indexPath.row]
        return cell
    }
    
    /*
     * action trigger: the Chatr logo button on the top left
     * Reveals/hides the sideBar menu when the button is pressed depending on the state.
     * If the menu was hidden when the button is pressed, then it will reveal the menu and vise versa.
     */
    @IBAction func sideBarMenu(_ sender: Any) {
        sideBarView.isHidden = false
        sideBarTable.isHidden = false
        self.view.bringSubview(toFront: sideBarView)
        if !isMenu {
            isMenu = true
            sideBarView.frame = CGRect(x: 0, y: 72, width: 0, height: 214)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 0, height: 214)
            UIView.setAnimationDuration(0.15)
            UIView.setAnimationDelegate(self)
            UIView.beginAnimations("sideBarAnimation", context: nil)
            sideBarView.frame = CGRect(x: 0, y: 72, width: 187, height: 214)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 187, height: 214)
            UIView.commitAnimations()
        } else {
            sideBarView.isHidden = true
            sideBarTable.isHidden = true
            isMenu = false
            sideBarView.frame = CGRect(x: 0, y: 72, width: 187, height: 214)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 187, height: 214)
            UIView.setAnimationDuration(0.15)
            UIView.setAnimationDelegate(self)
            UIView.beginAnimations("sideBarAnimation", context: nil)
            sideBarView.frame = CGRect(x: 0, y: 72, width: 0, height: 214)
            sideBarTable.frame = CGRect(x: 0, y: 0, width: 0, height: 214)
            UIView.commitAnimations()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // when you press the About us option in the sideBar it presents the "aboutPage" view
        // *** insert similar logic here to assign a view to a new option, the indexPath refers to the items in sideBarFeatures ***
        if indexPath.row == 2 {
            let aboutUs:AboutUsPage = self.storyboard?.instantiateViewController(withIdentifier: "aboutPage") as! AboutUsPage
            present(aboutUs, animated:true, completion: nil)
        }
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
