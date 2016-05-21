// ----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// ----------------------------------------------------------------------------
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit
import CareKit
import MobileCoreServices
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
 
    var client:MSClient?
    var adherenceTable:MSTable?
    var patientTable:MSTable?
    var PatientMedFreqTable:MSTable?
    var medicationTable:MSTable?
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    var window: UIWindow?
  
    
   
    

//MARK: Azure Methods
    
    //Every time user opens app for first time, or app enters background, or whenever background fetch occurs, this will query through all the health data for the past few days and generate a JSON file and upload it.
    func uploadJSON() {
        
        
        //UPDATE WILL ONLY FIRE IF USER HAS COMPLETED SURVEY. I.E HAS NAVIGATED TO MAIN VIEW CONTROLLER AND REGISTERD FOR UPDATE NOTIFICATION
            if NSUserDefaults.standardUserDefaults().boolForKey("surveyCompleted") == true
            {
                //This allows uploads to occur in the background
                registerBackgroundTask()
                
                
             
               
                
                let storeManager = CarePlanStoreManager.sharedCarePlanStoreManager
              
    
                
                    storeManager.store.eventsOnDate(NSDate().dateComponents(), type: .Intervention) { activities, errorOrNil in
                        for activity in activities
                        {
                            
                            let identifier = activity.first!.activity.identifier
                            let components = identifier.componentsSeparatedByString("/")
                            let medId:Int = Int(components.first!)!
                            let date:String = NSDate.dateFromComponents(activity.first!.date).monthDayYearString()
                            
                            
                          
                            
                            //Query to see if post already exists for that day
                            let medIdPredicate = NSPredicate(format:"Med_id == \(medId)")
                            let datePredicate = NSPredicate(format:"Date == '\(date)'")
                            let patPredicate = NSPredicate(format:"Patient_id == \(NSUserDefaults.standardUserDefaults().integerForKey(Constants.userIdKey))")
                            let compoundPredicate:NSCompoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates:[medIdPredicate,patPredicate,datePredicate])
                            let query = self.adherenceTable!.queryWithPredicate(compoundPredicate)
                            
                            query.readWithCompletion() {
                                (result, errorOrNil) in
                                if let error = errorOrNil
                                {
                                    print("LOCATION 1")
                                    print("ERROR:",error)
                                    
                                }
                                else
                                {
                                    var newAdherencePost:[String:AnyObject] = ["Patient_id":NSUserDefaults.standardUserDefaults().integerForKey(Constants.userIdKey),
                                                                                   "Med_id":medId,
                                                                                   "Date":date
                                                                                   ]
                                    var i:Int! = 1
                                    for event in activity
                                    {
                                        
                                        let time = NSDate.dateFromComponents(event.date).hourMinutesString()
                                        
                                        var result:String!
                                        switch event.state.rawValue
                                        {
                                        case 2:
                                            result = "Completed"
                                        default:
                                            result = "Not-Completed"
                                        }
                                       
                                        let statusString = "Status_" + String(i)
                                        let timeString = "Time_" + String(i)
                                        newAdherencePost[statusString] = result
                                        newAdherencePost[timeString] = time
                                        
                                        i = i+1
                                        
                                    }
                                    
                                   
                                    if let item = result.items.first
                                    {
                                        var newItem = item.mutableCopy() as! Dictionary<String,AnyObject>
                                        //Update Object
                                        newItem["Status_1"] = newAdherencePost["Status_1"]
                                        newItem["Status_2"] = newAdherencePost["Status_2"]
                                        newItem["Status_3"] = newAdherencePost["Status_3"]
                                        
                                        newItem["Time_1"] = newAdherencePost["Time_1"]
                                        newItem["Time_2"] = newAdherencePost["Time_2"]
                                        newItem["Time_3"] = newAdherencePost["Time_3"]
                                        
                                        self.adherenceTable!.update(newItem)
                                        {
                                            (results, error) in
                                            if let err = error {
                                                print("LOCATION 2")
                                                print("ERROR",err)
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                    else
                                    {
                                        //Insert new object
                                        self.adherenceTable!.insert(newAdherencePost)
                                        {
                                            (results, err2) in
                                            if let error = err2
                                            {
                                                print("LOCATION 3")
                                                print("ERROR",error)
                                            }
                                        }
                                        

                                    }
                                                                }
                            }
                            
    
                               
                            
                        }
                    }


                    
                    
                    
                    
                }
        
                
                
                
                
        }
        
        
    
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        uploadJSON()
    }
    func registerBackgroundTask() {
        backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler {
            [unowned self] in
            self.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        NSLog("Background task ended.")
        UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
//MARK: Normal Methods
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {

        
        
                
        //Updates store in background every 12 hours
        let twelveHourInterval:NSTimeInterval! = 12 * 60 * 60
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(twelveHourInterval)
        
        
        
        

       
        //REQUIRED FOR NOTIFICATIONS TO SHOW UP
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:[.Alert, .Badge, .Sound], categories: nil))  // types are UIUserNotificationType members
        
        
        //self.uploadJSON()
        
        
    
        return true
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
       
        
        
        
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        uploadJSON()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        endBackgroundTask()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] 
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("QSTodoDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("qstodoitem.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
}
struct Constants
{
    static var userIdKey = "idKey"
}

