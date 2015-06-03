//
//  EdgeExtension.swift
//  CoreDataModeller
//
//  Created by David Marquis on 2015-06-02.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

import UIKit

extension Edge {
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

// pass in two empty verts and this method will assign them
-(void)connects:(Vert**)v And:(Vert**)w {

    // check that the number of verts on an edge is correct
    // this is made more important because verts can be deleted from the graph
    if( [self.joinedTo count]!=2 ) {
        NSLog(@"Edge cat: vertArray: err edge has too many verts in joinedTo");
    }

    int count=0;
    
    for(id vert in self.joinedTo) {
        if(![vert isKindOfClass:[Vert class]]) {
            NSLog(@"Graph cat: connects:And: vert on edge contains object that is not Vert");
        }
        if(count==0) {
            *v=(Vert*)vert;
        }
        else {
            *w=(Vert*)vert;
        }
        count++;
    }
}
*/
}
