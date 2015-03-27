//
//  _SPLTableViewUpdateState.h
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <SPLTableViewBehavior/SPLTableViewUpdate.h>

@interface _SPLIndexPathUpdate : NSObject

@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) UITableViewRowAnimation animation;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation NS_DESIGNATED_INITIALIZER;

@end

@interface _SPLSectionUpdate : NSObject

@property (nonatomic, readonly) NSInteger section;
@property (nonatomic, readonly) UITableViewRowAnimation animation;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithSection:(NSInteger)section animation:(UITableViewRowAnimation)animation NS_DESIGNATED_INITIALIZER;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface _SPLTableViewUpdateState : NSObject <SPLTableViewUpdate>

@property (nonatomic, readonly) NSArray *insertedSections;
@property (nonatomic, readonly) NSArray *deletedSections;

@property (nonatomic, readonly) NSArray *insertedIndexPaths;
@property (nonatomic, readonly) NSArray *deletedIndexPaths;
@property (nonatomic, readonly) NSArray *updatedIndexPaths;

@end
