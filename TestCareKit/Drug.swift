//
//  TakeMedication.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/4/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//

import CareKit
import ResearchKit
class Drug: Activity {
    
    
    let activityType: ActivityType = .TakeMedication
    var drugName: String!
    var startDate:NSDateComponents!
    var freq:Int!
    init(withName name:String,start:NSDateComponents,occurences:Int)
    {
        self.drugName = name
        self.startDate = start
        self.freq = occurences
    }
    func carePlanActivity() -> OCKCarePlanActivity {
        
        let schedule = OCKCareSchedule.dailyScheduleWithStartDate(startDate, occurrencesPerDay:UInt(freq))
        
        
        
        return OCKCarePlanActivity.interventionWithIdentifier(activityType.rawValue, groupIdentifier: "", title: drugName, text: nil, tintColor: UIColor.redColor(), instructions: "Take \(freq) time(s) a day", imageURL: nil, schedule: schedule, userInfo: nil)
        
        
        
        
    }
}
