//
//  NestedCompoundViewController.m
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer.
//  Copyright 2015 Oliver Letterer. All rights reserved.
//

#import "NestedCompoundViewController.h"

#import <SPLTableViewBehavior/SPLTableViewBehavior.h>



@interface NestedCompoundViewController ()

@property (nonatomic, readonly) NSArray *toggleBehaviors;
@property (nonatomic, readonly) SPLCompoundBehavior *behavior;

@end



@implementation NestedCompoundViewController

- (instancetype)init
{
    if (self = [super init]) {
        UITableViewCell *dataPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dataPrototype"];
        dataPrototype.selectionStyle = UITableViewCellSelectionStyleNone;

        NSArray *data1 = @[ @"1", @"2", @"3" ];
        SPLArrayBehavior *arrayBehavior1 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data1 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"arrayBehavior1";
            cell.detailTextLabel.text = object;
        }];
        [arrayBehavior1 setDeletionHandler:^(NSString *object) {

        }];

        NSArray *data2 = @[ @"1", @"2", @"3" ];
        SPLArrayBehavior *arrayBehavior2 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data2 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"arrayBehavior2";
            cell.detailTextLabel.text = object;
        }];
        [arrayBehavior2 setDeletionHandler:^(NSString *object) {

        }];

        NSArray *data3 = @[ @"1", @"2", @"3" ];
        SPLArrayBehavior *arrayBehavior3 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data3 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"arrayBehavior3";
            cell.detailTextLabel.text = object;
        }];
        [arrayBehavior3 setDeletionHandler:^(NSString *object) {

        }];

        NSArray *data4 = @[ @"1", @"2", @"3" ];
        SPLArrayBehavior *arrayBehavior4 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data4 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"arrayBehavior4";
            cell.detailTextLabel.text = object;
        }];

        NSArray *data5 = @[ @"1", @"2", @"3", @"4" ];
        SPLArrayBehavior *arrayBehavior5 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data5 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"arrayBehavior5";
            cell.detailTextLabel.text = object;
        }];

        SPLCompoundBehavior *compound1 = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ arrayBehavior1, arrayBehavior2 ]];
        SPLSectionBehavior *section = [[SPLSectionBehavior alloc] initWithTitle:@"Section" behaviors:@[ arrayBehavior3 ]];
        SPLCompoundBehavior *compound2 = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ arrayBehavior4, arrayBehavior5 ]];

        _toggleBehaviors = @[ section, compound2 ];
        _behavior = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ compound1, section, compound2 ]];
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

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStylePlain target:self action:@selector(_toggle)];
}

- (void)_toggle
{
    NSMutableArray *behaviors = self.behavior.childBehaviors.mutableCopy;

    if (self.behavior.visibleBehaviors.count == 3) {
        [behaviors removeObjectsInArray:self.toggleBehaviors];
    }

    [self.behavior setVisibleBehaviors:behaviors withRowAnimation:UITableViewRowAnimationTop];
}

@end
