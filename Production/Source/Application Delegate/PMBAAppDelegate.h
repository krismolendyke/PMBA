//
//  PMBAAppDelegate.h
//  PMBA
//
//  Created by Kris on 2/25/10.
//  Copyright Siemens 2010. All rights reserved.
//



#import <CoreData/CoreData.h>
@class TrailConditionsFeedParserDelegate;



@interface PMBAAppDelegate : NSObject <UIApplicationDelegate, 
                                       UIScrollViewDelegate,
                                       UIAlertViewDelegate> 
{
  NSString *version;
  NSString *build;
  NSURL *trailConditionsFeedURL;
  
  UIWindow *window;
  UIActivityIndicatorView *activityIndicatorView;
  UIScrollView *scrollView;
  UIPageControl *pageControl;
  BOOL pageControlUsed;

  NSMutableArray *viewControllersMutableArray;
  
  NSXMLParser *trailConditionsFeedParser;
  
  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;	    
  NSPersistentStoreCoordinator *persistentStoreCoordinator;
}



#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) NSString *version;
@property (nonatomic, retain) NSString *build;
@property (nonatomic, retain) NSURL *trailConditionsFeedURL;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllersMutableArray;
@property (nonatomic, retain) NSXMLParser *trailConditionsFeedParser;
@property (nonatomic, retain) TrailConditionsFeedParserDelegate *trailConditionsFeedParserDelegate;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;



#pragma mark -
#pragma mark Instance Methods
- (BOOL)isSavedTrailConditionsAvailableForTrailSystemNamed:(NSString *)name;
- (IBAction)changePage:(id)sender;
- (NSString *)applicationDocumentsDirectory;
- (void)trailConditionsFeedParserSuccess;
- (void)trailConditionsFeedParserError;



@end
