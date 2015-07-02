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
import MessageUI

class CoreController: UIViewController, UIScrollViewDelegate, VertViewWasTouchedProtocol, MailGenDelegate {

    let vscale:CGFloat=0.15;
    var hght:CGFloat=CGFloat();
    var wdth:CGFloat=CGFloat();
    var vertViewCount:Int=Int();
    var edgeButton:imgTextButton?;
    var moveButton:imgTextButton?;
    var vertButton:imgTextButton?;
    
    var inEdgeMode=false;
    var inVertMode=false;
    var inMoveMode=false;
    
    // the controls for adding verts, removing verts, and removing edge
    var addVertControl:UIView?;
    var remVertControl:UIView?;
    var remEdgeControl:UIView?;
    
    // the controls for adding verts, removing verts, and removing edge are attached directly to a subclass of UIScrollView. The following content offset vars are for repositioning these controls after scrolling occurs
    var graphViewContentOffsetDeltaX:CGFloat = 0;
    var graphViewContentOffsetDeltaY:CGFloat = 0;
    var graphViewPrevContentOffsetX:CGFloat = 0;
    var graphViewPrevContentOffsetY:CGFloat = 0;
    
    var unselectedTextColor = UIColor.grayColor();
    var selectedTextColor = UIColor.blackColor();
    
    // mailGen trigers an async call so need to keep a strong reference to it. mailGen is a subclass of MFMailComposeViewController();
    var mailGen = MailGen();
    
