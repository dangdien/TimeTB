//
//  AddNewEventTableViewController.swift
//  Demo
//
//  Created by Dien Dang on 9/1/16.
//  Copyright © 2016 Dien Dang. All rights reserved.
//

import UIKit

protocol setNewEvent{
    func setTitleForLabel(titleForLabel: String)
    func settStartTime(Time: NSDate)
    func settFinishTime(Time: NSDate)
    func settStartDay(day: NSDate)
    func settFinishDay(day: NSDate)
    func setColor(color: UIColor, colorName: String)
    
}

class AddNewEventTableViewController: UITableViewController, setNewEvent {
    
    var addJobToDatabaseDelegate: addToDatabase?
    var updateJobToDatabaseDelegate: updateJobToDatabase?
    
    var startTime = NSDate()
    var finishTime = NSDate()
    var startDay = NSDate()
    var finishDay = NSDate()
    let dateFormatter = NSDateFormatter()
    let hourFormatter = NSDateFormatter()
    let fullDateFormatter = NSDateFormatter()
    var colorForEvent = UIColor.blueColor().colorWithAlphaComponent(0.5)
    
    var updateJob = job()
    var isUpdate = false

    
    @IBOutlet weak var LabelDetail: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var finishTimeLabel: UILabel!
    @IBOutlet weak var startDayLabel: UILabel!
    @IBOutlet weak var finishDayLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()        
        self.tableView.reloadData()
        if !isUpdate {
        hourFormatter.dateFormat = "HH:mm"
        startTimeLabel.text = hourFormatter.stringFromDate(startTime)
        finishTimeLabel.text = hourFormatter.stringFromDate(finishTime)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        startDayLabel.text = dateFormatter.stringFromDate(startDay)
        finishDayLabel.text = dateFormatter.stringFromDate(finishDay)
        colorLabel.text = "Blue"
        }
        
        else {
            hourFormatter.dateFormat = "HH:mm"
            dateFormatter.dateFormat = "dd-MM-yyyy"
            fullDateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
            
    
            startTime = fullDateFormatter.dateFromString((updateJob.startTime!))!
            finishTime = fullDateFormatter.dateFromString((updateJob.finishTime!))!
            startDay = fullDateFormatter.dateFromString((updateJob.startDay!))!
            finishDay = fullDateFormatter.dateFromString((updateJob.finishDay!))!
            
           
            LabelDetail.text = updateJob.label
            startTimeLabel.text = hourFormatter.stringFromDate(fullDateFormatter.dateFromString(updateJob.startTime!)!)
            finishTimeLabel.text = hourFormatter.stringFromDate(fullDateFormatter.dateFromString(updateJob.finishTime!)!)
            
            startDayLabel.text = dateFormatter.stringFromDate(fullDateFormatter.dateFromString(updateJob.startDay!)!)
            finishDayLabel.text = dateFormatter.stringFromDate(fullDateFormatter.dateFromString(updateJob.finishDay!)!)
            colorLabel.text = updateJob.color
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }



    
    func setTitleForLabel(titleForLabel: String){
        LabelDetail.text = titleForLabel
    }
    
    
    func settStartTime(Time: NSDate) {
        startTime = Time
        startTimeLabel.text = hourFormatter.stringFromDate(startTime)
    }
    
    func settFinishTime(Time: NSDate) {
        finishTime = Time
        finishTimeLabel.text = hourFormatter.stringFromDate(finishTime)
    }
    
    func settStartDay(day: NSDate) {
        startDay = day
        startDayLabel.text = dateFormatter.stringFromDate(startDay)
    }
    
    func settFinishDay(day: NSDate) {
        finishDay = day
        finishDayLabel.text = dateFormatter.stringFromDate(finishDay)
    }
    
    func setColor(color: UIColor, colorName: String) {
        colorLabel.text = colorName
        colorForEvent = color
    }
    
    
    @IBAction func addNewEvent(sender: AnyObject) {
        if !isUpdate{
        addJobToDatabaseDelegate?.insertJobToDatabase(LabelDetail.text!, startTime: startTime, finishTime: finishTime, startDay: startDay, finishDay: finishDay, color: colorLabel.text!)
        }
        
        else{
            let updateStatementString = "UPDATE Jobs SET Label = \"\(LabelDetail.text!)\", startTime = '\(fullDateFormatter.stringFromDate(startTime))',finishTime = '\(fullDateFormatter.stringFromDate(finishTime))',startDay = '\(fullDateFormatter.stringFromDate(startDay))',finishDay = '\(fullDateFormatter.stringFromDate(finishDay))',color = \"\(colorLabel.text!)\" WHERE id = \(updateJob.id!);"
            print(updateStatementString)
            updateJobToDatabaseDelegate?.updateInDatabase(updateStatementString)
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    

    


 

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "labelSegue"){
            (segue.destinationViewController as! LabelViewController).labelDelegate = self
        }
        
        if(segue.identifier == "startTimeSegue"){
            (segue.destinationViewController as! TimePickerViewController).startTimeSelectedDelegate = self
        }
        
        if(segue.identifier == "finishTimeSegue"){
            (segue.destinationViewController as! TimePickerViewController).finishTimeSelectedDelegate = self
        }
        
        if(segue.identifier == "colorSegue"){
            (segue.destinationViewController as! ColorTableViewController).colorDelegate = self
        }
        
        if(segue.identifier == "startDaySegue"){
            (segue.destinationViewController as! TimePickerViewController).startDaySelectedDelegate = self
        }
        
        if(segue.identifier == "finishDaySegue"){
            (segue.destinationViewController as! TimePickerViewController).finishDaySelectedDelegate = self
        }
        
        if(segue.identifier == "updateJob"){
            print("qwd")
        }
    }
    

}
