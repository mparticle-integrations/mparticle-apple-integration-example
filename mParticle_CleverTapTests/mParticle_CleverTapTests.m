#import <XCTest/XCTest.h>
#import "MPKitCleverTap.h"

@interface mParticle_CleverTapTests : XCTestCase

@end

@implementation mParticle_CleverTapTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitCleverTap kitCode], @123);
}0

- (void)testStarted {
    MPKitCleverTap *clevertapKit = [[MPKitCleverTap alloc] init];
    [clevertapKit didFinishLaunchingWithConfiguration:@{@"<dictionary key to retrieve API Key>":@"12345"}];
    XCTAssertTrue(clevertapKit.started);
}

@end
