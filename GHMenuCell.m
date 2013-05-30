//
//  GHSidebarMenuCell.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHMenuCell.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark -
#pragma mark Constants
NSString const *kSidebarCellTextKey = @"CellText";
NSString const *kSidebarCellImageKey = @"CellImage";
NSString const *kSidebarCellHighlightedImageKey = @"CellImageHighlighted";

#pragma mark -
#pragma mark Implementation
@implementation GHMenuCell

#pragma mark Memory Management
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.clipsToBounds = YES;
		
        CAGradientLayer *gradientS = [CAGradientLayer layer];
		gradientS.frame = CGRectMake(0, 0, 320, 44);
		gradientS.colors = @[
        (id)[UIColor colorWithRed:(15.0f/255.0f) green:(15.0f/255.0f) blue:(15.0f/255.0f) alpha:1.0f].CGColor,
        (id)[UIColor colorWithRed:(10.0f/255.0f) green:(10.0f/255.0f) blue:(10.0f/255.0f) alpha:1.0f].CGColor,
		];
        
		UIView *bgView = [[UIView alloc] init];
		[bgView.layer insertSublayer:gradientS atIndex:0];
		self.selectedBackgroundView = bgView;
		
        CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = CGRectMake(0, 0, 320, 44);
		gradient.colors = @[
        (id)[UIColor colorWithRed:(25.0f/255.0f) green:(25.0f/255.0f) blue:(25.0f/255.0f) alpha:1.0f].CGColor,
        (id)[UIColor colorWithRed:(20.0f/255.0f) green:(20.0f/255.0f) blue:(20.0f/255.0f) alpha:1.0f].CGColor,
		];
        UIView *statView = [[UIView alloc] init];
        [statView.layer insertSublayer:gradient atIndex:0];
        self.backgroundView = statView;
		self.imageView.contentMode = UIViewContentModeCenter;
		
		self.textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:([UIFont systemFontSize] * 1.1f)];
		self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.99f];
		self.textLabel.textColor = [UIColor colorWithRed:(155.0f/255.0f) green:(155.0f/255.0f) blue:(155.0f/255.0f) alpha:1.0f];
        self.textLabel.highlightedTextColor = [UIColor colorWithRed:(5.0f/255.0f) green:(185.0f/255.0f) blue:(255.0f/255.0f) alpha:1.0f];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(40.0f/255.0f) green:(40.0f/255.0f) blue:(40.0f/255.0f) alpha:0.7f];
		[self.textLabel.superview addSubview:topLine];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(10.0f/255.0f) green:(10.0f/255.0f) blue:(10.0f/255.0f) alpha:1.0f];
		[self.textLabel.superview addSubview:bottomLine];
	}
	return self;
}

#pragma mark UIView
- (void)layoutSubviews {
	[super layoutSubviews];
	
    if (self.imageView.image == nil) {
        self.textLabel.frame = CGRectMake(20.0f, 0.0f, 200.0f, 43.0f);
    }
    else {
        self.textLabel.frame = CGRectMake(45.0f, 0.0f, 200.0f, 43.0f);
        self.imageView.frame = CGRectMake(15.0f, 12.0f, 20.0f, 20.0f);
        [self.imageView setAlpha:0.7];
    }
	
}

@end
