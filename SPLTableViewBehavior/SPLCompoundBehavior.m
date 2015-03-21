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



@interface SPLCompoundBehavior ()

@property (nonatomic, readonly) NSArray *behaviors;

@end



@implementation SPLCompoundBehavior

#pragma mark - Initialization

- (instancetype)initWithBehaviors:(NSArray *)behaviors
{
    if (self = [super init]) {
        _behaviors = behaviors;
    }
    return self;
}

#pragma mark - NSObject

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
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
        id<SPLTableViewBehavior> behavior = self.behaviors[section];

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
    return self.behaviors.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.behaviors[section] tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *childIndexPath = nil;
    id<SPLTableViewBehavior> behavior = [self _behaviorForIndexPath:indexPath childIndexPath:&childIndexPath];
    return [behavior tableView:tableView cellForRowAtIndexPath:childIndexPath];
}

#pragma mark - Private category implementation ()

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

    NSString *lowercaseSelector = NSStringFromSelector(selector).lowercaseString;
    if (![lowercaseSelector containsString:@"tableview"]) {
        return NO;
    }

    if (![self _isIndexPathBasedSelector:selector] && ![self _isSectionBasedSelector:selector]) {
        return NO;
    }

    for (id<SPLTableViewBehavior> behavior in self.behaviors) {
        if ([behavior respondsToSelector:selector]) {
            return YES;
        }
    }

    return NO;
}

- (id<SPLTableViewBehavior>)_behaviorForIndexPath:(NSIndexPath *)indexPath childIndexPath:(out NSIndexPath **)childIndexPath
{
    if (childIndexPath) {
        *childIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    }

    return self.behaviors[indexPath.section];
}

@end
