//
//  GraphView.m
//  Calculator
//
//  Created by Matthew Weinecke on 7/15/12.
//  Copyright (c) 2012 MTW Enterprises. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@protocol GraphViewDataSource 

-(int) graphView:(GraphView *)sender yAxisValueForX: (int) x;

@end

@implementation GraphView


- (void)setup
{
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib
{
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    //CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint midPoint; // center of our bounds in our coordinate system
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    
   [AxesDrawer drawAxesInRect:rect originAtPoint:midPoint scale:1];
}


@end
