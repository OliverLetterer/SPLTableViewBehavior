/*
 SPLTableViewBehavior.h
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

#import <UIKit/UIKit.h>

#import <SPLTableViewBehavior/SPLTableViewUpdate.h>
#import <SPLTableViewBehavior/SPLTableViewBehaviorProtocol.h>
#import <SPLTableViewBehavior/UITableView+SPLTableViewUpdate.h>

#import <SPLTableViewBehavior/SPLSectionBehavior.h>
#import <SPLTableViewBehavior/SPLArrayBehavior.h>
#import <SPLTableViewBehavior/SPLCompoundBehavior.h>
#import <SPLTableViewBehavior/SPLFetchedResultsBehavior.h>



NS_ASSUME_NONNULL_BEGIN

@interface SPLTableViewBehavior : NSObject <SPLTableViewBehavior>

@property (nonatomic, weak) id<SPLTableViewUpdate> update;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithPrototype:(UITableViewCell *)prototype configuration:(void(^)(id cell))configuration;
- (instancetype)initWithPrototype:(UITableViewCell *)prototype configuration:(void(^)(id cell))configuration action:(void(^ __nullable)(id cell))action NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
