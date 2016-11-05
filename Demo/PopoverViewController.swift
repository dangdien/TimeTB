//
//  PopoverViewController.swift
//  Demo
//
//  Created by Dang Dien on 9/30/16.
//  Copyright © 2016 Dien Dang. All rights reserved.
//

import UIKit

protocol updateJobToDatabase {
    func updateInDatabase(updateStatementString: String)
}

class PopoverViewController: Database, UITableViewDataSource, UITableViewDelegate, updateJobToDatabase {

    
    let cellLabels = ["Label", "Start Time", "Finish Time", "Start Day", "Finish Day","Color"]
    let weekdaysArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    var detailJob: job? = nil
    
    var currentTag = -1
    var detailArray = [String]()
    var jobArray = [job]()
    var thisMonDay = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let startTime = (detailJob?.startTime)!
        let finishTime = (detailJob?.finishTime)!
        let startDay = (detailJob?.startDay)!
        let finishDay = (detailJob?.finishDay)!
        
        let range = startTime.startIndex.advancedBy(11)..<startTime.endIndex
        let range2 = startDay.startIndex.advancedBy(0)..<startDay.startIndex.advancedBy(11)
        
        detailArray.append((detailJob?.label)!)
        detailArray.append(startTime[range])
        detailArray.append(finishTime[range])
        detailArray.append(startDay[range2])
        detailArray.append(finishDay[range2])
        detailArray.append((detailJob?.color)!)

        jobArray = getAllDataFromDatabase()
        // Do any additional setup after loading the view.
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
//
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = cellLabels[indexPath.row]
        cell.detailTextLabel?.text = detailArray[indexPath.row]
        

        return cell
    }
//
    @IBAction func BtnPopOut(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func BtnDelete(sender: AnyObject) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure?", preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "Yes", style: .Default, handler: {(alert: UIAlertAction!) in self.deleteJob()})
        let NoAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
        alert.addAction(OKAction)
        alert.addAction(NoAction)
        presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    func deleteJob(){
        var job = jobArray[0]
        
        for jobb in jobArray{
            if jobb.id == currentTag {
                job = jobb
            }
        }
//---------//        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let thisday = get(thisMonDay, direction: .Next, weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.startDay!)!) - 1], considerThisday: true)
        
        var updateStatementString = ""
        
        //Delete start day
        if NSCalendar.currentCalendar().startOfDayForDate(thisMonDay).compare(NSCalendar.currentCalendar().startOfDayForDate(get(dateFormatter.dateFromString(job.startDay!)!, direction: .Previous, "Monday", considerThisday: true))) == NSComparisonResult.OrderedSame {
            
            updateStatementString = "UPDATE Jobs SET startDay = '\(dateFormatter.stringFromDate(get(dateFormatter.dateFromString(job.startDay!)!, direction: .Next, weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.startDay!)!) - 1], considerThisday: false)))' WHERE id = \(job.id!)"
            
            updateInDatabase(updateStatementString)
        }
        
        //Delete finish day
        else if NSCalendar.currentCalendar().startOfDayForDate(thisMonDay).compare(NSCalendar.currentCalendar().startOfDayForDate(get(dateFormatter.dateFromString(job.finishDay!)!, direction: .Previous, "Monday", considerThisday: true))) == NSComparisonResult.OrderedSame {
            
            updateStatementString = "UPDATE Jobs SET finishDay = '\(dateFormatter.stringFromDate(get(dateFormatter.dateFromString(job.finishDay!)!, direction: .Previous, weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.finishDay!)!) - 1], considerThisday: false)))' WHERE id = \(job.id!)"
            
            updateInDatabase(updateStatementString)
        }
        
        //Delete between start day and finish day
        else{
            
//            print(get(thisday.dayBefore, direction: .Previous, weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.startDay!)!) - 1], considerThisday: false))
//            print(thisday)
//            print(thisday.dayAfter)
//            print(weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.startDay!)!) - 1])
//            print(get(thisday.dayAfter, direction: .Next, weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.startDay!)!) - 1], considerThisday: false))
            
            insertJobToDatabase(job.label!, startTime: dateFormatter.dateFromString(job.startTime!)! , finishTime: dateFormatter.dateFromString(job.finishTime!)!, startDay: dateFormatter.dateFromString(job.startDay!)!, finishDay: get(thisday.dayBefore, direction: .Previous, weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.startDay!)!) - 1], considerThisday: false).dateByAddingTimeInterval(12*3600), color: job.color!)
            
            insertJobToDatabase(job.label!, startTime: dateFormatter.dateFromString(job.startTime!)! , finishTime: dateFormatter.dateFromString(job.finishTime!)!, startDay: get(thisday.dayAfter, direction: .Next, weekdaysArray[calendar.component(.Weekday, fromDate: dateFormatter.dateFromString(job.startDay!)!) - 1], considerThisday: false).dateByAddingTimeInterval(12*3600), finishDay: dateFormatter.dateFromString(job.finishDay!)!, color: job.color!)
            
            deleteInDatabase(job.id!)
        }
        
        
        
    }
    


    func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    //Enum indicates how the weekday will be searched
    enum SearchDirection {
        case Next
        case Previous
        
        //https://developer.apple.com/reference/foundation/nscalendar.options
        var calendarOptions: NSCalendarOptions {
            switch self {
            case .Next:
                return .MatchNextTime
            case .Previous:
                return [.SearchBackwards, .MatchNextTime]
            }
        }
    }
    
    //get weekdays date
    func get(day: NSDate, direction: SearchDirection, _ dayName: String, considerThisday consider: Bool = false) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.indexOf(dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        if consider && calendar.component(.Weekday, fromDate: day) == nextWeekDayIndex {
            return day  //the weekday will be searched with this day considered or not.
        }
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        //https://developer.apple.com/reference/foundation/nscalendar/1417170-nextdateafterdate?language=objc
        let date = calendar.nextDateAfterDate(day, matchingComponents: nextDateComponent, options: direction.calendarOptions)
        return date!
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "updateJob" {
            (segue.destinationViewController as! AddNewEventTableViewController).updateJob = detailJob!
            (segue.destinationViewController as! AddNewEventTableViewController).isUpdate = true
            (segue.destinationViewController as! AddNewEventTableViewController).updateJobToDatabaseDelegate = self
        }
    }
    

}
