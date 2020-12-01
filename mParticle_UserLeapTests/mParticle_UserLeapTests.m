#import <XCTest/XCTest.h>
#import "MPKitUserLeap.h"

@interface mParticle_UserLeapTests : XCTestCase

@end

@implementation mParticle_UserLeapTests

static MPKitUserLeap *kit;

- (void)setUp {
    if (!kit) {
        kit = [[MPKitUserLeap alloc] init];
        [kit didFinishLaunchingWithConfiguration:@{@"environmentId":@"someEnvironmentId"}];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

#pragma mark - Tests

- (void)testModuleID {
    XCTAssertEqualObjects([MPKitUserLeap kitCode], @1169);
}

- (void)testStarted {
    XCTestExpectation *exp = [[XCTestExpectation alloc] initWithDescription:@"desc"];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (kit.started) [exp fulfill];
    }];
    XCTWaiterResult result = [XCTWaiter waitForExpectations:@[exp] timeout:5];
    XCTAssertEqual(result, XCTWaiterResultCompleted);
    XCTAssertTrue(kit.started);
    XCTAssertNotNil(kit.providerKitInstance);
    [timer invalidate];
}

- (void)testInvalidEnvironmentIdTypeReturnsFalse {
    MPKitUserLeap *invalidKit = [[MPKitUserLeap alloc] init];
    MPKitExecStatus *status = [invalidKit didFinishLaunchingWithConfiguration:@{@"_environmentId":@"thekeyisinvalid"}];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeRequirementsNotMet);
}

- (void)testSetAttributesWithStringValueReturnsSuccess {
    MPKitExecStatus *status = [kit setUserAttribute:@"key" value:@"value"];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

- (void)testSetAttributesWithNumberValueReturnsSuccess {
    MPKitExecStatus *status = [kit setUserAttribute:@"key" value:@1];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

- (void)testSetAttributesWithArrayReturnsFalse {
    MPKitExecStatus *status = [kit setUserAttribute:@"key" value:@[@"value"]];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeUnavailable);
}

- (void)testSetAttributesWithDictionaryReturnsFalse {
    MPKitExecStatus *status = [kit setUserAttribute:@"key" value:@{@"value":@1}];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeUnavailable);
}

- (void)testSetEmailAddressReturnsTrue {
    MPKitExecStatus *status = [kit setUserIdentity:@"someEmail@gmail.com" identityType:MPUserIdentityEmail];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

- (void)testSetCustomerIdReturnsTrue {
    MPKitExecStatus *status = [kit setUserIdentity:@"anything" identityType:MPUserIdentityCustomerId];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

- (void)testSetUserTagReturnsTrue {
    MPKitExecStatus *status = [kit setUserTag:@"something"];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

- (void)testLogEventReturnsSuccess {
    MPBaseEvent *event = [[MPBaseEvent alloc] initWithEventType:MPEventTypeAddToCart];
    event.messageType = MPMessageTypeEvent;
    MPKitExecStatus *status = [kit logBaseEvent:event];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

- (void)testLogCommerceEventReturnsSuccess {
    MPBaseEvent *event = [[MPBaseEvent alloc] initWithEventType:MPEventTypeAddToCart];
    event.messageType = MPMessageTypeCommerceEvent;
    MPKitExecStatus *status = [kit logBaseEvent:event];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

- (void)testLogOtherEventReturnsUnsupported {
    MPBaseEvent *event = [[MPBaseEvent alloc] initWithEventType:MPEventTypeAddToCart];
    event.messageType = MPMessageTypeMedia;
    MPKitExecStatus *status = [kit logBaseEvent:event];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeUnavailable);
}

- (void)testLogoutReturnsSuccess {
    MPKitExecStatus *status = [kit logout];
    XCTAssertEqual(status.returnCode, MPKitReturnCodeSuccess);
}

@end
