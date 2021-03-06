/*
 SPLFetchedResultsBehavior.m
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

#import "SPLFetchedResultsBehavior.h"
#import "UITableViewCell+SPLTableViewBehavior.h"



@interface SPLFetchedResultsBehavior ()

@property (nonatomic, copy) void(^action)(id object);
@property (nonatomic, readonly) void(^configuration)(id cell, id object);
@property (nonatomic, readonly) UITableViewCellPrototypeDeque deque;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *insertedRows;

@end



@implementation SPLFetchedResultsBehavior

#pragma mark - setters and getters

- (void)setController:(NSFetchedResultsController * __nonnull)controller
{
    if (controller != _controller) {
        _controller.delegate = nil;

        _controller = controller;

        _controller.delegate = self;
        [_controller performFetch:NULL];

        [self.update reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone fromTableViewBehavior:self];
    }
}

- (void)setDeletionHandler:(void (^ __nullable)(id __nonnull object))deletionHandler
{
    return [self setDeletionHandler:deletionHandler withName:nil];
}

- (void)setDeletionHandler:(void (^ __nullable)(id __nonnull object))deletionHandler withName:(nullable NSString *)deleteConfirmationName
{
    _deletionHandler = deletionHandler;
    _deleteConfirmationName = deleteConfirmationName;
}

#pragma mark - Initialization

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithPrototype:(UITableViewCell *)prototype controller:(NSFetchedResultsController *)controller configuration:(void(^)(id cell, id object))configuration
{
    return [self initWithPrototype:prototype controller:controller configuration:configuration action:nil];
}

- (instancetype)initWithPrototype:(UITableViewCell *)prototype controller:(NSFetchedResultsController *)controller configuration:(void(^)(id cell, id object))configuration action:(void(^)(id object))action
{
    if (self = [super init]) {
        if (controller.sectionNameKeyPath != nil) {
            [NSException raise:NSInternalInconsistencyException format:@"SPLFetchedResultsBehavior (%@) only supports NSFetchedResultsController with single sections: %@", self, controller];
        }

        _deque = prototype.dequeBlock;
        _configuration = configuration;
        _action = action;
        _insertedRowsScrollPosition = UITableViewScrollPositionNone;

        self.controller = controller;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (aSelector == @selector(tableView:didSelectRowAtIndexPath:)) {
        return self.action != nil;
    }

    if (aSelector == @selector(tableView:canEditRowAtIndexPath:) || aSelector == @selector(tableView:commitEditingStyle:forRowAtIndexPath:)) {
        return self.deletionHandler != nil;
    }

    if (aSelector == @selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)) {
        return self.deletionHandler != nil && self.deleteConfirmationName.length > 0;
    }

    if (aSelector == @selector(tableView:heightForRowAtIndexPath:)) {
        return self.computesHeight != nil;
    }

    return [super respondsToSelector:aSelector];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView = tableView;
    return self.controller.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.deque(tableView);

    id object = self.controller.fetchedObjects[indexPath.row];
    self.configuration(cell, object);

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id object = self.controller.fetchedObjects[indexPath.row];
        self.deletionHandler(object);
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.controller.fetchedObjects[indexPath.row];
    self.action(object);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.deleteConfirmationName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.controller.fetchedObjects[indexPath.row];
    return self.computesHeight(object);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.update tableViewBehaviorBeginUpdates:self];

    self.insertedRows = [NSMutableArray array];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.update tableViewBehaviorEndUpdates:self];

    if (self.observer != nil) {
        self.observer();
    }

    if (self.insertedRows.count > 0 && self.insertedRowsScrollPosition != UITableViewScrollPositionNone) {
        NSIndexPath *lastIndexPath = [self.insertedRows sortedArrayUsingSelector:@selector(compare:)].lastObject;
        lastIndexPath = [self.update convertIndexPath:lastIndexPath fromChildBehavior:self];

        [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:self.insertedRowsScrollPosition animated:YES];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.insertedRows addObject:newIndexPath];
            [self.update insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationTop fromTableViewBehavior:self];
            break;
        } case NSFetchedResultsChangeDelete: {
            [self.update deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationTop fromTableViewBehavior:self];
            break;
        } case NSFetchedResultsChangeUpdate: {
            [self.update reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone fromTableViewBehavior:self];
            break;
        } case NSFetchedResultsChangeMove: {
            if ([indexPath isEqual:newIndexPath]) {
                return;
            }

            [self.update insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationTop fromTableViewBehavior:self];
            [self.update deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationTop fromTableViewBehavior:self];
            break;
        }
    }
}

@end
