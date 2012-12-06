//
//  TaxTable.m
//  SalaryCalculator
//
//  Created by Erik Aderstedt on 2009-03-03.
//  Copyright 2009 Aderstedt Software AB. All rights reserved.
//

#import "TaxTable.h"


@implementation TaxTable

@synthesize name;

- (id)initWithPath:(NSString *)path {
	if (self = [super init]) {
		name = [[[[path lastPathComponent] componentsSeparatedByString:@"."] objectAtIndex:0] retain];
        NSError *error = nil;
		NSString *all = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (all == nil) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
            return nil;
        }
		NSArray *rows = [all componentsSeparatedByString:@"\n"];
		
		length = [rows count];
		incomes = calloc(sizeof(double), length);
		tax_deductions = calloc(sizeof(double), length);
		
		int i;
		for (i = 0; i < length; i++) {
			NSArray *row = [[rows objectAtIndex:i] componentsSeparatedByString:@";"];
			if ([row count] != 3) {
				break;
			}
			incomes[i] = [[row objectAtIndex:0] doubleValue];
			tax_deductions[i] = [[row objectAtIndex:2] doubleValue];
			if (i > 0 && (tax_deductions[i] < tax_deductions[i-1])) {
				proportionalBreakOff = i;
			}
		}
		length = i;
	}
	return self;
}

- (void)dealloc {
	free(incomes);
	free(tax_deductions);
	
	[name release];
	
	[super dealloc];
}

- (double)getTaxDeductionOn:(double)value {
	int i;
	if (value < 0.0) return 0.0;
	
	for (i = length - 1; i >= 0; i--) {
		if (incomes[i] < value) {
			if (i >= proportionalBreakOff) {
				return 0.01*tax_deductions[i]*value;
			}
			return tax_deductions[i];
		}
	}
	
	return 0.0;
}

- (double)findGrossIncomeForPayment:(double)value {
	int i;
	if (value < 0.0) return 0.0;
	double net;
	
	for (i = length - 1; i >= 0; i--) {
		net = (i >= proportionalBreakOff)?((1.0 - 0.01*tax_deductions[i])*incomes[i]):(incomes[i] - tax_deductions[i]);
		if (net < value) {
			return (i >= proportionalBreakOff)?(value/(1.0 - 0.01*tax_deductions[i])):(value + tax_deductions[i]);
		}
	}
	return 0.0;
}

@end
