//
//  ListTableViewCell.swift
//  eDrive
//
//  Created by Kata on 24/11/16.
//  Copyright © 2016 Kata. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var s: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
