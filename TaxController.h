//
//  TaxController.h
//  SalaryCalculator
//
//  Created by Erik Aderstedt on 2010-12-21.
//  Copyright 2010 Aderstedt Software AB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EconomacsSDK/EconomacsSDK.h>

@class TaxTable;

#define ARBETSGIVARAVGIFTER 0.3142

enum ASABRecalculationReason {
    kASABBruttolon = 1,
    kASABLonekostnad,
    kASABUtbetalning,
    kASABSkattetabell
};

@interface TaxController : NSObject {
	NSArray *taxTables;
	
	TaxTable *selectedTable;
	NSDate *paymentDay;
	NSString *entryTitle;
	
	NSDecimalNumber *bruttolon;
	NSDecimalNumber *lonekostnad;
	NSDecimalNumber *utbetalning;
	
	NSDecimalNumber *askatt;
	NSDecimalNumber *arbetsgivaravgifter;
	
	Account *account_skatt;
	Account *account_arbetsgivaravgifter;
	Account *account_arbetsgivaravgifter_kostnad;
	Account *account_krediteras;
	Account *account_lonekostnad;
	
	NSManagedObjectContext *managedObjectContext;
    
    BOOL recalculating;
}
@property(retain,readonly) NSArray *taxTables;
@property(retain) NSString *entryTitle;
@property(retain) NSDate *paymentDay;

@property(retain) Account *account_skatt;
@property(retain) Account *account_arbetsgivaravgifter;
@property(retain) Account *account_arbetsgivaravgifter_kostnad;
@property(retain) Account *account_krediteras;
@property(retain) Account *account_lonekostnad;

@property(retain) TaxTable *selectedTable;

@property(retain) NSDecimalNumber *bruttolon;
@property(retain) NSDecimalNumber *lonekostnad;
@property(retain) NSDecimalNumber *utbetalning;

@property(retain) NSDecimalNumber *askatt;
@property(retain) NSDecimalNumber *arbetsgivaravgifter;

@property(nonatomic,retain) NSManagedObjectContext *managedObjectContext;

// Storing account settings in the plist file.
- (NSDictionary *)accountSettings;
- (void)updateAccountSelection;
- (void)storeAccountSettings;

- (IBAction)updateCalculations:(id)sender;
- (IBAction)createEntry:(id)sender;

@end
