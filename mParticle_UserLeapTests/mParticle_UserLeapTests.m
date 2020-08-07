#import <XCTest/XCTest.h>
#import "MPKitUserLeap.h"

@interface mParticle_UserLeapTests : XCTestCase

@end

@implementation mParticle_UserLeapTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitUserLeap kitCode], @123);
}

- (void)testStarted {
    MPKitUserLeap *exampleKit = [[MPKitUserLeap alloc] init];
    [exampleKit didFinishLaunchingWithConfiguration:@{@"environmentId":@"fyi3PTZxk"}];
    XCTAssertTrue(exampleKit.started);
}

@end
