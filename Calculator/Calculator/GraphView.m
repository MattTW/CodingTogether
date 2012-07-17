//
//  GraphView.m
//  Calculator
//
//  Created by Matthew Weinecke on 7/15/12.
//  Copyright (c) 2012 MTW Enterprises. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize scale = _scale;
@synthesize origin = _origin;

#define DEFAULT_SCALE 10  //pixels per unit

- (CGPoint)origin {
    if (!_origin.x) {
        // center of our bounds in our coordinate system
        _origin.x = self.bounds.origin.x + self.bounds.size.width/2;
    }
    if (!_origin.y) {
        _origin.y = self.bounds.origin.y + self.bounds.size.height/2;
    }
 
    return _origin;
}

- (void)setOrigin:(CGPoint)origin {
    if (origin.x != _origin.x ||
        origin.y != _origin.y) {
        _origin = origin;
        [self setNeedsDisplay];
    }
}

- (CGFloat)scale {
    if (!_scale) {
        return DEFAULT_SCALE; // don't allow zero scale
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}

- (void)setup {
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib {
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
   [AxesDrawer drawAxesInRect:rect originAtPoint:self.origin scale:self.scale];

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGContextSetLineWidth(context, 2.0);
    [[UIColor redColor] setStroke];

    //in the rect we are asked to redraw, go through each x pixel and
    //find the corresponding y pixel to graph
    int startXPoint = rect.origin.x;
    int endXPoint = rect.origin.x + rect.size.width;
    for (int currentXPoint = startXPoint; currentXPoint <= endXPoint; currentXPoint++) {
        //convert our X pixel to x graph value
        double currentXUnit = (currentXPoint - self.origin.x)/self.scale;
        
        //ask our datasource for the corresponding x unit
        double currentYUnit = [self.dataSource graphView:self yAxisValueForX:currentXUnit];
        
        //convert returned Y value back to pixels
        int currentYPoint = self.origin.y - (currentYUnit * self.scale);
        
        //NSLog(@"Gonna draw a line from last point to x:%i y:%i",currentXPoint,currentYPoint);
        //now draw it
        if (currentXPoint != startXPoint) { 
            CGContextAddLineToPoint(context, currentXPoint, currentYPoint);
        } else {
            CGContextMoveToPoint(context, currentXPoint, currentYPoint);
        }

    }
    CGContextStrokePath(context);
    
    UIGraphicsPopContext();

}


- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        self.origin = CGPointMake(self.origin.x + translation.x, self.origin.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

- (void)tapNewOrigin:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.origin = [gesture locationInView:self];
    }
}

@end
