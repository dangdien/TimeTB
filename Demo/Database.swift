//
//  Database.swift
//  Demo
//
//  Created by Dang Dien on 10/7/16.
//  Copyright © 2016 Dien Dang. All rights reserved.
//

import UIKit

class Database: UIViewController {
    
    func connectDatabase(fileName: String) -> COpaquePointer {
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
            print("Database already exist in \(dbPath)")            //Notify by an alert if there's already a
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("Successfully opened connection to database") //Open database without copy
            } else {
                print("Unable to open database")
            }
        }
        
        return db
    }

    
    func insertJobToDatabase(label: String, startTime: NSDate, finishTime: NSDate, startDay: NSDate, finishDay: NSDate, color: String){
        let newId = self.getMaxIdOfTable()
        
        let db = connectDatabase("TimeTable.sqlite")
        // Set date formatter
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        //Insert string of interting new job
        let insertStatementString = "INSERT INTO Jobs VALUES (\"\(label)\",'\(dateFormatter.stringFromDate(startTime))','\(dateFormatter.stringFromDate(finishTime))','\(dateFormatter.stringFromDate(startDay))','\(dateFormatter.stringFromDate(finishDay))',\"\(color)\", \(Int(newId+1)));"
        
        //compile Insert string
        var insertStatement: COpaquePointer = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            
            //Execute Insert string
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
                let msg = String.fromCString(sqlite3_errmsg(db))
                print("error : \(msg)")
            }
            sqlite3_finalize(insertStatement)
        }
        else {
            print("INSERT statement could not be prepared.")
        }
        // 5
        
        
        if sqlite3_close_v2(db) == SQLITE_OK{
            print("closed")
        }
    }
    

    
    func getMaxIdOfTable() -> Int{
        let db = connectDatabase("TimeTable.sqlite")
        let queryStatementString = "SELECT max(id) FROM Jobs"
        var queryStatement: COpaquePointer = nil
        var id = 0
        if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK{
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                id =  Int(sqlite3_column_int(queryStatement, 0))
                
            }
            sqlite3_finalize(queryStatement)
        }
        if sqlite3_close_v2(db) == SQLITE_OK{
            print("closed")
        }
        return id
        
    }

    
    func queryById(id: Int) -> job? {
        
        let db = connectDatabase("TimeTable.sqlite")
        let queryStatementString = "SELECT * FROM Jobs WHERE id = \(id)"
        var queryStatement: COpaquePointer = nil
        var jobRow: job?
        //compile the queryStatementString
        if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK{
            if sqlite3_step(queryStatement) == SQLITE_ROW {      //while the result returns rows then....
                jobRow = job(                                   //create a job with data from row returned
                    label: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 0))),
                    startTime: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 1))),
                    finishTime: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 2))),
                    startDay: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 3))),
                    finishDay: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 4))),
                    color: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 5))),
                    id: Int(sqlite3_column_int(queryStatement, 6))
                    
                )
            }
             sqlite3_finalize(queryStatement)
        }
       
        
        if sqlite3_close_v2(db) == SQLITE_OK{
            print("closed")
        }
        
        return jobRow
        
    }
    

    func getAllDataFromDatabase() -> Array<job> {
        // array of job struct
        let db = connectDatabase("TimeTable.sqlite")
        var jobArray = [job]()
        
        //SELECT statement
        let queryStatementString = "SELECT * FROM Jobs"
        var queryStatement: COpaquePointer = nil
        
        //compile the queryStatementString
        if sqlite3_prepare(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK{
            while sqlite3_step(queryStatement) == SQLITE_ROW {      //while the result returns rows then....
                let jobRow = job(                                   //create a job with data from row returned
                    
                    label: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 0))),
                    startTime: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 1))),
                    finishTime: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 2))),
                    startDay: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 3))),
                    finishDay: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 4))),
                    color: String.fromCString(UnsafePointer<CChar>(sqlite3_column_text(queryStatement, 5))),
                    id: Int(sqlite3_column_int(queryStatement, 6))
                    
                )
                jobArray.append(jobRow) //append new job into job array
            }
             sqlite3_finalize(queryStatement)
        }
       
        
        if sqlite3_close_v2(db) == SQLITE_OK{
            print("closed")
        }
        
        return jobArray
        
    }
    
    
    func updateInDatabase(updateStatementString: String){
        
        let db = connectDatabase("TimeTable.sqlite")
        var updateStatement: COpaquePointer = nil
        if sqlite3_prepare(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK{
            if sqlite3_step(updateStatement) == SQLITE_DONE{
                print("Successfully update row.")
            }
            else{
                print("Could not update row.")
                let msg = String.fromCString(sqlite3_errmsg(db))
                print("error : \(msg)")
            }
            sqlite3_finalize(updateStatement)
        }
        else{
            print("UPDATE statement could not be prepared")
        }
        
        
        if sqlite3_close_v2(db) == SQLITE_OK{
            print("closed")
        }
    }


    func deleteInDatabase(id: Int){
        
        let db = connectDatabase("TimeTable.sqlite")
        let deleteStatementString = "DELETE FROM Jobs WHERE id = \(id)"
        var deleteStatement: COpaquePointer = nil
        if sqlite3_prepare(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK{
            if sqlite3_step(deleteStatement) == SQLITE_DONE{
                print("Successfully deleted row.")
            }
            else{
                print("Could not delete row.")
                let msg = String.fromCString(sqlite3_errmsg(db))
                print("error : \(msg)")
            }
            sqlite3_finalize(deleteStatement)
        }
        else{
            print("DELETE statement could not be prepared")
        }
        
        
        if sqlite3_close_v2(db) == SQLITE_OK{
            print("closed")
        }
    }

    
}
