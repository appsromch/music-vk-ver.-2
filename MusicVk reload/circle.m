//
//  circle.m
//  circle progress
//
//  Created by David Dreval on 01.06.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "circle.h"

@interface circle () {
    CGFloat startAngle;
    CGFloat endAngle;
}

@end

@implementation circle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        // Determine our start and stop angles for the arc (in radians)
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
 //   NSString* textContent = [NSString stringWithFormat:@"%d", self.percent];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:80
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (_percent / 100.0) + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 12;
    [[UIColor colorWithWhite:0.1 alpha:0.1] setStroke];
    [bezierPath stroke];
    
    UIBezierPath* bezierPath2 = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    [bezierPath2 addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:80
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * 1 + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath2.lineWidth = 12;
    [[UIColor colorWithWhite:0.1 alpha:0.04] setStroke];
    [bezierPath2 stroke];
    
    // Text Drawing
 //   CGRect textRect = CGRectMake((rect.size.width / 2.0) - 71/2.0, (rect.size.height / 2.0) - 45/2.0, 71, 45);
 //   [[UIColor blackColor] setFill];
 //   [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"Helvetica-Bold" size: 42.5] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
}

@end
