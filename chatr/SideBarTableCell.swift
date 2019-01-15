//
//  SideBarTableCell.swift
//  chatr
//
//  Created by Diana Voronin on 1/15/19.
//  Copyright © 2019 Microsoft Intune. All rights reserved.
//

import UIKit

class SideBarTableCell: UITableViewCell {

    @IBOutlet weak var cellLbl: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
