//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Matthew Weinecke on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

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

- (void)viewDidUnload {
    [self setSentToTheBrain:nil];
    [super viewDidUnload];
}
@end
