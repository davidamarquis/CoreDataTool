//
//  Graph + GraphEdit.h
//  April25NotGoingWell
//
//  Created by David Marquis on 2015-05-12.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

// import the class we are extending
//#import "Graph.h"

// import everything else
#import <Foundation/Foundation.h>
#import "Vert + VertEdit.h"
#import "Edge + EdgeEdit.h"

@interface Graph (GraphEdit)

-(void)setupVert:(Vert*)vertToSetup atX:(double)xPos atY:(double)yPos;
-(Vert*)getVertById:(NSNumber*)vertId;
-(void)moveVertById:(NSNumber*)vertId toXPos:(double)endX toYPos:(double)endY;
-(void)removeVertById:(NSNumber*)vertId;

-(void)setupEdge:(Edge*)edgeToSetup from:(Vert*)vert1 to:(Vert*)vert2;
-(Edge*)getEdgeById:(NSNumber*)edgeId;
-(void)removeEdgeById:(NSNumber*)edgeId;

#pragma mark graph theory
-(BOOL)cycleExists;
-(NSMutableArray*)getCycle;

#pragma getting id array
-(void)edgeIdArray:(NSMutableArray**)edgeArray;
-(void)sortedEdgeIdArray:(NSArray**)sortedEdges;

@end