    ////MARK: Setup
    //Setup: view lifecycle
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if sender is VertView {
            let vv:VertView = sender as! VertView;
            if graph != nil {
                let vert:Vert? = graph!.getVertById(vv.vertViewId!);
                if vert != nil {
                    if segue.destinationViewController is EntityTableVC {
                        //set vert
                        (segue.destinationViewController as! EntityTableVC).vert=vert;
                        //set attr observers
                        setupAttrObservers(vert!, vc: segue.destinationViewController as! EntityTableVC);
                        //set context
                        if context == nil {print("Core")}
                        (segue.destinationViewController as! EntityTableVC).context=context!;
                    }
                }
                else { print("CoreController: prepareForSegue: vert is nil"); }
            }
            else { print("CoreController: prepareForSegue: graph is nil");}
            
        }
        if segue.destinationViewController is Options {
            if user != nil {
                (segue.destinationViewController as! Options).user = user;
            }
        }
    }

    func setKVOForAttrTable(attr:Attribute, vc:UIViewController, vert:Vert) {
        attr.addObserver(vc as! EntityTableVC, forKeyPath: "name", options: .New, context: nil);
        attr.addObserver(vc as! EntityTableVC, forKeyPath: "type", options: .New, context: nil);
    }
    
    // prepareForSegue helper
    func setupAttrObservers(vert:Vert, vc:EntityTableVC) {
    
        for attr in vert.attributes! {
            if attr is Attribute {
                setKVOForAttrTable(attr as! Attribute, vc: vc, vert: vert);
            }
        }
    }

    // must be public due to target-action
    // nav bar button actions
    func email() {
        mailGen.delegate=self;
        mailGen.user = user;
        mailGen.emailPressed();
    }
    
    // must be public due to target-action
    func grid() {
        if graphView != nil {
            graphView!.switchGraphState();
        }
    }

    // must be public due to target-action
    func clear() {
    
        let alert = UIAlertController(title: "Confirm Clear", message: "Please confirm removing all entities and relationships", preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil);
        let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler:
            {
            (alert:UIAlertAction!) -> Void in
                // reset the showAttrErr flag
                for obj in self.graph!.verts!
                {
                    if obj is Vert {
                        let vertId:Int32? = (obj as! Vert).vertViewId;
                        if vertId != nil {
                            self.remVertView(vertId!);
                        }
                        else {print("CoreController: clearPressed: vertId is nil");}
                    }
                }
                for obj in self.graph!.edges!
                {
                    if obj is Edge {
                        let edgeId:Int32? = (obj as! Edge).edgeViewId;
                        if edgeId != nil {
                            self.remEdgeView(edgeId!);
                        }
                        else {print("CoreController: clearPressed: edgeId is nil");}
                    }
                }
            }
        );
        alert.addAction(cancelAction);
        alert.addAction(confirmAction);
        
        self.presentViewController(alert, animated: false, completion:nil);

    }
    
    // must be public due to target-action
    // gotoOptions() triggers a segue to the options menu
    func gotoOptions() {
        self.performSegueWithIdentifier("optionsSegue", sender: self);
    }
    
    override func viewDidLoad() {

        // set right nav buttons
        let options = UIBarButtonItem(title:"options", style: UIBarButtonItemStyle.Plain, target: self, action: "gotoOptions");
        let grid = UIBarButtonItem(title:"grid", style: UIBarButtonItemStyle.Plain, target: self, action: "grid");
        let email = UIBarButtonItem(title:"email", style: UIBarButtonItemStyle.Plain, target: self, action: "email");
        let rightNavButtons = [options,grid,email];
        navigationItem.rightBarButtonItems = rightNavButtons;
        
        // set left nav buttons
        let clear = UIBarButtonItem(title:"clear", style: UIBarButtonItemStyle.Plain, target: self, action: "clear");
        let leftNavButtons = clear;
        navigationItem.leftBarButtonItem = leftNavButtons;
        
        // set title to be textfield
        let navTextField = UITextField(frame: CGRectMake(0,0,100,30));
        navTextField.placeholder = "Set model title";
        navigationItem.titleView = navTextField;

        hght=view.bounds.size.height;
        wdth=view.bounds.size.width;
        barButtons();
        setupVertButtons();

        // assign the graph variable to a saved graph
        fetchGraph();
        // assign the user variable to a saved user
        fetchUser();
        
        // notification response to object deletion from context
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
    
    private func fetchGraph() {
        //var error: NSError? = nil;
        let entityDescription = NSEntityDescription.entityForName("Graph", inManagedObjectContext: context!);
        let graphRequest:NSFetchRequest = NSFetchRequest();
        graphRequest.entity = entityDescription;

        let savedGraphs: [AnyObject]?
        do {
            savedGraphs = try context!.executeFetchRequest(graphRequest)
        } catch let error1 as NSError {
            //error = error1
            savedGraphs = nil
        };
        
        if (savedGraphs == nil){print("CoreController: viewDidLoad: fetch is nil");}
        else {
            if savedGraphs!.count > 0 {
                graph = savedGraphs![0] as? Graph;
                loadGraph();
            }
            else {
                // TODO: move testGraph into options
                testGraph();
            }
        }
    }
    
    // fetchUser() does a fetch request for users and assigns the user variable to the first user found
    private func fetchUser() {
        //var error: NSError? = nil;
        let entityDescription = NSEntityDescription.entityForName("User", inManagedObjectContext: context!);
        let userRequest:NSFetchRequest = NSFetchRequest();
        userRequest.entity = entityDescription;

        let savedUsers: [AnyObject]?
        do {
            savedUsers = try context!.executeFetchRequest(userRequest)
        } catch let error1 as NSError {
            //error = error1
            savedUsers = nil
        };
        
        if savedUsers == nil {print("CoreController: fetchUser: fetch is nil");}
        else {
        
            if savedUsers!.count > 0 {
                for savedUser in savedUsers! {
                    if (savedUser as! User).email != "" {
                    
                        user = savedUser as? User;
                        return;
                    }
                }
            }
            
            // If no saved user with a real email address was found then user will have a lazy init. Assign its properties as empty strings.
            user!.username = "";
            user!.email = "";
        }
    }
    
    // loadGraph() draws the verts and edges of a saved vert
    // when debugging core data use println not debugging commands
    private func loadGraph() {
        
        if graph == nil {print("CoreController: loadGraph: graph is nil");}
        for obj in graph!.verts! {

            let vert = obj as! Vert;
            vert.addObserver(self, forKeyPath: "finishedObservedMethod", options: .New, context: nil);
            vert.addObserver(self, forKeyPath: "title", options: .New, context: nil);
            drawVert(vert);
        }
        for obj in graph!.edges! {
            let edge = obj as! Edge;
            edge.addObserver(self, forKeyPath: "freshView", options: .New, context: nil);
            drawEdge(edge);
        }
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
                    else {print("CoreController: viewDidLoad(): vertId is nil"); }
                }
                else if obj is Edge {
                
                    // get the view id from the vert
                    let edgeId:Int32? = (obj as! Edge).edgeViewId;
                    if edgeId != nil {
                        self.remEdgeView(edgeId!);
                    }
                    else {print("CoreController: respondToDeletion(): edgeId is nil"); }
                }
                else {print("CoreController: respondToDeletion(): object to be deleted has unknown type");}
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
    
        // clobber attrTable if it exists
        
    
        //TODO: if needed arrange views into final order here 
        /* ... */

        // starting mode is one of moveMode(), vertMode(), edgeMode()
        moveMode();
    }
    
    //Setup: 
    func addCenteredImageToView(view:UIView?, image:UIImage?) {
        if image != nil && view != nil {
            let circView=UIImageView(image: image! );
            circView.center=CGPointMake(view!.frame.width/2, view!.frame.height/2);
            view!.addSubview(circView);
        }
        else {print("CoreController: addCenteredImageToView: one of the inputs is nil");}
    }
    
    //setupVertButtons: buttons for adding vert, removing vert, and removing edge
    func setupVertButtons() {
        
        // add vert "button"
        addVertControl=UIView();
        if addVertControl == nil {print("CoreController: setupVertButtons: could not create addVertController");}
        addVertControl!.frame=CGRectMake(wdth*0.666,hght*(1-2*vscale),wdth*0.334,hght*vscale);
        addCenteredImageToView(addVertControl, image:UIImage(named:"addCircle"));
        
        // rem vert "button"
        remVertControl=UIView();
        if remVertControl == nil {print("CoreController: setupVertButtons: could not create addVertController");}
        remVertControl!.frame=CGRectMake(0,hght*(1-2*vscale),wdth*0.333,hght*vscale);
        addCenteredImageToView(remVertControl, image:UIImage(named:"remCircle"));
        
        // rem edge "button"
        remEdgeControl=UIView();
        if remEdgeControl == nil {print("CoreController: setupVertButtons: could not create addVertController");}
        remEdgeControl!.frame=CGRectMake(0,hght*(1-2*vscale),wdth*0.333,hght*vscale);
        addCenteredImageToView(remEdgeControl, image:UIImage(named:"remCircle"));
        

    }
    
    // sets up 3 buttons for the view controllers UI states
    func barButtons() {
        
        //edgeButton = imgTextButton.buttonWithType(.System) as? imgTextButton;
        edgeButton = imgTextButton(type: .System);
        view.addSubview(edgeButton!);
        edgeButton!.frame=CGRectMake(0,hght*(1-vscale),wdth*0.333,hght*vscale);
        edgeButton!.addTarget(self, action: "edgeMode", forControlEvents:.TouchUpInside);
        edgeButton!.setImage( UIImage(named:"link"), forState:UIControlState.Normal );
        edgeButton!.setTitle("relationship", forState: UIControlState.Normal);
        
        //moveButton = barButton("M");
        //moveButton = imgTextButton.buttonWithType(.System) as? imgTextButton;
        moveButton = imgTextButton(type: .System);
        view.addSubview(moveButton!);
        moveButton!.frame=CGRectMake(wdth*0.333,hght*(1-vscale),wdth*0.333,hght*vscale);
        moveButton!.addTarget(self, action: "moveMode", forControlEvents:.TouchUpInside);
        moveButton!.setImage( UIImage(named:"scroll"), forState:UIControlState.Normal );
        moveButton!.setTitle("move", forState: UIControlState.Normal);

        //vertButton
        //vertButton = imgTextButton.buttonWithType(.System) as? imgTextButton;
        vertButton = imgTextButton(type: .System);
        view.addSubview(vertButton!);
        vertButton!.frame=CGRectMake(wdth*0.666,hght*(1-vscale),wdth*0.334,hght*vscale);
        vertButton!.addTarget(self, action: "vertMode", forControlEvents:.TouchUpInside);
        vertButton!.setImage( UIImage(named:"share"), forState:UIControlState.Normal );
        vertButton!.setTitle("entity", forState: UIControlState.Normal);
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

    // model graph
    lazy var graph:Graph?={
        var graph:Graph?;
        if self.context != nil {
            let graphDescription = NSEntityDescription.entityForName("Graph",inManagedObjectContext: self.context!);
            graph = Graph(entity: graphDescription!,insertIntoManagedObjectContext: self.context!);
            graph?.addObserver(self, forKeyPath: "finishedObservedMethod", options: .New, context: nil);
        }
        else {
            print("CoreController: graph: cannot create graph, context is nil");
        }
        return graph;
    }()
    
    // model user
    lazy var user:User?={
        var user:User?;
        if self.context != nil {
            let userDescription = NSEntityDescription.entityForName("User",inManagedObjectContext: self.context!);
            user = User(entity: userDescription!,insertIntoManagedObjectContext: self.context!);
            user?.addObserver(self, forKeyPath: "finishedObservedMethod", options: .New, context: nil);
        }
        else {
            print("CoreController: user: cannot create user, context is nil");
        }
        return user;
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
            print("CoreController: remVertView: could not find vert to delete. Id to delete is \(vertId)");
        }
    }
    
    func addVert(loc:CGPoint) {
    
        let vertDescription = NSEntityDescription.entityForName("Vert",inManagedObjectContext: context!);
        let vert:Vert? = Vert(entity: vertDescription!,insertIntoManagedObjectContext: context);
        if vert == nil {print("CoreController: addVert: created vert is nil");}
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
             for e in vert!.edges! {
                 if e is Edge {
                     let edge=e as! Edge;
                    
                     context!.deleteObject(edge);
                 }
             }
             for elem in vert!.neighbors! {
                 if elem is Vert {
                     let vert=elem as! Vert;
                     vert.freshViews=false;
                 }
             }
            
             context!.deleteObject(vert!);
        }
        else { print("removeVertById: err"); }
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
        let edge:Edge? = Edge(entity: edgeDescription!,insertIntoManagedObjectContext: context);
        
        if graph != nil && edge != nil && vert1 != nil && vert2 != nil {
            graph!.SetupEdge(edge!, From:vert1!, To:vert2!);
        }
    }
    
    func remEdge(edgeId: Int32) {
        // save current context
        saveContext();
        // get a vert
        if graph != nil && context != nil {
        
            let edge:Edge? = graph!.getEdgeById(edgeId);
            if edge != nil {
                let v:Vert?;
                let w:Vert?;
                
                (v,w)=edge!.Connects();
                if v != nil && w != nil {
                    // core data update bidirectional relationships so it should be necc to call removeEdge on v
                    v!.removeEdge(edge, vertOrNil:w);
                    
                    
                }
                else {
                    print("CoreController: remEdge: v or w is nil");
                }
                context!.deleteObject(edge!);
            }
            else {print("CoreController: remEdge: edge to delete could not be found");}
            
        }
        else {print("removeEdgeById: err");}
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
        if graphView == nil {print("CoreController: scrollOff: graphView is nil");}
        (graphView!.maximumZoomScale,graphView!.minimumZoomScale) = (1.0,1.0);
        graphView!.panGestureRecognizer.enabled=false;
    }
    
    private func scrollOn() {
        if graphView == nil {print("CoreController: scrollOn: graphView is nil");}
        (graphView!.maximumZoomScale,graphView!.minimumZoomScale) = (2.0,0.2);
        graphView!.panGestureRecognizer.enabled=true;
    }
    
    // edgeMode() handles switching from vertMode() or moveMode()
    func edgeMode() {
        // method cannot be private, called by action
        
        edgeButton!.setTitleColor(selectedTextColor, forState:.Normal);
        vertButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        moveButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        scrollOff();
        if addVertControl != nil && remVertControl != nil {
            addVertControl!.removeFromSuperview();
            remVertControl!.removeFromSuperview();

            graphView!.addSubview(remEdgeControl!);
            graphView!.sendSubviewToBack(remEdgeControl!);
            graphView!.sendSubviewToBack(graphView!.gridBack!);
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
        if addVertControl == nil && remVertControl == nil {print("CoreController: vertMode: addVert or remVert buttons are nil");}
        
        // disable gesture recognizers
        enableOrDisableGestureRecognizers(false);
        
        inVertMode=false;
        inMoveMode=true;
        inEdgeMode=false;
    }
    
    func vertMode() {
        // method cannot be private, called by action
    
        if edgeButton == nil || vertButton == nil || moveButton == nil {
            print("CoreController: vertMode: one of the buttons is nil");
        }
        else {
            edgeButton!.setTitleColor(unselectedTextColor, forState:.Normal);
            vertButton!.setTitleColor(selectedTextColor, forState:.Normal);
            moveButton!.setTitleColor(unselectedTextColor, forState:.Normal);
        }
        scrollOff();
        
        if addVertControl == nil || remVertControl == nil {print("CoreController: vertMode: addVert or remVert buttons are nil");}
        else {
        
            graphView!.addSubview(addVertControl!);
            graphView!.addSubview(remVertControl!);
            // gridBack must go behind the addVertControls
            graphView!.sendSubviewToBack(addVertControl!);
            graphView!.sendSubviewToBack(remVertControl!);
            graphView!.sendSubviewToBack(graphView!.gridBack!);
            
            remEdgeControl!.removeFromSuperview();
        }

        // enable gesture recognizers
        enableOrDisableGestureRecognizers(true);
        
        inVertMode=true;
        inMoveMode=false;
        inEdgeMode=false;
    }

    // enableOrDisableGestureRecognizersForView() turns all gesture recognizers on gwv except for tap recognizer on the view on or off
    func enableOrDisableGestureRecognizers(isEnabled: Bool) {
        if graphView == nil { print("CoreController: enableOrDisableGestureRecognizers: graphView is nil");}
        if graphView!.gwv == nil { print("CoreController: enableOrDisableGestureRecognizers: graphView.gwv is nil");}
        
        // enable or disable on current view
        enableOrDisableGestureRecognizersForView(graphView!.gwv!, isEnabled:isEnabled);

        // enable or disable on subviews
        for sub in graphView!.gwv!.subviews {
            enableOrDisableGestureRecognizersForView((sub as UIView), isEnabled:isEnabled);
        }
    }
    
    // enableOrDisableGestureRecognizersForView() turns all gesture recognizers on the view except for tap recognizer on the view on or off
    func enableOrDisableGestureRecognizersForView(view:UIView, isEnabled:Bool) {
        if view.gestureRecognizers != nil {
            for recog in view.gestureRecognizers! {
                if !(recog is UITapGestureRecognizer) { (recog as UIGestureRecognizer).enabled = isEnabled;}
            }
        }
    }
    
    // entry point from other view controllers
    func onResumeGraph() {
        // TO DO
    }
    // entry point from other view controllers
    func onNewGraph() {
        testGraph();
    }

    //MARK: KVO on model
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [NSObject: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if graphView == nil {print("CoreController: observeValueForKeyPath: graphView is nil"); }
        
        if object is Vert {

            if keyPath == "finishedObservedMethod" {
                if !(object as! Vert).freshViews {
                    drawVert(object as! Vert);
                }
            }
            else if keyPath == "title" {
                setVertViewTitle(object as! Vert);
            }
            else {print("CoreController: observeValueForKeyPath: unrecognized keyPath \(keyPath) for object vert");}
        }
        else if object is Edge {
        
            if keyPath == "freshView" {
                if !(object as! Edge).freshView {
                    drawEdge(object as! Edge);
                }
            }
        }
    }
    
    // caller of this function should check that the edge view really does need to be redrawn
    private func drawVert(v:Vert) {
    
        // check if a view exists corresponding to the vert instance. Then (1) if no view is found then vertView is nil and
        // we init a vertView and paste it to view. (2) otherwise model and view are out of date.
        let vertView:VertView? = graphView!.gwv!.getVertViewById(v.vertViewId);
        if(vertView != nil) {
            // Refresh any properties of the vert view:
            // (1) title
            setVertViewTitle(vertView!, title:v.title!);
        
            // (2) frame
            (vertView!.frame.origin.x, vertView!.frame.origin.y) = (CGFloat(v.x), CGFloat(v.y));
            
            // in the unlikely event the vert view wants to be clobbered oblige it
            if !vertView!.isDrawn {
                vertView!.setNeedsDisplay();
            }
        }
        else {
            // create a vert view
            let vv:VertView = graphView!.gwv!.addVertAtPoint(CGPointMake(CGFloat(v.x), CGFloat(v.y)) );
            
            // set title, delegate, and id of the new vert view
            setVertViewTitle(vv, title:v.title!);
            vv.delegate=self;
            vv.vertViewId=v.vertViewId;
            
        }
        
        // vert view is now fresh
        v.freshViews=true;
    }
    
    // caller of this function should check that the edge view really does need to be redrawn
    private func drawEdge(e:Edge) {
    
        let v,w:Vert?;
        (v,w)=e.Connects();
        
        // step 1: setup
        
        // diameter holds diamter of vertViews
        let diameter=graphView!.gwv!.diameter;
        var X1,Y1,X2,Y2,frameWidth,frameHeight,minX,minY:CGFloat?;
        (X1,Y1,X2,Y2) = (CGFloat(v!.x),CGFloat(v!.y),CGFloat(w!.x),CGFloat(w!.y));
        (frameWidth,frameHeight) = (fabs(X1!-X2!)+diameter,fabs(Y1!-Y2!)+diameter);
        (minX,minY) = (min(X1!,X2!),min(Y1!,Y2!));
        
        // step 2: adjust the frame based on the least coordinate for the xval and yval for the pair of points
        let edgeFrame = CGRectMake(minX!, minY!, frameWidth!, frameHeight!);
        // there are four cases to consider for the positions of the origins of the verts. 
        // There are two cases for the direction of the edge between the two verts: top left to bottom right or bottom left to top right. 
        // The edge view must be told which of these cases it falls into
        let edgeDir:Bool;
        if (X1<X2 && Y1<Y2) || (X1>=X2 && Y1>=Y2) {
            edgeDir=true;
        }
        else {
            edgeDir=false;
        }
        
        // step 3: getEdgeView()
        var edgeView:EdgeView? = graphView!.gwv!.getEdgeViewById(e.edgeViewId);
        if(edgeView != nil) {

            // fix the frame
            edgeView!.frame=edgeFrame;
            // fix the path direction
            edgeView!.topLeftToBotRight = edgeDir;
            // redraw the bez path
            edgeView!.setNeedsDisplay();
        }
        else {
            // init the new view in setEdge() input
            edgeView=graphView!.gwv!.setEdge(EdgeView(frame: edgeFrame), topLeftToBotRight: edgeDir);
            
            // do any additional setup i.e. length or angle
            edgeView!.edgeViewId=e.edgeViewId;
        }
        // redraw the edge
        edgeView!.setNeedsDisplay();
        e.freshView = true;
    }
    
    // MARK: scroll
    func scrollViewDidScroll(scrollView: UIScrollView) {
    
    
        (graphViewContentOffsetDeltaX,graphViewContentOffsetDeltaY) = (scrollView.contentOffset.x - graphViewPrevContentOffsetX, scrollView.contentOffset.y - graphViewPrevContentOffsetY);
        // reset the stored offset values
        (graphViewPrevContentOffsetX, graphViewPrevContentOffsetY) = (scrollView.contentOffset.x, scrollView.contentOffset.y);
        
        // adjust x and y positions by delta
        addVertControl!.center = CGPointMake(addVertControl!.center.x + graphViewContentOffsetDeltaX, addVertControl!.center.y + graphViewContentOffsetDeltaY);
        remVertControl!.center = CGPointMake(remVertControl!.center.x + graphViewContentOffsetDeltaX, remVertControl!.center.y + graphViewContentOffsetDeltaY);
        remEdgeControl!.center = CGPointMake(remEdgeControl!.center.x + graphViewContentOffsetDeltaX, remEdgeControl!.center.y + graphViewContentOffsetDeltaY);
    }
    
    //MARK: title
    // sets the title of a vert view
    func setVertViewTitle(v:Vert) {
        let vv:VertView? = graphView!.gwv!.getVertViewById(v.vertViewId);
        if vv != nil {
            if vv!.titleLabel != nil {
                // labels update live so we don't need to call setNeedsDisplay()
                
                vv!.titleLabel!.text = v.title;
                //vv!.setNeedsDisplay();
            }
        }
        else {
            print("CoreController: updateAttributes: no vert view was found");
        }
    }
    
    // set the title of the given vert view
    private func setVertViewTitle(vv:VertView, title:String) {
        if vv.titleLabel == nil {print("CoreController: drawVert: titleLabel is nil")}
        vv.titleLabel!.text=title;
    }

    //MARK: UIScrollViewDelegateProtocol
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return graphView!.gwv ;
    }

    //MARK: deinit (for KVO)
    deinit {
        for vert in graph!.verts! {
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
                print("drawGraphAfterMovingVert: view id too large or small", appendNewline: false);
            }
            else {
                // moveVertById changes the core model
                // this class is listening for changes in the core model
                graph!.moveVertById(viewId, toXPos:endX, toYPos:endY);
            }
        }
        else {
            print("CoreController: drawGraphAfterMovingVertById: err", appendNewline: false)
        }
    }

    // MARK: core data
    lazy var applicationDocumentsDirectory: NSURL =
    {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.david.CoreDataTest" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
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
        
        var newContext = NSManagedObjectContext();
        newContext.persistentStoreCoordinator = coordinator;
        return newContext
    }()
    
    // MARK: Vert attributes
    // setTitle
    func setTitle(vertId:Int32, title: String) {
        let vert:Vert? = graph!.getVertById(vertId);
        if vert == nil { print("CoreController: addAttributeById: setTitle"); }
        vert!.title = title;
    }
    
    //MARK: - Core Data Saving support
    func saveContext() {
    
        if let moc = context {
            var error: NSError? = nil
            //println("save context: context to save is \(context!)");
            
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch let error1 as NSError {
                    error = error1
                };
                print("error is \(error)");
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                //NSLog("Unresolved error \(error), \(error!.userInfo)")
                //abort()
            }
            
        }
    }
    
    //MARK:testing
    
    // use vert id to get a vert and add an attribute to it
    func addAttributeById(vert:Vert)->Attribute {
        // make attr
        let attrDescription = NSEntityDescription.entityForName("Attribute",inManagedObjectContext: context!);
        let attr:Attribute = Attribute(entity: attrDescription!,insertIntoManagedObjectContext: context);

        // set KVO on self
        attr.addObserver(self, forKeyPath: "name", options: .New, context: nil);
        attr.addObserver(self, forKeyPath: "type", options: .New, context: nil);
        
        let manyRelation:AnyObject? = vert.valueForKeyPath("attributes") ;
        if manyRelation is NSMutableSet {
            (manyRelation as! NSMutableSet).addObject(attr);
        }
        return attr;
    }
    
    // create some variables in the managedObjectModel and send them to the model for setup
    private func testGraph() {
        // setup: step 1: create a ref to some verts and observers for them, step 2: create a ref to some edges and observers for them, step 3: set the position of the verts and attach to graph, step 4: attach edges
        var verts=testVertsArray(4);
        var edges=testEdgesArray(4);
        if graph != nil {
      
            graph!.SetupVert(verts[0], AtX:10, AtY:70 );
            graph!.SetupVert(verts[1], AtX:100, AtY:200 );
            graph!.SetupVert(verts[2], AtX:50, AtY:300 );
            graph!.SetupVert(verts[3], AtX:200, AtY:80 );
            graph!.SetupEdge(edges[0], From:verts[0], To:verts[1]);
            graph!.SetupEdge(edges[1], From:verts[1], To:verts[2]);
            graph!.SetupEdge(edges[2], From:verts[0], To:verts[2]);
            graph!.SetupEdge(edges[3], From:verts[2], To:verts[3]);
            
            // set default titles and relationships
            verts[0].title = "Dog";
            verts[1].title = "Owner";
            verts[2].title = "Brand";
            verts[3].title = "Photo";
            
            // the indexs of the verts are the same as the first column of vert indexs above
            edges[0].setNameForVert(verts[0], relationshipName: "Owner");
            edges[1].setNameForVert(verts[1], relationshipName: "FavoriteBrand");
            edges[2].setNameForVert(verts[0], relationshipName: "FavoriteBrand");
            edges[3].setNameForVert(verts[2], relationshipName: "Photo");
            
            edges[0].setNameForInverseOfVert(verts[1], relationshipName: "Dog");
            edges[1].setNameForInverseOfVert(verts[2], relationshipName: "OwnersThatLike");
            edges[2].setNameForInverseOfVert(verts[2], relationshipName: "DogsThatLike");
            edges[3].setNameForInverseOfVert(verts[3], relationshipName: "Brand");

            let dogname = addAttributeById(verts[0]);
            dogname.name = "Name";
            dogname.type = "String";
            
            let dogbreed = addAttributeById(verts[0]);
            dogbreed.name = "Breed";
            dogbreed.type = "String";
            
            let dogage = addAttributeById(verts[0]);
            dogage.name = "Age";
            dogage.type = "String";
            
            let dogweight = addAttributeById(verts[0]);
            dogweight.name = "Weight";
            dogweight.type = "String";
            
            // customize owner
            let ownername = addAttributeById(verts[1]);
            ownername.name = "Name";
            ownername.type = "String";
            
            let membershipId = addAttributeById(verts[1]);
            membershipId.name = "MembershipId";
            membershipId.type = "String";
            
            // customize brand
            let brandname = addAttributeById(verts[2]);
            brandname.name = "Name";
            brandname.type = "String";
            
            let cost = addAttributeById(verts[2]);
            cost.name = "Cost";
            cost.type = "Double";
            
            let desc = addAttributeById(verts[2]);
            desc.name = "Description";
            desc.type = "String";
            
            // customize photo
            let photo = addAttributeById(verts[3]);
            photo.name = "Description";
            photo.type = "Binary Data";
            
            saveContext();
            // let testArr:Array<Int32> = graph!.getIds();
        }
        else {
            print("CoreController: testGraph: err graph is nil");
        }
    }
    
    private func testVertsArray(numVerts:Int)->Array<Vert> {
        var verts=Array<Vert>();
        if context == nil { print("CoreController: makeVertsArray: context is nil");}
        else {
            let vertDescription = NSEntityDescription.entityForName("Vert",inManagedObjectContext: context!);
            for var i=0;i<numVerts;i++ {
                let vert:Vert = Vert(entity: vertDescription!,insertIntoManagedObjectContext: context);
                vert.addObserver(self, forKeyPath: "finishedObservedMethod", options: .New, context: nil);
                vert.addObserver(self, forKeyPath: "title", options: .New, context: nil);
                verts.append(vert);
            }
        }
        return verts;
    }

    // conveince function for making an array of edges observers associated to them
    private func testEdgesArray(numEdges:Int)->Array<Edge> {
        var edges=Array<Edge>();
        let edgeDescription = NSEntityDescription.entityForName("Edge",inManagedObjectContext: context!);
        
        if context != nil {
            for var i=0;i<numEdges;i++ {
                let edge:Edge? = Edge(entity: edgeDescription!,insertIntoManagedObjectContext: context);
                edge!.addObserver(self, forKeyPath: "freshView", options: .New, context: nil);
                
                edges.append(edge!);
            }
        }
        else {
        
        }
        return edges;
    }
}
