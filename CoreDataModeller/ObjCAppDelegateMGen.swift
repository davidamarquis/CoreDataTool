//
//  ObjCAppDelegateMGen.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-21.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

class ObjCAppDelegateMGen: NSObject {

    let username:String = "David Marquis";
    var graph:Graph?;
    
    var appDelegateM = String();
    var comment:Array<String> = Array<String>();
    var privInterface:Array<String> = Array<String>();
    var didFinishLaunch:Array<String> = Array<String>();
    var appWillResign:Array<String> = Array<String>();
    
    var appDidEnterBackground:Array<String> = Array<String>();
    var appWillEnterForeground:Array<String> = Array<String>();
    var appDidBecomeActive:Array<String> = Array<String>();
    var appWillTerminate:Array<String> = Array<String>();
    var variables:Array<String> = Array<String>();
    var appDocumentsDirectory:Array<String> = Array<String>();
    var managedObjectModel:Array<String> = Array<String>();
    var persistentStoreCoordinator:Array<String> = Array<String>();
    var context:Array<String> = Array<String>();
    var save:Array<String> = Array<String>();
   
    override init() {
        comment = ["//","//  AppDelegate.m","//  June4CoreDataObjCTest","//","//  Created by \(username) on 2015-06-04.","//  Copyright (c) 2015 \(username). All rights reserved.","//","","#import \"AppDelegate.h\"","#import <CoreData/CoreData.h>",""];
        // any custom class names should be put at the start of this array
        privInterface = ["@interface AppDelegate ()","","@end","@implementation AppDelegate"]
        didFinishLaunch = ["- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {","\t // Override point for customization after application launch.","[self setUpModel];","\t return YES;","}",""];
        appWillResign = ["- (void)applicationWillResignActive:(UIApplication *)application {","\t // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.","\t // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.","}",""];
        
        appDidEnterBackground = ["- (void)applicationDidEnterBackground:(UIApplication *)application {","// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.","// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.","}",""];
        appWillEnterForeground = ["- (void)applicationWillEnterForeground:(UIApplication *)application {","\t// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.","}",""];
        appDidBecomeActive = ["- (void)applicationDidBecomeActive:(UIApplication *)application {","\t// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.","}",""];
        appWillTerminate = ["- (void)applicationWillTerminate:(UIApplication *)application {","\t// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.", "}",""];
        variables = ["","#pragma mark - Core Data stack","","@synthesize context = _context;","@synthesize managedObjectModel = _managedObjectModel;","@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;",""];
        //TODO: fix the name in the comment
        appDocumentsDirectory = ["- (NSURL *)applicationDocumentsDirectory {","\t// The directory the application uses to store the Core Data store file. This code uses a directory named \"com.david.May10CoreDataHard\" in the application's documents directory.","\treturn [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];","}",""];
        managedObjectModel = ["- (NSManagedObjectModel *)managedObjectModel {","    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.","    if (_managedObjectModel != nil) {","","        return _managedObjectModel;","    }","    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@\"Model\" withExtension:@\"momd\"];","    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];","    return _managedObjectModel;","}",""];
        persistentStoreCoordinator = ["- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {","\t// The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.","\tif (_persistentStoreCoordinator != nil) {","\treturn _persistentStoreCoordinator;","\t}","","\t// Create the coordinator and store","","\t_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];","\tNSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@\"Model.sqlite\"];","\tNSError *error = nil;","\tNSString *failureReason = @\"There was an error creating or loading the application's saved data.\";","\tif (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {","\t\t// Report any error we got.","\t\tNSMutableDictionary *dict = [NSMutableDictionary dictionary];","\t\tdict[NSLocalizedDescriptionKey] = @\"Failed to initialize the application's saved data\";","\t\tdict[NSLocalizedFailureReasonErrorKey] = failureReason;","\t\tdict[NSUnderlyingErrorKey] = error;","\t\terror = [NSError errorWithDomain:@\"YOUR_ERROR_DOMAIN\" code:9999 userInfo:dict];","\t\t// Replace this with code to handle the error appropriately.","\t\t// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.","\t\tNSLog(@\"Unresolved error %@, %@\", error, [error userInfo]);","\t\tabort();","\t}","","\treturn _persistentStoreCoordinator;","}","",""];

        context = ["- (NSManagedObjectContext *)context {","","\t// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)","\tif (_context !=nil) {","","\treturn _context;","\t}","","\tNSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];","\tif (!coordinator) {","","\t\treturn nil;","\t}","\t_context = [[NSManagedObjectContext alloc] init];","\t[_context setPersistentStoreCoordinator:coordinator];","","\treturn _context;","}",""];

        save = ["#pragma mark - Core Data Saving support","","- (void)saveContext {","\tNSManagedObjectContext *managedObjectContext = self.context;","\tif (managedObjectContext != nil) {","\t\tNSError *error = nil;","\t\t\tif ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {","\t\t\t\t// Replace this implementation with code to handle the error appropriately.","\t\t\t\t// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.","\t\t\t\tNSLog(@\"Unresolved error %@, %@\", error, [error userInfo]);","\t\t\tabort();","\t\t}","\t}","}","","","@end","","\t}",""];
    }

    func updateString() {
        for str in comment {
            appDelegateM += str+"\n";
        }
        for str in privInterface {
            appDelegateM += str+"\n";
        }
        for str in didFinishLaunch {
            appDelegateM += str+"\n";
        }
        
        appDelegateM += "-(void)setupModel {\n";
        for obj in graph!.verts {
            if obj is Vert {
                let vert = obj as! Vert;
                // entity
                appDelegateM += "NSEntityDescription *runEntity = [[NSEntityDescription alloc] init];\n";
                appDelegateM += "[runEntity setName:@\"Run\"];\n";
                appDelegateM += "[runEntity setManagedObjectClassName:@\"Run\"];\n";
                appDelegateM += "[self.managedObjectModel setEntities:@[runEntity]];\n";
                appDelegateM += "\n";
                appDelegateM += "NSMutableArray *runProperties = [NSMutableArray array];\n";
                for elem in vert.attributes {
                    if elem is Attribute {
                        let attr = elem as! Attribute;
                        appDelegateM += "NSAttributeDescription *dateAttribute = [[NSAttributeDescription alloc] init];\n";
                        appDelegateM += "[runProperties addObject:dateAttribute];\n";
                        appDelegateM += "[dateAttribute setName:@\"date\"];\n"
                        appDelegateM += "[dateAttribute setAttributeType:NSDateAttributeType];\n";
                        appDelegateM += "[dateAttribute setOptional:NO];\n";
                    }
                }
                appDelegateM += "}\n";
                appDelegateM += "[runEntity setProperties:runProperties];\n";
                appDelegateM += "}\n";
            }
        }

        for str in appWillResign {
            appDelegateM += str+"\n";
        }
        for str in appDidEnterBackground {
            appDelegateM += str+"\n";
        }
        for str in appWillEnterForeground {
            appDelegateM += str+"\n";
        }
        for str in appDidBecomeActive {
            appDelegateM += str+"\n";
        }
        for str in appWillTerminate {
            appDelegateM += str+"\n";
        }
        for str in variables {
            appDelegateM += str+"\n";
        }
        for str in appDocumentsDirectory {
            appDelegateM += str+"\n";
        }
        for str in managedObjectModel {
            appDelegateM += str+"\n";
        }
        for str in persistentStoreCoordinator {
            appDelegateM += str+"\n";
        }
        for str in context {
            appDelegateM += str+"\n";
        }
        for str in save {
            appDelegateM += str+"\n";
        }
    }
}
