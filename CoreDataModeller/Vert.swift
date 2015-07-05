//
//  Vert.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-07-01.
//  Copyright © 2015 David Marquis. All rights reserved.
//

import Foundation
import CoreData

@objc(Vert)
class Vert: NSManagedObject {

    // computed property
    class func MAXPosition()->Float {
        let maxPos:Float=1000;
        return maxPos;
    }

    //MARK: accessor methods
    // freshViews
    func gFinishedObservedMethod()->Bool {
        let selfFinishedObservedMethod:NSNumber? = valueForKeyPath("finishedObservedMethod") as? NSNumber;
        if selfFinishedObservedMethod == nil {print("Vert: getFinishedObservedMethod: FinishedObservedMethod is nil");}
        return selfFinishedObservedMethod!.boolValue;
    }

    // shouldSyncEntityAttributes, Bool
    func gFreshViews()->Bool {
        let selfFreshViews:NSNumber? = valueForKeyPath("freshViews") as? NSNumber;
        if selfFreshViews == nil {print("Vert: getFreshViews: FreshViews is nil");}
        return selfFreshViews!.boolValue;
    }

    // title, String?
    func gShouldSyncEntityAttributes()->Bool {
        let selfShouldSyncEntityAttributes:NSNumber? = valueForKeyPath("shouldSyncEntityAttributes") as? NSNumber;
        if selfShouldSyncEntityAttributes == nil {print("Vert: getShouldSyncEntityAttributes: ShouldSyncEntityAttributes is nil");}
        return selfShouldSyncEntityAttributes!.boolValue;
    }

    // vertViewId, Int32
    func gTitle()->String {
        //setValue("", forKeyPath: "title");
        //let obj = valueForKeyPath("title");

        let selfTitle:String? = valueForKeyPath("title") as? String;
        if selfTitle == nil {print("Vert: getTitle: Title is nil");}
        return selfTitle!;
    }

    // x, Float
    func gX()->Float {
        let selfX:NSNumber? = valueForKeyPath("x") as? NSNumber;
        if selfX == nil {print("Vert: getX: X is nil");}
        return selfX!.floatValue;
    }

    // y, Float
    func gY()->Float {
        let selfY:NSNumber? = valueForKeyPath("y") as? NSNumber;
        if selfY == nil {print("Vert: getY: Y is nil");}
        return selfY!.floatValue
    }

    func gVertViewId()->Int32 {
        let selfFreshViews:NSNumber? = valueForKeyPath("vertViewId") as? NSNumber;
        if selfFreshViews == nil {print("Vert: getVertViewId: FreshViews is nil");}
        return selfFreshViews!.intValue;
    }

    // attributes,
    func gAttributes()->Set<Attribute> {
        let selfAttributes:Set<Attribute>? = valueForKeyPath("attributes") as? Set<Attribute>;
        if selfAttributes == nil {print("Vert: getAttributes: Attributes is nil");}
        return selfAttributes!
    }

    func gNeighbors()->Set<Vert> {
        let selfNeighbors:Set<Vert>? = valueForKeyPath("neighbors") as? Set<Vert>;
        if selfNeighbors == nil {print("Vert: getNeighbors: neighbors is nil");}
        return selfNeighbors!;
    }

    func gEdges()->Set<Edge> {
        let selfEdges:Set<Edge>? = valueForKeyPath("edges") as? Set<Edge>;
        
        if selfEdges == nil {print("Vert: getEdges: edges is nil");}
        return selfEdges!;
    }

    // MARK: setters - names start with s rather than set to avoid conflict w/ the autogenerated methods (which are broken in xcode 7 beta 2)
    // freshViews
    func sFinishedObservedMethod(bool:Bool) {
        setValue(NSNumber(bool: bool),forKeyPath: "finishedObservedMethod") ;
    }

    // shouldSyncEntityAttributes, Bool
    func sFreshViews(bool:Bool) {
        setValue(NSNumber(bool: bool),forKeyPath: "freshViews");
    }

    // title, String?
    func sShouldSyncEntityAttributes(bool:Bool) {
        setValue(NSNumber(bool: bool),forKeyPath: "shouldSyncEntityAttributes");
    }

