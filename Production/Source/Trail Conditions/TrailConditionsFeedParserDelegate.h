//
//  TrailConditionsFeedParser.h
//  PMBA
//
//  Created by Kris on 3/1/10.
//  Copyright 2010 Siemens. All rights reserved.
//



#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
@class TrailSystem;
@class TrailCondition;



@interface TrailConditionsFeedParserDelegate : NSObject <NSXMLParserDelegate,
                                                         UIAlertViewDelegate>
{
  NSString *currentElementName;
  NSManagedObjectContext *managedObjectContext;  

  TrailSystem *trailSystem;
  TrailCondition *currentTrailCondition;

  int elementCount;
  BOOL inItemNode;
  NSMutableString *currentCharacters;
  NSDateFormatter *dateFormatter;
  NSDictionary *htmlEntityReplacementMap;

  id parserResultDelegate;
  SEL didEndDocumentSelector;
  SEL parseErrorOccurredSelector;
}



#pragma mark -
#pragma mark Properties
@property (nonatomic, retain) NSString *currentElementName;
@property (nonatomic, retain) TrailSystem *trailSystem;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) NSDictionary *htmlEntityReplacementMap;
@property (nonatomic, readonly) int elementCount;



#pragma mark -
#pragma mark Instance Methods
- (id)initWithTrailSystem:(TrailSystem *)system
  managedObjectContext:(NSManagedObjectContext *)context 
              parserResultDelegate:(id)delegate
            didEndDocumentSelector:(SEL)successSelector
        parseErrorOccurredSelector:(SEL)errorSelector;



@end
