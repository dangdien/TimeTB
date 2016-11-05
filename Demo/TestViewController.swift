//
//  TestViewController.swift
//  Demo
//
//  Created by Dang Dien on 10/2/16.
//  Copyright © 2016 Dien Dang. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    var db: COpaquePointer = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = openDatabase("TimeTable.sqlite")

        
        
        // Do any additional setup after loading the view.
    }

    
    func openDatabase(fileName: String) -> COpaquePointer
    {
        var db: COpaquePointer = nil
        
        //Searching for path of database
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileURL = documentsURL.URLByAppendingPathComponent(fileName)
        
        let dbPath: String = fileURL!.path!
        let fileManager = NSFileManager.defaultManager()
        if !fileManager.fileExistsAtPath(dbPath){       //If database not exist then...
            
            let documentURL = NSBundle.mainBundle().resourceURL
            let fromPath = documentURL!.URLByAppendingPathComponent(fileName)        //Get database path from projects location
            
            var error: NSError?
            
            do {
                try fileManager.copyItemAtPath(fromPath!.path!, toPath: dbPath) //Try to copy database from projects location to applications documents location
            } catch let error1 as NSError{
                error = error1
            }
            
            let alert: UIAlertView = UIAlertView()
            
            if(error != nil){
                alert.title = "Error Occured"
                alert.message = error?.localizedDescription //If database is not exist in projects location then pop out error alert
            }
            else {
                alert.title = "Successfully Copy"                   //Notify by an alert if copy successfully
                alert.message = "Your database copy successfully"
                if sqlite3_open(dbPath, &db) == SQLITE_OK {
                    print("Successfully opened connection to database")     //Open database just copied
                } else {
                    print("Unable to open database")
                }
                
            }
            alert.delegate = nil
            alert.addButtonWithTitle("Ok")
            alert.show()
        }
        else{
            print("Database already exist in \(dbPath)")            //Notify by an alert if there's already a database in applications documents location
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("Successfully opened connection to database") //Open database without copy
            } else {
                print("Unable to open database")
            }
        }
        
        return db
    }

    func deleteDatabase(id: Int, db: COpaquePointer){
        
        let deleteStatementString = "DELETE FROM Jobs WHERE id = \(id)"
        var deleteStatement: COpaquePointer = nil
        if sqlite3_prepare(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK{
            if sqlite3_step(deleteStatement) == SQLITE_DONE{
                print("Successfully deleted row.")
            }
            else{
                print("Could not delete row.")
            }
        }
        else{
            print("DELETE statementt could not be prepared")
        }
        sqlite3_finalize(deleteStatement)
    }

    @IBAction func touchBtn(sender: AnyObject) {
        deleteDatabase(1, db: db)
    }
    
}
