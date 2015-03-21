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

        NSArray *data = @[ @"Object 1", @"Object 2", @"Object 3" ];
        SPLArrayBehavior *arrayBehavior = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data configurator:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"Data:";
            cell.detailTextLabel.text = object;
        } handler:^(NSString *object) {
            NSLog(@"Do something with %@", object);
        }];

        _behavior = [[SPLSectionBehavior alloc] initWithBehaviors:@[ b1, arrayBehavior ]];
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
