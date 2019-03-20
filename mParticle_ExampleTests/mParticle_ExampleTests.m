#import <XCTest/XCTest.h>
#import "MPKitPilgrim.h"


@interface mParticle_ExampleTests : XCTestCase

@end

@implementation mParticle_ExampleTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitPilgrim kitCode], @211);
}

@end
