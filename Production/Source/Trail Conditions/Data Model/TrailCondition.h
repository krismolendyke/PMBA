//
//  TrailCondition.h
//  PMBA
//
//  Created by Kris on 3/30/10.
//  Copyright 2010 Siemens. All rights reserved.
//

#import <CoreData/CoreData.h>

@class TrailSystem;

@interface TrailCondition :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * user;
@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) TrailSystem * trailSystem;

@end



