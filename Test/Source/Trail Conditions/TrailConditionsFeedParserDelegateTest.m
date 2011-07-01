//
//  TrailConditionsFeedParserDelegateTest.m
//  PMBA
//
//  Created by Kris on 3/2/10.
//  Copyright 2010 Siemens. All rights reserved.
//



#import "GTMSenTestCase.h"
#import "TrailSystem.h"
#import "TrailCondition.h"
#import "TrailConditionsFeedParserDelegate.h"



#pragma mark Interface
@interface TrailConditionsFeedParserDelegateTest : GTMTestCase
{
  TrailConditionsFeedParserDelegate *parserDelegate;

  NSManagedObjectModel *managedObjectModel;
  NSManagedObjectContext *managedObjectContext;	    
  NSPersistentStoreCoordinator *persistentStoreCoordinator;  
}
@property (nonatomic, retain) TrailConditionsFeedParserDelegate *parserDelegate;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSXMLParser *)newTrailConditionsFeedParserWithXMLString:(NSString *)string
                                    didEndDocumentSelector:(SEL)successSelector
                                parseErrorOccurredSelector:(SEL)errorSelector;
- (NSString *)applicationDocumentsDirectory;
@end



#pragma mark -
#pragma mark Implementation
@implementation TrailConditionsFeedParserDelegateTest



@synthesize parserDelegate;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;



#pragma mark -
#pragma mark Set Up & Tear Down Methods
- (void)setUp
{

}



- (void)tearDown
{
  [self.parserDelegate release];
}



#pragma mark -
#pragma mark Helper Methods
- (NSXMLParser *)newTrailConditionsFeedParserWithXMLString:(NSString *)string
                                    didEndDocumentSelector:(SEL)successSelector
                                parseErrorOccurredSelector:(SEL)errorSelector
{
  
  NSXMLParser *parser = 
  [[NSXMLParser alloc] 
   initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
  [parser setShouldProcessNamespaces:YES];
  [parser setShouldReportNamespacePrefixes:YES];
  [parser setShouldResolveExternalEntities:YES];
  
  TrailSystem *trailSystem = 
  (TrailSystem *)[NSEntityDescription
                  insertNewObjectForEntityForName:@"TrailSystem"
                  inManagedObjectContext:self.managedObjectContext];
  trailSystem.name = @"Wissahickon Park";  
  
  self.parserDelegate =
  [[TrailConditionsFeedParserDelegate alloc] 
   initWithTrailSystem:trailSystem
   managedObjectContext:self.managedObjectContext
   parserResultDelegate:self
   didEndDocumentSelector:successSelector
   parseErrorOccurredSelector:errorSelector];
  [parser setDelegate:self.parserDelegate];  
  
  return parser;
}



#pragma mark -
#pragma mark Test Methods
- (void)testParserDelegateIsNotNULL
{
  self.parserDelegate = 
    [[TrailConditionsFeedParserDelegate alloc] 
     initWithTrailSystem:nil
     managedObjectContext:self.managedObjectContext
     parserResultDelegate:self
     didEndDocumentSelector:nil
     parseErrorOccurredSelector:nil];
  
  STAssertNotNULL(self.parserDelegate, @"Parser delegate is NULL.");
}



- (void)testShouldFindTwoTrailConditionItems
{
  NSString *testXML = @"<rss><item></item><item></item></rss>";

  NSXMLParser *parser = 
  [self newTrailConditionsFeedParserWithXMLString:testXML 
                           didEndDocumentSelector:@selector(shouldFindTwoTrailConditions)
                       parseErrorOccurredSelector:@selector(parserErrorOccurred)];

  STAssertTrue([parser parse], @"Parsing was aborted.");
  
  [parser release];
}



- (void)shouldFindTwoTrailConditions
{
  uint expectedFeedItemsCount = 2;
  
  STAssertEquals([self.parserDelegate.trailSystem.trailConditions count],
                 expectedFeedItemsCount,                  
                 @"Incorrect amount of trail conditions parsed.");
}



- (void)testShouldFindTitleElement
{
  NSString *testXML = @"<root><item><title>Perfect - Super title!</title></item></root>";
  
  NSXMLParser *parser = 
  [self newTrailConditionsFeedParserWithXMLString:testXML
                           didEndDocumentSelector:@selector(shouldFindTitleElement)
                       parseErrorOccurredSelector:@selector(parserErrorOccurred)];
  
  STAssertTrue([parser parse], @"Parsing was aborted.");
  
  [parser release];
}



- (void)shouldFindTitleElement
{
  NSString *expectedCondition = @"Perfect";
  NSString *expectedTitle = @"Super title!";

  uint expectedTrailConditionsCount = 1;
  
  STAssertEquals([self.parserDelegate.trailSystem.trailConditions count], 
                 expectedTrailConditionsCount,
                 @"No trail conditions available.");
  
  TrailCondition *trailCondition = 
    [self.parserDelegate.trailSystem.trailConditions anyObject];
  STAssertNotNil(trailCondition, @"Trail condition is nil.");
  
  STAssertEqualStrings(trailCondition.condition,
                       expectedCondition,
                       @"Conditions don't match");
  
  STAssertEqualStrings(trailCondition.title, 
                       expectedTitle, 
                       @"Titles don't match.");
}



- (void)testShouldFindDateELement
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  NSString *expectedDateFormat = @"EEE, dd MMM yyyy HH:mm:ss ZZZ";
  [dateFormatter setDateFormat:expectedDateFormat];
  
  NSString *expectedDateString = @"Fri, 26 Feb 2010 02:00:56 +0000";
  
  NSString *testXML = 
    [NSString 
     stringWithFormat:@"<rss><item><pubDate>%@</pubDate></item></rss>",
     expectedDateString];

  NSXMLParser *parser = 
    [self newTrailConditionsFeedParserWithXMLString:testXML 
                             didEndDocumentSelector:@selector(shouldFindDateElement)
                         parseErrorOccurredSelector:@selector(parserErrorOccurred)];
  
  STAssertTrue([parser parse], @"Parsing was aborted.");
  
  [dateFormatter release];
  [parser release];
}



