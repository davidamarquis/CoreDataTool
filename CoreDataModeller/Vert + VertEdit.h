//
//  Vert + VertEdit.h
//  April25NotGoingWell
//
//  Created by David Marquis on 2015-05-11.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Vert.h"
#import "Edge + EdgeEdit.h"

@interface Vert (VertEdit)

+(double)MAXPosition;
-(BOOL)isNeighborOf:(Vert*) other;
-(Edge*)getSharedEdge:(Vert*)other;
-(NSNumber*)getEdgeId:(Vert*)other withError:(int*)err;

-(void)setupVert:(double)newX :(double)newY;
-(void)moveVertToX:(double)newX toY:(double)newY;

-(BOOL)isPositionEqual:(Vert*) other;

-(void)addEdge:(Edge*)edge toVert:(Vert*)v2;
-(void)removeEdge:(Edge*)edge toVert:(Vert*)v2;

// distance returns MAXPosition if self and other are not neighbors
// otherwise it returns their Euclidean distance
-(double)distance:(Vert*)other;
-(BOOL)isNeighborOf:(Vert*) other;

// getters
-(BOOL)depthSearchSeen;
-(double)x;
-(double)y;

-(BOOL)freshVertView;
-(BOOL)freshEdgeViews;

// setters
// set both X and Y at same time as this method is under KVO
-(void)setDepthSearchSeen:(BOOL)depthSearchSeen;
-(void)setX:(double)x Y:(double)y;
-(void)setFreshVertView:(BOOL)drawn;
-(void)setFreshEdgeViews:(BOOL)neighborsDrawn;

#pragma mark graph theory
// returns true if all the neighbors of the vert are marked visited
-(BOOL)allNeighborsSeen;
-(Vert*)findUnseen;

@end
