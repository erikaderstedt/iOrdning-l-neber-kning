//
//  MainController.h
//  SalaryCalculator
//
//  Created by Erik Aderstedt on 2009-03-03.
//  Copyright 2009 Aderstedt Software AB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <EconomacsSDK/EconomacsSDK.h>

@class TaxController;

@interface MainViewController : NSViewController  <ASViewControllerProtocol> 
{	
	NSManagedObjectContext *managedObjectContext;
	TaxController *taxController;
}
@property(nonatomic,retain) IBOutlet TaxController *taxController;
@property(nonatomic,retain) NSManagedObjectContext *managedObjectContext;

@end

@interface MainController : ASViewPluginBase {

}

- (Class)viewControllerClass;


@end