- (void)shouldFindDateElement
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  
  NSString *expectedDateFormat = @"EEE, dd MMM yyyy HH:mm:ss ZZZ";
  [dateFormatter setDateFormat:expectedDateFormat];
  
  NSString *expectedDateString = @"Fri, 26 Feb 2010 02:00:56 +0000";
  NSDate *expectedDate = [dateFormatter dateFromString:expectedDateString];
  
  TrailCondition *trailCondition = 
    [self.parserDelegate.trailSystem.trailConditions anyObject];
  STAssertEqualObjects(trailCondition.date, 
                       expectedDate, 
                       @"Expected date not found.");
  
  [trailCondition release];
}



- (void)testShouldFindUserElement
{
  NSString *testXML = @"<?xml version=\"1.0\" encoding=\"utf-8\" ?><rss version=\"2.0\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\"><item><dc:creator>vegancheesesteak</dc:creator></item></rss>";
  
  NSXMLParser *parser = 
    [self newTrailConditionsFeedParserWithXMLString:testXML
                             didEndDocumentSelector:@selector(shouldFindUserElement)
                         parseErrorOccurredSelector:@selector(parserErrorOccurred)];
  
  STAssertTrue([parser parse], @"Parsing was aborted.");
  
  [parser release];  
}



- (void)shouldFindUserElement
{
  NSString *expectedUser = @"vegancheesesteak";
  
  uint expectedTrailConditionsCount = 1;
  STAssertEquals([self.parserDelegate.trailSystem.trailConditions count],
                 expectedTrailConditionsCount,
                 @"No trail conditions available.");
  
  TrailCondition *trailCondition = 
    [self.parserDelegate.trailSystem.trailConditions anyObject];
  STAssertNotNil(trailCondition, @"Trail condition is nil.");
  
  STAssertEqualStrings(trailCondition.user, 
                       expectedUser, 
                       @"Users don't match.");
}



- (void)testShouldAllowForCaseInsensitiveTagsInRSSFeed
{
  char *string = "<RSS></RSS>";
  NSString *testXML = [NSString stringWithUTF8String:string];
  
  NSXMLParser *parser = 
  [self newTrailConditionsFeedParserWithXMLString:testXML
                           didEndDocumentSelector:@selector(shouldAllowForCaseInsensitiveTagsInRSSFeed)
                       parseErrorOccurredSelector:@selector(parserErrorOccurred)];
  
  STAssertTrue([parser parse], @"Parsing was aborted.");
  
  [parser release];   
}



- (void)shouldAllowForCaseInsensitiveTagsInRSSFeed
{
  int elementCount = [self.parserDelegate elementCount];
  STAssertTrue(elementCount > 0,
               @"Tags should be able to be upper or lower case.");
}



- (void)testShouldShowAlertIfNotRSSFeed
{
  char *string = "<html></html>";
  NSString *testXML = [NSString stringWithUTF8String:string];
  
  NSXMLParser *parser = 
  [self newTrailConditionsFeedParserWithXMLString:testXML
                           didEndDocumentSelector:@selector(shouldShowAlertIfNotRSSFeed)
                       parseErrorOccurredSelector:@selector(expectedParserErrorOccurred)];
  
  STAssertTrue([parser parse], @"Parsing was aborted.");
  
  [parser release]; 
}



- (void)shouldShowAlertIfNotRSSFeed
{
  int expectedElementCount = 0;
  int actualElementCount = [self.parserDelegate elementCount];
  STAssertEquals(expectedElementCount,
                 actualElementCount,
                 @"No elements should have been parsed.");
}



- (void)expectedParserErrorOccurred
{
  STAssertTrue(YES, 
               @"This error was expected.");
}



- (void)testShouldRemoveHTMLEntitiesFromTitle
{
  char *string = "<rss><item><title>Excellent - It&#039;s awesome!</title></item></rss>\0";
  NSString *testXML = [NSString stringWithUTF8String:string];
  
  NSXMLParser *parser = 
  [self newTrailConditionsFeedParserWithXMLString:testXML
                           didEndDocumentSelector:@selector(shouldRemoveHTMLEntitiesFromTitle) 
                       parseErrorOccurredSelector:@selector(parserErrorOccurred)];
  
  STAssertTrue([parser parse], @"Parsing was aborted.");
  
  [parser release];
}



- (void)shouldRemoveHTMLEntitiesFromTitle
{
  NSString *expectedTitle = @"Its awesome";
  
  TrailCondition *trailCondition = 
    [self.parserDelegate.trailSystem.trailConditions anyObject];
  
  STAssertEqualStrings(trailCondition.title,
                       expectedTitle,
                       @"Titles don't match.");
}



- (void)parserErrorOccurred
{
  STFail(@"Parser error occurred.");
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
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
    
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    
		abort();
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

