#import "CKSparkline.h"


@implementation CKSparkline

@synthesize selected;
@synthesize lineColor;
@synthesize highlightedLineColor;
@synthesize data;
@synthesize computedData;


- (id)initWithFrame:(CGRect)frame {
	
    if (self = [super initWithFrame:frame]) {
		self.selected = NO;
		self.backgroundColor = [UIColor clearColor];
        self.lineColor = [UIColor colorWithWhite:0.65 alpha:1.0];
		self.highlightedLineColor = [UIColor whiteColor];
    }
	
    return self;
}


- (void)setSelected:(BOOL)isSelected {
	
	selected = isSelected;	
	[self setNeedsDisplay];
}


- (void)setData:(NSArray *)newData {

	CGFloat max = 0.0;
	CGFloat min = FLT_MAX;
	NSMutableArray *mutableComputedData = [[NSMutableArray alloc] initWithCapacity:[newData count]];

	for (NSNumber *dataValue in newData) {
		min = MIN([dataValue floatValue], min);
		max = MAX([dataValue floatValue], max);
	}
	
	for (NSNumber *dataValue in newData) {
		NSNumber *value = [[NSNumber alloc] initWithFloat:([dataValue floatValue] - min) / (max - min + 1.0)];
		[mutableComputedData addObject:value];
		[value release];
	}
	
	[computedData release];	
	computedData = mutableComputedData;

	[data release];
	data = [newData retain];
}


- (void)drawRect:(CGRect)rect {
    
	if ([self.computedData count] < 1)
		return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat maxX = CGRectGetMaxX(rect) - 1;
	CGFloat maxY = CGRectGetMaxY(rect) - 1;
	
	CGColorRef strokeColor = [(self.selected ? self.highlightedLineColor : self.lineColor) CGColor];
	CGContextSetStrokeColorWithColor(context, strokeColor);

	CGContextBeginPath(context);				
	CGContextMoveToPoint(context, 0.0, maxY - maxY * [[computedData objectAtIndex:0] floatValue]);
	
	for (int i = 1; i < [self.computedData count]; i++) {
		CGContextAddLineToPoint(context, maxX * ((CGFloat)i / ([self.computedData count] - 1)),
								maxY - maxY * [[self.computedData objectAtIndex:i] floatValue]);
		if (i == [self.computedData count] - 1) {
			CGContextStrokePath(context);			
			CGContextSaveGState(context);
			CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
			CGContextAddRect(context, CGRectMake(maxX * ((CGFloat)i / ([self.computedData count] - 1)) - 1,
			  		   maxY - maxY * [[self.computedData objectAtIndex:i] floatValue] - 1, 
					   2, 2));
			CGContextFillPath(context);
			CGContextRestoreGState(context);
			CGContextStrokePath(context);						
		}
	}

}


- (void)dealloc {
	[data release];
	[computedData release];
    [super dealloc];
}


@end
