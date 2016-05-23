//
//  File.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/13/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.

import ResearchKit
import UIKit

public var ConsentDocument: ORKConsentDocument {

    let consentDocument = ORKConsentDocument()
    consentDocument.title = "Consent Form"
    
    //Consent Sections
    let consentSectionTypes: [ORKConsentSectionType] = [
        .Overview,
        .DataGathering,
        .Privacy,
        .DataUse,
        .TimeCommitment,
        .StudySurvey,
        .StudyTasks,
        .Withdrawing
    ]
    
    

    let consentSections: [ORKConsentSection] = consentSectionTypes.map { contentSectionType in
        let consentSection = ORKConsentSection(type: contentSectionType)
        consentSection.summary = "If you wish to complete this study..."
        consentSection.content = "In this study you will be asked to submit data"
        return consentSection
    }
    
    consentDocument.sections = consentSections
    //Signature
    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: "Patient", dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))
   
    
    return consentDocument



}