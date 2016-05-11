//
//  Survey.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/5/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//
import ResearchKit
import CareKit

struct ChoiceSurvey: Assessment {
    // MARK: Activity
    
    let activityType: ActivityType = .ChoiceSurvey
     func carePlanActivity() -> OCKCarePlanActivity {
        // Create a weekly schedule.
        let startDate = NSDateComponents(year: 2016, month: 01, day: 01)
        let schedule = OCKCareSchedule.weeklyScheduleWithStartDate(startDate, occurrencesOnEachDay: [1, 1, 1, 1, 1, 1, 1])
        
        // Get the localized strings to use for the assessment.
        let title = NSLocalizedString("Choice Survey", comment: "")
        
        
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
        
        //Create text choice
        let questQuestionStepTitle = "What is your choice?"
        let textChoices = [
            ORKTextChoice(text: "Option One: App 1", value: "App 1"),
            ORKTextChoice(text: "Option Two: App 2", value: "App 2"),
            ORKTextChoice(text: "Option Three: App 3", value: "App 3")
        ]
        let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: textChoices)
        let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questQuestionStepTitle, answer: questAnswerFormat)
        questQuestionStep.optional = false
        let task = ORKOrderedTask(identifier: activityType.rawValue, steps: [questQuestionStep])
        
        return task
    }
    
    
    
    
}
