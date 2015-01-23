//
//  TaxController.m
//  SalaryCalculator
//
//  Created by Erik Aderstedt on 2010-12-21.
//  Copyright 2010 Aderstedt Software AB. All rights reserved.
//

#import "TaxController.h"
#import "TaxTable.h"


@implementation TaxController
@synthesize bruttolon;
@synthesize utbetalning;
@synthesize arbetsgivaravgifter;
@synthesize askatt;
@synthesize lonekostnad;

@synthesize account_skatt;
@synthesize account_arbetsgivaravgifter;
@synthesize account_arbetsgivaravgifter_kostnad;
@synthesize account_krediteras;
@synthesize account_lonekostnad;

@synthesize paymentDay;
@synthesize entryTitle;

@synthesize managedObjectContext;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.paymentDay = [NSDate date];
		self.entryTitle = @"Lön";
	}
	return self;
}

- (void)dealloc {
	[taxTables release];
	
	[bruttolon release];
	[utbetalning release];
	[lonekostnad release];
	[askatt release];
	[arbetsgivaravgifter release];
	
	[account_skatt release];
	[account_arbetsgivaravgifter release];
	[account_arbetsgivaravgifter_kostnad release];
	[account_lonekostnad release];
	[account_krediteras release];
	
	[selectedTable release];
	
	[paymentDay release];
	[entryTitle release];
	
	[managedObjectContext release];
	
	[super dealloc];
}

- (NSArray *)taxTables {
	if (taxTables == nil) {
		// http://www.skatteverket.se/privat/skatter/arbeteinkomst/vadblirskattenskattetabellermm/skattetabeller/kommunalaskattesatsermmunder2015/skattetabellerforberakningavpreliminaraskatt.4.3f4496fd14864cc5ac9de2e.html
        // Download the text file "Månadslön".
        // Run the script importeraSkatteverket.py on this file.
		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSArray *tables = [bundle pathsForResourcesOfType:@"csv" inDirectory:nil];
		taxTables = [NSMutableArray arrayWithCapacity:[tables count]];
		
		for (NSString *path in tables) {
			[(NSMutableArray *)taxTables addObject:[[[TaxTable alloc] initWithPath:path] autorelease]];
		}
		
		NSString *selectedTableName = [[NSUserDefaults standardUserDefaults] stringForKey:@"Loneberakning_table"];
		if (selectedTableName != nil) {
			for (TaxTable *t in taxTables) {
				if ([t.name isEqualToString:selectedTableName]) {
					self.selectedTable = t;
					break;
				}
			}
		}
		
		// This is not related, but we don't have anywhere else to put it :(
		[self updateAccountSelection];
        [taxTables retain];
	}
	return taxTables;
}

#pragma mark -

- (NSDictionary *)accountSettings {
	NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
							  @"Loneberakning_account_skatt", @"account_skatt", 
							  @"Loneberakning_account_arbetsgivaravgifter", @"account_arbetsgivaravgifter",
							  @"Loneberakning_account_arbetsgivaravgifter_kostnad", @"account_arbetsgivaravgifter_kostnad",
							  @"Loneberakning_account_krediteras", @"account_krediteras",
							  @"Loneberakning_account_lonekostnad", @"account_lonekostnad", nil];
	
	return defaults;
}


- (void)updateAccountSelection {
	NSDictionary *defaults = [self accountSettings];
	for (NSString *key in defaults) {
        NSNumber *n = [[NSUserDefaults standardUserDefaults] valueForKey:[defaults valueForKey:key]];
        Account *a = [Account locateAccountWithNumber:n inContext:[self managedObjectContext]];
        if (a == nil) {
            n = @([n integerValue]*10);
            [Account locateAccountWithNumber:n inContext:[self managedObjectContext]];
        }
		[self setValue:a forKey:key];
	}
}

- (void)storeAccountSettings {
	NSDictionary *defaults = [self accountSettings];
	for (NSString *key in defaults) {
		[[NSUserDefaults standardUserDefaults] setValue:[[self valueForKey:key] valueForKey:@"number"] forKey:[defaults valueForKey:key]];
	}
}

#pragma mark -

