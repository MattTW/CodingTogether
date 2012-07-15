//
//  GraphViewController.m
//  Calculator
//
//  Created by Matthew Weinecke on 7/15/12.
//  Copyright (c) 2012 MTW Enterprises. All rights reserved.
//

#import "GraphViewController.h"
#import "CalculatorBrain.h"

@interface GraphViewController ()

@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UILabel *programDisplay;

@end

@implementation GraphViewController
@synthesize graphView = _graphView;
@synthesize programDisplay = _programDisplay;
@synthesize program = _program;

//when program is set, update the program display in the view, then graph it
-(void)setProgram:(id)program {
    _program = program;
    
    //when called during segue, programDisplay/view not initialized yet so view stuff
    //is nill and will fail silently.  ViewDidLoad will update display.
    //but if this set is called after segue, this update will work.
    [self updateDisplay];
    
}

-(void)updateDisplay {
    self.programDisplay.text = [CalculatorBrain descriptionOfProgram:self.program];
    //TODO tell the view to redraw its graph for the new program
    
    //tell view to refresh its display
    [self.graphView setNeedsDisplay];

}

//once view is fully loaded, initialize display
-(void)viewDidLoad {
    [self updateDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setProgramDisplay:nil];
    [self setGraphView:nil];
    [super viewDidUnload];
}
@end
