/*
 _SPLUITableViewUpdate.m
 Copyright (c) 2015 Oliver Letterer <oliver.letterer@gmail.com>, Sparrow-Labs

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "_SPLUITableViewUpdate.h"
#import "_SPLTableViewUpdateState.h"



@interface _SPLUITableViewUpdate ()

@property (nonatomic, assign) NSInteger updateLevel;
@property (nonatomic, strong) _SPLTableViewUpdateState *state;

@end



@implementation _SPLUITableViewUpdate

- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [super init]) {
        _tableView = tableView;
    }
    return self;
}

- (void)tableViewBehaviorBeginUpdates:(id<SPLTableViewBehavior>)tableViewBehavior
{
    self.updateLevel++;

    if (self.updateLevel == 1) {
        self.state = [[_SPLTableViewUpdateState alloc] init];
    }
}

- (void)tableViewBehaviorEndUpdates:(id<SPLTableViewBehavior>)tableViewBehavior
{
    self.updateLevel--;

    if (self.updateLevel == 0) {
        [self _applyUpdateFromState:self.state];
        self.state = nil;
    }
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (self.updateLevel == 0) {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } else {
        [self.state insertRowsAtIndexPaths:indexPaths withRowAnimation:animation fromTableViewBehavior:tableViewBehavior];
    }
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (self.updateLevel == 0) {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } else {
        [self.state deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation fromTableViewBehavior:tableViewBehavior];
    }
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior;
{
    if (self.updateLevel == 0) {
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } else {
        [self.state reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation fromTableViewBehavior:tableViewBehavior];
    }
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (self.updateLevel == 0) {
        [self.tableView insertSections:sections withRowAnimation:animation];
    } else {
        [self.state insertSections:sections withRowAnimation:animation fromTableViewBehavior:tableViewBehavior];
    }
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (self.updateLevel == 0) {
        [self.tableView deleteSections:sections withRowAnimation:animation];
    } else {
        [self.state deleteSections:sections withRowAnimation:animation fromTableViewBehavior:tableViewBehavior];
    }
}

- (void)_applyUpdateFromState:(_SPLTableViewUpdateState *)state
{
    NSInteger totalChanges = state.deletedSections.count + state.insertedSections.count + state.deletedIndexPaths.count + state.insertedIndexPaths.count + state.updatedIndexPaths.count;

    if (totalChanges > 50 || !self.tableView.window) {
        return [self.tableView reloadData];
    }

    NSIndexPath *(^transform)(NSIndexPath *indexPath) = ^NSIndexPath *(NSIndexPath *indexPath) {
        NSIndexPath *result = indexPath;

        for (_SPLSectionUpdate *update in state.insertedSections) {
            if (update.section <= result.section) {
                result = [NSIndexPath indexPathForRow:result.row inSection:result.section + 1];
            }
        }

        return result;
    };

    [self.tableView beginUpdates];

    for (_SPLSectionUpdate *update in state.deletedSections) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:update.animation];
    }

    for (_SPLSectionUpdate *update in state.insertedSections) {
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:update.animation];
    }

    for (_SPLIndexPathUpdate *update in state.deletedIndexPaths) {
        [self.tableView deleteRowsAtIndexPaths:@[ transform(update.indexPath) ] withRowAnimation:update.animation];
    }

    for (_SPLIndexPathUpdate *update in state.insertedIndexPaths) {
        [self.tableView insertRowsAtIndexPaths:@[ transform(update.indexPath) ] withRowAnimation:update.animation];
    }

    for (_SPLIndexPathUpdate *update in state.updatedIndexPaths) {
        [self.tableView reloadRowsAtIndexPaths:@[ transform(update.indexPath) ] withRowAnimation:update.animation];
    }

    [self.tableView endUpdates];
}

@end