//- (void)textDidEndEditing:(NSNotification *)obj {
//    NSTextField *field = (NSTextField *)[obj object];
//    enum ASABRecalculationReason reason = (enum ASABRecalculationReason)[field tag];
//    NSDecimalNumber *nuNumber = (NSDecimalNumber *)[[field formatter] numberFromString:[field stringValue]];
//    BOOL update = NO;
//    switch (reason) {
//        case kASABBruttolon:
//            update = ![nuNumber isEqualToNumber:self.bruttolon];
//            break;
//        case kASABLonekostnad:
//            update = ![nuNumber isEqualToNumber:self.lonekostnad];
//            break;
//        case kASABUtbetalning:
//            update = ![nuNumber isEqualToNumber:self.utbetalning];
//            break;
//        default:
//            break;
//    }
//    if (update)
//        [self recalculate:reason];
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (recalculating) return;
    if ([keyPath isEqualToString:@"bruttolon"]) {
        [self recalculate:kASABBruttolon];
    } else if ([keyPath isEqualToString:@"lonekostnad"]) {
        [self recalculate:kASABLonekostnad];
    } else if ([keyPath isEqualToString:@"utbetalning"]) {
        [self recalculate:kASABUtbetalning];
    } else if ([keyPath isEqualToString:@"selectedTable"]) {
        [self recalculate:kASABSkattetabell];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)recalculate:(enum ASABRecalculationReason)reason {
    double b, u, l, d;
    recalculating = YES;
    switch (reason) {
        case kASABBruttolon:
            b = [self.bruttolon doubleValue];
            d = [selectedTable getTaxDeductionOn:b];
            u = b - d;
            l = floor(b * (1.0 + ARBETSGIVARAVGIFTER));
            break;
        case kASABLonekostnad:
            l = [self.lonekostnad doubleValue];
            b = l / (1.0 + ARBETSGIVARAVGIFTER);
            d = [selectedTable getTaxDeductionOn:b];
            u = b - d;
            break;
        case kASABUtbetalning:
            u = [self.utbetalning doubleValue];
            b = ceil([selectedTable findGrossIncomeForPayment:u]);
            l = floor(b * (1.0 + ARBETSGIVARAVGIFTER));
            break;
        case kASABSkattetabell:
            b = [self.bruttolon doubleValue];
            l = [self.lonekostnad doubleValue];
            u = [self.utbetalning doubleValue];
            break;
        default:
            break;
    }
    if (reason != kASABBruttolon || self.bruttolon == nil)
        self.bruttolon = [NSDecimalNumber decimalNumberWithMantissa:abs((long)b) exponent:0 isNegative:(b < 0)];
    if (reason != kASABLonekostnad || self.lonekostnad == nil)
        self.lonekostnad = [NSDecimalNumber decimalNumberWithMantissa:abs((long)l) exponent:0 isNegative:(l < 0)];
    if (reason != kASABUtbetalning || self.utbetalning == nil)
        self.utbetalning = [NSDecimalNumber decimalNumberWithMantissa:abs((long)u) exponent:0 isNegative:(u < 0)];
    
    self.arbetsgivaravgifter = [self.lonekostnad decimalNumberBySubtracting:self.bruttolon];
    self.askatt = [self.bruttolon decimalNumberBySubtracting:self.utbetalning];
    
    if (reason != kASABBruttolon)
        self.bruttolon = [self.bruttolon decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber defaultBehavior]];
    if (reason != kASABLonekostnad)
        self.lonekostnad = [self.lonekostnad decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber defaultBehavior]];
    if (reason != kASABUtbetalning)
        self.utbetalning = [self.utbetalning decimalNumberByRoundingAccordingToBehavior:[NSDecimalNumber defaultBehavior]];
    
    [[NSUserDefaults standardUserDefaults] setValue:selectedTable.name forKey:@"Loneberakning_table"];
    [self storeAccountSettings];
    recalculating = NO;
}

- (IBAction)createEntry:(id)sender {
	//
	// Create a new entry based on the entered information.
	// We rely on the UI to prevent us from clicking the button unless
	// all the required info is filled out.
	//
	// As a last resort, the document will refuse to save if the entry does not
	// validate.
	//
	
	Entry *e = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:[self managedObjectContext]];
	Row *r = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:[self managedObjectContext]];
	r.entry = e;
	r.account = account_krediteras;
	r.credit = self.utbetalning;
    r.stricken = @NO;
	
	r = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:[self managedObjectContext]];
	r.entry = e;
	r.account = account_lonekostnad;
	r.debit = self.bruttolon;
    r.stricken = @NO;
	
	r = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:[self managedObjectContext]];
	r.entry = e;
	r.account = account_arbetsgivaravgifter_kostnad;
	r.debit = [self.lonekostnad decimalNumberBySubtracting:self.bruttolon];
    r.stricken = @NO;
	
	r = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:[self managedObjectContext]];
	r.entry = e;
	r.account = account_arbetsgivaravgifter;
	r.credit = [self.lonekostnad decimalNumberBySubtracting:self.bruttolon];
    r.stricken = @NO;
	
	r = [NSEntityDescription insertNewObjectForEntityForName:@"Row" inManagedObjectContext:[self managedObjectContext]];
	r.entry = e;
	r.account = account_skatt;
	r.credit = [self.bruttolon decimalNumberBySubtracting:self.utbetalning];
    r.stricken = @NO;
	
	e.name = self.entryTitle;
	e.date = [self.paymentDay dateIndex];
	e.fiscalYear = nil;
	e.number = nil;
	
	NSAlert *alert = [NSAlert alertWithMessageText:@"Verifikation skapad" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"En kommande verifikation har skapats. Du hittar den under 'Kommande' i sidofältet."];
	[alert runModal];
}

@synthesize selectedTable;


@end
