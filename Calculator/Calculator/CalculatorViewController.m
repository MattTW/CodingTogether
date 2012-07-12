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
@synthesize variableValueDisplay = _variableValueDisplay;
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
    
    self.sentToTheBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}

- (IBAction)enterPressed {    
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
    
    self.sentToTheBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];

}

- (void)updateVariableValueDisplay {
    self.variableValueDisplay.text = @""; //clear anything already in there
    for (NSString *currentVar in [CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        NSString *currentValue = [[self.testVariableValues valueForKey:currentVar] stringValue];
        if (!currentValue) currentValue = @"0";
        self.variableValueDisplay.text = [self.variableValueDisplay.text stringByAppendingFormat:@"%@ = %@ ",currentVar,currentValue];
    }
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    //push operation
    [self.brain performOperation:sender.currentTitle];
    
    //update display, including current variable values
    self.display.text = [NSString stringWithFormat:@"%g", [CalculatorBrain runProgram:self.brain.program usingVariables:self.testVariableValues]];
    
    //update the display that shows what was sent to the brain
    self.sentToTheBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    [self updateVariableValueDisplay];
}

- (IBAction)variablePressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    [self.brain pushVariable:sender.currentTitle];
    self.sentToTheBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
}


- (IBAction)clearPressed {
    self.sentToTheBrain.text = @"";
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearMemory];
}

- (void)viewDidUnload {
    [self setSentToTheBrain:nil];
    [self setVariableValueDisplay:nil];
    [super viewDidUnload];
}
@end
