//
//  Tower.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/5/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//
import CareKit
import ResearchKit
struct Tower: Assessment {
    
    let activityType: ActivityType = .Tower
    //MARK: Activity
    func carePlanActivity() -> OCKCarePlanActivity {
        let startDate = NSDateComponents(year: 2000, month: 1, day: 1)
        let schedule = OCKCareSchedule.dailyScheduleWithStartDate(startDate, occurrencesPerDay: 1)
        
        let activity = OCKCarePlanActivity(identifier: activityType.rawValue, groupIdentifier: nil, type: .Assessment, title: "Tower", text: "", tintColor:UIColor.redColor(), instructions: "", imageURL:nil, schedule: schedule, resultResettable: true, userInfo: nil)
        return activity
        
    }
    
    
    //MARK: Assessment
    func task() -> ORKTask {
            let towerStep = ORKTowerOfHanoiStep(identifier: "TowerStep")
        
        
            towerStep.numberOfDisks = 3
    
        
        
        
        
        return ORKOrderedTask(identifier:activityType.rawValue, steps: [towerStep])
    }
}
