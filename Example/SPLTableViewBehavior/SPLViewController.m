//
//  SPLViewController.m
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer on 03/20/2015.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLViewController.h"

#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

@interface SPLViewController ()

@property (nonatomic, readonly) id<SPLTableViewBehavior> behavior;

@end



@implementation SPLViewController

#pragma mark - setters and getters

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        UITableViewCell *plainPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//        plainPrototype.selectionStyle = UITableViewCellSelectionStyleNone;
        plainPrototype.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        SPLTableViewBehavior *b1 = [[SPLTableViewBehavior alloc] initWithPrototype:plainPrototype configurator:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Hello from";
            cell.detailTextLabel.text = @"SPLTableViewBehavior";
        }];

        SPLTableViewBehavior *b2 = [[SPLTableViewBehavior alloc] initWithPrototype:plainPrototype configurator:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Some action";
            cell.detailTextLabel.text = @"SPLTableViewBehavior";
        }];

        SPLTableViewBehavior *b3 = [[SPLTableViewBehavior alloc] initWithPrototype:plainPrototype configurator:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Action three";
            cell.detailTextLabel.text = @"SPLTableViewBehavior";
        } handler:^{
            NSLog(@"Action 3");
        }];

        _behavior = [[SPLSectionBehavior alloc] initWithBehaviors:@[ b1, b2, b3 ]];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.behavior.update = self.tableView.update;

    self.tableView.dataSource = self.behavior;
    self.tableView.delegate = self.behavior;
    self.tableView.rowHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 66.0 : 88.0;
}

#pragma mark - Private category implementation ()

@end
