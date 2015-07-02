//
//  CoreDataModellerTests.swift
//  CoreDataModellerTests
//
//  Created by David Marquis on 2015-05-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class CoreDataModellerTests: XCTestCase {
    
var graph:Graph?;
var verts:Array<Vert>?;
var edges:Array<Edge>?;

// setUp sets up the XCTestCases
override func setUp() {
    let graphDescription = NSEntityDescription.entityForName("Graph",inManagedObjectContext: context!);
    graph = Graph(entity: graphDescription!,insertIntoManagedObjectContext: context);
    
    super.setUp();
    makeGraph1();
}

// MARK: - Core Data stack
lazy var applicationDocumentsDirectory: NSURL =
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.david.CoreDataTest" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1] as NSURL
}()

lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    // TODO: change "CoreDataTest" using grep
    let urlOrNil = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd");
    if urlOrNil == nil {

    }
    let modelURL = urlOrNil! ;
    return NSManagedObjectModel(contentsOfURL: modelURL)! ;
}()

lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataTest.sqlite")
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
        try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch var error1 as NSError {
        error = error1
        coordinator = nil
        // Report any error we got.
        var dict = [String: AnyObject]()
        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
        dict[NSLocalizedFailureReasonErrorKey] = failureReason
        dict[NSUnderlyingErrorKey] = error
        error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog("Unresolved error \(error), \(error!.userInfo)")
        abort()
    } catch {
        fatalError()
    }
    
    return coordinator
}()

lazy var context: NSManagedObjectContext? = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
        return nil
    }
    var context = NSManagedObjectContext()
    context.persistentStoreCoordinator = coordinator
    return context
}()

// MARK: - Core Data Saving support

func saveContext () {
    if let moc = context {
        if moc.hasChanges {
            do {
               try moc.save();
            }
            catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
            }
        }
    }
}

// MARK: tests

// verts array using swift arrays
func makeVertsArray(numVerts:Int) {
    verts=Array<Vert>();
    let vertDescription = NSEntityDescription.entityForName("Vert",inManagedObjectContext: context!);
    
    // check if verts is nonnil
    if(verts != nil && context != nil) {
        for var i=0;i<numVerts;i++ {
            let vert:Vert? = Vert(entity: vertDescription!,insertIntoManagedObjectContext: context);
            verts!.append(vert!);
        }
    }
    else {print("CoreController: makeVertsArray(): verts is nil or context is nil");}
}

func makeEdgesArray(numEdges:Int) {
    edges=Array<Edge>();
    let edgeDescription = NSEntityDescription.entityForName("Edge",inManagedObjectContext: context!);
    
    if (edges != nil && context != nil) {
        for var i=0;i<numEdges;i++ {
            let edge:Edge? = Edge(entity: edgeDescription!,insertIntoManagedObjectContext: context);
            if edge != nil {
                edges!.append(edge!);
            }
            else { print("tests: makeEdgesArray: edge is nil"); }
        }
    }
    else {print("CoreController: makeEdgesArray(): edges is nil or context is nil");}
}

func makeGraph1() {
    makeVertsArray(4);
    makeEdgesArray(4);
    
    // setup edges and verts and add to graph
    // the methods SetupVert and SetupEdges expect optionals
    if (graph != nil && verts != nil && edges != nil) {
        graph!.SetupVert(verts![0], AtX:10, AtY:70);
        graph!.SetupVert(verts![1], AtX:100, AtY:200);
        graph!.SetupVert(verts![2], AtX:50, AtY:300);
        graph!.SetupVert(verts![3], AtX:200, AtY:80);
        // passing 3 arguments into
        
        // TODO: probably bad
        graph!.SetupEdge(edges![0], From:verts![0], To:verts![1]);
        graph!.SetupEdge(edges![1], From:verts![0], To:verts![2]);
        graph!.SetupEdge(edges![2], From:verts![0], To:verts![3]);
        graph!.SetupEdge(edges![3], From:verts![1], To:verts![2]);
        
        edges![0].setNameForVert(verts![0], relationshipName:"photosTaken");
        edges![0].setNameForVert(verts![1], relationshipName:"photographer");
    }
    
}

func makeGraph2() {
    makeVertsArray(3);
    makeEdgesArray(3);
    
    // setup edges and verts and add to graph
    if (graph != nil && verts != nil && edges != nil) {
        graph!.SetupVert(verts![0], AtX:10, AtY:70);
        graph!.SetupVert(verts![1], AtX:100, AtY:200);
        graph!.SetupVert(verts![2], AtX:50, AtY:300);
        graph!.SetupEdge(edges![0], From:verts![0], To:verts![1]);
        graph!.SetupEdge(edges![1], From:verts![1], To:verts![2]);
        graph!.SetupEdge(edges![2], From:verts![2], To:verts![0]);
    }
}

// takes an array of verts and sets them up at (0,0)
func setupVertsAtZero(verts: Array<Vert>) {
    
    if graph != nil {
        for vert in verts
        {
            graph!.SetupVert(vert, AtX:0, AtY:0);
        }
    }
}

