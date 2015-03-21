//
//  ManagedObject.h
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer on 21.03.15.
//  Copyright (c) 2015 Oliver Letterer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ManagedObject : NSManagedObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *date;

@end
