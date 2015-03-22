# SPLTableViewBehavior

[![CI Status](http://img.shields.io/travis/Oliver Letterer/SPLTableViewBehavior.svg?style=flat)](https://travis-ci.org/Oliver Letterer/SPLTableViewBehavior)
[![Version](https://img.shields.io/cocoapods/v/SPLTableViewBehavior.svg?style=flat)](http://cocoadocs.org/docsets/SPLTableViewBehavior)
[![License](https://img.shields.io/cocoapods/l/SPLTableViewBehavior.svg?style=flat)](http://cocoadocs.org/docsets/SPLTableViewBehavior)
[![Platform](https://img.shields.io/cocoapods/p/SPLTableViewBehavior.svg?style=flat)](http://cocoadocs.org/docsets/SPLTableViewBehavior)

The goal of this project is to define a whole UITableView behavior by providing lightweight, reusable and composable UITableViewDataSources/Delegates components.

## Usage

### SPLTableViewBehavior
Display's a single cell

```objc
UITableViewCell *prototype = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"prototype"];
prototype.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

SPLTableViewBehavior *behavior = [[SPLTableViewBehavior alloc] initWithPrototype:prototype configurator:^(UITableViewCell *cell) {
  // setup the table view cell
} handler:^{
  // do something when tapped
}];
```

### SPLArrayBehavior
Display's an array of data

```objc
UITableViewCell *prototype = ...
NSArray *data = @[ @"Object 1", @"Object 2", @"Object 3" ];

SPLArrayBehavior *behavior = [[SPLArrayBehavior alloc] initWithPrototype:prototype data:data configurator:^(UITableViewCell *cell, NSString *object) {
  cell.textLabel.text = @"Section 0";
  cell.detailTextLabel.text = object;
} handler:^(NSString *object) {
  NSLog(@"Do something with %@ when tapped", object);
}];
```

### SPLFetchedResultsBehavior
Display's an array of data backed by a NSFetchedResultsController

```objc
UITableViewCell *prototype = ...
NSFetchedResultsController *controller = ...

SPLFetchedResultsBehavior *behavior = [[SPLFetchedResultsBehavior alloc] initWithPrototype:dataPrototype controller:controller configurator:^(UITableViewCell *cell, ManagedObject *object) {
  cell.textLabel.text = @"From CoreData";
  cell.detailTextLabel.text = object.name;
}];
```

### SPLSectionBehavior
Group's multiple behaviors into one section

```objc
NSArray *behaviors = @[ behavior1, behavior2, behavior3 ];

SPLSectionBehavior *behavior = [[SPLSectionBehavior alloc] initWithTitle:@"Section 0" behaviors:behaviors];
```

### SPLCompoundBehavior
Display's multiple behaviors with it's own section

```objc
NSArray *behaviors = @[ behavior1, behavior2, behavior3 ];

self.behavior = [[SPLCompoundBehavior alloc] initWithBehaviors:behaviors];
```

### Hook it up
Bind your final behavior to your UITableView

```objc
- (void)viewDidLoad
{
  [super viewDidLoad];

  self.behavior.update = self.tableView.update;

  self.tableView.dataSource = self.behavior;
  self.tableView.delegate = self.behavior;
}
```

## Installation

SPLTableViewBehavior is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "SPLTableViewBehavior"

## Author

Oliver Letterer, oliver.letterer@gmail.com

## License

SPLTableViewBehavior is available under the MIT license. See the LICENSE file for more info.
