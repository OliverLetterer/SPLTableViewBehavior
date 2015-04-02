/*
 SPLSectionBehavior.m
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


#import "SPLSectionBehavior.h"

#import <SPLTableViewBehavior/RuntimeHelpers.h>



@interface SPLSectionBehavior () <SPLTableViewUpdate>

@end



@implementation SPLSectionBehavior

#pragma mark - setters and getters

- (void)setVisibleBehaviors:(NSArray *)visibleBehaviors
{
    [self setVisibleBehaviors:visibleBehaviors withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setVisibleBehaviors:(NSArray *)visibleBehaviors withRowAnimation:(UITableViewRowAnimation)animation
{
    if (visibleBehaviors != _visibleBehaviors) {
        visibleBehaviors = [visibleBehaviors sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSParameterAssert([self.childBehaviors containsObject:obj1]);
            NSParameterAssert([self.childBehaviors containsObject:obj2]);

            NSNumber *index1 = @([self.childBehaviors indexOfObject:obj1]);
            NSNumber *index2 = @([self.childBehaviors indexOfObject:obj2]);

            return [index1 compare:index2];
        }];

        NSArray *previousVisibleBehaviors = _visibleBehaviors;
        _visibleBehaviors = visibleBehaviors;

        [self _animateFromVisibleBehaviors:previousVisibleBehaviors to:visibleBehaviors withAnimation:animation];
    }
}

#pragma mark - Initialization

- (instancetype)initWithBehaviors:(NSArray *)behaviors
{
    return [self initWithTitle:nil behaviors:behaviors];
}

- (instancetype)initWithTitle:(NSString *)title behaviors:(NSArray *)behaviors
{
    if (self = [super init]) {
        _title = title.copy;
        _childBehaviors = behaviors.copy;
        _visibleBehaviors = behaviors.copy;

        for (id<SPLTableViewBehavior> behavior in _childBehaviors) {
            behavior.update = self;
        }
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }

    if (aSelector == @selector(tableView:titleForHeaderInSection:)) {
        return self.title != nil;
    }

    NSArray *protocols = @[ @protocol(UITableViewDataSource), @protocol(UITableViewDelegate) ];
    for (Protocol *protocol in protocols) {
        if ([self _canForwardSelector:aSelector inProtocol:protocol]) {
            return YES;
        }
    }

    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSArray *protocols = @[ @protocol(UITableViewDataSource), @protocol(UITableViewDelegate) ];

    for (Protocol *protocol in protocols) {
        struct objc_method_description description = objc_protocolGetInstanceMethod(protocol, aSelector);
        if (description.name != NULL) {
            return [NSMethodSignature signatureWithObjCTypes:description.types];
        }
    }

    return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSUInteger tableViewIndex = NSNotFound;
    NSUInteger indexPathIndex = NSNotFound;

    for (NSUInteger i = 0; i < invocation.methodSignature.numberOfArguments; i++) {
        const char *signature = [invocation.methodSignature getArgumentTypeAtIndex:i];
        if (signature[0] == '@') {
            __unsafe_unretained id object = nil;
            [invocation getArgument:&object atIndex:i];

            if ([object isKindOfClass:[UITableView class]]) {
                tableViewIndex = i;
            } else if ([object isKindOfClass:[NSIndexPath class]]) {
                indexPathIndex = i;
            }
        }
    }

    NSParameterAssert(tableViewIndex != NSNotFound);
    NSParameterAssert(indexPathIndex != NSNotFound);

    __unsafe_unretained UITableView *tableView = nil;
    __unsafe_unretained NSIndexPath *indexPath = nil;

    [invocation getArgument:&tableView atIndex:tableViewIndex];
    [invocation getArgument:&indexPath atIndex:indexPathIndex];

    NSIndexPath *childIndexPath = nil;
    id<SPLTableViewBehavior> behavior = [self _behaviorForTableView:tableView atIndexPath:indexPath childIndexPath:&childIndexPath];

    if ([behavior respondsToSelector:invocation.selector]) {
        [invocation setArgument:&childIndexPath atIndex:indexPathIndex];
        return [invocation invokeWithTarget:behavior];
    }

    if (invocation.methodSignature.methodReturnLength > 0) {
        void *result = calloc(invocation.methodSignature.methodReturnLength, 1);
        [invocation setReturnValue:&result];
        free(result);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;

    for (id<SPLTableViewBehavior> behavior in self.visibleBehaviors) {
        numberOfRows += [behavior tableView:tableView numberOfRowsInSection:0];
    }

    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *childIndexPath = nil;
    id<SPLTableViewBehavior> behavior = [self _behaviorForTableView:tableView atIndexPath:indexPath childIndexPath:&childIndexPath];
    return [behavior tableView:tableView cellForRowAtIndexPath:childIndexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.title;
}

#pragma mark - SPLTableViewUpdate

- (void)tableViewBehaviorBeginUpdates:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (![self.visibleBehaviors containsObject:tableViewBehavior]) {
        return;
    }

    [self.update tableViewBehaviorBeginUpdates:self];
}

- (void)tableViewBehaviorEndUpdates:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (![self.visibleBehaviors containsObject:tableViewBehavior]) {
        return;
    }

    [self.update tableViewBehaviorEndUpdates:self];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (![self.visibleBehaviors containsObject:tableViewBehavior]) {
        return;
    }

    NSMutableArray *newIndexPaths = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        [newIndexPaths addObject:[self _convertIndexPath:indexPath fromTableViewBehavior:tableViewBehavior]];
    }

    [self.update insertRowsAtIndexPaths:newIndexPaths withRowAnimation:animation fromTableViewBehavior:self];
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (![self.visibleBehaviors containsObject:tableViewBehavior]) {
        return;
    }

    NSMutableArray *newIndexPaths = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        [newIndexPaths addObject:[self _convertIndexPath:indexPath fromTableViewBehavior:tableViewBehavior]];
    }

    [self.update deleteRowsAtIndexPaths:newIndexPaths withRowAnimation:animation fromTableViewBehavior:self];
}

- (void)reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    if (![self.visibleBehaviors containsObject:tableViewBehavior]) {
        return;
    }

    NSMutableArray *newIndexPaths = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        [newIndexPaths addObject:[self _convertIndexPath:indexPath fromTableViewBehavior:tableViewBehavior]];
    }

    [self.update reloadRowsAtIndexPaths:newIndexPaths withRowAnimation:animation fromTableViewBehavior:self];
}

- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self doesNotRecognizeSelector:_cmd];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildBehavior:(id<SPLTableViewBehavior>)childBehavior
{
    if (![self.visibleBehaviors containsObject:childBehavior]) {
        return nil;
    }

    NSIndexPath *convertedIndexPath = [self _convertIndexPath:indexPath fromTableViewBehavior:childBehavior];
    return [self.update convertIndexPath:convertedIndexPath fromChildBehavior:self];
}

#pragma mark - Private category implementation ()

- (NSIndexPath *)_convertIndexPath:(NSIndexPath *)indexPath fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    NSInteger index = [self.visibleBehaviors indexOfObject:tableViewBehavior];

    NSInteger count = 0;
    for (id<SPLTableViewBehavior> behavior in [self.visibleBehaviors subarrayWithRange:NSMakeRange(0, index)]) {
        count += [behavior tableView:nil numberOfRowsInSection:0];
    }

    return [NSIndexPath indexPathForRow:count + indexPath.row inSection:indexPath.section];
}

- (BOOL)_canForwardSelector:(SEL)selector inProtocol:(Protocol *)protocol
{
    if (!objc_protocolContainsInstanceMethod(protocol, selector)) {
        return NO;
    }

    NSString *lowercaseSelector = NSStringFromSelector(selector).lowercaseString;
    if (![lowercaseSelector containsString:@"tableview"]) {
        return NO;
    }

    if (![lowercaseSelector containsString:@"rowatindexpath"] && ![lowercaseSelector containsString:@"rowwithindexpath"]) {
        return NO;
    }

    for (id<SPLTableViewBehavior> behavior in self.childBehaviors) {
        if ([behavior respondsToSelector:selector]) {
            return YES;
        }
    }

    return NO;
}

- (id<SPLTableViewBehavior>)_behaviorForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath childIndexPath:(out NSIndexPath **)childIndexPath
{
    NSInteger currentIndex = 0;
    NSRange currentRange = NSMakeRange(0, [self.visibleBehaviors[currentIndex] tableView:tableView numberOfRowsInSection:1]);

    while (!NSLocationInRange(indexPath.row, currentRange)) {
        currentIndex++;
        currentRange = NSMakeRange(currentRange.location + currentRange.length, [self.visibleBehaviors[currentIndex] tableView:tableView numberOfRowsInSection:0]);
    }

    if (childIndexPath) {
        *childIndexPath = [NSIndexPath indexPathForRow:indexPath.row - currentRange.location inSection:0];
    }
    
    return self.visibleBehaviors[currentIndex];
}

- (void)_animateFromVisibleBehaviors:(NSArray *)previousBehaviors to:(NSArray *)visibleBehaviors withAnimation:(UITableViewRowAnimation)animation
{
    [self.update tableViewBehaviorBeginUpdates:self];

    __block NSInteger deletionOffset = 0;
    [previousBehaviors enumerateObjectsUsingBlock:^(id<SPLTableViewBehavior> behavior, NSUInteger idx, BOOL *stop) {
        NSInteger count = [behavior tableView:nil numberOfRowsInSection:0];

        if (![visibleBehaviors containsObject:behavior]) {
            for (NSInteger i = 0; i < count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deletionOffset + i inSection:0];
                [self.update deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:animation fromTableViewBehavior:self];
            }
        }

        deletionOffset += count;
    }];

    __block NSInteger insertionOffset = 0;
    [visibleBehaviors enumerateObjectsUsingBlock:^(id<SPLTableViewBehavior> behavior, NSUInteger idx, BOOL *stop) {
        NSInteger count = [behavior tableView:nil numberOfRowsInSection:0];

        if (![previousBehaviors containsObject:behavior]) {
            for (NSInteger i = 0; i < count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertionOffset + i inSection:0];
                [self.update insertRowsAtIndexPaths:@[ indexPath ] withRowAnimation:animation fromTableViewBehavior:self];
            }
        }

        insertionOffset += count;
    }];

    [self.update tableViewBehaviorEndUpdates:self];
}

@end
