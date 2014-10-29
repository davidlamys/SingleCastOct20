//
//  SingleCastOct20Tests.swift
//  SingleCastOct20Tests
//
//  Created by David Lam on 20/10/14.
//  Copyright (c) 2014 David Lam. All rights reserved.
//

import UIKit
import XCTest

class SingleCastOct20Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}



/*
- (void)invokeBackgroundSessionCompletionHandler {
[self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];

if (!count) {
MTAppDelegate *applicationDelegate = (MTAppDelegate *)[[UIApplication sharedApplication] delegate];
void (^backgroundSessionCompletionHandler)() = [applicationDelegate backgroundSessionCompletionHandler];

if (backgroundSessionCompletionHandler) {
[applicationDelegate setBackgroundSessionCompletionHandler:nil];
backgroundSessionCompletionHandler();
}
}
}];
}
*/