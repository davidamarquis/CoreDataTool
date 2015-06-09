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

class CoreController: UIViewController, UIScrollViewDelegate, VertViewWasTouchedProtocol {

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

        hght=view.bounds.size.height;
        wdth=view.bounds.size.width;
        self.barButtons();
        
        testGraph();
        
        let edgeIds:Array<Array<Int32>> = graph!.edgeIdArray();
        println(edgeIds);
        let sortedEdgeIds:Array<Array<Int32>> = graph!.sortedEdgeIdArray();
        println(sortedEdgeIds);
    }

    // MARK: Setup
    // verts array using swift arrays
    private func makeVertsArray(numVerts:Int)->Array<Vert> {
       
        var verts=Array<Vert>();
        if context == nil { println("CoreController: makeVertsArray: context is nil");}
        else {
            let vertDescription = NSEntityDescription.entityForName("Vert",inManagedObjectContext: context!);
            for var i=0;i<numVerts;i++ {
                verts.append(Vert(entity: vertDescription!,insertIntoManagedObjectContext: context));
            }
        }
        return verts;
    }

    private func makeEdgesArray(numEdges:Int)->Array<Edge> {
        var edges=Array<Edge>();
        let edgeDescription = NSEntityDescription.entityForName("Edge",inManagedObjectContext: context!);
        
        if context != nil {
            for var i=0;i<numEdges;i++ {
                var edge:Edge? = Edge(entity: edgeDescription!,insertIntoManagedObjectContext: context);
                edges.append(edge!);
            }
        }
        else {
        
        }
        return edges;
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

    // main view is graphView
    // use a closure to contain the initialization logic
    lazy var graphView:GraphView? = {
        // this is how designated initializers are called in swift
        var gv=GraphView(frame: CGRectMake(CGFloat(0), CGFloat(0), self.wdth, self.hght*(1-self.vscale)));
        gv.backgroundColor=UIColor( red:CGFloat(0),green:CGFloat(0),blue:CGFloat(0),alpha:CGFloat(0) );
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
        if self.context != nil {
            let graphDescription = NSEntityDescription.entityForName("Graph",inManagedObjectContext: self.context!);
            graph = Graph(entity: graphDescription!,insertIntoManagedObjectContext: self.context!);
            graph?.addObserver(self, forKeyPath: "finishedObservedMethod", options: .New, context: nil);
        }
        else {
            println("CoreController: graph: cannot create graph, context is nil");
        }
        return graph;
    }()

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

    
    // KVO
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject: AnyObject], context: UnsafeMutablePointer<Void>) {
        var v:Vert?
        if object is Vert {
            v = object as? Vert;
        }
        else {
            println("CoreController: observeValueForKeyPath: object is not Vert");
        }
        if( keyPath=="finishedObservedMethod" && graphView != nil ) {
            if(!v!.freshViews) {
                //NOTE: gwv class = graphWorldView
                
                // check if a view exists corresponding to the vert instance
                //   if no view is found then vertView is nil and we alloc a vertView and add it
                //   otherwise model and view are out of date: drawn==NO implies Vert instance has changed since the last time the VC drew
                // VC updates the view by removing the outdated VertView and adding a correct one
                let vertView:VertView? = graphView!.gwv.getVertViewById(v!.vertViewId);
                if(vertView != nil) {
                    vertView!.removeFromSuperview();
                    vertView!.x = CGFloat(v!.x);
                    vertView!.y = CGFloat(v!.y);
                    graphView!.gwv.addSubview(vertView!);
                    vertView!.setNeedsDisplay();
                }
                else {
                    let vv:VertView = graphView!.gwv.addVertAtPoint(CGPointMake(CGFloat(v!.x), CGFloat(v!.y)) );
                    vv.delegate=self;
                    vv.vertViewId=v!.vertViewId;
                }
                // vert instance now fresh
                v!.freshViews=true;
            }
            if(!v!.freshEdges) {
                // call drawEdges to prepare for the drawing of the edges of v
                drawEdges(v!);
                // edge instance now fresh
                v!.freshEdges=true;
            }
        }
    }
    
    // drawEdges draws the edges out of v
    private func drawEdges(v:Vert) {

        var X1:CGFloat?;
        var Y1:CGFloat?;
        var X2:CGFloat?;
        var Y2:CGFloat?;
        var diameter:CGFloat?;
        var frameWidth:CGFloat?;
        var frameHeight:CGFloat?;
        var edgeFrame:CGRect?;
        var w:Vert!;
        
        for vert in v.neighbors {
            // check that the class is correct
            // and the verts v and w are not equal
            // and the neighbors of v have not been drawn already
            if vert is Vert {
                w=vert as! Vert;
            }
            else {
                println("CoreController: drawEdges: v.neighbors has an element that is not a vert");
            }
            
            if v.isPositionEqual(w) {
                if !v.freshEdges {
                    // ensure edges don't get drawn twice with neighborsDrawn flag

                    X1=CGFloat(v.x);
                    Y1=CGFloat(v.y);
                    X2=CGFloat(w.x);
                    Y2=CGFloat(w.y);
                    diameter=graphView!.gwv.diameter;
                    frameWidth=fabs(X1!-X2!)+diameter!;
                    frameHeight=fabs(Y1!-Y2!)+diameter!;
                    // adjust the frame based on the least coordinate for the xval and yval for the pair of points
                    if(X1<X2 && Y1<Y2) {
                        edgeFrame=CGRectMake(X1!, Y1! , frameWidth!, frameHeight!);
                        graphView!.gwv.addEdgeWithFrame(edgeFrame!, edgeDirectionCase: 0);
                    }
                    else if(X1<X2 && Y1>=Y2) {
                        edgeFrame=CGRectMake(X1!, Y2! , frameWidth!, frameHeight!);
                        graphView!.gwv.addEdgeWithFrame(edgeFrame!, edgeDirectionCase: 1);
                    }
                    else if(X1>=X2 && Y1<Y2) {
                        edgeFrame=CGRectMake(X2!, Y1! , frameWidth!, frameHeight!);
                        graphView!.gwv.addEdgeWithFrame(edgeFrame!, edgeDirectionCase: 1);
                    }
                    else if(X1>=X2 && Y1>=Y2) {
                        edgeFrame=CGRectMake(X2!, Y2! , frameWidth!, frameHeight!);
                        graphView!.gwv.addEdgeWithFrame(edgeFrame!, edgeDirectionCase: 0);
                    }
                }
            }
        }
    }

    // MARK: deinit
    deinit {
        for vert in graph!.verts {
            if vert is Vert {
                (vert as! Vert).removeObserver(self, forKeyPath:"modelInt");
            }
        }
    }

    // MARK: protocol conformance
    // public
    // this method is called the -(void)pan in VertView
    func drawGraphAfterMovingVert(viewId:Int32, toXPos endX:Float, toYPos endY:Float) {
        if graph != nil {
            // cast the number of verts in the array to an Int32
            let vertCount:Int32 = Int32(graph!.verts.count);
            if( viewId < 0 || vertCount < viewId ) {
                print("drawGraphAfterMovingVert: view id too large or small");
            }
            else {
                // moveVertById changes the core model
                // this class is listening for changes in the core model
                graph!.moveVertById(viewId, toXPos:endX, toYPos:endY);
            }
        }
        else {
            print("CoreController: drawGraphAfterMovingVertById: err")
        }
    }

    // MARK: core data
    lazy var applicationDocumentsDirectory: NSURL =
    {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.david.CoreDataTest" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        // TODO: change "CoreDataTest" using grep
        //let modelURL = NSBundle.mainBundle().URLForResource("CoreDataModeller", withExtension: "momd")!
        
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd");
        if modelURL == nil {

        }
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataModeller.sqlite")
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
        var newContext = NSManagedObjectContext();
        newContext.persistentStoreCoordinator = coordinator;
        return newContext
    }()

    //MARK: - Core Data Saving support

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
    
    //MARK:testing
    // create some variables in the managedObjectModel and send them to the model for setup
    private func testGraph() {

        var verts=makeVertsArray(4);
        var edges=makeEdgesArray(4);
        if graph != nil {
            graph!.SetupVert(verts[0], AtX:10, AtY:70);
            graph!.SetupVert(verts[1], AtX:100, AtY:200);
            graph!.SetupVert(verts[2], AtX:50, AtY:300);
            graph!.SetupVert(verts[3], AtX:200, AtY:80);
            graph!.SetupEdge(edges[0], From:verts[0], To:verts[1]);
            graph!.SetupEdge(edges[1], From:verts[1], To:verts[3]);
            graph!.SetupEdge(edges[2], From:verts[1], To:verts[2]);
            graph!.SetupEdge(edges[3], From:verts[2], To:verts[3]);
        }
        else {
            println("CoreController: testGraph: err graph is nil");
        }
    }
    /*

    // public
    // the method addVertToModel is triggered whenever the user hits the button
    - (void)addVertToModel {
        // TO DO
        [self testVertAtX:200 AtY:300];
    }
    */

}
