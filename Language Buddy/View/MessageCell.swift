//
//  MessageCell.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/27/22.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        usernameLabel.layer.masksToBounds = true
        usernameLabel.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
