//
//  Graph + GraphEdit.m
//  April25NotGoingWell
//
//  Created by David Marquis on 2015-05-12.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

#import "Graph + GraphEdit.h"
// private methods are contained in another category
#import "Graph + PrivateCatMethods.h"

@implementation Graph (GraphEdit)

// public
-(void)setupVert:(Vert*)vertToSetup atX:(double)xPos atY:(double)yPos {
    // vertViewIds are 0 indexed. Warning: setting of ids should be guarded against the deletion of managed verts from but is not currently
  
    if(self.vert==nil) {
        NSLog(@"setupVert Graph cat: err self.vert is nil");
    }
    // add to set
    [self addVertObject:vertToSetup];
    
    long vertId=[self.vert count]-1;
    vertToSetup.vertViewId=[[NSNumber alloc] initWithUnsignedLong:vertId];
    [vertToSetup setupVert:xPos :yPos];
}

// public
-(Vert*)getVertById:(NSNumber*)vertId {
    int idAsInt=[vertId intValue];
    
    // check id
    if(idAsInt<0 || [self.vert count]<=idAsInt) {
        NSLog(@"getVertById: err id argument is too large or small");
        return nil;
    }
    // search for matching id
    for(id v in self.vert) {
        if([v isKindOfClass:[Vert class]]) {
            Vert* vert=(Vert*)v;
            if([vert.vertViewId isEqualToNumber:vertId]){
                return vert;
            }
        }
    }
    return nil;
}

// public
-(void)moveVertById:(NSNumber*)vertId toXPos:(double)endX toYPos:(double)endY {
    Vert* v=[self getVertById:vertId];
    // check v
    if(v==nil) {
        NSLog(@"moveVertById err: no vert found");
    }
    [v moveVertToX:endX toY:endY];
}

// public
-(void)removeVertById:(NSNumber*)vertId {
    // TO DO
}

# pragma mark edges
// public
-(void)setupEdge:(Edge*)edgeToSetup from:(Vert*)vert1 to:(Vert*)vert2 {
    if(self.edge==nil) {
        NSLog(@"setupVert Graph cat: err self.vert is nil");
    }
    // add to edge set
    [self addEdgeObject:edgeToSetup];
    long edgeId=[self.edge count]-1;
    edgeToSetup.edgeViewId=[[NSNumber alloc] initWithUnsignedLong:edgeId];
    // adding an edge sets vert1 and vert2 to be neighbors joined by the edge e
    [vert1 addEdge:edgeToSetup toVert:vert2];
}

// public
-(Edge*)getEdgeById:(NSNumber*)edgeId {
    int idAsInt=[edgeId intValue];
    
    // check id
    if(idAsInt<0 || [self.edge count]<=idAsInt) {
        NSLog(@"getVertById: err id argument is too large or small");
        return nil;
    }
    // search for matching id
    for(id e in self.edge) {
        if([e isKindOfClass:[Edge class]]) {
            Edge* edge=(Edge*)e;
            if([edge.edgeViewId isEqualToNumber:edgeId]){
                return edge;
            }
        }
    }
    return nil;
}

// public
-(void)removeEdgeById:(NSNumber*)edgeId {
    // TO DO
}

#pragma mark testing methods

// returns an array of the form [id1, id2] where the elements are ints
-(void)edgeIdArray:(NSMutableArray**)edgeArray {
    if(*edgeArray==nil) {
        *edgeArray=[[NSMutableArray alloc] init];
    }
    Vert* v, * w;
    Edge* edge;
    for(id e in self.edge) {
        // check that the elements of the edge array have the correct type
        if(![e isKindOfClass:[Edge class]]) {
            NSLog(@"Graph cat: edgeIdArray: err edge contains object that is not Edge");
        }
        edge=(Edge*)e;
        // pass in pointers to two verts
        [edge connects:&v And:&w];
        // create a pair of verts
        NSArray* vertPair=[NSArray arrayWithObjects:v.vertViewId,w.vertViewId, nil];
        
        [*edgeArray addObject:vertPair];
    }
    // test: try to print everything in the array
    for(id idPair in *edgeArray) {
        //NSArray* pair=(NSArray*)idPair;

    }
}

-(void)sortedEdgeIdArray:(NSArray**)sortedEdges {
    NSMutableArray* mutableEdges;
    
    [self edgeIdArray:&mutableEdges];
    if(mutableEdges==nil) {
        sortedEdges=nil;
    }
    NSArray* edges=[NSArray arrayWithArray:mutableEdges];
    
    *sortedEdges = [edges sortedArrayUsingComparator:
    ^NSComparisonResult(id obj1, id obj2) {
        NSArray * idPair0,* idPair1;
        NSNumber * id00, * id01, * id10, * id11;
        // first vert in first edge, second vert in first edge, etc
        
        // TO DO fix suicidal casts
        idPair0=(NSArray*)obj1;
        idPair1=(NSArray*)obj2;
        id00=(NSNumber*)idPair0[0];
        id01=(NSNumber*)idPair0[1];
        id10=(NSNumber*)idPair1[0];
        id11=(NSNumber*)idPair1[1];
        
        if ([id00 intValue] < [id10 intValue]) {
            return NSOrderedAscending;
        }
        else if ([id00 intValue] > [id10 intValue]) {
            return NSOrderedDescending;
        }
        else {
            if([id01 intValue] < [id11 intValue]) {
                return NSOrderedAscending;
            }
            else if([id01 intValue] > [id11 intValue]) {
                return NSOrderedDescending;
            }
            else {
                return NSOrderedSame;
            }
        }
    }];
}

// NSObject override
-(NSString*)description {
    // store methodName for logging errors
    NSMutableString* description=[[NSMutableString alloc] initWithFormat:@"#V(G)=%lu    ",[self.vert count]];
    NSArray* edges;
    NSString* pairString;

    // get an array of "edge pairs"
    [self sortedEdgeIdArray:&edges];
    
    for(id p in edges) {
        if(![p isKindOfClass:[NSArray class]]) {
            NSLog(@"Graph cat: description: err");
            return nil;
        }
        NSArray* pair=(NSArray*)p;
        NSString* vertPairString=[NSString stringWithFormat:@"[%d %d],",[(NSNumber*)pair[0] intValue],[(NSNumber*)pair[1] intValue] ];
        [description appendString:vertPairString];
    }
    return description;
}

#pragma mark graph theory
// returns YES if a cycle exists in the graph and NO otherwise
// tests if graph has any cycles by recursively calling [cycleExistsExcludingEdgeBetween:v And:w]
-(BOOL)cycleExists {
    int depth=0;
    // start with arbitrary vert
    Vert* current=[self.vert anyObject];
    return [self cycleExistsExcludingEdgeBetween:current And:nil :depth];
}

// returns a cycle if one exists
-(NSMutableArray*)getCycle {
    int depth=0;
    // start with arbitrary vert
    Vert* current=[self.vert anyObject];
    NSMutableArray* edgePairs=[[NSMutableArray alloc] init];
    [self addEdgeToCycleIfCycleExistsExcludingEdgeBetween:current And:nil :depth OnEdges:edgePairs];
    // clean up model
    for(id v in self.vert) {
        if(![v isKindOfClass:[Vert class]]) {
            NSLog(@"graph cat: getCycle: self.vert contains elements that are not verts");
        }
        Vert* vert=(Vert*)v;
        [vert setDepthSearchSeen:NO];
    }
    return edgePairs;
}

@end
