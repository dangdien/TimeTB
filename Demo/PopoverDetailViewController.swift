//
//  PopoverDetailViewController.swift
//  Demo
//
//  Created by Dang Dien on 9/30/16.
//  Copyright © 2016 Dien Dang. All rights reserved.
//

import UIKit

class PopoverDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableViewLabels = ["Label", "Start Time", "Finish Time", "Start Day", "Finish Day", "Color"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableViewLabels[indexPath.row]
        
        
        return cell
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
