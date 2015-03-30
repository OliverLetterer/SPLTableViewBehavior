//
//  VisibleSectionViewController.m
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer.
//  Copyright 2015 Oliver Letterer. All rights reserved.
//

#import "VisibleSectionViewController.h"

#import <SPLTableViewBehavior/SPLTableViewBehavior.h>


@interface VisibleSectionViewController ()

@property (nonatomic, readonly) NSArray *toggleBehaviors;
@property (nonatomic, readonly) SPLSectionBehavior *behavior;

@end



@implementation VisibleSectionViewController

#pragma mark - setters and getters

#pragma mark - Initialization

- (id)init
{
    if (self = [super init]) {
        UITableViewCell *prototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"prototype"];

        __weak typeof(self) weakSelf = self;
        SPLTableViewBehavior *b1 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Dummy 1";
            cell.detailTextLabel.text = nil;
        }];

        NSArray *data1 = @[ @"Object 1", @"Object 2", @"Object 3" ];
        SPLArrayBehavior *arrayBehavior = [[SPLArrayBehavior alloc] initWithPrototype:prototype data:data1 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"Dummy";
            cell.detailTextLabel.text = object;
        }];

        SPLTableViewBehavior *b2 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Dummy 2";
            cell.detailTextLabel.text = nil;
        }];

        SPLTableViewBehavior *toggle = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Toggle";
            cell.detailTextLabel.text = nil;
        } action:^(id cell) {
            __strong typeof(self) self = weakSelf;
            NSMutableArray *behaviors = self.behavior.childBehaviors.mutableCopy;

            if (self.behavior.visibleBehaviors.count == 4) {
                [behaviors removeObjectsInArray:self.toggleBehaviors];
            }

            [self.behavior setVisibleBehaviors:behaviors withRowAnimation:UITableViewRowAnimationTop];
        }];

        _toggleBehaviors = @[ b1, arrayBehavior, b2 ];
        _behavior = [[SPLSectionBehavior alloc] initWithBehaviors:@[ b1, arrayBehavior, toggle, b2 ]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.behavior.update = self.tableView.tableViewUpdate;

    self.tableView.dataSource = self.behavior;
    self.tableView.delegate = self.behavior;
    self.tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 66.0 : 88.0;
}

@end
