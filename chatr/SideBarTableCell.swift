//
//  SideBarTableCell.swift
//  chatr
//
//  Created by Mesert Kebed on 6/25/18.
//  Copyright © 2018 Microsoft Intune. All rights reserved.
//

import UIKit

class SideBarTableCell: UITableViewCell {
    
    @IBOutlet weak var cellImg: UIImageView!
    @IBOutlet weak var cellLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
