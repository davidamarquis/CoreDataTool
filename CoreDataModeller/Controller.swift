//
//  Controller.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-31.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class CoreController: UIViewController, UIScrollViewDelegate {

required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
    hght=self.view.bounds.size.height;
    wdth=self.view.bounds.size.width;
}

let hght:CGFloat;
let wdth:CGFloat;
let vscale:CGFloat=0.15;

// main view is graphView
// use a closure to contain the initialization logic
lazy var graphView:GraphView? = {
    var gv=GraphView()
    
    gv.frame=CGRectMake(CGFloat(0), CGFloat(0), self.wdth, self.hght*(1-self.vscale));
    gv.backgroundColor=UIColor.whiteColor;
    gv.maximumZoomScale=2.0;
    gv.minimumZoomScale=0.2;
    gv.delegate=self;
    self.view.addSubview=gv;
    return gv;
}()

// the graph property is our model
// Controller owns so the model so we maintain a strong reference
var graph:Graph?;
// TO DO what is this?
var resume:Bool?;

var vertViewCount:Int;

let context:NSManagedObjectContext;
let managedObjectModel:NSManagedObjectModel;
let persistentStoreCoordinator:NSPersistentStoreCoordinator;
/*
lazy var graph:Graph?={
    var tempGraph=NSEntityDescription.insertNewObjectForEntityForName(<#entityName: String#>, inManagedObjectContext: <#NSManagedObjectContext#>);
    return tempGraph;
    }()

func setGraphView(graphView: GraphView) {
  
      if(!_graphView) {
        _graphView=[[GraphView alloc] init];
        _graphView.frame=CGRectMake(0, 0,self.view.bounds.size.width,self.hght*(1-self.bottomBarScale));
        _graphView.backgroundColor=[UIColor whiteColor];
        
        // add as a subview
        [self.view addSubview:_graphView];
        
        // set up zoom
        _graphView.maximumZoomScale=2.0;
        _graphView.minimumZoomScale=0.2;
        _graphView.delegate=self;
    }
    _graphView=graphView;
}
func setGraph(graph:Graph) {
    if(!_graph) {
        _graph=[NSEntityDescription insertNewObjectForEntityForName:@"Graph" inManagedObjectContext:self.context];
    }
    _graph=graph;
}

func barButtons() {
    UIButton* edgeButton=[self barButton:@"E"];
    edgeButton.frame=CGRectMake(0,self.hght*(1-self.bottomBarScale),self.wdth*0.333,self.hght*self.bottomBarScale);
    [edgeButton addTarget:self action:@selector(edgeMode) forControlEvents:UIControlEventTouchUpInside];

    UIButton* moveButton=[self barButton:@"M"];
    moveButton.frame=CGRectMake(self.wdth*0.333,self.hght*(1-self.bottomBarScale),self.wdth*0.333,self.hght*self.bottomBarScale);
    [moveButton addTarget:self action:@selector(moveMode) forControlEvents:UIControlEventTouchUpInside];

    UIButton* vertButton=[self barButton:@"V"];
    vertButton.frame=CGRectMake(self.wdth*0.666,self.hght*(1-self.bottomBarScale),self.wdth*0.334,self.hght*self.bottomBarScale);
    [vertButton addTarget:self action:@selector(vertMode) forControlEvents:UIControlEventTouchUpInside];
}

// creates an individual button
func barButton:(NSString*)title {
    UIColor* backCol=[UIColor blackColor];
    UIFont* buttonFont=[UIFont systemFontOfSize:60];
    UIColor* textCol=[UIColor grayColor];
    
    UIButton* button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.backgroundColor=backCol;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:textCol forState:UIControlStateNormal];
    button.titleLabel.font = buttonFont;
    [self.view addSubview:button];
    return button;
}

func setupController() {

    // constants
    self.bottomBarScale=0.15f;
    self.hght=self.view.bounds.size.height;
    self.wdth=self.view.bounds.size.width;
    
    // bottom bar
    UIView* bottomBar =[[UIView alloc] initWithFrame:CGRectMake(0,self.hght*(1-self.bottomBarScale),
    self.view.bounds.size.width,
    self.hght*self.bottomBarScale)];
    bottomBar.backgroundColor=[UIColor blueColor];
    [self.view addSubview:bottomBar];
    
    // add the buttons to the bottom bar
    [self barButtons];

}
func moveMode() {
}
func vertMode() {
}
func edgeMode() {
    // TO DO turn off pan and zoom
    self.graphView.maximumZoomScale=1.0;
    self.graphView.minimumZoomScale=1.0;
}

func -(void)onResumeGraph {
    [self setupController];
    // TO DO
}

func -(void)onNewGraph {
    [self setupController];
    [self testGraph];
}

// private
-(void)testGraph {
    Vert* v1=[self testVertAtX:10 AtY:70];
    Vert* v2=[self testVertAtX:100 AtY:200];
    Vert* v3=[self testVertAtX:50 AtY:300];
    Vert* v4=[self testVertAtX:200 AtY:80];
    Edge* e1=[NSEntityDescription insertNewObjectForEntityForName:@"Edge" inManagedObjectContext:self.context];
    Edge* e2=[NSEntityDescription insertNewObjectForEntityForName:@"Edge" inManagedObjectContext:self.context];
    Edge* e3=[NSEntityDescription insertNewObjectForEntityForName:@"Edge" inManagedObjectContext:self.context];
    Edge* e4=[NSEntityDescription insertNewObjectForEntityForName:@"Edge" inManagedObjectContext:self.context];
    [self.graph setupEdge:e1 from:v1 to:v2];
    [self.graph setupEdge:e2 from:v1 to:v3];
    [self.graph setupEdge:e3 from:v1 to:v4];
    [self.graph setupEdge:e4 from:v2 to:v3];
    
    //-(Edge*)getSharedEdge:(Vert*)other;
    //-(NSNumber*)getEdgeId:(Vert*)other withError:(int*)err;
}

// private
-(Vert*)testVertAtX:(double)xPos AtY:(double)yPos {
    Graph* graph=self.graph;
    // alloc, observe it, set it up in graph (vertId and relationship)
    Vert* vert=[NSEntityDescription insertNewObjectForEntityForName:@"Vert" inManagedObjectContext:self.context];
    [vert addObserver:self forKeyPath:@"finishedObservedMethod" options:0 context:NULL];
    // setupVert calls Vert to finish setup
    [graph setupVert:vert atX:xPos atY:yPos];
    return vert;
}

// KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
   if ([object isKindOfClass:[Vert class]]) {
        Vert* v=(Vert*)object;
        if([keyPath isEqualToString:@"finishedObservedMethod"] && self.graphView)
        {
            if(![v freshVertView]) {
                VertView* vertView=[self.graphView.gwv getVertViewById:v.vertViewId];
                
                // check if a view exists corresponding to the vert instance
                //   if no view is found then vertView is nil and we alloc a vertView and add it
                //   otherwise model and view are out of date: drawn==NO implies Vert instance has changed since the last time the VC drew
                // VC updates the view by removing the outdated VertView and adding a correct one
                if(vertView!=nil) {
                    [vertView removeFromSuperview];
                    vertView.x=[v.xNum doubleValue];
                    vertView.y=[v.yNum doubleValue];
                    [self.graphView.gwv addSubview:vertView];
                    [vertView setNeedsDisplay];
                }
                else if(vertView==nil) {
                    VertView* vv=[self.graphView.gwv addVertAtPoint:CGPointMake([v x], [v y])];
                    vv.delegate=self;
                    vv.vertViewId=[[NSNumber alloc] initWithInt:[v.vertViewId intValue]];
                    
                }
                // vert instance now fresh
                [v setFreshVertView:YES];
            }
            if(![v freshEdgeViews]) {
                [self drawEdges:v];
                // edge instance now fresh
                [v setFreshEdgeViews:YES];
            }
        }
    }
}

-(void)dealloc {
    for(Vert* vert in self.graph.vert) {
        [vert removeObserver:self forKeyPath:@"modelInt"];
    }
}

// more zoom stuff
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.graphView.gwv;
}

// private method
// drawEdges draws the edges out of v
-drawEdges()->v:Vert {

    double X1,Y1,X2,Y2,diameter,frameWidth,frameHeight;
    CGRect edgeFrame;
    
    for(Vert* w in v.neighbor) {
        // check that the class is correct
        // and the verts v and w are not equal
        // and the neighbors of v have not been drawn already
        
        if([w isKindOfClass:[Vert class]] && ![v isPositionEqual:w] && ![v freshEdgeViews]) {
            // ensure edges don't get drawn twice with neighborsDrawn flag

            X1=v.x;
            Y1=v.y;
            X2=w.x;
            Y2=w.y;
            diameter=self.graphView.gwv.diameter;
            frameWidth=fabs(X1-X2)+diameter;
            frameHeight=fabs(Y1-Y2)+diameter;
            // adjust the frame based on the least coordinate for the xval and yval for the pair of points
            if(X1<X2 && Y1<Y2) {
                edgeFrame=CGRectMake(X1, Y1 , frameWidth, frameHeight);
                [self.graphView.gwv addEdgeWithFrame:edgeFrame :0 ];
            }
            else if(X1<X2 && Y1>=Y2) {
                edgeFrame=CGRectMake(X1, Y2 , frameWidth, frameHeight);
                [self.graphView.gwv addEdgeWithFrame:edgeFrame :1 ];
            }
            else if(X1>=X2 && Y1<Y2) {
                edgeFrame=CGRectMake(X2, Y1 , frameWidth, frameHeight);
                [self.graphView.gwv addEdgeWithFrame:edgeFrame :1 ];
            }
            else if(X1>=X2 && Y1>=Y2) {
                edgeFrame=CGRectMake(X2, Y2 , frameWidth, frameHeight);
                [self.graphView.gwv addEdgeWithFrame:edgeFrame :0 ];
            }
        }
    }
}

// public
// this method is called the -(void)pan in VertView
-(void)drawGraphAfterMovingVert:(NSArray*)args
{
    if(![args[0] isKindOfClass:[NSNumber class]]) {
        NSLog(@"drawGraphAfterMovingVert: args[0] is not an NSNumber");
    }
    else {
        NSNumber* viewId=args[0];
        if(!(0 < [viewId intValue] < [self.graph.vert count])) {
            NSLog(@"drawGraphAfterMovingVert: view id too large or small");
        }
        else {
            double endX=[args[1] doubleValue];
            double endY=[args[2] doubleValue];
            // moveVertById changes the core model
            // this class is listening for changes in the core model
            [self.graph moveVertById:viewId toXPos:endX toYPos:endY];
        }
    }
}

// public
// the method addVertToModel is triggered whenever the user hits the button
- (void)addVertToModel {
    // TO DO
    [self testVertAtX:200 AtY:300];
}

// context = _context;
// managedObjectModel = _managedObjectModel;
// persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.david.May10CoreDataHard" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
    
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)context {

    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_context !=nil) {
    
        return _context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
    
        return nil;
    }
    _context = [[NSManagedObjectContext alloc] init];
    [_context setPersistentStoreCoordinator:coordinator];
    
    return _context;
}

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.context;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
*/
}
