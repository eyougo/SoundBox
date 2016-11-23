//
//  LocalSoundTableTableViewController.swift
//  SoundBox
//
//  Created by Mei on 8/29/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import UIKit
import AVFoundation

class LocalSoundTableViewController: UITableViewController {
	
	let appDelegate = UIApplication.shared.delegate as! AppDelegate
	
	var sounds = [[Sound]]()
	
	var count = 0
	
	var nextStart = 0
    
    var soundPlayer = AVPlayer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.estimatedRowHeight = tableView.rowHeight
		tableView.rowHeight = UITableViewAutomaticDimension
		
		// Uncomment the following line to preserve selection between presentations
		self.clearsSelectionOnViewWillAppear = false
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		// self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		self.count = appDelegate.localDataController.fetchLocalSoundCount()
		loadData()
        
        let compare = UIDevice.current.systemVersion.compare("10.0", options: .numeric)
        if compare != .orderedAscending {
            if #available(iOS 10.0, *) {
                self.soundPlayer.automaticallyWaitsToMinimizeStalling = false
            } else {
                // Fallback on earlier versions
            }
        }
        
        self.soundPlayer.addObserver(self, forKeyPath: "rate", options: [.new, .old], context: nil)
        self.soundPlayer.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
        self.soundPlayer.addObserver(self, forKeyPath: "currentItem", options: [.new, .old], context: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.count = appDelegate.localDataController.fetchLocalSoundCount()
		if self.sounds[0].count != self.count {
			self.nextStart = 0
			// TODO 滚动回最前端
			loadData()
		}
		
		MobClick.beginLogPageView("LocalSoundTableView")
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		MobClick.endLogPageView("LocalSoundTableView")
	}
	
	func loadData() {
        if let localDataController = appDelegate.localDataController {
            let sounds = localDataController.fetchLocalSounds(nextStart, limit: 10)
            if nextStart == 0 {
                self.sounds.removeAll()
                self.sounds.insert(sounds, at: 0)
            } else if nextStart > 0 {
                for sound in sounds {
                    self.sounds[0].append(sound)
                }
            }
            nextStart = nextStart + 10
            if nextStart >= self.count {
                nextStart = -1
            }
            tableView.reloadData()
        }
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		if (self.sounds.count > 0 && self.sounds[0].count > 0) {
			self.tableView.separatorStyle = .singleLine;
			self.tableView.backgroundView = nil;
		} else {
			self.tableView.separatorStyle = .none;
			let label = UILabel()
			label.text = NSLocalizedString("MySoundsIsEmpty", comment: "");
			label.numberOfLines = 2;
			label.textAlignment = .center;
			label.textColor = UIColor.darkGray;
			self.tableView.backgroundView = label;
		}
		return sounds.count;
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return sounds[section].count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LocalSoundCell", for: indexPath) as! SoundTableViewCell
		
		// Configure the cell...
		
		cell.sound = self.sounds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
		
		if (nextStart >= 0 && (indexPath as NSIndexPath).row == self.sounds[(indexPath as NSIndexPath).section].count - 1) {
			loadData()
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sound = sounds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        if let file = sound.file {
            let fileManager = FileManager.default
            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = directoryURL.appendingPathComponent(file)
            let item = AVPlayerItem(url: fileURL)
            self.soundPlayer.replaceCurrentItem(with: item)
            self.soundPlayer.play()
        }
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Delete the row from the data source
			let sound = self.sounds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
			appDelegate.localDataController.deleteSound(sound)
			self.sounds[(indexPath as NSIndexPath).section].remove(at: (indexPath as NSIndexPath).row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		} else if editingStyle == .insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        self.performSegue(withIdentifier: "LocalSoundDetail", sender: indexPath)
    }
	
	/*
	 // Override to support rearranging the table view.
	 override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

	 }
	 */
	
	/*
	 // Override to support conditional rearranging of the table view.
	 override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
	 // Return false if you do not want the item to be re-orderable.
	 return true
	 }
	 */
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		if segue.identifier == "LocalSoundDetail" {
			let localSoundDetailTableViewController = segue.destination as! LocalSoundDetailTableViewController
			
			// Get the cell that generated this segue.
			if let indexPath = sender as? IndexPath {
				let selectedSound = self.sounds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
				localSoundDetailTableViewController.sound = selectedSound
			}
			
		}
		
	}
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != nil else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch (keyPath!) {
        case "status": break
        case "currentItem": break
        case "rate":
            if change?[.oldKey] as? Float == 1.0 && change?[.newKey] as? Float == 0.0{
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
            break
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
	
}
