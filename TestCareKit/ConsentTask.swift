//
//  ConsentTask.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/13/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.

import ResearchKit


public var ConsentTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    let consentDocument = ConsentDocument
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]
    let ageStep = ORKFormStep(identifier: "dateOfBirthPage", title: "Date of Birth", text: "Enter date of birth")
    ageStep.optional = false
    
    let dateItem = ORKFormItem(identifier: "dateOfBirth", text: "Born:", answerFormat:ORKDateAnswerFormat(style: ORKDateAnswerStyle.Date))
    dateItem.placeholder = "MM/DD/YYYY"
    ageStep.formItems = [dateItem]
    steps += [ageStep]
    
    let signature = consentDocument.signatures!.first! 
    
    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, inDocument: consentDocument)
    
    reviewConsentStep.text = "Review Consent!"
    reviewConsentStep.reasonForConsent = "Consent to join study"
    
    steps += [reviewConsentStep]
    
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
