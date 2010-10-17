#import <GHUnitIOS/GHUnitIOS.h>

@interface MyTest : GHTestCase { }
@end

@implementation MyTest   

- (void)testFoo {
    // Assert a is not NULL, with no custom error description
    GHAssertNotNULL(a, nil);
}

@end