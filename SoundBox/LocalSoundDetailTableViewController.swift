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
    
    @IBAction func playSwitchAction(sender: UISwitch) {
        if sender.on {
            MobClick.event("PlaySound")
            play()
        } else {
            self.soundPlayer.pause()
        }
    }
    @IBAction func shakeSwitchAction(sender: UISwitch) {
        if sender.on {
            MobClick.event("SetShakePlay")
            let alertController = UIAlertController(title: "设置成功", message: "请点击“好的”之后摇动手机播放", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.Default, handler: nil)
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            self.becomeFirstResponder()
        }
    }
    
    func play() {
        self.soundPlayer.pause()
        if let file = self.sound?.file {
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileURL = directoryURL.URLByAppendingPathComponent(file)
            let item = AVPlayerItem(URL: fileURL)
            soundPlayer.replaceCurrentItemWithPlayerItem(item)
            soundPlayer.play()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(itemPlayEndOrFail), name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
        }
    }
    
    func itemPlayEndOrFail(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if self.cycleSwitch.on {
            if self.playSwitch.on || self.shakeSwitch.on {
                self.soundPlayer.seekToTime(kCMTimeZero)
                self.soundPlayer.play()
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(itemPlayEndOrFail), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.soundPlayer.currentItem)
            }
        } else {
            if self.playSwitch.on {
                self.playSwitch.setOn(false, animated: true)
            }
        }
    }
    
    override func motionBegan(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake && shakeSwitch.on{
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("LocalSoundDetailTableView")
    }
    
    override func viewWillDisappear(animated: Bool) {
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

    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
