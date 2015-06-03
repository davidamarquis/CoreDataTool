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
    
var context:NSManagedObjectContext?;
var graph:Graph?;
var verts:Array<Vert>?;
var edges:Array<Edge>?;

var modelURL:NSURL?;
var model:NSManagedObjectModel?;
var store:NSPersistentStoreCoordinator?;

override func setUp() {
    super.setUp();
    setCore();
    makeGraph1();
}

func setCore() {
    modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension:"momd");
    if let nonnilURL=modelURL {
        model = NSManagedObjectModel(contentsOfURL: nonnilURL);
    }
    else {
    
    }
    if let nonnilModel = model {
        // init the persistent store coordinator
        store = NSPersistentStoreCoordinator(managedObjectModel: nonnilModel);
        
        // test if we can create an in-memory store
        // the return is an optional
        // TODO: not sure about the error
        if let nonnilStore=store {
            let inMem:NSPersistentStore? = store!.addPersistentStoreWithType(NSInMemoryStoreType, configuration:nil, URL:nil, options:nil, error:nil);
            if inMem==nil {
                XCTAssert(false, "Should be able to add a store in memory");
            }
        }
        else {
        
        }
    }
    else {
      
    }
    context = NSManagedObjectContext();
    if let nonnilContext=context {
        context!.persistentStoreCoordinator = store;
        graph=NSEntityDescription.insertNewObjectForEntityForName("Graph", inManagedObjectContext:nonnilContext) as? Graph;
    }
}

// verts array using swift arrays
func makeVertsArray(numVerts:Int) {
    verts=Array<Vert>();
    // check if verts is nonnil
    
    if var nonnilVerts=verts, nonnilContext=context {
        // assuming type inference will be able to handle the lack of an int declaration
        for var i=0;i<numVerts;i++ {
            var vert:Vert = NSEntityDescription.insertNewObjectForEntityForName("Vert", inManagedObjectContext: nonnilContext) as! Vert;
            // just append the fucker
            nonnilVerts.append(vert);
        }
    }
}

func makeEdgesArray:(int)numEdges {
    self.edges=[[NSMutableArray alloc] init];
    for(int i=0;i<numEdges;i++) {
        Edge* edge=[NSEntityDescription insertNewObjectForEntityForName:@"Edge" inManagedObjectContext:self.context];
        self.edges[i]=edge;
    }
}

func makeGraph1() {
    [self setCore];
    [self makeVertsArray:4];
    [self makeEdgesArray:4];
    
    // setup edges and verts and add to graph
    [self setupVert:@[_verts[0],@10,@70]];
    [self setupVert:@[_verts[1],@100,@200]];
    [self setupVert:@[_verts[2],@50,@300]];
    [self setupVert:@[_verts[3],@200,@80]];
    [self.graph setupEdge:_edges[0] from:_verts[0] to:_verts[1]];
    [self.graph setupEdge:_edges[1] from:_verts[0] to:_verts[2]];
    [self.graph setupEdge:_edges[2] from:_verts[0] to:_verts[3]];
    [self.graph setupEdge:_edges[3] from:_verts[1] to:_verts[2]];
}

/*
func makeGraph2() {
    [self setCore];
    [self makeVertsArray:3];
    [self makeEdgesArray:3];
    
    // setup edges and verts and add to graph
    [self setupVert:@[_verts[0],@10,@70]];
    [self setupVert:@[_verts[1],@100,@200]];
    [self setupVert:@[_verts[2],@50,@300]];
    [self.graph setupEdge:_edges[0] from:_verts[0] to:_verts[1]];
    [self.graph setupEdge:_edges[1] from:_verts[1] to:_verts[2]];
    [self.graph setupEdge:_edges[2] from:_verts[2] to:_verts[0]];
}

-(void)makeGraph3 {
    [self setCore];
    [self makeVertsArray:5];
    [self makeEdgesArray:4];
    // alias
    NSArray* E=self.edges;
    NSArray* V=self.edges;
    
    // setup edges and verts and add to graph
    [self setupVertsAtZero:_verts];
    [self.graph setupEdge:E[0] from:V[0] to:V[1]];
    [self.graph setupEdge:E[1] from:V[1] to:V[4]];
    [self.graph setupEdge:E[2] from:V[1] to:V[2]];
    [self.graph setupEdge:E[3] from:V[2] to:V[3]];
    
    // eventually should have [self.graph setupGraph:@[@[@1,@2],@[@1,@3],
}
//-(void)setupGraph

// takes an array of 3 args to setup a single vert
// arg0=vert index, arg1=xCoord, arg2=yCoord
-(void)setupVert:(NSArray*)args {
    [self.graph setupVert:args[0] atX:[args[1] doubleValue] atY:[args[2] doubleValue]];
}
// takes an array of verts and sets them up at (0,0)
-(void)setupVertsAtZero:(NSArray*)verts {
    for(id v in verts) {
        if(![v isKindOfClass:[Vert class]]) {
            XCTAssert(NO);
        }
        Vert* vert=(Vert*)v;
        [self setupVert:@[vert,@0,@0]];
    }
}

#pragma mark vert methods

-(void)testEdges1 {
    //NSMutableArray* mutableEdges;
    //[_graph edgeIdArray:&mutableEdges];
    
    NSArray* edges;
    [_graph sortedEdgeIdArray:&edges];
    
}

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

// all verts initially have not been seen
-(void)testSeen1 {
    XCTAssert([_verts[0] allNeighborsSeen]==NO);
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

// dist from v0=(10,70) to v1=(100,200) is 158
-(void)testDistance1 {
    double dist=[_verts[0] distance:_verts[1]];
    XCTAssert((158<dist) && (dist<159));
}

// dist from v0 to v0 is MAX
-(void)testDistance2 {
    double dist=[_verts[0] distance:_verts[0]];
    XCTAssert(([Vert MAXPosition]-0.1<dist) & (dist<[Vert MAXPosition]+0.1));
}

// dist from v2 to v3 is MAX
-(void)testDistance3 {
    double dist=[_verts[2] distance:_verts[3]];
    XCTAssert((([Vert MAXPosition]-0.1)<dist) & (dist<([Vert MAXPosition]+0.1)));
}

// v0 is a neighbor of v1
-(void)testNeighbor1 {
    // isNeighborOf always returns a BOOL so don't need to check for nil result
    XCTAssert([_verts[0] isNeighborOf:_verts[1]]);
}

// v2 is not a neighbor of v3
-(void)testNeighbor2 {
    XCTAssert(![_verts[2] isNeighborOf:_verts[3]]);
}

// an edge exists between v0 and v1
-(void)testSharedEdge1 {
    // expected edge id
    NSNumber* edgeId=((Edge*) _edges[0]).edgeViewId;
    // found edge
    Edge* edge=[_verts[0] getSharedEdge:_verts[1]];
    if((edge==nil) || ![edgeId isEqualToNumber:edge.edgeViewId]) {
        XCTAssert(NO);
    }
}

// an edge does not exist between v2 and v3
-(void)testSharedEdge2 {
    if([_verts[2] getSharedEdge:_verts[3]] != nil) {
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
