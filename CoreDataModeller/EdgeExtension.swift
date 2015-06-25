//
//  EdgeExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-02.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

extension Edge:Printable {

override var description:String {
    // store methodName for logging errors
    // should use connects
    // not going to worry about deterministic display when there are only two elements
    //let (v:Vert,w:Vert)=Connects();
    
    //var desc:String="Edge(\(Int(v.x)),\(Int(v.y)))(\(Int(w.x)),\(Int(w.y)))";
    var desc = String();
    
    if joinedTo.count != 2 {
        desc=desc+"INCOMPLETE";
    }
    for v in joinedTo {
        if let vert:Vert=v as? Vert {
            desc=desc + "(";
            desc=desc + "\(Int(vert.x)) , \(Int(vert.y))";
            desc=desc + ")";
        }
        else {
            println("Edge cat description err");
        }
    }
    
    return desc;
}

// computed property
func length()->Float? {
    let v:Vert?;
    let w:Vert?;
    (v,w)=Connects();
    if v != nil && w != nil {
        return v!.distance(w!);
    }
    println("Edge cat: length: v or w is nil");
    return nil;
}

func angle()->Float? {
    let v:Vert?;
    let w:Vert?;
    (v,w)=Connects();
    if v != nil && w != nil {
        return Float(atan2(v!.y - w!.y, v!.x-w!.x ));
    }
        println("Edge cat: length: v or w is nil");
        return nil;
}

// not tested
func getNameForVert(vert:Vert)->String? {
    var v:Vert?;
    var w:Vert?;
    (v,w)=Connects();
    
    if v == nil || w == nil {println("Edge ext: getNameForVert: could not get pair of verts that the edge connects");}
    if vert === v! {
        return rel1name;
    }
    else if vert === w! {
        return rel1name;
    }
    else {
        println("Edge ext: getNameForVert: err");
        return nil;
    }
}

// not tested
// setNameForVert() sets the relationship name for the given vert
func setNameForVert(vert:Vert, relationshipName:String) {
    var v:Vert?;
    var w:Vert?;
    (v,w)=Connects();
    if v == nil || w == nil {println("Edge ext: getNameForVert: could not get pair of verts that the edge connects");}
    if vert === v! {
        rel1name = relationshipName;
    }
    else if vert === w! {
        rel2name = relationshipName;
    }
    else {
        println("Edge ext: setNameForVert: err");
    }
}

// not tested
func setNameForInverseOfVert(vert:Vert, relationshipName:String) {

    let inverse = vert.getNeighborOnEdge(self);
    var v:Vert?;
    var w:Vert?;
    (v,w)=Connects();
    if v == nil || w == nil {println("Edge ext: getNameForVert: could not get pair of verts that the edge connects");}
    if inverse === v! {
        rel1name = relationshipName;
    }
    else if inverse === w! {
        rel2name = relationshipName;
    }
    else {println("Edge ext: getNameForVert: err");}
}

// returns the two verts that an edge is connected to
func Connects()->(v:Vert?,w:Vert?) {
    
    // v and w: if both do not exist both will be nil
    var v:Vert?;
    var w:Vert?;
    // check that the number of verts on an edge is correct
    // this is made more important because verts can be deleted from the graph
    if joinedTo.count < 2 {
        println("Edge cat: Connects: vertArray: err edge has too few verts in joinedTo");
    }
    else if joinedTo.count > 2 {
        println("Edge cat: Connects: vertArray: err edge has too few verts in joinedTo")
    }
    else {
    
        var count:Int=0;
        for vert in joinedTo{
            if(count==0) {
                if vert is Vert {
                    v=vert as? Vert;
                }
                else {
                    println("Edge cat: Connects(): err");
                }
            }
            else {
                if vert is Vert {
                    w=vert as? Vert;
                }
                else {
                    println("Edge cat: Connects(): err");
                }
            }
            count++;
        }
    }
    
    // ordering of verts: verts are almost always ordered by their x-coord. In the unlikely event of a tie they are ordered by their y-coord
    if v!.x < w!.x {
        return (v,w);
    }
    else if v!.x > w!.x {
        return (w,v);
    }
    else {
        if v!.y < w!.y {
            return (v,w);
        }
        else if v!.y > w!.y {
            return (w,v);
        }
        else {
            println("Edge extension: connects(): err: v and w have the same x and y values");
        }
    }
    return (v,w); // not called just to suppress compiler warnings.
}

}
