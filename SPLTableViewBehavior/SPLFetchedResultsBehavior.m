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

@property (nonatomic, copy) void(^handler)(id object);
@property (nonatomic, readonly) void(^configurator)(UITableViewCell *cell, id object);
@property (nonatomic, readonly) UITableViewCellPrototypeDeque deque;

@end



@implementation SPLFetchedResultsBehavior

#pragma mark - Initialization

- (instancetype)initWithPrototype:(UITableViewCell *)prototype controller:(NSFetchedResultsController *)controller configurator:(void(^)(UITableViewCell *cell, id object))configurator
{
    return [self initWithPrototype:prototype controller:controller configurator:configurator handler:nil];
}

- (instancetype)initWithPrototype:(UITableViewCell *)prototype controller:(NSFetchedResultsController *)controller configurator:(void(^)(UITableViewCell *cell, id object))configurator handler:(void(^)(id object))handler
{
    if (self = [super init]) {
        if (controller.sectionNameKeyPath != nil) {
            [NSException raise:NSInternalInconsistencyException format:@"SPLFetchedResultsBehavior (%@) only supports NSFetchedResultsController with single sections: %@", self, controller];
        }

        _controller = controller;
        _controller.delegate = self;
        [_controller performFetch:NULL];

        _deque = prototype.dequeBlock;
        _configurator = configurator;
        _handler = handler;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if (aSelector == @selector(tableView:didSelectRowAtIndexPath:)) {
        return self.handler != nil;
    }

    return [super respondsToSelector:aSelector];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.controller.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.deque(tableView);

    id object = self.controller.fetchedObjects[indexPath.row];
    self.configurator(cell, object);

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.controller.fetchedObjects[indexPath.row];
    self.handler(object);
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.update tableViewBehaviorBeginUpdates:self];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.update tableViewBehaviorEndUpdates:self];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.update insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationTop fromTableViewBehavior:self];
            break;
        } case NSFetchedResultsChangeDelete: {
            [self.update deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationTop fromTableViewBehavior:self];
            break;
        } case NSFetchedResultsChangeUpdate: {
            [self.update reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone fromTableViewBehavior:self];
            break;
        } case NSFetchedResultsChangeMove: {
            [self.update moveRowAtIndexPath:indexPath toIndexPath:newIndexPath fromTableViewBehavior:self];
            break;
        }
    }
}

@end