//
//  getDateString.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-27.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class CurDate: NSObject {

    func getDateString()->String {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate());
        let year = Int32(components.year);
        let month = Int32(components.month);
        let day = Int32(components.day);
        return "\(year)-\(month)-\(day)";
    }
    
    func getYearString()->String {
        let components = NSCalendar.currentCalendar().components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate());
        let year = Int32(components.year);
        return "\(year)";
    }
}
