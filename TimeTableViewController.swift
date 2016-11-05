//
//  TimeTableViewController.swift
//  Demo
//
//  Created by Dien Dang on 8/31/16.
//  Copyright © 2016 Dien Dang. All rights reserved.
//

import UIKit


extension NSDate{
    func isBetweeen(date date1: NSDate, andDate date2: NSDate) -> Bool {
        return date1.compare(self) == self.compare(date2)
    }
    var dayAfter:NSDate {
        let oneDay:Double = 60 * 60 * 24
        return self.dateByAddingTimeInterval(oneDay)
    }
    var dayBefore:NSDate {
        let oneDay:Double = 60 * 60 * 24
        return self.dateByAddingTimeInterval(-(Double(oneDay)))
    }
}

struct job {
    
    var label: String?
    var startTime: String?
    var finishTime: String?
    var startDay: String?
    var finishDay: String?
    var color: String?
    var id: Int?
}

protocol addToDatabase {
    func insertJobToDatabase(label: String, startTime: NSDate, finishTime: NSDate, startDay: NSDate, finishDay: NSDate, color: String)
}
class TimeTableViewController: Database, addToDatabase, UIPopoverPresentationControllerDelegate {

    var weekdaysViewArray = [UIView]()
    var dayLabelsArray = [UILabel]()

    //struct of job (records' struct in database)

    //weekdays' views
    @IBOutlet weak var monView: UIView!
    @IBOutlet weak var tueView: UIView!
    @IBOutlet weak var wedView: UIView!
    @IBOutlet weak var thuView: UIView!
    @IBOutlet weak var friView: UIView!
    @IBOutlet weak var satView: UIView!
    @IBOutlet weak var sunView: UIView!
    
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var tueLabel: UILabel!
    @IBOutlet weak var wedLabel: UILabel!
    @IBOutlet weak var thuLabel: UILabel!
    @IBOutlet weak var friLabel: UILabel!
    @IBOutlet weak var satLabel: UILabel!
    @IBOutlet weak var sunLabel: UILabel!
    
    
    let colorNameArray = ["Purple","Red","Blue","Orange"]
    let colorArray = [UIColor.purpleColor().colorWithAlphaComponent(0.5), UIColor.redColor().colorWithAlphaComponent(0.5), UIColor.blueColor().colorWithAlphaComponent(0.5), UIColor.orangeColor().colorWithAlphaComponent(0.5)]
    
    var currentMonDay = NSDate()
    
    var currentButtonsTag = 0
    
