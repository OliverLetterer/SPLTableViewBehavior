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

@property (nonatomic, readonly) id<SPLTableViewBehavior> behavior;

@end



@implementation NestedCompoundViewController

- (id)init
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

        SPLCompoundBehavior *compound1 = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ arrayBehavior1, arrayBehavior2 ]];
        SPLSectionBehavior *section = [[SPLSectionBehavior alloc] initWithTitle:@"Secction" behaviors:@[ arrayBehavior3 ]];

        _behavior = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ compound1, section ]];
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
