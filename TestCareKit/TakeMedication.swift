//
//  TakeMedication.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/4/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//

import CareKit
import ResearchKit
class TakeMedication: Activity {

    
    let activityType: ActivityType = .TakeMedication
    
    
    func carePlanActivity() -> OCKCarePlanActivity {
        
        let startDate = NSDateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.dailyScheduleWithStartDate(startDate, occurrencesPerDay:3)
        

        
        return OCKCarePlanActivity.interventionWithIdentifier(activityType.rawValue, groupIdentifier: "", title: "Ibuprofen", text: nil, tintColor: UIColor.redColor(), instructions: "Take three times a day", imageURL: nil, schedule: schedule, userInfo: nil)
        
        


    }
}
