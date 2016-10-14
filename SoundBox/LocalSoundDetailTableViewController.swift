//
//  LocalSoundDetailTableViewController.swift
//  SoundBox
//
//  Created by Mei on 9/6/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import UIKit
import AVFoundation

class LocalSoundDetailTableViewController: UITableViewController {
	
	var sound: Sound?
	
	var soundPlayer = AVPlayer()
	
	@IBOutlet weak var descTextView: UITextView!
	
	@IBOutlet weak var playSwitch: UISwitch!
	
	@IBOutlet weak var cycleSwitch: UISwitch!
	
	@IBOutlet weak var shakeSwitch: UISwitch!
	
	@IBAction func playSwitchAction(_ sender: UISwitch) {
		if sender.isOn {
			MobClick.event("PlaySound")
			play()
		} else {
			self.soundPlayer.pause()
		}
	}
	@IBAction func shakeSwitchAction(_ sender: UISwitch) {
		if sender.isOn {
			MobClick.event("SetShakePlay")
			let alertController = UIAlertController(title: "设置成功", message: "请点击“好的”之后摇动手机播放", preferredStyle: .alert)
			let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.default, handler: nil)
			alertController.addAction(okAction)
			self.present(alertController, animated: true, completion: nil)
			self.becomeFirstResponder()
		}
	}
	
	func play() {
		self.soundPlayer.pause()
		if let file = self.sound?.file {
			let fileManager = FileManager.default
			let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
			let fileURL = directoryURL.appendingPathComponent(file)
			let item = AVPlayerItem(url: fileURL)
			soundPlayer.replaceCurrentItem(with: item)
			soundPlayer.play()
			NotificationCenter.default.addObserver(self, selector: #selector(itemPlayEndOrFail), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
		}
	}
	
	func itemPlayEndOrFail(_ notification: Notification) {
		NotificationCenter.default.removeObserver(self)
		if self.cycleSwitch.isOn {
			if self.playSwitch.isOn || self.shakeSwitch.isOn {
				self.soundPlayer.seek(to: kCMTimeZero)
				self.soundPlayer.play()
				NotificationCenter.default.addObserver(self, selector: #selector(itemPlayEndOrFail), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.soundPlayer.currentItem)
			}
		} else {
			if self.playSwitch.isOn {
				self.playSwitch.setOn(false, animated: true)
			}
		}
	}
	
	override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake && shakeSwitch.isOn {
			play()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to preserve selection between presentations
		self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
		if let name = sound?.name {
			self.navigationItem.title = name
		}
		if let desc = sound?.desc {
			self.descTextView.text = desc
		}
        
        let compare = UIDevice.current.systemVersion.compare("10.0", options: .numeric)
        if compare != .orderedAscending {
            if #available(iOS 10.0, *) {
                self.soundPlayer.automaticallyWaitsToMinimizeStalling = false
            } else {
                // Fallback on earlier versions
            }
        }
	}
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        soundPlayer.pause()
        soundPlayer.replaceCurrentItem(with: nil)
		MobClick.beginLogPageView("LocalSoundDetailTableView")
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		MobClick.endLogPageView("LocalSoundDetailTableView")
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	/*
	 // MARK: - Navigation

	 // In a storyboard-based application, you will often want to do a little preparation before navigation
	 override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	 // Get the new view controller using segue.destinationViewController.
	 // Pass the selected object to the new view controller.
	 }
	 */
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}
