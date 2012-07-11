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

@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize sentToTheBrain = _sentToTheBrain;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
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
    //put space after number tat is about to be sent to the brain, then add that to our label
    //that shows what was send to the brain
    NSString *toBrainString = [self.display.text stringByAppendingString:@" "];
    self.sentToTheBrain.text = [self.sentToTheBrain.text stringByAppendingString:toBrainString];
    
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    //capture the operation pressed as a string, put a space after it, then show it in our label that shows
    //what operation the brain was asked to perform.
    NSString *operandString = [sender.currentTitle stringByAppendingString:@" "];
    self.sentToTheBrain.text = [self.sentToTheBrain.text stringByAppendingString:operandString];
    
    double result = [self.brain performOperation:sender.currentTitle];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}


- (IBAction)clearPressed {
    self.sentToTheBrain.text = @"";
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    [self.brain clearMemory];
}

- (void)viewDidUnload {
    [self setSentToTheBrain:nil];
    [super viewDidUnload];
}
@end
