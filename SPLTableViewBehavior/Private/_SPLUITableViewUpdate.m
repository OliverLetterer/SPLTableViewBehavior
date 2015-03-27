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



@interface _SPLUITableViewUpdate ()

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
    [self.tableView beginUpdates];
}

- (void)tableViewBehaviorEndUpdates:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self.tableView endUpdates];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior;
{
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self.tableView insertSections:sections withRowAnimation:animation];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self.tableView deleteSections:sections withRowAnimation:animation];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self.tableView reloadSections:sections withRowAnimation:animation];
}

@end
