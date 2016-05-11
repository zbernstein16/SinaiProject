import CareKit

class QueryActivityEventsOperation: NSOperation {
    // MARK: Properties
    
    private let store: OCKCarePlanStore
    
    private let activityIdentifier: String
    
    private let startDate: NSDateComponents
    
    private let endDate: NSDateComponents
    
    private(set) var dailyEvents: DailyEvents?
    
    // MARK: Initialization
    
    init(store: OCKCarePlanStore, activityIdentifier: String, startDate: NSDateComponents, endDate: NSDateComponents) {
        self.store = store
        self.activityIdentifier = activityIdentifier
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // MARK: NSOperation
    
    override func main() {
        // Do nothing if the operation has been cancelled.
        guard !cancelled else { return }
        
        // Find the activity with the specified identifier in the store.
        guard let activity = findActivity() else { return }
        
        /*
         Create a semaphore to wait for the asynchronous call to `enumerateEventsOfActivity`
         to complete.
         */
        let semaphore = dispatch_semaphore_create(0)
        
        // Query for events for the activity between the requested dates.
        self.dailyEvents = DailyEvents()
        
        dispatch_async(dispatch_get_main_queue()) { // <rdar://problem/25528295> [CK] OCKCarePlanStore query methods crash if not called on the main thread
            self.store.enumerateEventsOfActivity(activity, startDate: self.startDate, endDate: self.endDate, handler: { event, _ in
                if let event = event {
                    self.dailyEvents?[event.date].append(event)
                }
                }, completion: { _, _ in
                    // Use the semaphore to signal that the query is complete.
                    dispatch_semaphore_signal(semaphore)
            })
        }
        
        // Wait for the semaphore to be signalled.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    // MARK: Convenience
    
    private func findActivity() -> OCKCarePlanActivity? {
        /*
         Create a semaphore to wait for the asynchronous call to `activityForIdentifier`
         to complete.
         */
        let semaphore = dispatch_semaphore_create(0)
        
        var activity: OCKCarePlanActivity?
        
        dispatch_async(dispatch_get_main_queue()) { // <rdar://problem/25528295> [CK] OCKCarePlanStore query methods crash if not called on the main thread
            self.store.activityForIdentifier(self.activityIdentifier) { success, foundActivity, error in
                activity = foundActivity
                if !success {
                    print(error?.localizedDescription)
                }
                
                // Use the semaphore to signal that the query is complete.
                dispatch_semaphore_signal(semaphore)
            }
        }
        
        // Wait for the semaphore to be signalled.
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)

        
        return activity
    }
}



struct DailyEvents {
    // MARK: Properties
    
    private var mappedEvents: [NSDateComponents: [OCKCarePlanEvent]]
    
    var allEvents: [OCKCarePlanEvent] {
        return Array(mappedEvents.values.flatten())
    }
    
    var allDays: [NSDateComponents] {

        return Array(mappedEvents.keys)
    }
    
    subscript(day: NSDateComponents) -> [OCKCarePlanEvent] {
        get {
            if let events = mappedEvents[day] {
                return events
            }
            else {
                return []
            }
        }
        
        set(newValue) {
            mappedEvents[day] = newValue
        }
    }
    
    // MARK: Initialization
    
    init() {
        mappedEvents = [:]
    }
}