//
//  PMBAAppDelegate.m
//  PMBA
//
//  Created by Kris on 2/25/10.
//  Copyright Siemens 2010. All rights reserved.
//



#import "PMBAAppDelegate.h"
#import "TrailSystem.h"
#import "TrailCondition.h"
#import "TrailConditionViewController.h"
#import "TrailConditionsFeedParserDelegate.h"
#import "ASIHTTPRequest.h"



#pragma mark -
#pragma mark Private Interface
@interface PMBAAppDelegate (PrivateMethods)
- (void)setVersionAndBuildSettings;
- (BOOL)isSettingsAvailable;
- (void)setDefaultSettings;
- (TrailSystem *)getSavedTrailSystemWithName:(NSString *)name;
- (TrailSystem *)getNewTrailSystemWithName:(NSString *)name;
- (void)loadSavedTrailConditionsForTrailSystemNamed:(NSString *)name;
- (void)makeTrailConditionsRequestWithURL:(NSURL *)url;
- (void)initializeViewControllersMutableArray;
- (void)initializeScrollViewWithNumberOfPages:(int)numberOfPages;
- (void)initializePageControlWithNumberOfPages:(int)numberOfPages;
- (void)initializeTrailConditionsFeedParserWithData:(NSData *)data;
- (void)scrollToCurrentPageAnimated:(BOOL)animated;
- (void)loadScrollViewWithTrailConditionsArray:(NSArray *)trailConditionsArray;
- (void)loadScrollViewWithPage:(int)page;
@end



#pragma mark -
#pragma mark Public Interface
@implementation PMBAAppDelegate



#pragma mark -
#pragma mark Constants
#define kVersionSettingsKey @"version"
#define kBuildSettingsKey @"build"
#define kTrailConditionsFeedURLSettingsKey @"trail_conditions_feed_url"
#define kWissName @"Wissahickon Park"
#define kRequestTimeout 30
#define kMaxNumberOfPages 5



#pragma mark -
#pragma mark Properties
@synthesize version;
@synthesize build;
@synthesize trailConditionsFeedURL;
@synthesize window;
@synthesize activityIndicatorView;
@synthesize scrollView;
@synthesize pageControl;
@synthesize viewControllersMutableArray;
@synthesize trailConditionsFeedParser;
@synthesize trailConditionsFeedParserDelegate;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;



#pragma mark -
#pragma mark Instance Methods
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
  [self setVersionAndBuildSettings];

  if(![self isSettingsAvailable])
  {
    [self setDefaultSettings];
  }
  
  [window makeKeyAndVisible];
}



- (void)applicationDidBecomeActive:(UIApplication *)application
{
  if([self isSavedTrailConditionsAvailableForTrailSystemNamed:kWissName])
  {
    [self loadSavedTrailConditionsForTrailSystemNamed:kWissName];    
  }
  
  self.trailConditionsFeedURL = 
  [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] 
                        stringForKey:kTrailConditionsFeedURLSettingsKey]];
  [self makeTrailConditionsRequestWithURL:self.trailConditionsFeedURL];  
}



