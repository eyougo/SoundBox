//
//  AboutMoreTableViewController.swift
//  SoundBox
//
//  Created by Mei on 9/8/16.
//  Copyright © 2016 Mei. All rights reserved.
//

import UIKit
import LeanCloudFeedback

class AboutMoreTableViewController: UITableViewController {

    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let infoDictionary = Bundle.main.infoDictionary
        let majorVersion = infoDictionary! ["CFBundleShortVersionString"] as! String
        let minorVersion = infoDictionary! ["CFBundleVersion"] as! String
        self.versionLabel.text = majorVersion + " (" + minorVersion + ")"
        let aboutText = NSLocalizedString( "juU-Vd-Bed.text", tableName: "Main", comment: "")
        self.aboutTextView.text = aboutText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MobClick.beginLogPageView("AboutMoreTableView")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView("AboutMoreTableView")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if let identifier = cell.reuseIdentifier {
                switch identifier {
                case "FeedbackCell":
                    print("Feedback")
                    let feedbackViewController = LCUserFeedbackViewController()
                    feedbackViewController.navigationBarStyle = LCUserFeedbackNavigationBarStyleNone;
                    feedbackViewController.contact = nil
                    feedbackViewController.contactHeaderHidden = true
                    feedbackViewController.feedbackTitle = nil
                    feedbackViewController.presented = false
                    feedbackViewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(feedbackViewController, animated: true)
                default:
                    return
                }
            
            }
        }
    }
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
