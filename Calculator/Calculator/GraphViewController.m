//
//  GraphViewController.m
//  Calculator
//
//  Created by Matthew Weinecke on 7/15/12.
//  Copyright (c) 2012 MTW Enterprises. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController() <GraphViewDataSource, UISplitViewControllerDelegate> 

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *splitViewBarButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *programDescriptionDisplay;

@end

@implementation GraphViewController
@synthesize graphView = _graphView;
@synthesize toolbar = _toolbar;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;
@synthesize programDescriptionDisplay = _programDescriptionDisplay;
@synthesize program = _program;

//when program is set, update the program display in the view, then graph it
-(void)setProgram:(id)program {
    _program = program;
    
    //if during segue, programDisplay/view not initialized
    //view stuff is nill so updateDisplay will do nothing
    //ViewDidLoad will update display in this case.
    //If this set is called after segue, this update will work.
    [self updateDisplay];
    
}

-(void)setGraphView:(GraphView *)graphView {
    _graphView = graphView;
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tapNewOrigin:)];
    tap.numberOfTapsRequired = 3;   
    [self.graphView addGestureRecognizer:tap];
    self.graphView.dataSource = self;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
        if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.splitViewBarButtonItem = nil;
}

-(void)updateDisplay {
    NSString *programDesc = [CalculatorBrain descriptionOfProgram:self.program];
    if (self.splitViewController) {
        self.programDescriptionDisplay.title = programDesc;
    } else if (self.navigationController) {
        self.title = programDesc;
    }//technically we need another place to display prog
      //desc if not inside a nav or split controller, not doing that
      //for assignment.
    
    //tell view to refresh its display
    [self.graphView setNeedsDisplay];

}

-(double) graphView:(GraphView *)sender yAxisValueForX:(double)x {    
    //ask calculator brain to run the program using the given x value
    NSNumber *xNumber = [NSNumber numberWithDouble:x];
    NSDictionary *dictionaryWithX = [NSDictionary dictionaryWithObject:xNumber forKey: @"x"];
    double result = [CalculatorBrain runProgram:self.program usingVariables:dictionaryWithX];
    //NSLog(@"When x=%g, I think y should be %g", x, result);
    return result;
}

//once view is fully loaded, initialize display
-(void)viewDidLoad {
    if (self.splitViewController) {
        self.splitViewController.delegate = self;
    }
    [self updateDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.splitViewController) { //in split view?  
        return YES;
    } else {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
}

- (void)viewDidUnload {
    [self setGraphView:nil];
    [self setToolbar:nil];
    [self setProgramDescriptionDisplay:nil];
    [super viewDidUnload];
}
@end
