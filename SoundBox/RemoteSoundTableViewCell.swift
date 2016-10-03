//
//  RemoteSoundTableViewCell.swift
//  SoundBox
//
//  Created by Mei on 8/31/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import UIKit
import AVFoundation

class RemoteSoundTableViewCell: UITableViewCell {
    
    var remoteSound:RemoteSound?{
        didSet{
            updateUI()
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!

    @IBAction func DownloadAction(_ sender: UIButton) {
        MobClick.event("DownloadRemote")
        downloadAction?(self)
    }
    
    var downloadAction: ((RemoteSoundTableViewCell) -> Void)?
    
    func updateUI() {
        self.nameLabel.text = remoteSound?.name
        self.descLabel.text = remoteSound?.description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
