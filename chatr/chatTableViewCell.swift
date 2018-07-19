//
//  chatTableViewCell.swift
//  chatr
//
//  Created by Meseret  Kebede on 05/07/2018.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

import UIKit

class chatTableViewCell: UITableViewCell {

   
    @IBOutlet weak var messageView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
