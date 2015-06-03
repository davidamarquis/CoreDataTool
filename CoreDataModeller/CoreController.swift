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

override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);    
}

required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder);
}

let vscale:CGFloat=0.15;
var hght:CGFloat=CGFloat();
var wdth:CGFloat=CGFloat();
var vertViewCount:Int=Int();

override func viewDidLoad() {

    hght=self.view.bounds.size.height;
    wdth=self.view.bounds.size.width;
    self.barButtons();
}

// sets up 3 buttons for the view controllers UI states
func barButtons() {

    let edgeButton:UIButton = self.barButton("E");
    edgeButton.frame=CGRectMake(0,hght*(1-vscale),wdth*0.333,hght*vscale);
    edgeButton.addTarget(self, action: "edgeMode", forControlEvents:.TouchUpInside);

    let moveButton:UIButton = self.barButton("M");
    moveButton.frame=CGRectMake(wdth*0.333,hght*(1-vscale),wdth*0.333,hght*vscale);
    moveButton.addTarget(self, action: "moveMode", forControlEvents:.TouchUpInside);

    let vertButton:UIButton = self.barButton("V");
    vertButton.frame=CGRectMake(wdth*0.666,hght*(1-vscale),wdth*0.334,hght*vscale);
    vertButton.addTarget(self, action: "vertMode", forControlEvents:.TouchUpInside);
}

// main view is graphView
// use a closure to contain the initialization logic
lazy var graphView:GraphView? = {
    // this is how designated initializers are called in swift
    var gv=GraphView()
    
    gv.frame=CGRectMake(CGFloat(0), CGFloat(0), self.wdth, self.hght*(1-self.vscale));
    gv.backgroundColor=UIColor.init( red:CGFloat(0),green:CGFloat(0),blue:CGFloat(0),alpha:CGFloat(0) );
    gv.maximumZoomScale=2.0;
    gv.minimumZoomScale=0.2;
    gv.delegate=self;
    self.view.addSubview(gv);
    return gv;
}()

// the graph property is our model
// Controller owns so the model so we maintain a strong reference
lazy var graph:Graph?={
    var graph:Graph?;
    if let context=self.context {
        graph = NSEntityDescription.insertNewObjectForEntityForName("Graph", inManagedObjectContext: context) as? Graph;
    }
    return graph;
}()

// creates an individual button
func barButton(title:String) -> UIButton {
    // bcol is color of back of button, tcol of the text on the button
    let bcol:UIColor=UIColor.blackColor();
    let tcol:UIColor=UIColor.grayColor();
    let buttonFont:UIFont=UIFont.systemFontOfSize(60);
    
    let button:UIButton=UIButton.buttonWithType(.System) as! UIButton;
    button.backgroundColor=bcol;
    button.setTitle(title, forState:UIControlState.Normal);
    button.setTitleColor(tcol, forState:.Normal);
    if let label=button.titleLabel {
         label.font=buttonFont;
    }
    view.addSubview(button);
    return button;
}

func edgeMode() {
    // TO DO turn off pan and zoom
    if let gv=graphView {
        gv.maximumZoomScale=1.0;
        gv.minimumZoomScale=1.0;
    }
    else {
        
    }
}
func moveMode() {
}
func vertMode() {
}

func onResumeGraph() {
    // TO DO
}

func onNewGraph() {
    testGraph();
}

func stupid() {
    var myGraph=GraphFunction();
    if let context=self.context {
        myGraph = NSEntityDescription.insertNewObjectForEntityForName("Graph", inManagedObjectContext: context) as! GraphFunction;
        myGraph.fuck();
    }
}

// private
// create some variables in the managedObjectModel and send them to the model for setup
private func testGraph() {

    var v1:Vert?=testVert(10, 70);
    var v2:Vert?=testVert(100, 200);
    var v3:Vert?=testVert(50, 300);
    var v4:Vert?=testVert(200, 80);
    var e1:Edge?;
    var e2:Edge?;
    var e3:Edge?;
    var e4:Edge?;
    if let nonnilCon=context, let nonnilGraph=graph {
        e1=NSEntityDescription.insertNewObjectForEntityForName("Edge", inManagedObjectContext:nonnilCon) as? Edge;
        e2=NSEntityDescription.insertNewObjectForEntityForName("Edge", inManagedObjectContext:nonnilCon) as? Edge;
        e3=NSEntityDescription.insertNewObjectForEntityForName("Edge", inManagedObjectContext:nonnilCon) as? Edge;
        e4=NSEntityDescription.insertNewObjectForEntityForName("Edge", inManagedObjectContext:nonnilCon) as? Edge;
        nonnilGraph.SetupEdge(e1, From:v1, To:v2);
        nonnilGraph.SetupEdge(e2, From:v1, To:v3);
        nonnilGraph.SetupEdge(e3, From:v1, To:v4);
        nonnilGraph.SetupEdge(e4, From:v2, To:v3);
    }
}

// private
// inits a vert at the given position
private func testVert(xPos:Double, _ yPos:Double) -> Vert? {
    // alloc, observe it, set it up in graph (vertId and relationship)
    var vert:Vert?;
    if let nonnilCon=context, nonnilGraph=graph {
        vert=NSEntityDescription.insertNewObjectForEntityForName("Vert", inManagedObjectContext:nonnilCon) as? Vert;
        // TODO: vert.addObserver:self forKeyPath:@"finishedObservedMethod" options:0 context:NULL];
        // setupVert calls Vert to finish setup
        nonnilGraph.SetupVert(vert, AtX:xPos, AtY:yPos);
    }
    return vert;
}

/*
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
*/

// context = _context;
// managedObjectModel = _managedObjectModel;
// persistentStoreCoordinator = _persistentStoreCoordinator;

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL =
    {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.david.CoreDataTest" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        // TODO: change "CoreDataTest" using grep
        let modelURL = NSBundle.mainBundle().URLForResource("CoreDataTest", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataTest.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
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
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}
