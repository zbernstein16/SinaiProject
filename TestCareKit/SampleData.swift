//
//  SampleData.swift
//  TestCareKit
//
//  Created by Zachary Bernstein on 5/4/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.
//  Copyright (c) 2016, Apple Inc. All rights reserved.

import UIKit
import CareKit
import ResearchKit
class SampleData: NSObject {

    
    
    //MARK: Properties
    
        //Array of activities used in app
    
        let activities:[Activity] = [BackPain(),TakeMedication(),NameSurvey(),ChoiceSurvey(),Tower()]
    
        //Array of Contacts to display 
    
        //TODO: Incorporate way of getting these from database
    
        let contacts:[OCKContact] = [
            OCKContact(contactType: .CareTeam,
            name: "Dr. Maria Ruiz",
            relation: "Physician",
            tintColor:UIColor.blueColor(),
            phoneNumber: CNPhoneNumber(stringValue: "888-555-5512"),
            messageNumber: CNPhoneNumber(stringValue: "888-555-5512"),
            emailAddress: "mruiz2@mac.com",
            monogram: "MR",
            image: nil)]
    
    
    
    //MARK: Initializers
    
    required init(carePlanStore: OCKCarePlanStore) {
        super.init()
        
        // Populate the store with the sample activities.
        for sampleActivity in activities {
            let carePlanActivity = sampleActivity.carePlanActivity()
            
            
            carePlanStore.addActivity(carePlanActivity) { success, error in
                if !success {
                    print(error?.localizedDescription)
                }
            }
        }
        
    }
    //MARK: Helper
    
    //Returns any activity with given type
    func activityWithType(type: ActivityType) -> Activity? {
        for activity in activities where activity.activityType == type {
            return activity
        }
        
        return nil
    }
    
    func generateSampleDocument() -> OCKDocument {
        let subtitle = OCKDocumentElementSubtitle(subtitle: "First subtitle")
        
        let paragraph = OCKDocumentElementParagraph(content: "Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque. Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque. Lorem ipsum dolor sit amet, vim primis noster sententiae ne, et albucius apeirian accusata mea, vim at dicunt laoreet. Eu probo omnes inimicus ius, duo at veritus alienum. Nostrud facilisi id pro. Putant oporteat id eos. Admodum antiopam mel in, at per everti quaeque.")
        
        let document = OCKDocument(title: "Sample Document Title", elements: [subtitle, paragraph])
        document.pageHeader = "App Name: OCKSample, User Name: John Appleseed"
        
        return document
    }
    
}
