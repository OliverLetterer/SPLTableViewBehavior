/*
 SPLArrayBehavior.m
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

#import "SPLArrayBehavior.h"
#import "UITableViewCell+SPLTableViewBehavior.h"



@interface SPLArrayBehavior ()

@property (nonatomic, copy) NSArray *data;
@property (nonatomic, readonly) NSMutableArray *mutableData;

@property (nonatomic, copy) void(^action)(id object);
@property (nonatomic, readonly) void(^configuration)(id cell, id object);
@property (nonatomic, readonly) UITableViewCellPrototypeDeque deque;

@end



@implementation SPLArrayBehavior

#pragma mark - setters and getters

- (NSMutableArray *)mutableData
{
    return [self mutableArrayValueForKey:NSStringFromSelector(@selector(data))];
}

- (void)setData:(NSArray *)data withAnimation:(UITableViewRowAnimation)animation
{
    if (data != _data) {
        _data = data;
        [self.update reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation fromTableViewBehavior:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - Instance methods

- (void)reloadWithAnimation:(UITableViewRowAnimation)animation
{
    [self.update reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation fromTableViewBehavior:self];
}

- (void)reloadRowForDataObject:(id)dataObject withAnimation:(UITableViewRowAnimation)animation
{
    NSInteger index = [self.data indexOfObject:dataObject];
    if (index == NSNotFound) {
        return;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.update reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:animation fromTableViewBehavior:self];
}

- (__kindof UITableViewCell *)cellForDataObject:(id)dataObject inTableView:(UITableView *)tableView
{
    NSInteger index = [self.data indexOfObject:dataObject];
    NSParameterAssert(index != NSNotFound);

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    return [tableView cellForRowAtIndexPath:[self.update convertIndexPath:indexPath fromChildBehavior:self]];
}

#pragma mark - Initialization

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithPrototype:(__kindof UITableViewCell *)prototype data:(NSArray *)data configuration:(void(^)(__kindof UITableViewCell *cell, id object))configuration
{
    return [self initWithPrototype:prototype data:data configuration:configuration action:nil];
}

- (instancetype)initWithPrototype:(__kindof UITableViewCell *)prototype data:(NSArray *)data configuration:(void(^)(__kindof UITableViewCell *cell, id object))configuration action:(void(^)(id object))action
{
    if (self = [super init]) {
        _data = data.copy;

        _deque = prototype.dequeBlock;
        _configuration = configuration;
        _action = action;
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

    return [super respondsToSelector:aSelector];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.deque(tableView);

    id object = self.data[indexPath.row];
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
        id object = self.data[indexPath.row];
        [self.mutableData removeObjectAtIndex:indexPath.row];

        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            self.deletionHandler(object);
        }];

        [self.update deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft fromTableViewBehavior:self];
        [CATransaction commit];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.data[indexPath.row];
    self.action(object);
}

@end
