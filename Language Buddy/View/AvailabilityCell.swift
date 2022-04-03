//
//  AvailabilityCell.swift
//  Language Buddy
//
//  Created by Nelson Aquino Jr  on 3/28/22.
//

import UIKit

class AvailabilityCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellView.layer.masksToBounds = false
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.shadowOffset = .zero
        cellView.layer.shadowRadius = 1
        cellView.layer.cornerRadius = cellView.frame.height/5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
