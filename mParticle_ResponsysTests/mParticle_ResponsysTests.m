#import <XCTest/XCTest.h>
#import "MPKitResponsys.h"

@interface mParticle_ResponsysTests : XCTestCase

@end

@implementation mParticle_ResponsysTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitResponsys kitCode], @102);
}

- (void)testStarted {
    MPKitResponsys *exampleKit = [[MPKitResponsys alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{@"apiKey":@"12345", @"accountToken":@"12345"}];
    XCTAssertTrue(exampleKit.started);
}

@end
