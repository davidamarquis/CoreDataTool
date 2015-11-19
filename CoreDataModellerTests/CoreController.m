//
//  CoreController.m
//  CoreDataModeller
//
//  Created by David Marquis on 2015-11-12.
//  Copyright © 2015 David Marquis. All rights reserved.
//

#import "CoreController.h"
#import "CoreDataModellerTests-Swift.h"
//#import <OCMock/OCMock.h>
#import "OCMock.h"

@implementation CoreControllerTestCase

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)setDirectionTestCase {
    CoreController* controller = [[CoreController alloc] init];

    CGFloat x1 = (CGFloat)1;
    CGFloat x2 = (CGFloat)2;
    CGFloat y1 = (CGFloat)1;
    CGFloat y2 = (CGFloat)2;
    BOOL result = [controller setDirection:x1 X2:x2 Y1:y1 Y2:y2];
    XCTAssertTrue(result);
}

@end
