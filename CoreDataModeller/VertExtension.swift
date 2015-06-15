//
//  VertExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation

extension Vert:Printable {

// computed property
class func MAXPosition()->Float {
    var maxPos:Float=1000;
    return maxPos;
}

override var description:String {
    // store methodName for logging errors
    var desc:String="Vert(\(Int(x)),\(Int(y)))[";
    let nghs:Array<Vert> = self.neighbors.allObjects as! Array<Vert>;
    let n:Int=self.neighbors.count;
    var i:Int;

    // first n-1 elems and last elem slightly different formatting
    for i=0;i<n-1;i++ {
        desc=desc+"(\(Int(nghs[i].x)),\(Int(nghs[i].y))),";
    }
    desc=desc+"(\(Int(nghs[i].x)),\(Int(nghs[i].y)))]";

    return desc;
}

func isNeighborOf(other:Vert)->Bool {

    if(self.neighbors.containsObject(other) && other.neighbors.containsObject(self)) {
        return true;
    }
    else if self.neighbors.containsObject(other) {
        return true;
    }
    else {
        return false;
    }
}

func getSharedEdge(other: Vert)->Edge? {
    if(!self.isNeighborOf(other)) {
        return nil;
    }
    
    for e1 in self.edges {
        for e2 in other.edges {
            if(e1 is Edge && e2 is Edge )
            {
                // Note in swift this is an equality test not an identity test
                if(e1===e2) {
                    return e1 as? Edge;
                }
            }
        }
    }
    return nil;
}

func isPositionEqual(other: Vert)->Bool {
    // TO DO: this comparison of doubles is bad
    if((self.x==other.x) && (self.y==other.y)) {
        return true;
    }
    else {
        return(false);
    }
}
// addEdge sets up a new edge
func AddEdge(edgeOrNil:Edge?, toVert vertOrNil:Vert?)  {

    if(edgeOrNil != nil && vertOrNil != nil) {
        // check if the verts already have an edge
        if (neighbors as Set).contains(vertOrNil!) {
            //
        }
        
        var manyRelation:AnyObject? = self.valueForKeyPath("neighbors") ;
        if manyRelation is NSMutableSet {
            (manyRelation as! NSMutableSet).addObject(vertOrNil!);
        }
        
        // update edges on self and other
        edges=edges.setByAddingObject(edgeOrNil!);
        vertOrNil!.edges=vertOrNil!.edges.setByAddingObject(edgeOrNil!);
        
        edgeOrNil!.joinedTo=edgeOrNil!.joinedTo.setByAddingObject(vertOrNil!);
        edgeOrNil!.joinedTo=edgeOrNil!.joinedTo.setByAddingObject(self);
        
        freshEdges=false;
        vertOrNil!.freshEdges=false;
        finishedObservedMethod=true;
        vertOrNil!.finishedObservedMethod=true;
    }
    else {
    
    }
}

func removeEdge(edgeOrNil:Edge?, vertOrNil:Vert?) {
    if(edgeOrNil != nil && vertOrNil != nil) {
        
        // neighbors is a bidirectional relationship
        //TODO: 9:30pm June 12 neighbors=neighbors.setByAddingObject(vertOrNil!);
        var manyRelation:AnyObject? = self.valueForKeyPath("neighbors") ;
        if manyRelation is NSMutableSet {
            (manyRelation as! NSMutableSet).removeObject(vertOrNil!);
        }
        
        // joinedTo updated by next line
        edges=edges.setByRemovingObject(edgeOrNil!);
        
        // joinedTo updated by next line
        vertOrNil!.edges=vertOrNil!.edges.setByRemovingObject(edgeOrNil!);
        
        edgeOrNil!.joinedTo=edgeOrNil!.joinedTo.setByRemovingObject(vertOrNil!);
        edgeOrNil!.joinedTo=edgeOrNil!.joinedTo.setByRemovingObject(self);
        
        freshEdges=false;
        vertOrNil!.freshEdges=false;
        finishedObservedMethod=true;
        vertOrNil!.finishedObservedMethod=true;
    }
    else {
    
    }
}

func distance(other:Vert)->Float{
    if(self.isNeighborOf(other)) {
        var x1:Float=self.x;
        var x2:Float=other.x;
        var y1:Float=self.y;
        var y2:Float=other.y;
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
    if edges.count > 0 {
        freshEdges=false;
    }
    freshViews=false;
}

// change vert position in data model
func moveVertTo(newX:Float, _ newY:Float) {
    invalidateViews();
    x=newX;
    y=newY;
    // no verts have been seen
    // set here so outside classes don't get confused about vert state
    // @search algos: set this flag to false at start when executed
    depthSearchSeen=false;
    finishedObservedMethod=true;
}

func allNeighborsSeen()->Bool {
    for v in self.neighbors {
        if let vert=v as? Vert {
            if(!vert.depthSearchSeen) {
                return false;
            }
        }
        else {
            print("Vert cat: allNeighborsSeen: err");
        }
    }
    return true;
}
// public
// finds an unseen vert, marks it as seen, and returns it
func findUnseen()->Vert? {
    for v in self.neighbors {
        if let vert=v as? Vert {
            if(!vert.depthSearchSeen) {
                return vert;
            }
        }
        else {
            print("Vert cat: findUnseen: err self.neighbor contains object that is not vert");
        }
    }
    return nil;
}

}
