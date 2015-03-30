//
//  ComplexVisibilityChangesViewController.m
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer.
//  Copyright 2015 Oliver Letterer. All rights reserved.
//

#import "ComplexVisibilityChangesViewController.h"

#import <SPLTableViewBehavior/SPLTableViewBehavior.h>



@interface ComplexVisibilityChangesViewController ()

@property (nonatomic, readonly) SPLSectionBehavior *toggleSection0;
@property (nonatomic, readonly) NSArray *toggleBehaviors0;

@property (nonatomic, readonly) NSArray *toggleBehaviors;
@property (nonatomic, readonly) SPLCompoundBehavior *behavior;

@end



@implementation ComplexVisibilityChangesViewController

#pragma mark - Initialization

- (id)init 
{
    if (self = [super init]) {
        UITableViewCell *prototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"prototype"];
        prototype.selectionStyle = UITableViewCellSelectionStyleNone;

        SPLTableViewBehavior *row00 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"0 - 0";
        }];
        SPLTableViewBehavior *row01 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"0 - 1";
        }];
        SPLTableViewBehavior *row02 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"0 - 2";
        }];

        SPLTableViewBehavior *row10 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"1 - 0";
        }];
        SPLTableViewBehavior *row11 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"1 - 1";
        }];
        SPLTableViewBehavior *row12 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"1 - 2";
        }];

        SPLTableViewBehavior *row20 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"2 - 0";
        }];
        SPLTableViewBehavior *row21 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"2 - 1";
        }];
        SPLTableViewBehavior *row22 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"2 - 2";
        }];

        SPLTableViewBehavior *row30 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"2.1 - 0";
        }];
        SPLTableViewBehavior *row31 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"2.1 - 1";
        }];
        SPLTableViewBehavior *row32 = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"2.1 - 2";
        }];

        SPLSectionBehavior *section0 = [[SPLSectionBehavior alloc] initWithTitle:@"Section 0" behaviors:@[ row00, row01, row02 ]];
        SPLSectionBehavior *section1 = [[SPLSectionBehavior alloc] initWithTitle:@"Section 1" behaviors:@[ row10, row11, row12 ]];

        SPLSectionBehavior *section2 = [[SPLSectionBehavior alloc] initWithTitle:@"Section 2" behaviors:@[ row20, row21, row22 ]];
        SPLSectionBehavior *section3 = [[SPLSectionBehavior alloc] initWithTitle:@"Section 3" behaviors:@[ row30, row31, row32 ]];

        SPLCompoundBehavior *compoundSection2 = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ section2, section3 ]];

        _toggleSection0 = section0;
        _toggleBehaviors0 = @[ row00, row01 ];

        _toggleSection0 = section1;
        _toggleBehaviors0 = @[ row10, row12 ];

        _toggleSection0 = section2;
        _toggleBehaviors0 = @[ row20, row21 ];

        _toggleBehaviors = @[ section0, compoundSection2 ];
        _behavior = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ section0, compoundSection2, section1 ]];
        _behavior.visibleBehaviors = _toggleBehaviors;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.behavior.update = self.tableView.tableViewUpdate;

    self.tableView.dataSource = self.behavior;
    self.tableView.delegate = self.behavior;
    self.tableView.rowHeight = 24.0;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Toggle" style:UIBarButtonItemStylePlain target:self action:@selector(_toggle)];
}

- (void)_toggle
{
    id<SPLTableViewUpdate> update = self.behavior.update;

    [update tableViewBehaviorBeginUpdates:self.behavior];

    {
        NSMutableArray *behaviors = self.toggleSection0.childBehaviors.mutableCopy;
        if (self.toggleSection0.visibleBehaviors.count == self.toggleSection0.childBehaviors.count) {
            [behaviors removeObjectsInArray:self.toggleBehaviors0];
        }
        [self.toggleSection0 setVisibleBehaviors:behaviors withRowAnimation:UITableViewRowAnimationTop];
    }

    {
        NSMutableArray *behaviors = self.behavior.childBehaviors.mutableCopy;
        if (self.behavior.visibleBehaviors.count == self.behavior.childBehaviors.count) {
            [behaviors removeObjectsInArray:self.toggleBehaviors];
        }
        [self.behavior setVisibleBehaviors:behaviors withRowAnimation:UITableViewRowAnimationTop];
    }

    [update tableViewBehaviorEndUpdates:self.behavior];
}

@end
