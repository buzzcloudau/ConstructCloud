//
//  CPPageControl.m
//  ConstructCloud
//
//  Created by Ricardo Russon
//  Copyright (c) Buzz Cloud 2015 ( buzzcloud.com.au )
//  All rights reserved.
//
//	Licensed under the MIT License - http://opensource.org/licenses/MIT
//

#import "CPPageControl.h"
#import "defs.h"

// Tweak these or make them dynamic.
#define kDotDiameter 7.0
#define kDotSpacer 7.0

@implementation CPPageControl

@synthesize dotColorCurrentPage;
@synthesize dotColorOtherPage;
@synthesize delegate = _delegate;

- (NSInteger)currentPage
{
    return _currentPage;
}

- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = MIN(MAX(0, page), _numberOfPages-1);
    [self setNeedsDisplay];
}

- (NSInteger)numberOfPages
{
    return _numberOfPages;
}

- (void)setNumberOfPages:(NSInteger)pages
{
    _numberOfPages = MAX(0, pages);
    _currentPage = MIN(MAX(0, _currentPage), _numberOfPages-1);
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Default colors.
        self.backgroundColor = [UIColor clearColor];
        self.dotColorCurrentPage = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
        self.dotColorOtherPage = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
		[self setAutoresizesSubviews:NO];
		[self setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

	if (_numberOfPages > 1) {

		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetAllowsAntialiasing(context, true);

		CGContextSetLineWidth(context, 1.0);
		
		CGRect currentBounds = self.bounds;
		CGFloat dotsWidth = self.numberOfPages*kDotDiameter + MAX(0, self.numberOfPages-1)*kDotSpacer;
		CGFloat x = CGRectGetMidX(currentBounds)-dotsWidth/2;
		CGFloat y = CGRectGetMidY(currentBounds)-kDotDiameter/2;
		for (int i=0; i<_numberOfPages; i++)
		{
			CGRect circleRect = CGRectMake(x, y, kDotDiameter, kDotDiameter);
			if (i == _currentPage)
			{
				CGContextSetStrokeColor(context, CGColorGetComponents(self.dotColorOtherPage.CGColor));
				CGContextStrokeEllipseInRect(context, circleRect);
				CGContextSetFillColorWithColor(context, self.dotColorCurrentPage.CGColor);
			}
			else
			{
				CGContextSetStrokeColor(context, CGColorGetComponents(self.dotColorCurrentPage.CGColor));
				CGContextStrokeEllipseInRect(context, circleRect);
				CGContextSetFillColorWithColor(context, self.dotColorOtherPage.CGColor);
			}
			CGContextFillEllipseInRect(context, circleRect);
			x += kDotDiameter + kDotSpacer;
		}
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_delegate) return;

    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];

    CGFloat dotSpanX = self.numberOfPages*(kDotDiameter + kDotSpacer);
    CGFloat dotSpanY = kDotDiameter + kDotSpacer;

    CGRect currentBounds = self.bounds;
    CGFloat x = touchPoint.x + dotSpanX/2 - CGRectGetMidX(currentBounds);
    CGFloat y = touchPoint.y + dotSpanY/2 - CGRectGetMidY(currentBounds);

    if ((x<0) || (x>dotSpanX) || (y<0) || (y>dotSpanY)) return;

    self.currentPage = floor(x/(kDotDiameter+kDotSpacer));
    if ([self.delegate respondsToSelector:@selector(pageControlPageDidChange:)])
    {
        [self.delegate pageControlPageDidChange:self];
    }
}

@end