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

@property (nonatomic, copy) void(^handler)(id object);
@property (nonatomic, readonly) void(^configurator)(id cell, id object);
@property (nonatomic, readonly) UITableViewCellPrototypeDeque deque;

@end



@implementation SPLArrayBehavior

#pragma mark - setters and getters

- (NSMutableArray *)mutableData
{
    return [self mutableArrayValueForKey:NSStringFromSelector(@selector(data))];
}

#pragma mark - Initialization

- (instancetype)initWithPrototype:(UITableViewCell *)prototype data:(NSArray *)data configurator:(void(^)(id cell, id object))configurator
{
    return [self initWithPrototype:prototype data:data configurator:configurator handler:nil];
}

- (instancetype)initWithPrototype:(UITableViewCell *)prototype data:(NSArray *)data configurator:(void(^)(id cell, id object))configurator handler:(void(^)(id object))handler
{
    if (self = [super init]) {
        _data = data.copy;

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
    self.configurator(cell, object);

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
        self.deletionHandler(object);
        [self.mutableData removeObjectAtIndex:indexPath.row];

        [self.update deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft fromTableViewBehavior:self];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.data[indexPath.row];
    self.handler(object);
}

@end
