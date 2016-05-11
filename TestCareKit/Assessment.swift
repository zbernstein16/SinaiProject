//
//  Assessment.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/4/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//  Copyright (c) 2016, Apple Inc. All rights reserved.

import CareKit
import ResearchKit

protocol Assessment: Activity {
    func task() -> ORKTask
}


/**
 Extends instances of `Assessment` to add a method that returns a
 `OCKCarePlanEventResult` for a `OCKCarePlanEvent` and `ORKTaskResult`. The
 `OCKCarePlanEventResult` can then be written to a `OCKCarePlanStore`.
 */
extension Assessment {
    func buildResultForCarePlanEvent(event: OCKCarePlanEvent, taskResult: ORKTaskResult) -> OCKCarePlanEventResult {
        // Get the first result for the first step of the task result.
        guard let firstResult = taskResult.firstResult as? ORKStepResult, stepResult = firstResult.results?.first else { fatalError("Unexepected task results") }
        
        // Determine what type of result should be saved.
        if let scaleResult = stepResult as? ORKScaleQuestionResult, answer = scaleResult.scaleAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: "out of 10", userInfo: nil)
        }
        else if let numericResult = stepResult as? ORKNumericQuestionResult, answer = numericResult.numericAnswer {
            return OCKCarePlanEventResult(valueString: answer.stringValue, unitString: numericResult.unit, userInfo: nil)
        }
        else if let choiceResult = stepResult as? ORKChoiceQuestionResult, answer = choiceResult.choiceAnswers?.first {
            
            return OCKCarePlanEventResult(valueString:String(answer), unitString: "", userInfo: nil)
        }
        else if let textResult = stepResult as? ORKTextQuestionResult, answer = textResult.textAnswer {
    
            return OCKCarePlanEventResult(valueString: answer, unitString: "", userInfo: nil)
        }
        else if let hanoiResult = stepResult as? ORKTowerOfHanoiResult {
            let answer = hanoiResult.puzzleWasSolved
            switch answer {
            case true:
                //return OCKCarePlanEventResult(valueString: "Solved", unitString: "", userInfo: nil)
                return OCKCarePlanEventResult(valueString: String(hanoiResult.moves!.count), unitString: "Moves", userInfo: nil)
            case false:
                return OCKCarePlanEventResult(valueString: "Failed", unitString: "", userInfo: nil)
            }
        }
        //TODO: Add Task Result types for all possible activities
        fatalError("Unexpected task result type")
    }
}