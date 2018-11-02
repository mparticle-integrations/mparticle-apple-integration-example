#import <XCTest/XCTest.h>
#import "MPKitFollowAnalytics.h"

@interface mParticle_FollowAnalyticsTests : XCTestCase

@end

@implementation mParticle_FollowAnalyticsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitFollowAnalytics kitCode], @123);
}

- (void)testStarted {
    MPKitFollowAnalytics *FollowAnalyticsKit = [[MPKitFollowAnalytics alloc] init];
    [FollowAnalyticsKit didFinishLaunchingWithConfiguration:@{@"apiKey":@"12345"}];
    XCTAssertTrue(FollowAnalyticsKit.started);
}

@end
