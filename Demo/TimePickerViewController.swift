//
//  TimePickerViewController.swift
//  Demo
//
//  Created by Dien Dang on 9/2/16.
//  Copyright © 2016 Dien Dang. All rights reserved.
//

import UIKit

class TimePickerViewController: UIViewController {

    var startTimeSelectedDelegate: setNewEvent?
    var finishTimeSelectedDelegate: setNewEvent?
    var startDaySelectedDelegate: setNewEvent?
    var finishDaySelectedDelegate: setNewEvent?
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var dayPicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func setTime(sender: AnyObject) {
        startTimeSelectedDelegate?.settStartTime(timePicker.date)
        finishTimeSelectedDelegate?.settFinishTime(timePicker.date)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func setDay(sender: AnyObject) {
        startDaySelectedDelegate?.settStartDay(dayPicker.date)
        finishDaySelectedDelegate?.settFinishDay(dayPicker.date)
        navigationController?.popViewControllerAnimated(true)
    }
    
    

}
