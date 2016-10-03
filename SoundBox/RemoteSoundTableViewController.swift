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
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var remoteSounds = [[RemoteSound]]()
    
    var nextStart = 0
    
    var soundPlayer = AVPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadData()
        self.soundPlayer.addObserver(self, forKeyPath: "rate", options: [.new, .old], context: nil)
        self.soundPlayer.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
        self.soundPlayer.addObserver(self, forKeyPath: "currentItem", options: [.new, .old], context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("RemoteSoundTableView")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("RemoteSoundTableView")
    }
    
    @IBAction func refreshAction(_ sender: UIRefreshControl?) {
        if sender != nil {
            self.nextStart = 0
        }
        let remoteDataController = appDelegate.remoteDataController
        remoteDataController?.fetchSounds(nextStart, limit: 12){
            (success, message, remoteSounds:[RemoteSound], nextStart) in
            if (success){
                if remoteSounds.count > 0 {
                    if self.nextStart == 0 {
                        self.remoteSounds.removeAll()
                        self.remoteSounds.insert(remoteSounds, at: 0)
                    } else {
                        for remoteSound in remoteSounds {
                            self.remoteSounds[0].append(remoteSound)
                        }
                    }
                } else {
                    if self.remoteSounds.count == 0 || self.remoteSounds[0].count > 0 {
                        if let view = self.tableView.backgroundView {
                            let label = view as! UILabel
                            label.text = "暂时无法获取到数据，请稍候下拉刷新"
                        }
                    } else {
                        
                    }
                }
                self.nextStart = nextStart
                self.tableView.reloadData()
            }else{
                if let view = self.tableView.backgroundView {
                    let label = view as! UILabel
                    label.text = message
                } else {
                    
                }
            }
            sender?.endRefreshing()
        }
    }
    
    
    func loadData(){
        if self.nextStart == 0 {
            if refreshControl != nil{
                refreshControl?.beginRefreshing()
            }
            refreshAction(refreshControl)
        } else {
            refreshAction(nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if (self.remoteSounds.count > 0 && self.remoteSounds[0].count > 0) {
            self.tableView.separatorStyle = .singleLine;
            self.tableView.backgroundView = nil;
        } else {
            self.tableView.separatorStyle = .none;
                if self.tableView.backgroundView == nil {
                let label = UILabel()
                label.numberOfLines = 2;
                label.textAlignment = .center;
                label.textColor = UIColor.darkGray;
                self.tableView.backgroundView = label;
            }
        }
        
        return remoteSounds.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return remoteSounds[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "RemoteSoundCell", for: indexPath) as! RemoteSoundTableViewCell
        
        cell.remoteSound = remoteSounds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        if (self.nextStart > 0 && (indexPath as NSIndexPath).row == self.remoteSounds[(indexPath as NSIndexPath).section].count-1) {
            loadData()
        }
        
        let remoteDataController = appDelegate.remoteDataController
        let localDataController = appDelegate.localDataController
        
        cell.downloadAction = { (cell) in
            if let remoteSound = cell.remoteSound {
                remoteDataController?.downloadSound(remoteSound, finished: { (success, message, remoteSound, file) in
                    let alertController = UIAlertController(title: "下载失败", message: message, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "好的", style: UIAlertActionStyle.default, handler: nil)
                    alertController.addAction(okAction)
                    //if success {
                        if let filePath = file {
                            
                            if let saved = localDataController?.saveRemoteSound(remoteSound, file: filePath) {
                                if saved == true{
                                    alertController.title = "下载成功"
                                    alertController.message = "已下载到我的声音中"
                                } else {
                                    alertController.message = "我的声音中已存在"
                                }
                            }
                        }
                    //}
                    self.present(alertController, animated: true, completion: nil)
                })
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.soundPlayer.pause()
        let remoteSound = remoteSounds[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        if let url = remoteSound.url {
            let fileURL = URL(string: url)
            let item = AVPlayerItem(url: fileURL!)
            self.soundPlayer.replaceCurrentItem(with: item)
            self.soundPlayer.play()
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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath != nil else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch (keyPath!) {
        case "status":
            print("status changed: \(change)")
        case "currentItem":
            print("currentItem changed: \(change)")
        case "rate":
            print("rate changed: \(change)")
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    deinit{
    }
}
