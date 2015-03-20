//
//  SPLViewController.m
//  SPLTableViewBehavior
//
//  Created by Oliver Letterer on 03/20/2015.
//  Copyright (c) 2014 Oliver Letterer. All rights reserved.
//

#import "SPLViewController.h"

@interface SPLViewController ()

@end



@implementation SPLViewController

#pragma mark - setters and getters

#pragma mark - Initialization

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - View lifecycle

//- (void)loadView
//{
//    [super loadView];
//
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - Private category implementation ()

@end