func makeGraph3() {
    makeVertsArray(5);
    makeEdgesArray(4);
    // setup edges and verts and add to graph
    
    if verts != nil {
        setupVertsAtZero(verts!);
        if(graph != nil) {
            graph!.SetupEdge(edges![0], From:verts![0], To:verts![1]);
            graph!.SetupEdge(edges![1], From:verts![1], To:verts![4]);
            graph!.SetupEdge(edges![2], From:verts![1], To:verts![2]);
            graph!.SetupEdge(edges![3], From:verts![2], To:verts![3]);
        }
    }
    // TODO: eventually should have [self.graph setupGraph:@[@[@1,@2],@[@1,@3],
}

// in Graph 1 the v0 is joined to v1 by e0
func testNeighborOnEdge1() {
    let neighbor:Vert?;
    neighbor = verts![0].getNeighborOnEdge(edges![0]);
    
    XCTAssert(verts![1] === neighbor);
}

// In Graph 1 all verts initially have not been seen
func testSeen1() {
    if verts != nil {
    
        XCTAssert(verts![0].allNeighborsSeen() == false);
    }
    else { XCTAssert(false); }
}

// In Graph 1 all verts start with edges that are not fresh
/*
func testFreshEdges1() {
    if verts != nil {
        XCTAssert(verts![0].freshEdges==false);
    }
}
*/

// graph 1 has been set up
// dist from v0=(10,70) to v1=(100,200) is 158
func testDistance1() {
    if verts != nil {
        let dist:Float = verts![0].distance(verts![1]);
        
        XCTAssert((158<dist) && (dist<159));
    }
    else {
        XCTAssert(false);
    }
}

// the relationship out of vert 0 via edge 0 is called photosTaken
func testGetNameForVert() {
    let relationshipName:String? = edges![0].getNameForVert(verts![0]);
    
    if relationshipName != nil {
        XCTAssert( relationshipName! == "photosTaken" );
    }
    else {
        XCTAssert( false );
    }
}

// the relationship out of vert 0 via edge 1 does not exist
func testGetNameForVert2() {
    let relationshipName:String? = edges![1].getNameForVert(verts![0]);
    
    if relationshipName != nil {
        XCTAssert( relationshipName! != "photosTaken" );
    }
    else {
        XCTAssert( false );
    }
}

// v0 is a neighbor of v1
func testNeighbor1() {
    // isNeighborOf always returns a BOOL so don't need to check for nil result
    XCTAssert( verts![0].isNeighborOf(verts![1]) );
}

// In graph 1 v2 is not a neighbor of v3
func testNeighbor2() {
    XCTAssert( !verts![2].isNeighborOf(verts![3]) );
}

// an edge exists between v0 and v1
func testSharedEdge1() {
    // expected edge id
    let edgeId = edges![0].edgeViewId;
    // found edge
    let edge:Edge? = verts![0].getSharedEdge(verts![1]);
    
    if edge == nil || edgeId != edge!.edgeViewId {
        XCTAssert(false);
    }
}

// an edge does not exist between v2 and v3
func testSharedEdge2() {
    if verts![2].getSharedEdge(verts![3]) != nil {
        XCTAssert(false);
    }
}

/*
// dist from v0 to v0 is MAX
func testDistance2() {
    double dist=[_verts[0] distance:_verts[0]];
    XCTAssert(([Vert MAXPosition]-0.1<dist) & (dist<[Vert MAXPosition]+0.1));
}

// dist from v2 to v3 is MAX
func testDistance3() {
    double dist=[_verts[2] distance:_verts[3]];
    XCTAssert((([Vert MAXPosition]-0.1)<dist) & (dist<([Vert MAXPosition]+0.1)));
}

#pragma mark vert methods

// a cycle exists (0,1),(1,2),(2,0)
-(void)testCycle1 {
    XCTAssert([self.graph cycleExists]);
}
// a cycle exists (0,1),(1,2),(2,0)
-(void)testCycle2 {
    [self makeGraph2];
    XCTAssert([self.graph cycleExists]);
}
// a cycle does not exist
-(void)testCycle3 {
    [self makeGraph3];
    XCTAssert(![self.graph cycleExists]);
}

// a neighbor of v0 has been seen but not all neighbors of v0 have been
-(void)testSeen2 {
    Vert* vert=(Vert*)_verts[1];
    [vert setDepthSearchSeen:NO];
    XCTAssert([_verts[0] allNeighborsSeen]==NO);
}
// all neighbors of v0 have not been seen
-(void)testSeen3 {
    Vert* v0=(Vert*)_verts[0];
    for(id v in v0.neighbor) {
        if([v isKindOfClass:[Vert class]]) {
            Vert* vert=(Vert*)v;
            if([vert depthSearchSeen]) {
                XCTAssert(NO);
            }
        }
    }
}
// one neighbor of v0 has not been seen
-(void)testSeen4 {
    int seenCount=0;
    Vert* v0=(Vert*)_verts[0];
    [[v0.neighbor anyObject] setDepthSearchSeen:YES];
    for(id v in v0.neighbor) {
        if([v isKindOfClass:[Vert class]]) {
            Vert* vert=(Vert*)v;
            if([vert depthSearchSeen]) {
                seenCount++;
            }
        }
    }
    if(seenCount!=1) {
        XCTAssert(NO);
    }
}

-(void)testest {
    // nothing here
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}
*/
}
