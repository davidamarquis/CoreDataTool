//
//  Edge + EdgeEdit.h
//  April25NotGoingWell
//
//  Created by David Marquis on 2015-05-22.
//  Copyright (c) 2015 David Marquis. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "Edge.h"

@interface Edge (EdgeEdit) 
// broken?
-(NSArray*)vertArray;

// pass in the two verts and assign them
// deterministic ?
-(void)connects:(Vert**)v And:(Vert**)w;

@end
