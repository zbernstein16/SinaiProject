//
//  Survey.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/5/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//
import ResearchKit
import CareKit

struct NameSurvey: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .NameSurvey
    
    func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = NSDateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklyScheduleWithStartDate(startDate, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Name Survey", comment: "")
       
        
        let activity = OCKCarePlanActivity.assessmentWithIdentifier(
            activityType.rawValue,
            groupIdentifier: nil,
            title: title,
            text: nil,
            tintColor: UIColor.blueColor(),
            resultResettable: true,
            schedule: schedule,
            userInfo: nil
        )
        
        return activity
    }
    
    // MARK: Assessment
    
    func task() -> ORKTask {
    
        
        
        //Create text input step
        let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
        nameAnswerFormat.multipleLines = false
        let nameQuestionStepTitle = "What is your name?"
        let nameQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nameQuestionStepTitle, answer: nameAnswerFormat)
        nameQuestionStep.optional = false
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [nameQuestionStep])
    
        
        return task
    }

    
    
    
}
