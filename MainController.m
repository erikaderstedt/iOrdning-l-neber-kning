//
//  MainController.m
//  SalaryCalculator
//
//  Created by Erik Aderstedt on 2009-03-03.
//  Copyright 2009 Aderstedt Software AB. All rights reserved.
//

#import "MainController.h"
#import "TaxController.h"

@implementation MainViewController

@synthesize managedObjectContext;
@synthesize taxController;

- (void)dealloc {
	[managedObjectContext release];
	[taxController release];
	
	[super dealloc];
}

+ (NSString *)defaultNibName {
	return @"SalaryCalculator";
}

- (void)willAppear {
	[taxController setManagedObjectContext:self.managedObjectContext];
	[taxController updateAccountSelection];
    Company *foretag = [Company inContext:self.managedObjectContext];
    [self.formatter setCurrencyCode:foretag.currency];
    [self.formatter setGeneratesDecimalNumbers:YES];
    [self.formatter setMaximumFractionDigits:0];
    
    [taxController addObserver:taxController forKeyPath:@"bruttolon" options:0 context:NULL];
    [taxController addObserver:taxController forKeyPath:@"lonekostnad" options:0 context:NULL];
    [taxController addObserver:taxController forKeyPath:@"utbetalning" options:0 context:NULL];
    [taxController addObserver:taxController forKeyPath:@"selectedTable" options:0 context:NULL];
}

- (void)willDisappear {
    [taxController removeObserver:taxController forKeyPath:@"bruttolon"];
    [taxController removeObserver:taxController forKeyPath:@"lonekostnad"];
    [taxController removeObserver:taxController forKeyPath:@"utbetalning"];
    [taxController removeObserver:taxController forKeyPath:@"selectedTable"];
}

@end


@implementation MainController

- (Class)viewControllerClass {
	return [MainViewController class];
}


- (NSString *)title {
	return @"Löneberäkning 2016";
}

- (enum ASPluginType)type {
	return kASViewPlugin;
}

@end
