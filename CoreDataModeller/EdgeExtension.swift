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

// pass in two empty verts and this method will assign them
func Connects()->(v:Vert,w:Vert) {

    var v=Vert();
    var w=Vert();
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
                if let castVert=vert as? Vert {
                    v=castVert;
                }
                else {
                    println("Edge cat: Connects(): err");
                }
            }
            else {
                if let castVert=vert as? Vert {
                    w=castVert;
                }
                else {
                    println("Edge cat: Connects(): err");
                }
            }
            count++;
        }
    }
    
    return (v,w);
}

/*
// returns an array of two Verts that the edge is joined to
-(NSArray*)vertArray {
    Vert* vert;
    NSArray* vertPair;
    // check that the number of verts on an edge is correct
    // this is made more important because verts can be deleted from the graph
    if( [self.joinedTo count]!=2 ) {
        NSLog(@"Edge cat: vertArray: err edge has too many verts in joinedTo");
    }
    // convert the joinedTo NSSet to an NSArray so that the elements can be accessed by their index
    vertPair=[[NSMutableArray alloc] init];
    for(id v in self.joinedTo) {
        if(![v isKindOfClass:[Vert class]]) {
            NSLog(@"Graph cat: err vert on edge contains object that is not Vert");
            return nil;
        }
        vert=(Vert*)v;
        
        [vertPair arrayByAddingObject:vert];
    }        
    // append the description of the edge
    return vertPair;
}

*/
}
