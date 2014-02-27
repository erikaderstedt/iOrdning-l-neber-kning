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
}

- (void)willDisappear {
	
}


@end


@implementation MainController



- (Class)viewControllerClass {
	return [MainViewController class];
}


- (NSString *)title {
	return @"Löneberäkning 2014";
}

- (enum ASPluginType)type {
	return kASViewPlugin;
}

@end
