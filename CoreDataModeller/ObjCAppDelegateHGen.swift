//
//  ObjCAppDelegateHGen.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-21.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation

class ObjCAppDelegateHGen: NSObject {
   
    var appDelegateH:String = String();

    var user:User? = nil;    
    var username:String = "";
    
    var comment:Array<String> = Array<String>();
    var body:Array<String> = Array<String>();
    var date = "";
    var year = "";
    
    func setStrArrays() {
        comment = ["//","//  AppDelegate.h","//  June4CoreDataObjCTest","//","//  Created by \(username) on \(date).","//  Copyright (c) \(year) \(username). All rights reserved.","//","","#import <UIKit/UIKit.h>","","@interface AppDelegate : UIResponder <UIApplicationDelegate>",""];
        // any custom class names should be put at the start of this array
        body = ["-(void)setupModel;","","@property (strong, nonatomic) UIWindow *window;","","# pragma mark core data","@property (readonly, strong, nonatomic) NSManagedObjectContext *context;","@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;","@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;","","- (void)saveContext;","- (NSURL *)applicationDocumentsDirectory;","","@end"];
    }
    
    func updateString() {
    
        // set properties needed for strings
        username = user!.username;
        year = CurDate().getYearString();
        date = CurDate().getDateString();
        
        setStrArrays();
        for str in comment {
            appDelegateH += str+"\n";
        }
        for str in body {
            appDelegateH += str+"\n";
        }
    }
}
