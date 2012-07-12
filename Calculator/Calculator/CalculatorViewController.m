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

- (void)updateVariableValueDisplay {
    self.variableValueDisplay.text = @""; //clear anything already in there
    for (NSString *currentVar in [CalculatorBrain variablesUsedInProgram:self.brain.program]) {
        NSString *currentValue = [[self.testVariableValues valueForKey:currentVar] stringValue];
        if (!currentValue) currentValue = @"0";
        self.variableValueDisplay.text = [self.variableValueDisplay.text stringByAppendingFormat:@"%@ = %@ ",currentVar,currentValue];
    }
}

- (void)updateDisplays {
    //show the description of the program up top
    self.sentToTheBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    
    //show the result of running the program
    double programResult = [CalculatorBrain runProgram:self.brain.program usingVariables:self.testVariableValues];
    self.display.text = [NSString stringWithFormat:@"%g", programResult];
    
    //show the value of variables at the bottom of the display
    [self updateVariableValueDisplay];
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
    
    //self.sentToTheBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
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

- (IBAction)testNilPressed {
    self.testVariableValues=nil;
    [self updateDisplays];
}

- (IBAction)testSomePressed {
    NSDictionary *testDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:3], @"x", 
                              [NSNumber numberWithDouble:-1.75], @"a", nil];
    self.testVariableValues=testDict;
    [self updateDisplays];
}

- (IBAction)testAllPressed {
    NSDictionary *testDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithDouble:598.896], @"x", 
                              [NSNumber numberWithInt:-4], @"a",
                              [NSNumber numberWithInt:0], @"b", nil];
    self.testVariableValues=testDict;
    [self updateDisplays];

}

- (IBAction)clearPressed {
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.testVariableValues = nil;
    [self.brain clearMemory];
    [self updateDisplays];
}

- (void)viewDidUnload {
    [self setSentToTheBrain:nil];
    [self setVariableValueDisplay:nil];
    [super viewDidUnload];
}
@end
