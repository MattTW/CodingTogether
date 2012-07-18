//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Matthew Weinecke on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h" //needed to send message in segue

@interface CalculatorViewController()

@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic,strong) CalculatorBrain *brain;
@property (nonatomic,strong) NSDictionary *testVariableValues;

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize sentToTheBrain = _sentToTheBrain;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;
@synthesize testVariableValues = _testVariableValues;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (NSDictionary *)testVariableValues {
    if (!_testVariableValues) _testVariableValues = [[NSDictionary alloc] init];
    return _testVariableValues;
}


//return GraphView that is the detail of a split view, if not in split
//view, just return nil;
- (GraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[GraphViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
        if ([segue.identifier isEqualToString:@"ShowGraph"]) {
            [segue.destinationViewController setProgram:self.brain.program];
        }
}

- (IBAction)graphPressed {
    if ([self splitViewGraphViewController]) {
        //in split view with graph, just give the graph its program
        //that setter will also update the graph
        [self splitViewGraphViewController].program = self.brain.program;
        
    }
    
    //iphone storyboard directly targets segue from graph button
    //without using target action.
}

- (void)updateDisplays {
    //show the description of the program up top
    self.sentToTheBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    //show the result of running the program
    double programResult = [CalculatorBrain runProgram:self.brain.program usingVariables:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", programResult];
    
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        //only allow decimal button if display doesn't already contain a decimal
        if ([digit isEqualToString:@"."] && [self.display.text rangeOfString:@"."].location != NSNotFound) {
            return;  //pretend that nothing happened.
        }
        self.display.text = [self.display.text stringByAppendingString:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    
}

- (IBAction)enterPressed {    
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    [self updateDisplays];
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    //push operation
    [self.brain performOperation:sender.currentTitle];
    
    [self updateDisplays];
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    [self.brain pushVariable:sender.currentTitle];
    
    [self updateDisplays];
}


- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.testVariableValues = nil;
    [self.brain clearMemory];
    [self updateDisplays];
}

- (IBAction)undoPressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        int newDisplayLength = [self.display.text length] - 1;
        self.display.text = [self.display.text substringToIndex:newDisplayLength];
        if (newDisplayLength == 0) {
            self.userIsInTheMiddleOfEnteringANumber = FALSE;
            [self updateDisplays];
        }
    } else {
        [self.brain removeTopItemFromStack];
        [self updateDisplays];
    }
 
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
    [self setSentToTheBrain:nil];
    [super viewDidUnload];
}
@end