    // vertViewId, Int32
    func sTitle(string:String) {
        setValue(string,forKeyPath: "title");
    }

    // x, Float
    func sX(float:Float) {
        setValue(NSNumber(float: float),forKeyPath: "x");
    }

    // y, Float
    func sY(float:Float) {
        setValue(NSNumber(float: float),forKeyPath: "y");
    }

    // y, Float
    func sVertViewId(int:Int32) {
        setValue(NSNumber(int:int),forKeyPath: "vertViewId");
    }

    //
    // ADD / REM
    //
    func addVertToNeighbors(vert:Vert) {
        let key="neighbors";
        var selfNeighbors:Set<Vert>? = valueForKeyPath(key) as? Set<Vert>;
        if selfNeighbors == nil {print("Vert: addVertToNeighbors: neighbors is nil");}
        selfNeighbors!.insert(vert);
        
        setValue(selfNeighbors, forKeyPath: key);
    }

    // adds an edge to the managed property "edges"
    func addEdgeToEdges(edge:Edge) {
        let key="edges";
        var selfEdges:Set<Edge>? = valueForKeyPath(key) as? Set<Edge>;
        if selfEdges == nil {print("Vert: addAttrFromAttrs: is nil");}
        selfEdges!.insert(edge);
        
        setValue(selfEdges, forKeyPath: key);
    }

    func addAttrFromAttrs(attr:Attribute) {
        let key="attributes";
        var selfAttrs:Set<Attribute>? = valueForKeyPath(key) as? Set<Attribute>;
        if selfAttrs == nil {print("Vert: addAttrFromAttrs: is nil");}
        selfAttrs!.insert(attr);
        
        setValue(selfAttrs, forKeyPath: key);
    }

    func remVertFromNeighbors(vert:Vert) {
        let key="neighbors";
        var selfNeighbors:Set<Vert>? = valueForKeyPath(key) as? Set<Vert>;
        if selfNeighbors == nil {print("Vert: remVertToNeighbors: is nil");}
        selfNeighbors!.remove(vert);
        
        setValue(selfNeighbors, forKeyPath: key);
    }

    // removes an edge to the managed property "edges"
    func remEdgeFromEdges(edge:Edge) {
        let key="attributes";
        var selfEdges:Set<Edge>? = valueForKeyPath(key) as? Set<Edge>;
        if selfEdges == nil {print("Vert: remEdgeToNeighbors: is nil");}
        selfEdges!.remove(edge);
        
        setValue(selfEdges, forKeyPath: key);
    }

    func remAttrFromAttrs(attr:Attribute) {
        let key="edges";
        var selfAttrs:Set<Attribute>? = valueForKeyPath(key) as? Set<Attribute>;
        if selfAttrs == nil {print("Vert: remAttrFromAttrs: is nil");}
        selfAttrs!.remove(attr);
        
        setValue(selfAttrs, forKeyPath: key);
    }

    //MARK: init
    // setVertProperties must set the initial values for all attributes of a vert
    func setVertProperties() {

        // assign the properties
        sTitle("");
        sFinishedObservedMethod(false);
        sFreshViews(false);
        sX(0);
        sY(0);
        sShouldSyncEntityAttributes(false);
        sVertViewId(-1);
    }

    //MARK: methods
    override var description:String {
        // store methodName for logging errors
        var desc:String="Vert(\(Int(x)),\(Int(y)))[";
        
        var nghs = Array<Vert>(self.gNeighbors());

        let n:Int = nghs.count;
        var i:Int;
        if n > 0 {
            // first n-1 elems and last elem slightly different formatting
            for i=0;i<n-1;i++ {
                desc=desc+"(\(Int(nghs[i].x)),\(Int(nghs[i].y))),";
            }
            desc=desc+"(\(Int(nghs[i].x)),\(Int(nghs[i].y)))]";
        }
        return desc;
    }

