//
//  SoundTableViewCell.swift
//  SoundBox
//
//  Created by Mei on 8/31/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import UIKit

class SoundTableViewCell: UITableViewCell {

    
    var sound: Sound?{
        didSet{
            updateUI()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    func updateUI() {
        self.nameLabel.text = sound?.name
        self.descLabel.text = sound?.desc
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
