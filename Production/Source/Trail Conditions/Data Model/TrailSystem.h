//
//  TrailSystem.h
//  PMBA
//
//  Created by Kris on 3/30/10.
//  Copyright 2010 Siemens. All rights reserved.
//

#import <CoreData/CoreData.h>

@class TrailCondition;

@interface TrailSystem :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* trailConditions;

@end


@interface TrailSystem (CoreDataGeneratedAccessors)
- (void)addTrailConditionsObject:(TrailCondition *)value;
- (void)removeTrailConditionsObject:(TrailCondition *)value;
- (void)addTrailConditions:(NSSet *)value;
- (void)removeTrailConditions:(NSSet *)value;

@end

