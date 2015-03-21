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



@interface SPLSectionBehavior ()

@property (nonatomic, readonly) NSArray *behaviors;

@end



@implementation SPLSectionBehavior

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
    id<SPLTableViewBehavior> behavior = [self _behaviorForTableView:tableView atndexPath:indexPath childIndexPath:&childIndexPath];

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

    for (id<SPLTableViewBehavior> behavior in self.behaviors) {
        numberOfRows += [behavior tableView:tableView numberOfRowsInSection:1];
    }

    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *childIndexPath = nil;
    id<SPLTableViewBehavior> behavior = [self _behaviorForTableView:tableView atndexPath:indexPath childIndexPath:&childIndexPath];
    return [behavior tableView:tableView cellForRowAtIndexPath:childIndexPath];
}

#pragma mark - Private category implementation ()

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

    for (id<SPLTableViewBehavior> behavior in self.behaviors) {
        if ([behavior respondsToSelector:selector]) {
            return YES;
        }
    }

    return NO;
}

- (id<SPLTableViewBehavior>)_behaviorForTableView:(UITableView *)tableView atndexPath:(NSIndexPath *)indexPath childIndexPath:(out NSIndexPath **)childIndexPath
{
    NSInteger currentIndex = 0;
    NSRange currentRange = NSMakeRange(0, [self.behaviors[0] tableView:tableView numberOfRowsInSection:1]);

    while (!NSLocationInRange(indexPath.row, currentRange)) {
        currentIndex++;
        currentRange = NSMakeRange(currentRange.location + currentRange.length, [self.behaviors[0] tableView:tableView numberOfRowsInSection:1]);
    }

    if (childIndexPath) {
        *childIndexPath = [NSIndexPath indexPathForRow:indexPath.row - currentRange.location inSection:0];
    }
    
    return self.behaviors[currentIndex];
}

@end