#pragma mark -
#pragma mark Settings Methods
- (void)setVersionAndBuildSettings
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  self.version = 
  [NSString stringWithFormat:@"%@", 
   [[NSBundle mainBundle] 
    objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
  [defaults setObject:version forKey:kVersionSettingsKey];
  
  self.build = 
  [NSString stringWithFormat:@"%@",
   [[NSBundle mainBundle]
    objectForInfoDictionaryKey:@"CFBundleVersion"]];  
  [defaults setObject:build forKey:kBuildSettingsKey];
  
  NSLog(@"v%@b%@", self.version, self.build);  
}



- (BOOL)isSettingsAvailable
{
  return [[NSUserDefaults standardUserDefaults] stringForKey:kTrailConditionsFeedURLSettingsKey] != nil;
}



- (void)setDefaultSettings
{
  NSString *pathStr = [[NSBundle mainBundle] bundlePath];
  NSString *settingsBundlePath = 
    [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
  NSString *finalPath = 
    [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];
  
  NSDictionary *settingsDict = 
    [NSDictionary dictionaryWithContentsOfFile:finalPath];
  NSArray *prefSpecifierArray = 
    [settingsDict objectForKey:@"PreferenceSpecifiers"];
  
  NSString *trailConditionsFeedURLDefault = @"";
  
  NSDictionary *prefItem;
  for(prefItem in prefSpecifierArray)
  {
    NSString *keyValueStr = [prefItem objectForKey:@"Key"];
    id defaultValue = [prefItem objectForKey:@"DefaultValue"];
    
    if([keyValueStr isEqualToString:kTrailConditionsFeedURLSettingsKey])
    {
      trailConditionsFeedURLDefault = defaultValue;
    }
  }
  
  NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                               trailConditionsFeedURLDefault,
                               kTrailConditionsFeedURLSettingsKey,
                               nil];
  [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}



#pragma mark -
#pragma mark Trail Systems & Conditions Methods
-(BOOL)isSavedTrailConditionsAvailableForTrailSystemNamed:(NSString *)name
{
  NSFetchRequest *fetchRequest = 
    [self.managedObjectModel 
    fetchRequestFromTemplateWithName:@"trailSystemNamed" 
    substitutionVariables:[NSDictionary dictionaryWithObject:name 
                                                      forKey:@"name"]];
  
  if(!fetchRequest)
  {
    return NO;
  }
    
  NSError *error = nil;
  NSArray *trailSystemsArray = 
    [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

  if([trailSystemsArray count] == 0)
  {
    return NO;
  }
  
  return YES;
}



- (TrailSystem *)getSavedTrailSystemWithName:(NSString *)name
{
  NSFetchRequest *fetchRequest = 
  [self.managedObjectModel 
   fetchRequestFromTemplateWithName:@"trailSystemNamed" 
   substitutionVariables:[NSDictionary dictionaryWithObject:name
                                                     forKey:@"name"]];
  
  NSError *error = nil;
  NSArray *trailSystemsArray = 
  [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  TrailSystem *trailSystem = nil;
  if([trailSystemsArray count] > 0)
  {
    trailSystem = (TrailSystem *)[trailSystemsArray objectAtIndex:0];
  }
  
  return trailSystem;
}



- (TrailSystem *)getNewTrailSystemWithName:(NSString *)name
{
  TrailSystem *trailSystem = 
    (TrailSystem *)[NSEntityDescription
                    insertNewObjectForEntityForName:@"TrailSystem"
                    inManagedObjectContext:managedObjectContext];
  trailSystem.name = name;
  
  return trailSystem;
}



-(void)loadSavedTrailConditionsForTrailSystemNamed:(NSString *)name
{
  NSFetchRequest *fetchRequest = 
  [self.managedObjectModel 
   fetchRequestFromTemplateWithName:@"trailSystemNamed" 
   substitutionVariables:[NSDictionary dictionaryWithObject:name 
                                                     forKey:@"name"]];
  
  NSError *error = nil;
  NSArray *trailSystemsArray = 
    [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
  
  NSSortDescriptor *sortDescriptor = 
    [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];

  if([trailSystemsArray count] > 0)
  {
    TrailSystem *trailSystem = 
      (TrailSystem *)[trailSystemsArray objectAtIndex:0];

    NSArray *trailConditionsArray = 
      [[[trailSystem trailConditions] allObjects] 
       sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    [self loadScrollViewWithTrailConditionsArray:trailConditionsArray];
  }

  [sortDescriptor release];  
}



#pragma mark -
#pragma mark HTTP Request Methods
- (void)makeTrailConditionsRequestWithURL:(NSURL *)url
{
  [self.activityIndicatorView startAnimating];
  
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  [request setDelegate:self];
  [request setTimeOutSeconds:kRequestTimeout];
  
  [request startAsynchronous];
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
}



- (void)requestFinished:(ASIHTTPRequest *)request
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
  NSString *string = [request responseString];
  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
  [self initializeTrailConditionsFeedParserWithData:data];
  [self.trailConditionsFeedParser parse];
}



- (void)requestFailed:(ASIHTTPRequest *)request
{
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
  
  [self.pageControl setNumberOfPages:0];
  
  NSString *description = [NSString stringWithFormat:@"%@.", 
                           [[request error] localizedDescription]];
  NSLog(@"%@", description);
  NSString *alertViewMessage = 
    [description stringByAppendingString:
     @" Please double check the URL in Settings if the problem persists."];
  
  UIAlertView *alertView = 
    [[UIAlertView alloc] initWithTitle:@"Current Trail Conditions Unavailable" 
                               message:alertViewMessage
                              delegate:self
                     cancelButtonTitle:@"Retry" 
                     otherButtonTitles:nil];
    
  [self.activityIndicatorView stopAnimating];  
  [alertView show];
  [alertView release];
}



#pragma mark -
#pragma mark Initialization Methods
- (void)initializeViewControllersMutableArray
{
  NSMutableArray *controllers = [[NSMutableArray alloc] init];
  for(unsigned i = 0; i < kMaxNumberOfPages; i++) 
  {
    [controllers addObject:[NSNull null]];
  }
  
  self.viewControllersMutableArray = controllers;
  
  [controllers release];  
}



- (void)initializeScrollViewWithNumberOfPages:(int)numberOfPages
{
  self.scrollView.delegate = self;
  self.scrollView.scrollsToTop = NO;
  self.scrollView.contentSize = 
    CGSizeMake(self.scrollView.frame.size.width * numberOfPages,
               self.scrollView.frame.size.height);  
}



- (void)initializePageControlWithNumberOfPages:(int)numberOfPages
{
  self.pageControl.numberOfPages = numberOfPages;
  self.pageControl.currentPage = numberOfPages - 1;  
}



- (void)initializeTrailConditionsFeedParserWithData:(NSData *)data
{
  self.trailConditionsFeedParser = [[NSXMLParser alloc] initWithData:data];
  [self.trailConditionsFeedParser setShouldResolveExternalEntities:YES];
  [self.trailConditionsFeedParser setShouldProcessNamespaces:YES];
  [self.trailConditionsFeedParser setShouldReportNamespacePrefixes:YES];  
  
  
  TrailSystem *trailSystem;
  if([self isSavedTrailConditionsAvailableForTrailSystemNamed:kWissName])
  {
    trailSystem = [self getSavedTrailSystemWithName:kWissName];
  }
  else 
  {
    trailSystem = [self getNewTrailSystemWithName:kWissName];
  }

  self.trailConditionsFeedParserDelegate = 
    [[TrailConditionsFeedParserDelegate alloc] 
     initWithTrailSystem:trailSystem
     managedObjectContext:self.managedObjectContext
     parserResultDelegate:self 
     didEndDocumentSelector:@selector(trailConditionsFeedParserSuccess) 
     parseErrorOccurredSelector:@selector(trailConditionsFeedParserError)];
  
  [self.trailConditionsFeedParser 
   setDelegate:trailConditionsFeedParserDelegate];
}



#pragma mark -
#pragma mark Parser Result Methods
- (void)trailConditionsFeedParserSuccess
{
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
                                      initWithKey:@"date" ascending:NO];

  NSArray *trailConditionsArray = 
    [[((TrailConditionsFeedParserDelegate *)
       self.trailConditionsFeedParser.delegate).trailSystem.trailConditions 
        allObjects] 
     sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  [sortDescriptor release];

  
  [self initializeViewControllersMutableArray];
  [self loadScrollViewWithTrailConditionsArray:trailConditionsArray];
}



- (void)trailConditionsFeedParserError
{
  NSString *message = 
    @"Trail conditions not currently available.  Please try later.";
  
  NSLog(@"%@", message);

  int errorViewControllerIndex = 0;
  [self loadScrollViewWithPage:errorViewControllerIndex];
  TrailConditionViewController *vc = 
    [self.viewControllersMutableArray objectAtIndex:errorViewControllerIndex];
  [vc.titleLabel setText:message];
   [self scrollToCurrentPageAnimated:NO];
  [[self activityIndicatorView] stopAnimating];
}



#pragma mark -
#pragma mark View Methods
- (void)alertView:(UIAlertView *)alertView 
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  [self makeTrailConditionsRequestWithURL:self.trailConditionsFeedURL];
}



- (IBAction)changePage:(id)sender
{
  int page = self.pageControl.currentPage;

  // load the visible page and the page on either side of it (to avoid flashes 
  // when the user starts scrolling)
  [self loadScrollViewWithPage:page - 1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page + 1];

  // update the scroll view to the appropriate page
  CGRect frame = self.scrollView.frame;
  frame.origin.x = frame.size.width * page;
  frame.origin.y = 0;
  [self.scrollView scrollRectToVisible:frame animated:YES];

  // Set the boolean used when scrolls originate from the UIPageControl. See 
  // scrollViewDidScroll: below.
  pageControlUsed = YES;  
}



- (void)scrollToCurrentPageAnimated:(BOOL)animated
{
  CGRect frame = self.scrollView.frame;
  frame.origin.x = frame.size.width * self.pageControl.currentPage;
  frame.origin.y = 0;
  [self.scrollView scrollRectToVisible:frame animated:animated];  
}



- (void)loadScrollViewWithTrailConditionsArray:(NSArray *)trailConditionsArray
{
  [self initializeViewControllersMutableArray];
  
  int numberOfPages = [trailConditionsArray count];
  
  [self initializeScrollViewWithNumberOfPages:numberOfPages];
  [self initializePageControlWithNumberOfPages:numberOfPages];
  
  [self.activityIndicatorView stopAnimating];
  
  NSUInteger pageNumber;
  for(pageNumber = 0; pageNumber < numberOfPages; pageNumber++) 
  {
    [self loadScrollViewWithPage:self.pageControl.currentPage - pageNumber];
    
    // Load most recent trail condition on the right most page.  That way
    // scrolling left will show historic trail conditions, going back in time.
    TrailCondition *trailCondition = 
      [trailConditionsArray objectAtIndex:pageNumber];

    TrailConditionViewController *vc = 
      [self.viewControllersMutableArray 
       objectAtIndex:numberOfPages - pageNumber - 1];
    
    [vc updateViewWithTrailCondition:trailCondition];
  }
  
  [self scrollToCurrentPageAnimated:NO];  
}



- (void)loadScrollViewWithPage:(int)page
{
  if(page < 0 || page >= kMaxNumberOfPages)
  {
    return;
  }
  
  TrailConditionViewController *vc = 
    [viewControllersMutableArray objectAtIndex:page];
  if((NSNull *)vc == [NSNull null])
  {
    vc = 
      [[TrailConditionViewController alloc] initWithNibName:@"TrailConditionView" 
                                                     bundle:nil];
    [self.viewControllersMutableArray replaceObjectAtIndex:page withObject:vc];
    [vc release];
  }
  
  if(vc.view.superview == nil)
  {
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    vc.view.frame = frame;    
    [self.scrollView addSubview:vc.view];
  }
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  // We don't want a "feedback loop" between the UIPageControl and the scroll 
  // delegate in which a scroll event generated from the user hitting the page 
  // control triggers updates from the delegate method. We use a boolean to 
  // disable the delegate logic when the page control is used.
  if(pageControlUsed) 
  {
    // do nothing - the scroll was initiated from the page control, not the user
    // dragging
    
    return;
  }
  
  // Switch the indicator when more than 50% of the previous/next page is 
  // visible  
  CGFloat pageWidth = self.scrollView.frame.size.width;
  int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) 
                   / pageWidth) + 1;
  self.pageControl.currentPage = page;
  
  // load the visible page and the page on either side of it (to avoid flashes 
  // when the user starts scrolling)
  [self loadScrollViewWithPage:page - 1];
  [self loadScrollViewWithPage:page];
  [self loadScrollViewWithPage:page + 1];

  // TODO: A possible optimization would be to unload the views+controllers 
  // which are no longer visible
}



// At the end of scroll animation, reset the boolean used when scrolls originate
// from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
  pageControlUsed = NO;
}



- (void)dealloc 
{
  [self.trailConditionsFeedURL release];
  [self.build release];
  [self.version release];
  [self.trailConditionsFeedParserDelegate release];
  [self.trailConditionsFeedParser release];
  [self.viewControllersMutableArray release];
  [self.scrollView release];
  [self.pageControl release];
  [self.managedObjectContext release];
  [self.managedObjectModel release];
  [self.persistentStoreCoordinator release];
  [self.activityIndicatorView release];
  [self.window release];
  
  [super dealloc];
}



// applicationWillTerminate: saves changes in the application's managed object 
// context before the application terminates.
- (void)applicationWillTerminate:(UIApplication *)application 
{
  NSError *error = nil;
  
  if(managedObjectContext != nil) 
  {
    if([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) 
    {
      
      // Replace this implementation with code to handle the error 
      // appropriately.
      // abort() causes the application to generate a crash log and terminate. 
      // You should not use this function in a shipping application, although it 
      // may be useful during development. If it is not possible to recover from
      // the error, display an alert panel that instructs the user to quit the 
      // application by pressing the Home button.
			
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      
      NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
      NSArray* detailedErrors = 
        [[error userInfo] objectForKey:NSDetailedErrorsKey];

      if(detailedErrors != nil && [detailedErrors count] > 0) 
      {
        for(NSError* detailedError in detailedErrors) 
        {
          NSLog(@"  DetailedError: %@", [detailedError userInfo]);
        }
      }
      else 
      {
        NSLog(@"  %@", [error userInfo]);
      }      

      UIAlertView *alertView = 
      [[UIAlertView alloc] initWithTitle:@"Unable to Save Trail Conditions"
                                 message:@"This really isn't that big of a deal.  Please quit using the Home button."        
                                delegate:nil 
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];
      [alertView show];
      [alertView release];
    } 
  }
}



#pragma mark -
#pragma mark Core Data Methods
/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent 
 store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext 
{
  if(managedObjectContext != nil) 
  {
    return managedObjectContext;
  }
	
  NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
  if(coordinator != nil) 
  {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  return managedObjectContext;
}



/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models 
 found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel 
{
  if (managedObjectModel != nil) 
  {
    return managedObjectModel;
  }
  
  managedObjectModel = 
    [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    

  return managedObjectModel;
}



/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's 
 store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator 
{
  if(persistentStoreCoordinator != nil) 
  {
    return persistentStoreCoordinator;
  }
	
  NSURL *storeUrl = 
    [NSURL fileURLWithPath: 
     [[self applicationDocumentsDirectory] 
      stringByAppendingPathComponent:@"CoreData.sqlite"]];
  
	NSError *error = nil;
  
  persistentStoreCoordinator = 
    [[NSPersistentStoreCoordinator alloc] 
     initWithManagedObjectModel:[self managedObjectModel]];
  
  if(![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
                                               configuration:nil 
                                                         URL:storeUrl 
                                                     options:nil 
                                                       error:&error])
  {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You 
     should not use this function in a shipping application, although it may be 
     useful during development. If it is not possible to recover from the error, 
     display an alert panel that instructs the user to quit the application by 
     pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed 
       object model
		 Check the error message to determine what the actual problem was.
		 */
    
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);

    UIAlertView *alertView = 
    [[UIAlertView alloc] initWithTitle:@"Unable to Save Trail Conditions" 
                               message:@"This really isn't that big of a deal.  Please quit using the Home button." 
                              delegate:nil 
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];    
  }    
	
  return persistentStoreCoordinator;
}



/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory 
{
	return 
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                         NSUserDomainMask, 
                                         YES) lastObject];
}



@end
