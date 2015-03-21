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

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        UITableViewCell *actionPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"actionPrototype"];
        actionPrototype.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UITableViewCell *dataPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dataPrototype"];
        dataPrototype.selectionStyle = UITableViewCellSelectionStyleNone;

        __weak typeof(self) weakSelf = self;
        SPLTableViewBehavior *b1 = [[SPLTableViewBehavior alloc] initWithPrototype:actionPrototype configurator:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Go to";
            cell.detailTextLabel.text = @"next view controller";
        } handler:^{
            __strong typeof(self) self = weakSelf;
            [self.navigationController pushViewController:[[SPLViewController alloc] init] animated:YES];
        }];

        NSArray *data1 = @[ @"Object 1", @"Object 2", @"Object 3" ];
        SPLArrayBehavior *arrayBehavior1 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data1 configurator:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"Section 0";
            cell.detailTextLabel.text = object;
        } handler:^(NSString *object) {
            NSLog(@"Do something with %@", object);
        }];

        NSArray *data2 = @[ @"Second 1", @"Second 2", @"Second 3", @"Second 4", @"Second 5", @"Second 6" ];
        SPLArrayBehavior *arrayBehavior2 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data2 configurator:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"Section 1";
            cell.detailTextLabel.text = object;
        }];

        SPLSectionBehavior *section0 = [[SPLSectionBehavior alloc] initWithTitle:@"Section 0" behaviors:@[ b1, arrayBehavior1 ]];
//        SPLSectionBehavior *section1 = [[SPLSectionBehavior alloc] initWithTitle:@"Section 1" behaviors:@[ arrayBehavior2 ]];

        _behavior = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ section0, arrayBehavior2 ]];
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
