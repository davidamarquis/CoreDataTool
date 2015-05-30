//
//  Vert + VertEdit.m
//  April25NotGoingWell
//
//  Created by David Marquis on 2015-05-11.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

#import "Vert + VertEdit.h"
#import "PFVert.h"
#import <Parse/Parse.h>

@implementation Vert (VertEdit)

// public
-(void)addEdge:(Edge*)edge toVert:(Vert *)v2  {
    // CD will handle addition of self from v2 automatically
    [self addNeighborObject:v2];

    [self addEdgeObject:edge];
    [v2 addEdgeObject:edge];
    
    [self setFreshEdgeViews:NO];
    self.finishedObservedMethod=[[NSNumber alloc] initWithBool:YES];
}

// public
-(void)removeEdge:(Edge*)edge toVert:(Vert *)v2 {
    // CD will handle removal of self from v2 automatically
    [self removeNeighborObject:v2];
    // edge sets of the two verts are distinct so need removes for both verts
    [self removeEdgeObject:edge];
    [v2 removeEdgeObject:edge];
    
    [self setFreshEdgeViews:NO];
    self.finishedObservedMethod=[[NSNumber alloc] initWithBool:YES];
}

// public
-(double)distance:(Vert*)other {
    if([self isNeighborOf:other]) {
        double x1=self.x;
        double x2=other.x;
        double y1=self.y;
        double y2=other.y;
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
-(void)invalidateViews {
    [self setFreshVertView:NO];
    [self setFreshEdgeViews:NO];
}

// public
-(void)setupVert:(double)newX :(double)newY {
    // core
    [self invalidateViews];
    [self setX:newX Y:newY];
    // no verts have been seen. Setting here is done only so outside classes will get correct information if they access this property:
    // all search algos will set this flag to NO at start and end of their run
    [self setDepthSearchSeen:NO];
}

// public
// change vert position in data model
-(void)moveVertToX:(double)newX toY:(double)newY  {
    [self invalidateViews];
    [self setX:newX Y:newY];
}

#pragma mark GraphTheory
// public
-(BOOL)allNeighborsSeen {
    for(id v in self.neighbor) {
        if([v isKindOfClass:[Vert class]]) {
            Vert* vert=(Vert*)v;
            if(!vert.depthSearchSeen) {
                return NO;
            }
        }
        else {
            NSLog(@"Vert cat: allNeighborsMarked: err self.neighbor contains object that is not vert");
        }
    }
    return YES;
}
// public
// finds an unseen vert, marks it as seen, and returns it
-(Vert*)findUnseen {
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

/* TO DO KVO for parse
# pragma mark parse KVO
# pragma mark -
// private
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.parseObjId=((PFVert*)object).parseObjId;
}
// private?
-(void)dealloc {
    if(self.parseObj) {
        [self.parseObj removeObserver:self forKeyPath:@"parseObjId"];
    }
}
*/

@end
