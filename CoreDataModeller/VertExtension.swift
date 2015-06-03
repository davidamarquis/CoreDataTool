//
//  VertExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-05-28.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import Foundation

extension Vert {

// computed property
class func MAXPosition()->Double {
    var maxPos:Double=1000;
    return maxPos;
}

func isNeighborOf(other:Vert)->Bool {
    if(self.neighbors.containsObject(other) && other.neighbors.containsObject(self))
    {
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
func addEdge(edgeOrNil:Edge?, toVert vertOrNil:Vert?)  {

    if let edge=edgeOrNil, let vert=vertOrNil {
        // neighbors is a bidirectional relationship
        neighbors.setByAddingObject(vert);
        edges.setByAddingObject(edge);
        vert.edges.setByAddingObject(edge);
        
        freshEdges=false;
        finishedObservedMethod=true;
    }
    else {
    
    }
}

func removeEdge(edge:Edge, vert:Vert) {
    // CD will handle removal of self from v2 automatically
    neighbors.setByRemovingObject(vert);
    edges.setByRemovingObject(edge);
    vert.edges.setByRemovingObject(edge);
    
    freshEdges=false;
    finishedObservedMethod=true;
}

func distance(other:Vert)->Double{
    if(self.isNeighborOf(other)) {
        var x1:Double=self.x;
        var x2:Double=other.x;
        var y1:Double=self.y;
        var y2:Double=other.y;
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
    self.freshEdges=false;
    self.freshViews=false;
}

// change vert position in data model
func moveVertTo(newX:Double, _ newY:Double) {
    invalidateViews();
    x=newX;
    y=newY;
    // no verts have been seen
    // set here so outside classes don't get confused about vert state
    // @search algos: set this flag to false at start when executed
    depthSearchSeen=false;
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
