//
//  SPLViewController.m
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer on 03/20/2015.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLViewController.h"
#import "AdvancedPlaygroundViewController.h"
#import "VisibleSectionViewController.h"
#import "NestedCompoundViewController.h"
#import "ComplexVisibilityChangesViewController.h"

#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

@interface SPLViewController ()

@property (nonatomic, readonly) id<SPLTableViewBehavior> behavior;

@end



@implementation SPLViewController

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        __weak typeof(self) weakSelf = self;

        UITableViewCell *actionPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"actionPrototype"];
        actionPrototype.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        SPLTableViewBehavior *complexWithDeletion = [[SPLTableViewBehavior alloc] initWithPrototype:actionPrototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Complex with deletions";
        } action:^(id cell) {
            __strong typeof(self) self = weakSelf;
            [self.navigationController pushViewController:[[AdvancedPlaygroundViewController alloc] init] animated:YES];
        }];

        SPLTableViewBehavior *visibleSections = [[SPLTableViewBehavior alloc] initWithPrototype:actionPrototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"VisibleSectionViewController";
        } action:^(id cell) {
            __strong typeof(self) self = weakSelf;
            [self.navigationController pushViewController:[[VisibleSectionViewController alloc] init] animated:YES];
        }];

        SPLTableViewBehavior *nestedCompound = [[SPLTableViewBehavior alloc] initWithPrototype:actionPrototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"NestedCompoundViewController";
        } action:^(id cell) {
            __strong typeof(self) self = weakSelf;
            [self.navigationController pushViewController:[[NestedCompoundViewController alloc] init] animated:YES];
        }];

        SPLTableViewBehavior *complexVisibilityChanges = [[SPLTableViewBehavior alloc] initWithPrototype:actionPrototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"ComplexVisibilityChangesViewController";
        } action:^(id cell) {
            __strong typeof(self) self = weakSelf;
            [self.navigationController pushViewController:[[ComplexVisibilityChangesViewController alloc] init] animated:YES];
        }];

        _behavior = [[SPLSectionBehavior alloc] initWithTitle:@"Paygrounds" behaviors:@[ complexWithDeletion, visibleSections, nestedCompound, complexVisibilityChanges ]];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.behavior.update = self.tableView.tableViewUpdate;

    self.tableView.dataSource = self.behavior;
    self.tableView.delegate = self.behavior;
    self.tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 66.0 : 88.0;
}

#pragma mark - Private category implementation ()

@end
