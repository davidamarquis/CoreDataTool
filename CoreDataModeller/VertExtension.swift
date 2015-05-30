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
class func MAXPosition()->Int {
    return 1000;
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
        return false;
    }
}
// addEdge sets up a new edge
func addEdge(edge:Edge, toVert vert:Vert)  {
    // neighbors is a bidirectional relationship
    neighbors.setByAddingObject(vert);
    edges.setByAddingObject(edge);
    vert.edges.setByAddingObject(edge);
    
    freshEdges=false;
    finishedObservedMethod=true;
}

func removeEdge(edge:Edge, toVert:Vert) {
    // CD will handle removal of self from v2 automatically
    neighbors.
    
    // edge sets of the two verts are distinct so need removes for both verts
    [self removeEdgeObject:edge];
    [v2 removeEdgeObject:edge];
    
    [self setFreshEdgeViews:NO];
    self.finishedObservedMethod=[[NSNumber alloc] initWithBool:YES];
}


// public
func distance(other:Vert)->double{
    if([self isNeighborOf:other]) {
        var x1=self.x;
        var x2=other.x;
        var y1=self.y;
        var y2=other.y;
        return sqrt(pow(x1-x2,2)+pow(y1-y2,2));
    }
    else {
        // like infinity
        return [[Vert class] MAXPosition];
    }
}

# pragma mark Core updates
# pragma mark -
// public
// change Fresh flags so VC must redraw (i.e. trigger a redraw of corresponding view)
func invalidateViews {
    [self setFreshVertView:NO];
    [self setFreshEdgeViews:NO];
}

// public
func setupVert:(double)newX :(double)newY {
    // core
    [self invalidateViews];
    [self setX:newX Y:newY];
    // no verts have been seen. Setting here is done only so outside classes will get correct information if they access this property:
    // all search algos will set this flag to NO at start and end of their run
    [self setDepthSearchSeen:NO];
}

// public
// change vert position in data model
func moveVertToX(newX:double newY:double)  {
    self.invalidateViews();
    self setX:newX Y:newY];
}

#pragma mark GraphTheory
// public
func allNeighborsSeen->Bool {
    for(v in self.neighbor) {
        if([v isKindOfClass:[Vert class]]) {
            Vert* vert=(Vert*)v;
            if(!vert.depthSearchSeen) {
                return false;
            }
        }
        else {
            NSLog(@"Vert cat: allNeighborsMarked: err self.neighbor contains object that is not vert");
        }
    }
    return true;
}
// public
// finds an unseen vert, marks it as seen, and returns it
func findUnseen {
    for(id v in self.neighbor) {
        if([v isKindOfClass:[Vert class]]) {
            Vert* vert=(Vert*)v;
            if(!vert.depthSearchSeen) {
                return vert;
            }
        }
        else {
            NSLog(@"Vert cat: findUnseen: err self.neighbor contains object that is not vert");
        }
    }
    return nil;
}

}
