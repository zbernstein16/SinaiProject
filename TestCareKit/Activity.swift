//
//  Activity.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/4/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//  Copyright (c) 2016, Apple Inc. All rights reserved.

import CareKit

//Protocol Defines what is necesssary for activities to have
protocol Activity {
    
    var activityType:ActivityType { get }
    func carePlanActivity() -> OCKCarePlanActivity
    
}



enum ActivityType:String {
    
    case HamstringStretch
    case TakeMedication
    case NameSurvey
    case ChoiceSurvey
    case BackPain
    case Mood
    case BloodGlucose
    case Tower
}