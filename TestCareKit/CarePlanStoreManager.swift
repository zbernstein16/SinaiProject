////  Copyright © 2016 Zachary Bernstein. All rights reserved.


import CareKit

class CarePlanStoreManager: NSObject {
    // MARK: Static Properties
    
    static var sharedCarePlanStoreManager = CarePlanStoreManager()
    
    // MARK: Properties
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate! as! AppDelegate
    
    weak var delegate: CarePlanStoreManagerDelegate?
    
    let store: OCKCarePlanStore

    private let insightsBuilder: InsightsBuilder
    
    var insights: [OCKInsightItem] {
        return insightsBuilder.insights
    }
    
    //TODO: NEED TO ARCHIVE THIS ARRAY
    
    var activities:[Activity]?
    
    // MARK: Initialization
    
    private override init() {
        
        
        
        //WARNING:
        //TODO:
        //NEED TO ADD HERE THAT WHENEVER APP STARTS UP, WE ADD ALL THE Activity Objects to this class' array
        // Start to build the initial array of insights.
        
        if let _ = NSKeyedUnarchiver.unarchiveObjectWithFile(Constants.archivePath) as? [Activity]
        {
            activities = NSKeyedUnarchiver.unarchiveObjectWithFile(Constants.archivePath) as? [Activity]
        }
        else
        {
            activities = [Activity]()
        }
        print("Location 1")
        print(activities)
        
        // Determine the file URL for the store.
        let searchPaths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)
        let applicationSupportPath = searchPaths[0]
        let persistenceDirectoryURL = NSURL(fileURLWithPath: applicationSupportPath)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(persistenceDirectoryURL.absoluteString, isDirectory: nil) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(persistenceDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create the store.
        store = OCKCarePlanStore(persistenceDirectoryURL: persistenceDirectoryURL)
        
        /*
         Create an `InsightsBuilder` to build insights based on the data in
         the store.
         */
        insightsBuilder = InsightsBuilder(carePlanStore: store)
        
        super.init()
        
        // Register this object as the store's delegate to be notified of changes.
        store.delegate = self
        
       
        
        updateInsights()
    }
    
    
    func updateInsights() {
        
        print("Location 2")
        print(NSKeyedUnarchiver.unarchiveObjectWithFile(Constants.archivePath) as? [Activity])
        
        insightsBuilder.updateInsights { [weak self] completed, newInsights in
            // If new insights have been created, notifiy the delegate, which is main view controller
            guard let storeManager = self, newInsights = newInsights where completed else { return }
            //TODO: Change method call here so that eventually it can add ResearchKIt Chart
            storeManager.delegate?.carePlanStoreManager(storeManager, didUpdateInsights: newInsights)
            
        }
    }
    func handleNewMedication(PatMedFreqDictionary:Dictionary<String,AnyObject>)
    {
        

        let medId:Int = PatMedFreqDictionary["Med_id"] as! Int
        let freq:Int = PatMedFreqDictionary["Freq"] as! Int
        let startDate:NSDate = PatMedFreqDictionary["Start_Date"] as! NSDate
        
        
        //4: Query through Med table with MedId to get all events with that Id
        
        let predicate = NSPredicate(format:"id == \(medId)", argumentArray: nil)
        self.appDelegate.medicationTable!.readWithPredicate(predicate)
        {
            results, errorOrNil in
            if let error = errorOrNil
            {
                fatalError(error.localizedDescription)
            }
            else if let results = results
            {
                for activity in results.items
                {
                    let name:String = activity["Name"] as! String
                    let type:String = activity["Type"] as! String
                    //TODO: Add more types here 
                    switch type {
                        case "Drug":
                           let drug = Drug(withName: name, start: startDate, occurences: freq, medId:medId)
                           self.store.addActivity(drug.carePlanActivity()) {
                                                success, errorOrNil in
                                                if let error = errorOrNil
                                                {
                                                    fatalError(error.localizedDescription)
                                                }
                                                else
                                                {
                                                    
                                                    self.activities!.append(drug)
                                                    NSKeyedArchiver.archiveRootObject(self.activities!, toFile:Constants.archivePath)
                                                }
                            }
                        case "PainScale":
                            let painScale = PainScale(withTypeOfPain: name, start: startDate, occurences: freq, medId: medId)
                            self.store.addActivity(painScale.carePlanActivity()) {
                                            success, error in
                                            if let error = errorOrNil
                                            {
                                                fatalError(error.localizedDescription)
                                            }
                                            else
                                            {
                                                self.activities!.append(painScale)
                                                NSKeyedArchiver.archiveRootObject(self.activities!, toFile:Constants.archivePath)
                                            }
                            }
                        default:
                            break
                    }
                    }
                
            }
        }
        
    }
    func activityWithType(type: ActivityType) -> Activity? {
        for activity in activities! where activity.activityType == type {
           return activity
        }
        
        return nil
    }
    
}



extension CarePlanStoreManager: OCKCarePlanStoreDelegate {
    func carePlanStoreActivityListDidChange(store: OCKCarePlanStore) {
        updateInsights()
    }
    
    func carePlanStore(store: OCKCarePlanStore, didReceiveUpdateOfEvent event: OCKCarePlanEvent) {
        updateInsights()
    }
}



protocol CarePlanStoreManagerDelegate: class {
    
    func carePlanStoreManager(manager: CarePlanStoreManager, didUpdateInsights insights: [OCKInsightItem])
    
}