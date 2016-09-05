//
//  RemoteSoundTableViewController.swift
//  SoundBox
//
//  Created by Mei on 8/31/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import UIKit
import AVFoundation

class RemoteSoundTableViewController: UITableViewController {
    
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var remoteSounds = [[RemoteSound]]()
    
    var nextStart = 0
    
    var soundPlayer = AVPlayer ()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.remoteSounds.count == 0 {
            loadData()
        }
        MobClick.beginLogPageView("RemoteSoundTableView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        MobClick.endLogPageView("RemoteSoundTableView")
    }
    
    func loadData(){
        let remoteDataController = appDelegate.remoteDataController
        remoteDataController.fetchSounds(nextStart, limit: 10){
            (success, message, remoteSounds:[RemoteSound], nextStart) in
            if (success){
                if remoteSounds.count > 0 {
                    if self.nextStart == 0 {
                        self.remoteSounds.removeAll()
                        self.remoteSounds.insert(remoteSounds, atIndex: 0)
                    } else {
                        for remoteSound in remoteSounds {
                            self.remoteSounds[0].append(remoteSound)
                        }
                    }
                    self.tableView.reloadData()
                }
                
                self.nextStart = nextStart
            }else{
                if let view = self.tableView.backgroundView {
                    let label = view as! UILabel
                    label.text = message
                } else {
                
                
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (self.remoteSounds.count > 0 && self.remoteSounds[0].count > 0) {
            self.tableView.separatorStyle = .SingleLine;
            self.tableView.backgroundView = nil;
        } else {
            self.tableView.separatorStyle = .None;
                if self.tableView.backgroundView == nil {
                let label = UILabel()
                label.numberOfLines = 2;
                label.textAlignment = .Center;
                label.textColor = UIColor.darkGrayColor();
                self.tableView.backgroundView = label;
            }
        }
        
        return remoteSounds.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return remoteSounds[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCellWithIdentifier("RemoteSoundCell", forIndexPath: indexPath) as! RemoteSoundTableViewCell
        
        cell.remoteSound = remoteSounds[indexPath.section][indexPath.row]
        
        let remoteDataController = appDelegate.remoteDataController
        let localDataController = appDelegate.localDataController
        
        cell.downloadAction = { (cell) in
            if let remoteSound = cell.remoteSound {
                remoteDataController.downloadSound(remoteSound, finished: { (success, message, remoteSound, file) in
                    localDataController.saveRemoteSound(remoteSound, file: file)
                })
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.soundPlayer.pause()
        let remoteSound = remoteSounds[indexPath.section][indexPath.row]
        if let url = remoteSound.url {
            let fileURL = NSURL(string: url)
            let item = AVPlayerItem(URL: fileURL!)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(itemPlayEndOrFail), name: AVPlayerItemDidPlayToEndTimeNotification, object: item)
            soundPlayer.replaceCurrentItemWithPlayerItem(item)
            soundPlayer.play()
        }
    }
    
    func itemPlayEndOrFail(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }
    }
    
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
