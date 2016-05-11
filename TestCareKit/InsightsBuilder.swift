////
////  InsightsBuilder.swift
////  TestCareKit
////
////  Created by Zachary Bernstein on 5/4/16.
////  Copyright © 2016 Zachary Bernstein. All rights reserved.
////
import ResearchKit
import CareKit

class InsightsBuilder {
    
    /// An array if `OCKInsightItem` to show on the Insights view.
    private(set) var insights = [OCKInsightItem.emptyInsightsMessage()]
    
    private let carePlanStore: OCKCarePlanStore
    
    private let updateOperationQueue = NSOperationQueue()
    
    required init(carePlanStore: OCKCarePlanStore) {
        self.carePlanStore = carePlanStore
    }
    
    /**
     Enqueues `NSOperation`s to query the `OCKCarePlanStore` and update the
     `insights` property.
     */
    func updateInsights(completion: ((Bool, [OCKInsightItem]?) -> Void)?) {
        // Cancel any in-progress operations.
        updateOperationQueue.cancelAllOperations()
        
        // Get the dates the current and previous weeks.
        let queryDateRange = calculateQueryDateRange()
        
        /*
         Create an operation to query for events for the previous week's
         `TakeMedication` activity.
         */
        
        
        //TODO: INCORPORATE NEW METRICS HERE
        let medicationEventsOperation = QueryActivityEventsOperation(store: carePlanStore,
                                                                     activityIdentifier: ActivityType.TakeMedication.rawValue,
                                                                     startDate: queryDateRange.start,
                                                                     endDate: queryDateRange.end)
        
        /*
         Create an operation to query for events for the previous week and
         current weeks' `BackPain` assessment.
         */
        let backPainEventsOperation = QueryActivityEventsOperation(store: carePlanStore,
                                                                   activityIdentifier: ActivityType.BackPain.rawValue,
                                                                   startDate: queryDateRange.start,
                                                                   endDate: queryDateRange.end)
        let towerEventsOperation = QueryActivityEventsOperation(store: carePlanStore, activityIdentifier: ActivityType.Tower.rawValue, startDate: queryDateRange.start, endDate: queryDateRange.end)
        
        /*
         Create a `BuildInsightsOperation` to create insights from the data
         collected by query operations.
         */
        let buildInsightsOperation = BuildInsightsOperation()
        
        /*
         Create an operation to aggregate the data from query operations into
         the `BuildInsightsOperation`.
         */
        let aggregateDataOperation = NSBlockOperation {
            // Copy the queried data from the query operations to the `BuildInsightsOperation`.
            buildInsightsOperation.medicationEvents = medicationEventsOperation.dailyEvents
            buildInsightsOperation.backPainEvents = backPainEventsOperation.dailyEvents
           buildInsightsOperation.towerEvents = towerEventsOperation.dailyEvents
        }
        
        /*
         Use the completion block of the `BuildInsightsOperation` to store the
         new insights and call the completion block passed to this method.
         */
        buildInsightsOperation.completionBlock = { [unowned buildInsightsOperation] in
            let completed = !buildInsightsOperation.cancelled
            let newInsights = buildInsightsOperation.insights
            // Call the completion block on the main queue.
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if completed {
                    completion?(true, newInsights)
                }
                else {
                    completion?(false, nil)
                }
            }
        }
        
        // The aggregate operation is dependent on the query operations.
        aggregateDataOperation.addDependency(medicationEventsOperation)
        aggregateDataOperation.addDependency(backPainEventsOperation)
        aggregateDataOperation.addDependency(towerEventsOperation)
        
        // The `BuildInsightsOperation` is dependent on the aggregate operation.
        buildInsightsOperation.addDependency(aggregateDataOperation)
        
        // Add all the operations to the operation queue.
        updateOperationQueue.addOperations([
            medicationEventsOperation,
            backPainEventsOperation,
            towerEventsOperation,
            aggregateDataOperation,
            buildInsightsOperation
            ], waitUntilFinished: false)
    }
    
    private func calculateQueryDateRange() -> (start: NSDateComponents, end: NSDateComponents) {
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        
        let currentWeekRange = calendar.weekDatesForDate(now)
        let previousWeekRange = calendar.weekDatesForDate(currentWeekRange.start.dateByAddingTimeInterval(-1))
        
        let queryRangeStart = NSDateComponents(date: previousWeekRange.start, calendar: calendar)
        let queryRangeEnd = NSDateComponents(date: now, calendar: calendar)
        
        return (start: queryRangeStart, end: queryRangeEnd)
    }
}



protocol InsightsBuilderDelegate: class {
    func insightsBuilder(insightsBuilder: InsightsBuilder, didUpdateInsights insights: [OCKInsightItem])
}