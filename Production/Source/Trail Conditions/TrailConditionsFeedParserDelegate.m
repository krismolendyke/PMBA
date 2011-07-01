//
//  TrailConditionsFeedParser.m
//  PMBA
//
//  Created by Kris on 3/1/10.
//  Copyright 2010 Siemens. All rights reserved.
//



#import "TrailConditionsFeedParserDelegate.h"
#import "TrailSystem.h"
#import "TrailCondition.h"
#import "PMBAAppDelegate.h"
#import "PMBAErrors.h"



@interface TrailConditionsFeedParserDelegate(PrivateMethods)
- (void)parseDate;
- (void)deleteSavedTrailConditions;
- (void)parseConditionAndTitle;
- (BOOL)isHTMLEntityInString:(NSString *)string;
- (void)parseCreator;
@end



@implementation TrailConditionsFeedParserDelegate



#pragma mark -
#pragma mark Constants
#define kDateFormat @"EEE, dd MMM yyyy HH:mm:ss ZZZ"



#pragma mark -
#pragma mark Properties
@synthesize currentElementName;
@synthesize trailSystem;
@synthesize dateFormatter;
@synthesize htmlEntityReplacementMap;
@synthesize elementCount;



#pragma mark -
#pragma mark Instance Methods
- (id)initWithTrailSystem:(TrailSystem *)system
     managedObjectContext:(NSManagedObjectContext *)context 
     parserResultDelegate:(id)delegate
   didEndDocumentSelector:(SEL)successSelector
parseErrorOccurredSelector:(SEL)errorSelector
{
  if(self = [super init])
  {
    // Drupal throws some weird escaped characters into the feed.  Presumably
    // for security reasons, but they look bizarre if they aren't cleaned up
    // and replaced with the characters they represent.
    htmlEntityReplacementMap = 
    [NSDictionary dictionaryWithObjectsAndKeys:
     @"\"", @"&#034;",
     @"'", @"&#039;",
     @"_", @"&#095;",     
     @"`", @"&#096;",
     nil];
    
    elementCount = 0;
    self.trailSystem = system;    
    managedObjectContext = context;
    parserResultDelegate = delegate;
    didEndDocumentSelector = successSelector;
    parseErrorOccurredSelector = errorSelector;

    inItemNode = NO;
    
    currentElementName = [[NSString alloc] init];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:kDateFormat];

    [self deleteSavedTrailConditions];
  }
  
  return self;
}



- (void)deleteSavedTrailConditions
{
  if([self.trailSystem.trailConditions count] > 0)
  {
    for(id trailCondition in self.trailSystem.trailConditions) 
    {
      [managedObjectContext deleteObject:trailCondition];
    }
    
    NSError *error = nil;
    [managedObjectContext save:&error];
  }    
}



#pragma mark -
#pragma mark Parser Methods
- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
  if([elementName caseInsensitiveCompare:@"rss"] == NSOrderedSame)
  {
    elementCount++;    
  }
  
  if(inItemNode && self.currentElementName != elementName)
  {
    currentCharacters = [NSMutableString stringWithCapacity:96];    
  }
  
  self.currentElementName = elementName;  
  
  if([@"item" isEqualToString:elementName])
  {    
    inItemNode = YES;
    
    currentTrailCondition = 
      (TrailCondition *)[NSEntityDescription 
                         insertNewObjectForEntityForName:@"TrailCondition" 
                         inManagedObjectContext:managedObjectContext];
  } 
}



- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
  if(inItemNode && currentCharacters != nil)
  {
    [currentCharacters appendString:string];    
  }
}



- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
  if(inItemNode && [@"pubDate" isEqualToString:elementName])
  {    
    [self parseDate];
  }
  else if(inItemNode && [@"title" isEqualToString:elementName])
  {
    [self parseConditionAndTitle];
  }
  else if(inItemNode && [@"creator" isEqualToString:elementName])
  {
    [self parseCreator];
  }
  
  if([@"item" isEqualToString:elementName])
  {
    inItemNode = NO;
    [self.trailSystem addTrailConditionsObject:currentTrailCondition];
  }
}



- (void)parseDate
{
  currentTrailCondition.date = 
  [self.dateFormatter dateFromString:currentCharacters];  
}



- (void)parseConditionAndTitle
{
  // Format: [Condition] - [Description]
  
  NSArray *titleComponentsArray = 
  [currentCharacters componentsSeparatedByString:@" - "];
  
  // Defaults in case of bad titles
  NSString *condition = @"Good";
  NSString *title = @"";
  
  if([titleComponentsArray count] > 1)
  {
    condition = [titleComponentsArray objectAtIndex:0];      

    title = [titleComponentsArray objectAtIndex:1];  
    
    if([self isHTMLEntityInString:title])
    {
      NSString *htmlEntity;
      NSString *replacement;
      for(htmlEntity in self.htmlEntityReplacementMap)
      {
        replacement = [self.htmlEntityReplacementMap valueForKey:htmlEntity];
        title = [title stringByReplacingOccurrencesOfString:htmlEntity 
                                                 withString:replacement];
      }
    }
  }
  
  currentTrailCondition.condition = condition;
  currentTrailCondition.title = title;  
}



- (BOOL)isHTMLEntityInString:(NSString *)string
{
  return [string rangeOfString:@"&#"].length > 0;
}



- (void)parseCreator
{
  currentTrailCondition.user = currentCharacters;  
}



- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
  NSString *errorDescription = [parseError localizedDescription];
  NSLog(@"%@", errorDescription);
  
  NSString *message = 
    [NSString stringWithFormat:@"%@ Please double check the URL in Settings.", 
     errorDescription];
  
  UIAlertView *alertView = 
  [[UIAlertView alloc] initWithTitle:@"Current Trail Conditions Unavailable" 
                             message:message
                            delegate:self
                   cancelButtonTitle:@"OK"
                   otherButtonTitles:nil];
  [alertView show];
  [alertView release];
}



- (void)parserDidEndDocument:(NSXMLParser *)parser
{
  if(self.elementCount == 0)
  {
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, 
                         nil];
    NSString *description = NSLocalizedString(@"Invalid RSS feed.", @"");
    NSArray *objectArray = [NSArray arrayWithObjects:description, nil];
    NSDictionary *userInfoDictionary = 
      [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray];
    NSError *error = [NSError errorWithDomain:@"PMBAErrors" 
                                         code:PMBANoValidRSSFeedFound
                                     userInfo:userInfoDictionary];

    [self parser:parser parseErrorOccurred:error];
  }
  else 
  {
    [parserResultDelegate performSelector:didEndDocumentSelector];    
  }
}



#pragma mark -
#pragma mark Alert View Methods
- (void)alertView:(UIAlertView *)alertView 
didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  [parserResultDelegate performSelector:parseErrorOccurredSelector];
}



- (void)dealloc
{
  [self.currentElementName release];
  [currentCharacters release];
  [self.htmlEntityReplacementMap release];
  [self.dateFormatter release];
  [self.trailSystem release];
  [currentTrailCondition release];
  [self.currentElementName release];
  
  [super dealloc];
}



@end
