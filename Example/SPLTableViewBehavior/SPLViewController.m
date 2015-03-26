//
//  SPLViewController.m
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer on 03/20/2015.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLViewController.h"
#import "CoreDataStack.h"
#import "ManagedObject.h"

#import <SPLTableViewBehavior/SPLTableViewBehavior.h>

@interface SPLViewController ()

@property (nonatomic, readonly) id<SPLTableViewBehavior> behavior;

@end



@implementation SPLViewController

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        NSDate *now = [NSDate date];
        [self _seedDemoDataAtDate:now];

        NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest:[self _fetchRequestAtDate:now]
                                                            managedObjectContext:[CoreDataStack sharedInstance].mainThreadManagedObjectContext
                                                              sectionNameKeyPath:nil
                                                                       cacheName:nil];

        UITableViewCell *actionPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"actionPrototype"];
        actionPrototype.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        UITableViewCell *dataPrototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dataPrototype"];
        dataPrototype.selectionStyle = UITableViewCellSelectionStyleNone;

        __weak typeof(self) weakSelf = self;
        SPLTableViewBehavior *b1 = [[SPLTableViewBehavior alloc] initWithPrototype:actionPrototype configuration:^(UITableViewCell *cell) {
            cell.textLabel.text = @"Go to";
            cell.detailTextLabel.text = @"next view controller";
        } action:^(id cell) {
            __strong typeof(self) self = weakSelf;
            [self.navigationController pushViewController:[[SPLViewController alloc] init] animated:YES];
        }];

        NSArray *data1 = @[ @"Object 1", @"Object 2", @"Object 3" ];
        SPLArrayBehavior *arrayBehavior1 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data1 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"Section 0";
            cell.detailTextLabel.text = object;
        } action:^(NSString *object) {
            NSLog(@"Do something with %@", object);
        }];

        NSArray *data2 = @[ @"Second 1", @"Second 2", @"Second 3", @"Second 4", @"Second 5", @"Second 6" ];
        SPLArrayBehavior *arrayBehavior2 = [[SPLArrayBehavior alloc] initWithPrototype:dataPrototype data:data2 configuration:^(UITableViewCell *cell, NSString *object) {
            cell.textLabel.text = @"Section 1";
            cell.detailTextLabel.text = object;
        }];
        [arrayBehavior2 setDeletionHandler:^(NSString *object) {
            NSLog(@"Do something with deleted object: %@", object);
        }];

        SPLFetchedResultsBehavior *coreDataBehavior = [[SPLFetchedResultsBehavior alloc] initWithPrototype:dataPrototype controller:controller configuration:^(UITableViewCell *cell, ManagedObject *object) {
            cell.textLabel.text = @"From CoreData";
            cell.detailTextLabel.text = object.name;
        }];
        [coreDataBehavior setDeletionHandler:^(ManagedObject *object) {
            [object.managedObjectContext deleteObject:object];

            NSError *saveError = nil;
            [object.managedObjectContext save:&saveError];
            NSCAssert(saveError == nil, @"error saving managed object context: %@", saveError);
        }];

        SPLSectionBehavior *section0 = [[SPLSectionBehavior alloc] initWithTitle:@"Section 0" behaviors:@[ b1, arrayBehavior1 ]];
        SPLSectionBehavior *section2 = [[SPLSectionBehavior alloc] initWithTitle:@"CoreData section" behaviors:@[ coreDataBehavior ]];

        _behavior = [[SPLCompoundBehavior alloc] initWithBehaviors:@[ section0, arrayBehavior2, section2 ]];
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

- (void)_seedDemoDataAtDate:(NSDate *)date
{
    NSManagedObjectContext *context = [CoreDataStack sharedInstance].mainThreadManagedObjectContext;

    for (int i = 0; i < 10; i++) {
        ManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([ManagedObject class])
                                                              inManagedObjectContext:context];
        object.name = [NSString stringWithFormat:@"CoreData Object %d", i];
        object.date = date;
    }

    NSError *saveError = nil;
    [context save:&saveError];
    NSCAssert(saveError == nil, @"error saving managed object context: %@", saveError);
}

- (NSFetchRequest *)_fetchRequestAtDate:(NSDate *)date
{
    NSFetchRequest *result = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([ManagedObject class])];
    result.predicate = [NSPredicate predicateWithFormat:@"date == %@", date];
    result.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ];

    return result;
}

@end
