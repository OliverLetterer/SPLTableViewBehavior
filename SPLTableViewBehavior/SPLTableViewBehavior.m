/*
 SPLTableViewBehavior.m
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

#import "SPLTableViewBehavior.h"
#import "UITableViewCell+SPLTableViewBehavior.h"



@interface SPLTableViewBehavior ()

@property (nonatomic, readonly) void(^action)(id cell);
@property (nonatomic, readonly) void(^configuration)(id cell);
@property (nonatomic, readonly) UITableViewCellPrototypeDeque deque;

@end



@implementation SPLTableViewBehavior

#pragma mark - Initialization

- (instancetype)initWithPrototype:(UITableViewCell *)prototype configuration:(void(^)(id cell))configuration
{
    return [self initWithPrototype:prototype configuration:configuration action:nil];
}

- (instancetype)initWithPrototype:(UITableViewCell *)prototype configuration:(void(^)(id cell))configuration action:(void(^)(id cell))action
{
    if (self = [super init]) {
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

    return [super respondsToSelector:aSelector];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = self.deque(tableView);
    self.configuration(cell);
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.action([tableView cellForRowAtIndexPath:indexPath]);
}

@end
