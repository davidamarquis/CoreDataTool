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
    
    return (v,w);
}

}
