//
//  Constants.swift
//  Sinai App
//
//  Created by Zachary Bernstein on 5/23/16.
//  Copyright © 2016 Zachary Bernstein. All rights reserved.


import Foundation


struct Constants
{
    static var userIdKey = "idKey"
    
    static var archivePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! 
        return url.URLByAppendingPathComponent("objectsArray").path!
    }
    
}