//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Matthew Weinecke on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()

@property (nonatomic,strong) NSMutableArray *programStack;

@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack {
    if (!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (id)program {
    return [self.programStack copy];
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation {
    return [[NSSet setWithObjects:@"+",@"*",@"-",@"/",nil] containsObject:operation];
}

+ (BOOL)isOneOperandOperation:(NSString *)operation {
    return [[NSSet setWithObjects:@"sin",@"cos",@"sqrt",nil] containsObject: operation];
}

+ (BOOL)isNoOperandOperation:(NSString *)operation {
    return [[NSSet setWithObjects:@"π",nil] containsObject: operation];
}

+ (BOOL)isValidOperation:(NSString *)operation {
    return [self isTwoOperandOperation:operation] ||
            [self isOneOperandOperation:operation] ||
            [self isNoOperandOperation:operation];
}

+ (NSString *)descriptionOfProgram:(id)program {
    return @"Implement this in Homework #2";
}


- (void)pushOperand:(double)operand {
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)pushVariable:(NSString *)var {
    //reject variables that are names of operations
    if (![[self class] isValidOperation: var]) {
        [self.programStack addObject:var];
    }
}

- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [[self class] runProgram:self.program];
}

+ (double)popOperandOffProgramStack: (NSMutableArray *)stack {
    
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];  
    } else if ([topOfStack isKindOfClass: [NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffProgramStack:stack] + [self popOperandOffProgramStack:stack];
        } else if ([@"*" isEqualToString:operation]) {
            result = [self popOperandOffProgramStack:stack] * [self popOperandOffProgramStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtractBy = [self popOperandOffProgramStack:stack];
            result = [self popOperandOffProgramStack:stack] - subtractBy;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffProgramStack:stack];
            //prevent divide by zero error
            if (divisor != 0) {
                result = [self popOperandOffProgramStack:stack] / divisor;
            }
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"sqrt"]) {
            result = sqrt([self popOperandOffProgramStack:stack]);
        } else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        }
    }

    return result;
}

+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffProgramStack:stack];
}

- (void)clearMemory {
    [self.programStack removeAllObjects];
}

@end
