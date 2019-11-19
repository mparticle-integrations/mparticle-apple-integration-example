#import <XCTest/XCTest.h>
#import "MPKitSwrve.h"

@interface Swrve_mParticleTests : XCTestCase

@end

@implementation Swrve_mParticleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitSwrve kitCode], @216);
}

- (void)testStarted {
    MPKitSwrve *swrveKit = [[MPKitSwrve alloc] init];
    [swrveKit didFinishLaunchingWithConfiguration:@{ @"app_id": @"1", @"api_key": @"ABCDE"}];
    XCTAssertTrue(swrveKit.started);
}

@end