    func isNeighborOf(other:Vert)->Bool {

        let selfNeighbors = gNeighbors();
        let otherNeighbors = gNeighbors();

        if(selfNeighbors.contains(other) && otherNeighbors.contains(self)) {
            return true;
        }
        else if selfNeighbors.contains(other) {
            return true;
        }
        else {
            return false;
        }
    }

    // getSharedEdge() returns the edge shared with the other vert if it is not nil
    func getSharedEdge(other: Vert)->Edge? {
        if(!self.isNeighborOf(other)) {
            return nil;
        }
        
        for e1 in gEdges() {
            for e2 in other.gEdges() {
                if e1===e2 {
                    return e1;
                }
            }
        }
        return nil;
    }

    // think of this as an inverse: you put one vert in and get the other one
    func getNeighborOnEdge(edge:Edge)->Vert? {
        let v:Vert?;
        let w:Vert?;
        (v,w)=edge.Connects();
        
        if v === self {
            return w;
        }
        else if w === self {
            return v;
        }
        else {
            return nil;
        }
    }

    // addEdge sets up a new edge
    func AddEdge(edgeOrNil:Edge?, toVert vertOrNil:Vert?)  {

        if(edgeOrNil != nil && vertOrNil != nil) {
            //TODO: check if the verts already have an edge

            // bidirectional relationship: only need to update on one side
            addVertToNeighbors(vertOrNil!);
            // update edge sets
            self.addEdgeToEdges(edgeOrNil!);
            vertOrNil!.addEdgeToEdges(edgeOrNil!);
            
            edgeOrNil!.addVertToJoinedTo(vertOrNil!);
            edgeOrNil!.addVertToJoinedTo(self);

            edgeOrNil!.sFreshView(false);
            self.sFinishedObservedMethod(true);
            vertOrNil!.sFinishedObservedMethod(true);
            
        }
        else {
           print("Vert: addEdge: one of the inputs is nil");
        }
    }

    // prepare for the removal of an edge from the context
    func removeEdge(edgeOrNil:Edge?, vertOrNil:Vert?) {
        if(edgeOrNil != nil && vertOrNil != nil) {

            remVertFromNeighbors(vertOrNil!);
            self.remEdgeFromEdges(edgeOrNil!);
            vertOrNil!.remEdgeFromEdges(edgeOrNil!);
            
            edgeOrNil!.sFreshView(false);
            self.sFinishedObservedMethod(true);
            vertOrNil!.sFinishedObservedMethod(true);
        }
        else {
            print("Vert cat: removeEdge: one of the inputs is nil");
        }
    }

    func distance(other:Vert)->Float{
        if(self.isNeighborOf(other)) {
            let x1:Float=self.gX();
            let x2:Float=other.gX();
            let y1:Float=self.gY();
            let y2:Float=other.gY();
            
            let z1=pow(x1-x2,2);
            let z2=pow(y1-y2,2);
            return sqrt(z1+z2);
        }
        else {
            // get the computed property. like infinity
            return Vert.MAXPosition();
        }
    }

    // change Fresh flags so VC must redraw (i.e. trigger a redraw of corresponding view)
    func invalidateViews() {
        for obj in edges! {
            if obj is Edge {
                (obj as! Edge).sFreshView(false);
            }
        }
        sFreshViews(false);
    }

    // change vert position in data model
    func moveVertTo(newX:Float, _ newY:Float) {
        // set the new x and y positions
        sX(newX);
        sY(newY);

        // now trigger kvo response to redraw the associated edge views
        invalidateViews();
    }

    /*
    func allNeighborsSeen()->Bool {
        for v in neighbors! {
            if let vert=v as? Vert {
                if(!vert.depthSearchSeen) {
                    return false;
                }
            }
            else {
                print("Vert cat: allNeighborsSeen: err", appendNewline: false);
            }
        }
        return true;
    }
    // public
    // finds an unseen vert, marks it as seen, and returns it
    func findUnseen()->Vert? {
        for v in neighbors! {
            if let vert=v as? Vert {
                if(!vert.depthSearchSeen) {
                    return vert;
                }
            }
            else {
                print("Vert cat: findUnseen: err self.neighbor contains object that is not vert", appendNewline: false);
            }
        }
        return nil;
    }
    */

}
