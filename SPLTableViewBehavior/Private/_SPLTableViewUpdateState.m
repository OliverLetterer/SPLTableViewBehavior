//
//  _SPLTableViewUpdateState.m
//  Pods
//
//  Created by Oliver Letterer.
//  Copyright 2015 __MyCompanyName__. All rights reserved.
//

#import "_SPLTableViewUpdateState.h"

@implementation _SPLIndexPathUpdate

- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation
{
    if (self = [super init]) {
        _indexPath = indexPath;
        _animation = animation;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[_SPLIndexPathUpdate class]]) {
        return [self isEqualToUpdate:object];
    }
    return [super isEqual:object];
}

- (BOOL)isEqualToUpdate:(_SPLIndexPathUpdate *)object
{
    return [object.indexPath isEqual:self.indexPath];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%ld - %ld", (long)self.indexPath.section, (long)self.indexPath.row];
}

@end

@implementation _SPLSectionUpdate

- (instancetype)initWithSection:(NSInteger)section animation:(UITableViewRowAnimation)animation
{
    if (self = [super init]) {
        _section = section;
        _animation = animation;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[_SPLSectionUpdate class]]) {
        return [self isEqualToUpdate:object];
    }
    return [super isEqual:object];
}

- (BOOL)isEqualToUpdate:(_SPLSectionUpdate *)object
{
    return self.section == object.section;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%ld", (long)self.section];
}

@end



@interface _SPLTableViewUpdateState ()

@property (nonatomic, strong) NSArray *insertedSections;
@property (nonatomic, strong) NSArray *deletedSections;

@property (nonatomic, strong) NSArray *insertedIndexPaths;
@property (nonatomic, strong) NSArray *deletedIndexPaths;
@property (nonatomic, strong) NSArray *updatedIndexPaths;

@end



@implementation _SPLTableViewUpdateState

- (instancetype)init
{
    if (self = [super init]) {
        _insertedSections = @[];
        _deletedSections = @[];

        _insertedIndexPaths = @[];
        _deletedIndexPaths = @[];
        _updatedIndexPaths = @[];
    }
    return self;
}

- (NSString *)description
{
    NSArray *updates = @[
                         [NSString stringWithFormat:@"\t* insertedSections: %@", [self.insertedSections componentsJoinedByString:@", "]],
                         [NSString stringWithFormat:@"\t* deletedSections: %@", [self.deletedSections componentsJoinedByString:@", "]],

                         [NSString stringWithFormat:@"\t* insertedIndexPaths: %@", [self.insertedIndexPaths componentsJoinedByString:@", "]],
                         [NSString stringWithFormat:@"\t* deletedIndexPaths: %@", [self.deletedIndexPaths componentsJoinedByString:@", "]],
                         [NSString stringWithFormat:@"\t* updatedIndexPaths: %@", [self.updatedIndexPaths componentsJoinedByString:@", "]],
                         ];
    return [NSString stringWithFormat:@"%@:\n%@", super.description, [updates componentsJoinedByString:@"\n"]];
}

- (void)tableViewBehaviorBeginUpdates:(id<SPLTableViewBehavior>)tableViewBehavior
{

}

- (void)tableViewBehaviorEndUpdates:(id<SPLTableViewBehavior>)tableViewBehavior
{

}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    self.insertedIndexPaths = [self _insertIndexPaths:[self _removeDeletedIndexPaths:indexPaths] intoArray:self.insertedIndexPaths withAnimation:animation];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    self.deletedIndexPaths = [self _insertIndexPaths:[self _removeDeletedIndexPaths:indexPaths] intoArray:self.deletedIndexPaths withAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    self.updatedIndexPaths = [self _insertIndexPaths:[self _removeDeletedIndexPaths:indexPaths] intoArray:self.updatedIndexPaths withAnimation:animation];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        _SPLSectionUpdate *update = [[_SPLSectionUpdate alloc] initWithSection:section animation:animation];
        if (![self.insertedSections containsObject:update]) {
            self.insertedSections = [self.insertedSections arrayByAddingObject:update];
        }
    }];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        _SPLSectionUpdate *update = [[_SPLSectionUpdate alloc] initWithSection:section animation:animation];
        if (![self.deletedSections containsObject:update]) {
            self.deletedSections = [self.deletedSections arrayByAddingObject:update];

            self.insertedIndexPaths = [self _removeIndexPathsWithSection:section fromArray:self.insertedIndexPaths];
            self.deletedIndexPaths = [self _removeIndexPathsWithSection:section fromArray:self.deletedIndexPaths];
            self.updatedIndexPaths = [self _removeIndexPathsWithSection:section fromArray:self.updatedIndexPaths];
        }
    }];
}

- (NSArray *)_removeIndexPathsWithSection:(NSInteger)section fromArray:(NSArray *)array
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:array];
    for (_SPLIndexPathUpdate *update in array) {
        if (update.indexPath.section == section) {
            [result removeObject:update];
        }
    }
    return result;
}

- (NSArray *)_insertIndexPaths:(NSArray *)newIndexPaths intoArray:(NSArray *)indexPaths withAnimation:(UITableViewRowAnimation)animation
{
    NSMutableArray *result = [NSMutableArray arrayWithArray:indexPaths];
    for (NSIndexPath *indexPath in newIndexPaths) {
        if (![result containsObject:indexPath]) {
            [result addObject:[[_SPLIndexPathUpdate alloc] initWithIndexPath:indexPath animation:animation]];
        }
    }
    return result;
}

- (NSArray *)_removeDeletedIndexPaths:(NSArray *)indexPaths
{
    NSMutableIndexSet *deletedSections = [NSMutableIndexSet indexSet];
    for (_SPLSectionUpdate *update in self.deletedSections) {
        [deletedSections addIndex:update.section];
    }

    NSMutableArray *result = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        if (![deletedSections containsIndex:indexPath.section]) {
            [result addObject:indexPath];
        }
    }
    return result;
}

@end
