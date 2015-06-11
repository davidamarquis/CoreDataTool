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
    var edgeButton:UIButton?;
    var moveButton:UIButton?;
    var vertButton:UIButton?;
    var addVert:UIButton?;
    var remVert:UIButton?;
    
    var unselectedTextColor = UIColor.grayColor();
    var selectedTextColor = UIColor.whiteColor();

    //MARK: view lifecycle
    override func viewDidLoad() {

        hght=view.bounds.size.height;
        wdth=view.bounds.size.width;
        barButtons();
        setupVertButtons();
        moveMode();
        
        testGraph();
        
        let edgeIds:Array<Array<Int32>> = graph!.edgeIdArray();
        println(edgeIds);
        let sortedEdgeIds:Array<Array<Int32>> = graph!.sortedEdgeIdArray();
        println(sortedEdgeIds);
    }
    
    override func viewWillAppear(animated: Bool) {
    
        // now is the time
        if addVert != nil {
            view.bringSubviewToFront(addVert!);
        }
    }

    //MARK: Setup
    func setupVertButtons() {
    
        let buttonFont:UIFont=UIFont.systemFontOfSize(60);
        
        // init a button
        addVert=UIButton.buttonWithType(.System) as? UIButton;
        
        addVert!.frame=CGRectMake(0,hght*(1-2*vscale),wdth*0.333,hght*vscale);
        addVert!.addTarget(self, action: "addVert", forControlEvents:.TouchUpInside);
        addVert!.setTitle("+", forState:UIControlState.Normal);
        addVert!.setTitleColor(unselectedTextColor, forState:.Normal);
        addVert!.titleLabel!.font=buttonFont;
        addVert!.backgroundColor=UIColor.clearColor();

        // init a button
        remVert=UIButton.buttonWithType(.System) as? UIButton;
        
        remVert!.frame=CGRectMake(wdth*0.666,hght*(1-2*vscale),wdth*0.334,hght*vscale);
        remVert!.addTarget(self, action: "remVert", forControlEvents:.TouchUpInside);
        remVert!.setTitle("X", forState:UIControlState.Normal);
        remVert!.setTitleColor(unselectedTextColor, forState:.Normal);
        remVert!.titleLabel!.font=buttonFont;
        remVert!.backgroundColor=UIColor.clearColor();
    }

    // sets up 3 buttons for the view controllers UI states
    func barButtons() {
        
        edgeButton = barButton("E");
        edgeButton!.frame=CGRectMake(0,hght*(1-vscale),wdth*0.333,hght*vscale);
        edgeButton!.addTarget(self, action: "edgeMode", forControlEvents:.TouchUpInside);

        moveButton = barButton("M");
        moveButton!.frame=CGRectMake(wdth*0.333,hght*(1-vscale),wdth*0.333,hght*vscale);
        moveButton!.addTarget(self, action: "moveMode", forControlEvents:.TouchUpInside);

        vertButton = barButton("V");
        vertButton!.frame=CGRectMake(wdth*0.666,hght*(1-vscale),wdth*0.334,hght*vscale);
        vertButton!.addTarget(self, action: "vertMode", forControlEvents:.TouchUpInside);
    }
    // creates an individual button
    func barButton(title:String) -> UIButton {
        // bcol is color of back of button, tcol of the text on the button
        let bcol:UIColor=UIColor.blackColor();
        let buttonFont:UIFont=UIFont.systemFontOfSize(60);
        
        let button:UIButton=UIButton.buttonWithType(.System) as! UIButton;
        button.backgroundColor=bcol;
        button.setTitle(title, forState:UIControlState.Normal);
        button.setTitleColor(unselectedTextColor, forState:.Normal);
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

    func scrollOff() {
        if graphView == nil {println("CoreController: scrollOff: graphView is nil");}
        (graphView!.maximumZoomScale,graphView!.minimumZoomScale) = (1.0,1.0);
        graphView!.panGestureRecognizer.enabled=false;
    }
    
    func scrollOn() {
        if graphView == nil {println("CoreController: scrollOn: graphView is nil");}
        (graphView!.maximumZoomScale,graphView!.minimumZoomScale) = (2.0,0.2);
        graphView!.panGestureRecognizer.enabled=true;
    }
    
    func edgeMode() {
        edgeButton!.setTitleColor(selectedTextColor, forState:.Normal);
        vertButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        moveButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        scrollOff();
        if addVert != nil && remVert != nil {
            addVert!.removeFromSuperview();
            remVert!.removeFromSuperview();
        }
    }
    func moveMode() {
        edgeButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        vertButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        moveButton!.setTitleColor(selectedTextColor, forState:.Normal);
        scrollOn();
        if addVert != nil && remVert != nil {
            addVert!.removeFromSuperview();
            remVert!.removeFromSuperview();
        }
    }
    func vertMode() {
        edgeButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        vertButton!.setTitleColor(selectedTextColor, forState:.Normal);
        moveButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        scrollOff();
        if addVert != nil && remVert != nil {
            view.addSubview(addVert!);
            view.addSubview(remVert!);
        }
        else {
        
        }
    }

    func onResumeGraph() {
        // TO DO
    }

    func onNewGraph() {
        testGraph();
    }

    //MARK: KVO on model
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
                // check if a view exists corresponding to the vert instance. (1) if no view is found then vertView is nil and
                // we init a vertView and paste it to view. (2) otherwise model and view are out of date
                // VC updates the view by removing the outdated VertView and adding a correct one
                let vertView:VertView? = graphView!.gwv.getVertViewById(v!.vertViewId);
                if(vertView != nil) {
                    // remove the old view
                    // set the new position
                    (vertView!.frame.origin.x, vertView!.frame.origin.y) = (CGFloat(v!.x), CGFloat(v!.y));
                    // add the new view
                    vertView!.setNeedsDisplay();
                }
                else {
                    let vv:VertView = graphView!.gwv.addVertAtPoint(CGPointMake(CGFloat(v!.x), CGFloat(v!.y)) );
                    vv.delegate=self;
                    // set the view id to match the model id
                    vv.vertViewId=v!.vertViewId;
                    
                }
                // vert instance now fresh
                v!.freshViews=true;
            }
            if(!v!.freshEdges) {
                // call drawEdges to prepare for the drawing of the edges of v
                drawEdges();
                // edge instance now fresh
                v!.freshEdges=true;
            }
        }
    }
    
    private func drawEdges() {
        var minX,minY,X1,Y1,X2,Y2,frameWidth,frameHeight:CGFloat?;
        var edgeFrame:CGRect?;
        var e:Edge?;
        var v,w:Vert?;
        var edgeDir:Bool?;
        
        if graph == nil || graphView == nil {
            println("CoreController: drawEdges: graph or graphView is nil");
        }
        let diameter=graphView!.gwv.diameter;
        
        for edge in graph!.edges {
            if edge is Edge {
                e=edge as? Edge;
            }
            else {
                println("CoreController: drawEdges: graph has an element that is not an edge");
            }
            
            (v,w)=e!.Connects();
            if v == nil || w == nil {
                println("CoreController: DrawEdges: edge is incomplete")
            }
            if !v!.freshEdges || !w!.freshEdges {
                (X1,Y1,X2,Y2) = (CGFloat(v!.x),CGFloat(v!.y),CGFloat(w!.x),CGFloat(w!.y));
                (frameWidth,frameHeight) = (fabs(X1!-X2!)+diameter,fabs(Y1!-Y2!)+diameter);
                (minX,minY) = (min(X1!,X2!),min(Y1!,Y2!));
                // adjust the frame based on the least coordinate for the xval and yval for the pair of points

                edgeFrame = CGRectMake(minX!, minY!, frameWidth!, frameHeight!);
                // there are four cases to consider. Two are topLeftToBotRight, other two are not
                if (X1<X2 && Y1<Y2) || (X1>=X2 && Y1>=Y2) {
                    edgeDir=true;
                }
                else {
                    edgeDir=false;
                }
                
                // getEdgeView()
                var edgeView:EdgeView? = graphView!.gwv.getEdgeViewById(e!.edgeViewId);
                if(edgeView != nil) {
                    // remove the old view
                    edgeView!.removeFromSuperview();
                    // fix the frame
                    edgeView!.frame=edgeFrame!;
                    graphView!.gwv.setEdge(edgeView!, topLeftToBotRight: edgeDir!);
                }
                else {
                    // init the new view in setEdge() input
                    edgeView=graphView!.gwv.setEdge(EdgeView(frame: edgeFrame!), topLeftToBotRight: edgeDir!);
                    // do any additional setup
                    edgeView!.edgeViewId=e!.edgeViewId;
                }
                // redraw the edge
                edgeView!.setNeedsDisplay();
            }
        }
    }
    //MARK: UIScrollViewDelegateProtocol
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return graphView!.gwv ;
    }

    //MARK: deinit (for KVO)
    deinit {
        for vert in graph!.verts {
            if vert is Vert {
                (vert as! Vert).removeObserver(self, forKeyPath:"modelInt");
            }
        }
    }

    //MARK: protocol conformance
    //called by pan() in VertView
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

        var verts=testVertsArray(4);
        var edges=testEdgesArray(4);
        if graph != nil {
            graph!.SetupVert(verts[0], AtX:10, AtY:70);
            graph!.SetupVert(verts[1], AtX:100, AtY:200);
            graph!.SetupVert(verts[2], AtX:50, AtY:300);
            graph!.SetupVert(verts[3], AtX:200, AtY:80);
            graph!.SetupEdge(edges[0], From:verts[0], To:verts[1]);
            graph!.SetupEdge(edges[1], From:verts[1], To:verts[3]);
            graph!.SetupEdge(edges[2], From:verts[1], To:verts[2]);
            graph!.SetupEdge(edges[3], From:verts[2], To:verts[3]);
            // add an observer of the graph object
        }
        else {
            println("CoreController: testGraph: err graph is nil");
        }
    }
    
    private func testVertsArray(numVerts:Int)->Array<Vert> {
        var verts=Array<Vert>();
        if context == nil { println("CoreController: makeVertsArray: context is nil");}
        else {
            let vertDescription = NSEntityDescription.entityForName("Vert",inManagedObjectContext: context!);
            for var i=0;i<numVerts;i++ {
                let vert:Vert = Vert(entity: vertDescription!,insertIntoManagedObjectContext: context);
                vert.addObserver(self, forKeyPath: "finishedObservedMethod", options: .New, context: nil);
                verts.append(vert);
            }
        }
        return verts;
    }

    private func testEdgesArray(numEdges:Int)->Array<Edge> {
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
    /*

    // public
    // the method addVertToModel is triggered whenever the user hits the button
    - (void)addVertToModel {
        // TO DO
        [self testVertAtX:200 AtY:300];
    }
    */

}
