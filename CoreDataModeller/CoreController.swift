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

    @IBAction func turnOffGrid(sender: AnyObject) {
        if graphView != nil {
            graphView!.switchGraphState();
        }
    }
    
    let vscale:CGFloat=0.15;
    var hght:CGFloat=CGFloat();
    var wdth:CGFloat=CGFloat();
    var vertViewCount:Int=Int();
    var edgeButton:UIButton?;
    var moveButton:UIButton?;
    var vertButton:UIButton?;
    
    var addVertControl:UILabel?;
    var remVertControl:UILabel?;
    var remEdgeControl:UILabel?;
    
    var inEdgeMode:Bool = false;
    var inVertMode:Bool = false;
    var inMoveMode:Bool = false;

    var unselectedTextColor = UIColor.grayColor();
    var selectedTextColor = UIColor.whiteColor();
    
    ////MARK: Setup
    //Setup: view lifecycle
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if sender is VertView {
            let vv:VertView = sender as! VertView;
            if graph != nil {
                let vert:Vert? = graph!.getVertById(vv.vertViewId!);
                if vert != nil {
                    if segue.destinationViewController is AttributeTable {
                        (segue.destinationViewController as! AttributeTable).vert=vert;
                    }
                }
                else { println("CoreController: prepareForSegue: vert is nil"); }
            }
            else { println("CoreController: prepareForSegue: graph is nil");}
        }
    }

    override func viewDidLoad() {

        hght=view.bounds.size.height;
        wdth=view.bounds.size.width;
        barButtons();
        setupVertButtons();
        
        testGraph();
        
        let noteCenter:NSNotificationCenter = NSNotificationCenter.defaultCenter();
        let mainQueue:NSOperationQueue=NSOperationQueue.mainQueue();
        noteCenter.addObserverForName( NSManagedObjectContextObjectsDidChangeNotification, object: nil, queue: mainQueue, usingBlock:
        {(notification:NSNotification!) -> Void in
            if notification.object! is NSManagedObjectContext {
                let con=notification.object! as! NSManagedObjectContext;
                
                let objs=con.deletedObjects;
                self.respondToDeletion(objs);
            }
        });
    }
    
    private func respondToDeletion(deletedObjs:Set<NSObject>) {
        if deletedObjs.count > 0 {
            for obj in deletedObjs {
                // case 1: object is VertView
                if obj is Vert {
                    // get the view id from the vert
                    let vertId:Int32? = (obj as! Vert).vertViewId;
                    if vertId != nil {
                        self.remVertView(vertId!);
                    }
                    else {println("CoreController: viewDidLoad(): vertId is nil"); }
                }
                else if obj is Edge {
                    // get the view id from the vert
                    let edgeId:Int32? = (obj as! Edge).edgeViewId;
                    if edgeId != nil {
                        self.remEdgeView(edgeId!);
                    }
                    else {println("CoreController: respondToDeletion(): edgeId is nil"); }
                }
                else {println("CoreController: respondToDeletion(): object to be deleted has unknown type");}
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
    
        //TODO: if needed arrange views into final order here 
        /* ... */

        // starting mode is one of moveMode(), vertMode(), edgeMode()
        moveMode();
    }
    
    //Setup: buttons
    func setupVertButtons() {
        // init and set frame
        addVertControl=setupClearButton("+");
        addVertControl!.frame=CGRectMake(wdth*0.666,hght*(1-2*vscale),wdth*0.334,hght*vscale);
        //addVert!.addTarget(self, action: "killVert", forControlEvents:.TouchUpInside);

        // init and set frame
        remVertControl=setupClearButton("X");
        remVertControl!.frame=CGRectMake(0,hght*(1-2*vscale),wdth*0.333,hght*vscale);
        
        // init and set frame
        remEdgeControl=setupClearButton("X");
        remEdgeControl!.frame=CGRectMake(0,hght*(1-2*vscale),wdth*0.333,hght*vscale);
        
        //
        if graphView != nil {
            if graphView!.gwv != nil {
                graphView!.gwv!.addVert = addVertControl;
                graphView!.gwv!.remVert = remVertControl;
            }
        }
        else {println("CoreController: setupVertButtons: one of graphView or gwv is nil");}
        //remVert!.addTarget(self, action: "makeVert", forControlEvents:.TouchUpInside);
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
    // sets a label with transparent background. Does not add to view
    func setupClearButton(title:String)->UILabel {
        //init
        let button=UILabel();
        (button.text,button.textColor, button.backgroundColor,button.font, button.textAlignment) = (title, unselectedTextColor, UIColor.clearColor(), UIFont.systemFontOfSize(60), NSTextAlignment.Center);
        return button;
    }
    // button with black background. adds to view
    func barButton(title:String) -> UIButton {
        // bcol is color of back of button, tcol of the text on the button
        let bcol:UIColor=UIColor.blackColor();
        let buttonFont:UIFont=UIFont.systemFontOfSize(60);
        
        let button:UIButton=UIButton.buttonWithType(.System) as! UIButton;
        button.backgroundColor=bcol;
        button.setTitle(title, forState:UIControlState.Normal);
        button.setTitleColor(unselectedTextColor, forState:.Normal);
        if button.titleLabel != nil {button.titleLabel!.font=buttonFont;}
        else {println("CoreController: barButton: titleLabel is nil");}
        
        view.addSubview(button);
        return button;
    }
    
    //Setup: lazy init
    //graphView property subclasses UIScrollView. It contains all the non-interface views as subviews.
    lazy var graphView:GraphView? = {
        var gv=GraphView(frame: CGRectMake(CGFloat(0), CGFloat(0), self.wdth, self.hght*(1-self.vscale)), graphWorldViewDeleg: self);
        
        gv.backgroundColor=UIColor( red:CGFloat(0),green:CGFloat(0),blue:CGFloat(0),alpha:CGFloat(0) );
        gv.delegate=self;

        self.view.addSubview(gv);
        
        return gv;
    }()

    // graph is the application model
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
    
    //
    //MARK: vert-vertView interface
    //
    private func addVertView() {
    
    }
    
    private func remVertView(vertId:Int32) {
        // get the corresponding view by its id. Not finding this view is not necessarily an error as the deleted managed objects list in context is sticky
        let vv:VertView? = graphView!.gwv!.getVertViewById(vertId);
        if vv != nil {
            vv!.removeFromSuperview();
            vv!.setNeedsDisplay();
        }
        else {
            println("CoreController: remVertView: could not find vert to delete. Id to delete is \(vertId)");
        }
    }
    
    func addVert(loc:CGPoint) {
    
        let vertDescription = NSEntityDescription.entityForName("Vert",inManagedObjectContext: context!);
        var vert:Vert? = Vert(entity: vertDescription!,insertIntoManagedObjectContext: context);
        if vert == nil {println("CoreController: addVert: created vert is nil");}
        vert!.addObserver(self, forKeyPath: "finishedObservedMethod", options: .New, context: nil);
        
        if graph != nil && vert != nil {
            graph!.SetupVert(vert, AtX: Float(loc.x), AtY: Float(loc.y));
        }
        
    }
    
    func remVert(vertId:Int32) {
    
        // save current context
        saveContext();
        // get a vert
        let vert:Vert? = graph!.getVertById(vertId);
        
        if context != nil && vert != nil {
             for e in vert!.edges {
                 if e is Edge {
                     let edge=e as! Edge;
                    
                     context!.deleteObject(edge);
                 }
             }
             for elem in vert!.neighbors {
                 if elem is Vert {
                     let vert=elem as! Vert;
                     vert.freshViews=false;
                 }
             }
            
             context!.deleteObject(vert!);
        }
        else { println("removeVertById: err"); }
    }
    
    //
    //MARK: edge-edgeView interface
    //
    private func addEdgeView() {

    }
    private func remEdgeView(edgeId:Int32) {
    
        // get the corresponding view by its id. Not finding this view is not necessarily an error as the deleted managed objects list in context is sticky
        let ev:EdgeView? = graphView!.gwv!.getEdgeViewById(edgeId);
        if ev != nil {
        
            ev!.removeFromSuperview();
            ev!.setNeedsDisplay();
        }
        else {
            //println("CoreController: deleteEdgeViewById: could not find edge to delete");
        }
    }
    
    func addEdge(vertId1:Int32, vertId2:Int32) {
        let vert1:Vert? = graph!.getVertById(vertId1);
        let vert2:Vert? = graph!.getVertById(vertId2);
        
        let edgeDescription = NSEntityDescription.entityForName("Edge",inManagedObjectContext: context!);
        var edge:Edge? = Edge(entity: edgeDescription!,insertIntoManagedObjectContext: context);
        
        if graph != nil && edge != nil && vert1 != nil && vert2 != nil {
            graph!.SetupEdge(edge!, From:vert1!, To:vert2!);
        }
    }
    
    func remEdge(edgeId: Int32) {
        
    }
    
    //MARK: unsorted
    //TODO: remove this test function
    private func printSomeTests() {
        let edgeIds:Array<Array<Int32>> = graph!.edgeIdArray();
        println(edgeIds);
        let sortedEdgeIds:Array<Array<Int32>> = graph!.sortedEdgeIdArray();
        println(sortedEdgeIds);
    }

    //MARK: modes
    
    // curMode() returns an int with current mode
    func curMode()->Int {
        if inEdgeMode {
            return 0;
        }
        else if inMoveMode {
            return 1;
        }
        else if inVertMode {
            return 2;
        }
        else {
            return -1;
        }
    }
    
    private func scrollOff() {
        if graphView == nil {println("CoreController: scrollOff: graphView is nil");}
        (graphView!.maximumZoomScale,graphView!.minimumZoomScale) = (1.0,1.0);
        graphView!.panGestureRecognizer.enabled=false;
    }
    
    private func scrollOn() {
        if graphView == nil {println("CoreController: scrollOn: graphView is nil");}
        (graphView!.maximumZoomScale,graphView!.minimumZoomScale) = (2.0,0.2);
        graphView!.panGestureRecognizer.enabled=true;
    }
    
    // edgeMode() holds logic for switching from vertMode() or moveMode()
    func edgeMode() {
        // method cannot be private, called by action
        
        edgeButton!.setTitleColor(selectedTextColor, forState:.Normal);
        vertButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        moveButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        scrollOff();
        if addVertControl != nil && remVertControl != nil {
            addVertControl!.removeFromSuperview();
            remVertControl!.removeFromSuperview();
            view.addSubview(remEdgeControl!);
        }
        
        // enable gesture recognizers
        enableOrDisableGestureRecognizers(true);
        
        inVertMode=false;
        inMoveMode=false;
        inEdgeMode=true;
    }
    func moveMode() {
        // method cannot be private, called by action
        
        edgeButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        vertButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        moveButton!.setTitleColor(selectedTextColor, forState:.Normal);
        scrollOn();
        if addVertControl != nil && remVertControl != nil {
            addVertControl!.removeFromSuperview();
            remVertControl!.removeFromSuperview();
            remEdgeControl!.removeFromSuperview();
        }
        if addVertControl == nil && remVertControl == nil {println("CoreController: vertMode: addVert or remVert buttons are nil");}
        
        // disable gesture recognizers
        enableOrDisableGestureRecognizers(false);
        
        inVertMode=false;
        inMoveMode=true;
        inEdgeMode=false;
    }
    
    func vertMode() {
        // method cannot be private, called by action
    
        if edgeButton == nil || vertButton == nil || moveButton == nil {
            println("CoreController: vertMode: one of the buttons is nil");
        }
        else {
            edgeButton!.setTitleColor(unselectedTextColor, forState:.Normal);
            vertButton!.setTitleColor(selectedTextColor, forState:.Normal);
            moveButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        }
        scrollOff();
        
        if addVertControl == nil || remVertControl == nil {println("CoreController: vertMode: addVert or remVert buttons are nil");}
        else {
            view.addSubview(addVertControl!);
            view.addSubview(remVertControl!);
            view.addSubview(remEdgeControl!);
        }

        // enable gesture recognizers
        enableOrDisableGestureRecognizers(true);
        
        inVertMode=true;
        inMoveMode=false;
        inEdgeMode=false;
    }
    
    func enableOrDisableGestureRecognizers(isEnabled: Bool) {
        // remove gesture recognizers
        if graphView!.gwv!.gestureRecognizers == nil {
            println("gestureRecognizers is nil");
        }
        else {
            for recog in graphView!.gwv!.gestureRecognizers! {
            
                // tap gestures are maintained in all modes so don't modify them here
                if !(recog is UITapGestureRecognizer) {
                    let recognizer = recog as! UIGestureRecognizer;
                    recognizer.enabled = isEnabled;
                }
            }
        }
        // remove gestures recognizers on subviews
        for sub in graphView!.gwv!.subviews {
        
            let subview=sub as! UIView;
            if subview.gestureRecognizers == nil {
                //println("CoreController: moveMode: gestureRecognizers are nil");
            }
            else {
                for recog in subview.gestureRecognizers! {
                    let recognizer = recog as! UIGestureRecognizer;
                    recognizer.enabled = isEnabled;
                }
            }
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
        if( keyPath=="finishedObservedMethod" && graphView != nil && v != nil) {
            drawVert(v!);
        }
    }
    private func drawVert(v:Vert) {
        if(!v.freshViews) {
            // check if a view exists corresponding to the vert instance. (1) if no view is found then vertView is nil and
            // we init a vertView and paste it to view. (2) otherwise model and view are out of date
            // VC updates the view by removing the outdated VertView and adding a correct one
            let vertView:VertView? = graphView!.gwv!.getVertViewById(v.vertViewId);
            if(vertView != nil) {
                // remove the old view
                // set the new position
                (vertView!.frame.origin.x, vertView!.frame.origin.y) = (CGFloat(v.x), CGFloat(v.y));
                // add the new view
                vertView!.setNeedsDisplay();
            }
            else {
                let vv:VertView = graphView!.gwv!.addVertAtPoint(CGPointMake(CGFloat(v.x), CGFloat(v.y)) );
                vv.delegate=self;
                // set the view id to match the model id
                vv.vertViewId=v.vertViewId;
                
            }
            // vert instance now fresh
            v.freshViews=true;
        }
        if(!v.freshEdges) {
            // call drawEdges to prepare for the drawing of the edges of v
            drawEdges();
            // edge instance now fresh
            v.freshEdges=true;
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
        let diameter=graphView!.gwv!.diameter;
        
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
            else if !v!.freshEdges || !w!.freshEdges {
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
                var edgeView:EdgeView? = graphView!.gwv!.getEdgeViewById(e!.edgeViewId);
                if(edgeView != nil) {
                    // remove the old view
                    edgeView!.removeFromSuperview();
                    // fix the frame
                    edgeView!.frame=edgeFrame!;
                    graphView!.gwv!.setEdge(edgeView!, topLeftToBotRight: edgeDir!);
                }
                else {
                    // init the new view in setEdge() input
                    edgeView=graphView!.gwv!.setEdge(EdgeView(frame: edgeFrame!), topLeftToBotRight: edgeDir!);
                    
                    // do any additional setup
                    //(1): id
                    edgeView!.edgeViewId=e!.edgeViewId;
                    //(2): length
                    edgeView!.length=CGFloat(e!.length()!);
                    //(3): angle
                    edgeView!.angle=CGFloat(e!.angle()!);
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
            if( viewId < 0 || graph!.curVertId < viewId ) {
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
    
    // use vert id to get a vert and add an attribute to it
    func addAttributeById(vertId:Int32, withString attrString:String) {
        // get vert
        let vert:Vert? = graph!.getVertById(vertId);
        // get attr
        let attrDescription = NSEntityDescription.entityForName("AttributeString",inManagedObjectContext: context!);
        let attr:AttributeString = AttributeString(entity: attrDescription!,insertIntoManagedObjectContext: context);
        // set the attr string to be the input string
        attr.string=attrString;
        
        if vert != nil {
            addAttrToVert(attr, newVert: vert!);
        }
        
        if navigationController == nil {println("CoreController: addAttributeById: nav controller is nil");}
        for vc in navigationController!.viewControllers {
            if vc is AttributeTable {
                (vc as! AttributeTable).getStringsFromVert();
            }
        }
    }
    
    private func addAttrToVert(newAttr:AttributeString, newVert:Vert) {
        var manyRelation:AnyObject? = newVert.valueForKeyPath("attributeStrings") ;
        if manyRelation is NSMutableSet {
            (manyRelation as! NSMutableSet).addObject(newAttr);
        }
    }
    
    //MARK: - Core Data Saving support
    func saveContext() {
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
        // setup: step 1: create a ref to some verts and observers for them, step 2: create a ref to some edges and observers for them, step 3: set the position of the verts and attach to graph, step 4: attach edges
        var verts=testVertsArray(4);
        var edges=testEdgesArray(4);
        if graph != nil {
     
            let attrDescription = NSEntityDescription.entityForName("AttributeString",inManagedObjectContext: context!);
            let attr:AttributeString = AttributeString(entity: attrDescription!,insertIntoManagedObjectContext: context);
            attr.string="test";
            
            // cause is that an optional is returned by setByAddingObject
            addAttrToVert(attr, newVert:verts[0]);
            addAttrToVert(attr, newVert:verts[1]);
            addAttrToVert(attr, newVert:verts[2]);
            addAttrToVert(attr, newVert:verts[3]);
            
            //var cat:NSSet=NSSet();
            //cat = cat.setByAddingObject(attr);
            
            graph!.SetupVert(verts[0], AtX:10, AtY:70 );
            graph!.SetupVert(verts[1], AtX:100, AtY:200 );
            graph!.SetupVert(verts[2], AtX:50, AtY:300 );
            graph!.SetupVert(verts[3], AtX:200, AtY:80 );
            graph!.SetupEdge(edges[0], From:verts[0], To:verts[1]);
            graph!.SetupEdge(edges[1], From:verts[1], To:verts[3]);
            graph!.SetupEdge(edges[2], From:verts[1], To:verts[2]);
            graph!.SetupEdge(edges[3], From:verts[2], To:verts[3]);
            // add an observer of the graph object
            
            
            let testArr:Array<Int32> = graph!.getIds();
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
                var vert:Vert = Vert(entity: vertDescription!,insertIntoManagedObjectContext: context);
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
}
