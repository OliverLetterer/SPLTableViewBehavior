/*
 SPLFetchedResultsBehavior.h
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
#import <CoreData/CoreData.h>

#import <SPLTableViewBehavior/SPLTableViewBehaviorProtocol.h>



NS_ASSUME_NONNULL_BEGIN

@interface SPLFetchedResultsBehavior : NSObject <SPLTableViewBehavior, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id<SPLTableViewUpdate> update;

@property (nonatomic, strong) NSFetchedResultsController *controller;

@property (nonatomic, copy, nullable) dispatch_block_t observer;
@property (nonatomic, copy, nullable) CGFloat(^computesHeight)(id object);

@property (nonatomic, nullable, readonly) void(^deletionHandler)(id object);
@property (nonatomic, nullable, readonly) NSString *deleteConfirmationName;

@property (nonatomic, assign) UITableViewScrollPosition insertedRowsScrollPosition;

- (void)setDeletionHandler:(void (^ __nullable)(id __nonnull object))deletionHandler;
- (void)setDeletionHandler:(void (^ __nullable)(id __nonnull object))deletionHandler withName:(nullable NSString *)deleteConfirmationName;

- (instancetype)init NS_DESIGNATED_INITIALIZER UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithPrototype:(UITableViewCell *)prototype controller:(NSFetchedResultsController *)controller configuration:(void(^)(id cell, id object))configuration;
- (instancetype)initWithPrototype:(UITableViewCell *)prototype controller:(NSFetchedResultsController *)controller configuration:(void(^)(id cell, id object))configuration action:(void(^ __nullable)(id object))action NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
