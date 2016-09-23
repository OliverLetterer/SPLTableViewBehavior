/*
 SPLCompoundBehavior.m
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

#import "SPLCompoundBehavior.h"

#import <SPLTableViewBehavior/RuntimeHelpers.h>



@interface SPLCompoundBehavior () <SPLTableViewUpdate>

@end



@implementation SPLCompoundBehavior

#pragma mark - setters and getters

- (void)setChildBehaviors:(NSArray *)childBehaviors
{
    [self setChildBehaviors:childBehaviors withRowAnimation:UITableViewRowAnimationNone];
}

- (void)setChildBehaviors:(NSArray *)childBehaviors withRowAnimation:(UITableViewRowAnimation)animation
{
    if (childBehaviors != _childBehaviors) {
        for (id<SPLTableViewBehavior> behavior in _childBehaviors) {
            behavior.update = nil;
        }

        NSArray *previousVisibleBehaviors = _visibleBehaviors;

        _childBehaviors = childBehaviors;
        _visibleBehaviors = childBehaviors;

        for (id<SPLTableViewBehavior> behavior in _childBehaviors) {
            behavior.update = self;
        }

        [self _animateFromVisibleBehaviors:previousVisibleBehaviors to:_visibleBehaviors withAnimation:animation];
    }
}

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

- (void)reloadWithRowAnimation:(UITableViewRowAnimation)animation
{
    [self.update tableViewBehaviorBeginUpdates:self];
    [self.update reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.visibleBehaviors.count)] withRowAnimation:animation fromTableViewBehavior:self];
    [self.update tableViewBehaviorEndUpdates:self];
}

#pragma mark - Initialization

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithBehaviors:(NSArray *)behaviors
{
    if (self = [super init]) {
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

    NSArray *protocols = @[ @protocol(UITableViewDataSource), @protocol(UITableViewDelegate), @protocol(UIScrollViewDelegate) ];
    for (Protocol *protocol in protocols) {
        if ([self _canForwardSelector:aSelector inProtocol:protocol]) {
            return YES;
        }
    }

    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSArray *protocols = @[ @protocol(UITableViewDataSource), @protocol(UITableViewDelegate), @protocol(UIScrollViewDelegate) ];

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
    if (objc_protocolContainsInstanceMethod(@protocol(UIScrollViewDelegate), invocation.selector)) {
        NSParameterAssert(invocation.methodSignature.methodReturnLength == 0);

        for (id<SPLTableViewBehavior> behavior in self.childBehaviors) {
            if ([behavior respondsToSelector:invocation.selector]) {
                [invocation invokeWithTarget:behavior];
            }
        }
        return;
    }

    if ([self _isIndexPathBasedSelector:invocation.selector]) {
        NSUInteger indexPathIndex = NSNotFound;

        for (NSUInteger i = 0; i < invocation.methodSignature.numberOfArguments; i++) {
            const char *signature = [invocation.methodSignature getArgumentTypeAtIndex:i];
            if (signature[0] == '@') {
                __unsafe_unretained id object = nil;
                [invocation getArgument:&object atIndex:i];

                if ([object isKindOfClass:[NSIndexPath class]]) {
                    indexPathIndex = i;
                }
            }
        }

        NSParameterAssert(indexPathIndex != NSNotFound);

        __unsafe_unretained NSIndexPath *indexPath = nil;

        [invocation getArgument:&indexPath atIndex:indexPathIndex];

        NSIndexPath *childIndexPath = nil;
        id<SPLTableViewBehavior> behavior = [self _behaviorForIndexPath:indexPath childIndexPath:&childIndexPath];

        if ([behavior respondsToSelector:invocation.selector]) {
            [invocation setArgument:&childIndexPath atIndex:indexPathIndex];
            return [invocation invokeWithTarget:behavior];
        }
    } else if ([self _isSectionBasedSelector:invocation.selector]) {
        NSUInteger sectionIndex = NSNotFound;

        for (NSUInteger i = 0; i < invocation.methodSignature.numberOfArguments; i++) {
            const char *signature = [invocation.methodSignature getArgumentTypeAtIndex:i];
            if (strcmp(signature, @encode(NSInteger)) == 0) {
                sectionIndex = i;
            }
        }

        NSParameterAssert(sectionIndex != NSNotFound);

        NSInteger section = 0;
        [invocation getArgument:&section atIndex:sectionIndex];

        NSInteger childSection = 0;
        id<SPLTableViewBehavior> behavior = [self _behaviorInSection:section childSection:&childSection];

        if ([behavior respondsToSelector:invocation.selector]) {
            [invocation setArgument:&childSection atIndex:sectionIndex];
            return [invocation invokeWithTarget:behavior];
        }
    }

    if (invocation.methodSignature.methodReturnLength > 0) {
        void *result = calloc(invocation.methodSignature.methodReturnLength, 1);
        [invocation setReturnValue:result];
        free(result);
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 0;
    for (id<SPLTableViewBehavior> behavior in self.visibleBehaviors) {
        count += [self _numberOfSectionsInBehavior:behavior];
    }

    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger childSection = 0;
    id<SPLTableViewBehavior> behavior = [self _behaviorInSection:section childSection:&childSection];
    return [behavior tableView:tableView numberOfRowsInSection:childSection];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *childIndexPath = nil;
    id<SPLTableViewBehavior> behavior = [self _behaviorForIndexPath:indexPath childIndexPath:&childIndexPath];
    return [behavior tableView:tableView cellForRowAtIndexPath:childIndexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *childIndexPath = nil;
    id<SPLTableViewBehavior> behavior = [self _behaviorForIndexPath:indexPath childIndexPath:&childIndexPath];
    return [behavior respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)] ? [behavior tableView:tableView heightForRowAtIndexPath:childIndexPath] : tableView.rowHeight;
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
    NSMutableIndexSet *newSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [newSections addIndex:[self _convertSection:idx fromTableViewBehavior:tableViewBehavior]];
    }];

    [self.update insertSections:newSections withRowAnimation:animation fromTableViewBehavior:self];
}

- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    NSMutableIndexSet *newSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [newSections addIndex:[self _convertSection:idx fromTableViewBehavior:tableViewBehavior]];
    }];

    [self.update deleteSections:newSections withRowAnimation:animation fromTableViewBehavior:self];
}

- (void)reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    NSMutableIndexSet *newSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [newSections addIndex:[self _convertSection:idx fromTableViewBehavior:tableViewBehavior]];
    }];

    [self.update reloadSections:newSections withRowAnimation:animation fromTableViewBehavior:self];
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

- (void)_animateFromVisibleBehaviors:(NSArray *)previousBehaviors to:(NSArray *)visibleBehaviors withAnimation:(UITableViewRowAnimation)animation
{
    [self.update tableViewBehaviorBeginUpdates:self];

    __block NSInteger deletionOffset = 0;
    [previousBehaviors enumerateObjectsUsingBlock:^(id<SPLTableViewBehavior> behavior, NSUInteger idx, BOOL *stop) {
        NSInteger count = [self _numberOfSectionsInBehavior:behavior];

        if (![visibleBehaviors containsObject:behavior]) {
            for (NSInteger i = 0; i < count; i++) {
                NSIndexSet *section = [NSIndexSet indexSetWithIndex:deletionOffset + i];
                [self.update deleteSections:section withRowAnimation:animation fromTableViewBehavior:self];
            }
        }

        deletionOffset += count;
    }];

    __block NSInteger insertionOffset = 0;
    [visibleBehaviors enumerateObjectsUsingBlock:^(id<SPLTableViewBehavior> behavior, NSUInteger idx, BOOL *stop) {
        NSInteger count = [self _numberOfSectionsInBehavior:behavior];

        if (![previousBehaviors containsObject:behavior]) {
            for (NSInteger i = 0; i < count; i++) {
                NSIndexSet *section = [NSIndexSet indexSetWithIndex:insertionOffset + i];
                [self.update insertSections:section withRowAnimation:animation fromTableViewBehavior:self];
            }
        }

        insertionOffset += count;
    }];

    [self.update tableViewBehaviorEndUpdates:self];
}

- (NSInteger)_numberOfSectionsInBehavior:(id<SPLTableViewBehavior>)behavior
{
    if ([behavior respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [behavior numberOfSectionsInTableView:(UITableView *__nonnull)nil];
    } else {
        return 1;
    }
}

- (NSInteger)_convertSection:(NSInteger)section fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    NSInteger index = [self.visibleBehaviors indexOfObject:tableViewBehavior];

    NSInteger count = 0;
    for (id<SPLTableViewBehavior> behavior in [self.visibleBehaviors subarrayWithRange:NSMakeRange(0, index)]) {
        count += [self _numberOfSectionsInBehavior:behavior];
    }

    return section + count;
}

- (NSIndexPath *)_convertIndexPath:(NSIndexPath *)indexPath fromTableViewBehavior:(id<SPLTableViewBehavior>)tableViewBehavior
{
    NSInteger section = [self _convertSection:indexPath.section fromTableViewBehavior:tableViewBehavior];
    return [NSIndexPath indexPathForRow:indexPath.row inSection:section];
}

- (BOOL)_isIndexPathBasedSelector:(SEL)selector
{
    NSString *lowercaseSelector = NSStringFromSelector(selector).lowercaseString;

    if ([lowercaseSelector containsString:@"rowatindexpath"] || [lowercaseSelector containsString:@"rowwithindexpath"]) {
        return YES;
    }

    return NO;
}

- (BOOL)_isSectionBasedSelector:(SEL)selector
{
    NSString *lowercaseSelector = NSStringFromSelector(selector).lowercaseString;

    if ([lowercaseSelector containsString:@"insection"] || [lowercaseSelector containsString:@"forsection"]) {
        return YES;
    }

    return NO;
}

- (BOOL)_canForwardSelector:(SEL)selector inProtocol:(Protocol *)protocol
{
    if (!objc_protocolContainsInstanceMethod(protocol, selector)) {
        return NO;
    }

    BOOL(^anyChildRespondsToSelector)(void) = ^BOOL {
        for (id<SPLTableViewBehavior> behavior in self.childBehaviors) {
            if ([behavior respondsToSelector:selector]) {
                return YES;
            }
        }

        return NO;
    };

    if (protocol == @protocol(UIScrollViewDelegate)) {
        return anyChildRespondsToSelector();
    }

    NSString *lowercaseSelector = NSStringFromSelector(selector).lowercaseString;
    if (![lowercaseSelector containsString:@"tableview"]) {
        return NO;
    }

    if (![self _isIndexPathBasedSelector:selector] && ![self _isSectionBasedSelector:selector]) {
        return NO;
    }

    return anyChildRespondsToSelector();
}

- (id<SPLTableViewBehavior>)_behaviorInSection:(NSInteger)section childSection:(out NSInteger *)childSection
{
    NSInteger currentIndex = 0;
    NSRange currentRange = NSMakeRange(0, [self _numberOfSectionsInBehavior:self.visibleBehaviors[currentIndex]]);

    while (!NSLocationInRange(section, currentRange)) {
        currentIndex++;
        currentRange = NSMakeRange(currentRange.location + currentRange.length, [self _numberOfSectionsInBehavior:self.visibleBehaviors[currentIndex]]);
    }

    if (childSection) {
        *childSection = section - currentRange.location;
    }

    return self.visibleBehaviors[currentIndex];
}

- (id<SPLTableViewBehavior>)_behaviorForIndexPath:(NSIndexPath *)indexPath childIndexPath:(out NSIndexPath **)childIndexPath
{
    NSInteger childSection = 0;
    id<SPLTableViewBehavior> behavior = [self _behaviorInSection:indexPath.section childSection:&childSection];
    
    if (childIndexPath) {
        *childIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:childSection];
    }
    
    return behavior;
}

@end
