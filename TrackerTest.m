#import <GHUnitIOS/GHUnitIOS.h>
#import "Tracker.h"


@interface TrackerTest : GHTestCase { }
@end

@implementation TrackerTest

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}   

- (void)testICanCreateATracker {
    GHAssertNotNULL([[Tracker alloc] initWithManagedObjectContext:nil], @"Tracker is nil");
}

@end