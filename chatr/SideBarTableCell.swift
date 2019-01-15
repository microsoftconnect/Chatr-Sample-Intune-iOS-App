//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//

import UIKit

class SideBarTableCell: UITableViewCell {
    
    // variables used throughout this class
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
