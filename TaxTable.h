//
//  TaxTable.h
//  SalaryCalculator
//
//  Created by Erik Aderstedt on 2009-03-03.
//  Copyright 2009 Aderstedt Software AB. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TaxTable : NSObject {
	NSString *name;
	
	double	proportionalBreakOff;

	double  *incomes;
	double	*tax_deductions;
	int		length;
}
@property(retain) NSString *name;

- (id)initWithPath:(NSString *)path;
- (double)getTaxDeductionOn:(double)value;
- (double)findGrossIncomeForPayment:(double)value;
@end
