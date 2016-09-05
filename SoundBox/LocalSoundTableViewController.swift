//
//  LocalSoundTableTableViewController.swift
//  SoundBox
//
//  Created by Mei on 8/29/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import UIKit

class LocalSoundTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var sounds = [[Sound]]()
    
    var count = 0
    
    var nextStart = 0
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.count = appDelegate.localDataController.fetchLocalSoundCount()
        if self.sounds[0].count != self.count {
            self.nextStart = 0
            //TODO 滚动回最前端
            loadData()
        }
        
        MobClick.beginLogPageView("LocalSoundTableView")
    }
    
    override func viewWillDisappear(animated: Bool) {
        MobClick.endLogPageView("LocalSoundTableView")
    }
    
    
    func loadData(){
        let localDataController = appDelegate.localDataController
        let sounds = localDataController.fetchLocalSounds(nextStart, limit: 10)
        if nextStart == 0 {
            self.sounds.removeAll()
            self.sounds.insert(sounds, atIndex: 0)
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (self.sounds.count > 0 && self.sounds[0].count > 0) {
            self.tableView.separatorStyle = .SingleLine;
            self.tableView.backgroundView = nil;
        } else {
            self.tableView.separatorStyle = .None;
            let label = UILabel()
            label.text = "我的声音是空的！\r\n快到模拟大师里去下载声音吧";
            label.numberOfLines = 2;
            label.textAlignment = .Center;
            label.textColor = UIColor.darkGrayColor();
            self.tableView.backgroundView = label;
        }
        return sounds.count;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sounds[section].count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("LocalSoundCell", forIndexPath: indexPath) as! SoundTableViewCell
        
        // Configure the cell...
        
        cell.sound = self.sounds[indexPath.section][indexPath.row]
        
        if (nextStart >= 0 && indexPath.row == self.sounds[indexPath.section].count-1) {
            loadData()
        }

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source  
            let sound = self.sounds[indexPath.section][indexPath.row]
            appDelegate.localDataController.deleteSound(sound)
            self.sounds[indexPath.section].removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
