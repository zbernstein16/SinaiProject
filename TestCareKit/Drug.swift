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
    var id:Int!
    init(withName name:String,start:NSDate,occurences:Int, medId:Int)
    {
        self.drugName = name
        self.startDate = start.dateComponents()
        self.freq = occurences
        self.id = medId
    }
    func carePlanActivity() -> OCKCarePlanActivity {
        print("Frequency")
        print(freq)
        
        //TODO: REMOVE THIS
        let schedule = OCKCareSchedule.dailyScheduleWithStartDate(startDate, occurrencesPerDay:UInt(freq))
       

        
        
        let identifier = String("\(id)/\(freq)")
        return OCKCarePlanActivity.interventionWithIdentifier(identifier, groupIdentifier: "", title: drugName, text: nil, tintColor: UIColor.redColor(), instructions: "Take \(freq) time(s) a day", imageURL: nil, schedule: schedule, userInfo: nil)

        
       
        
        
    }
}