    override func viewDidLoad() {
        
        weekdaysViewArray.append(sunView)
        weekdaysViewArray.append(monView)
        weekdaysViewArray.append(tueView)
        weekdaysViewArray.append(wedView)
        weekdaysViewArray.append(thuView)
        weekdaysViewArray.append(friView)
        weekdaysViewArray.append(satView)
        
        dayLabelsArray.append(monLabel)
        dayLabelsArray.append(tueLabel)
        dayLabelsArray.append(wedLabel)
        dayLabelsArray.append(thuLabel)
        dayLabelsArray.append(friLabel)
        dayLabelsArray.append(satLabel)
        dayLabelsArray.append(sunLabel)
        
        
        super.viewDidLoad()
        let today = NSDate()
        currentMonDay = get(today, direction: .Previous, "Monday", considerThisday: true)
        fillTimeTable(currentMonDay, endOfWeek: get(today, direction: .Next, "Sunday", considerThisday: true))
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(animated: Bool) {
        fillTimeTable(currentMonDay, endOfWeek: get(currentMonDay, direction: .Next, "Sunday", considerThisday: true))
        
    }
    
    
    
    @IBAction func btnPrevWeek(sender: AnyObject) {
        currentMonDay = get(currentMonDay, direction: .Previous, "Monday", considerThisday: false)
        fillTimeTable(currentMonDay, endOfWeek: get(currentMonDay, direction: .Next, "Sunday", considerThisday: false))
    }
    
    
    @IBAction func btnNextWeek(sender: AnyObject) {
        currentMonDay = get(currentMonDay, direction: .Next, "Monday", considerThisday: false)
        fillTimeTable(currentMonDay, endOfWeek: get(currentMonDay, direction: .Next, "Sunday", considerThisday: false))
    }
    
    
    
    
    // Function add new event button to calendar and add new record to database
    func addNewEventToTimeTable(startTime: NSDate, finishTime: NSDate, startDay: NSDate, finishDay: NSDate,withTitle: String, color: UIColor, tag: Int){
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        
        let indexOfDay = calendar.component(.Weekday, fromDate: startDay) - 1
        // add a button from start time to finish time on start days' weekday
        addButtonToCalendar(startTime, finishTime: finishTime, view: weekdaysViewArray[indexOfDay], color: color, title: withTitle, tag: tag)
 
    }
    


    // function to fill the timetable
    func fillTimeTable(startOfWeek: NSDate, endOfWeek: NSDate){
        
        // remove all button subviews in time table
        for view in weekdaysViewArray{
            for subView in view.subviews {
                subView.removeFromSuperview()
            }
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        
        let jobArray = getAllDataFromDatabase()     // retrieve all data from database and append to jobArray
        
        for job in jobArray {
            // get data from each record of jobArray
            let startTime = dateFormatter.dateFromString(job.startTime!)
            let finishTime = dateFormatter.dateFromString(job.finishTime!)
            let startDay = dateFormatter.dateFromString(job.startDay!)
            let finishDay = dateFormatter.dateFromString(job.finishDay!)
            let tag = job.id    //buttons' tag = id of record in database

            // for each job, if startDay < endOfWeek and finishDay > startOfWeek then add a job button to timetable
            if startDay?.compare(endOfWeek.dateByAddingTimeInterval(24*3600-1)) == NSComparisonResult.OrderedAscending && (finishDay?.dateByAddingTimeInterval(12*3600))!.compare(NSCalendar.currentCalendar().startOfDayForDate(startOfWeek)) == NSComparisonResult.OrderedDescending{
                addNewEventToTimeTable(startTime!, finishTime: finishTime!, startDay: startDay!, finishDay: finishDay!, withTitle: job.label!, color: colorArray[colorNameArray.indexOf(job.color!)!], tag: tag!)
            }
        }
        
        // --change days' label indicator--
        var daysInWeek = get(startOfWeek, direction: .Previous,  "Monday", considerThisday: true)  //start with monday
        
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "dd"
        
        for label in dayLabelsArray{
            label.text = dayFormatter.stringFromDate(daysInWeek)
            daysInWeek = daysInWeek.dayAfter            //set day label for the next day by change to next day
        }
    }
    
    
    
    
    
    
    // function to add subview (button) to time tables' view
    func addButtonToCalendar(startTime: NSDate, finishTime: NSDate, view: UIView, color: UIColor, title: String, tag: Int){
        
        let periodOfTime: NSTimeInterval = finishTime.timeIntervalSinceDate(startTime)/60 // Period time between startTime and finishTime
        let startOfDay = NSCalendar.currentCalendar().startOfDayForDate(startTime)     // 00:00 AM of startTime
        let periodFromStartOfDay: NSTimeInterval = startTime.timeIntervalSinceDate(startOfDay)/60  //Period time between startTime and 00:00AM of startTime

        // width of UIView
        let parentWidth = Double(view.frame.size.width)
        
        
        //Create a job as a button
        let newJob = UIButton()
        newJob.frame = CGRect(x: 5.0, y: periodFromStartOfDay*0.67+20, width:parentWidth, height: periodOfTime*0.67)
        newJob.backgroundColor = color
        newJob.setTitle(title, forState: .Normal)
        newJob.titleLabel!.sizeToFit()
        newJob.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        newJob.titleLabel!.font = UIFont(name: "ArchitectsDaughter", size: 15)
        newJob.addTarget(self, action: #selector(TimeTableViewController.presentPopover(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        newJob.tag = tag        //set new buttons' tag = id of event in database

        view.addSubview(newJob)
    }
    
    //function for TouchUpInside event
    
    func presentPopover(sender: UIButton!) {
        currentButtonsTag = sender.tag  //use for prepareForSegue
        self.performSegueWithIdentifier("showPopover", sender: sender)
        
    }
    

    //Function get weekday name in English
    
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
    
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail"{
          (segue.destinationViewController as! AddNewEventTableViewController).addJobToDatabaseDelegate = self
        }
        
        if segue.identifier == "showPopover"{
            let vc = segue.destinationViewController
            let controller = vc.popoverPresentationController
            (segue.destinationViewController as! PopoverViewController).detailJob = queryById(currentButtonsTag)
            (segue.destinationViewController as! PopoverViewController).currentTag = currentButtonsTag
            (segue.destinationViewController as! PopoverViewController).thisMonDay = currentMonDay
            (segue.destinationViewController as! PopoverViewController).currentTag = currentButtonsTag
            if controller != nil {
                controller!.delegate = self
            }

            

            
        }
    }
    
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    


}

