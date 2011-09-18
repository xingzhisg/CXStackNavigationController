//
//  MyViewController.m
//  TestStackNavigation
//
//  Created by Xingzhi C. on 9/16/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "MyViewController.h"
#import "UIViewController+Stack.h"
#import "CXStackNavigationController.h"

@implementation MyViewController
@synthesize menuList;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.menuList = [NSArray arrayWithObjects:@"Row 1", @"Row 2", @"Row 3", @"Row 4", @"Row 5", nil];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//	NSLog(@"view Will Appear \t %@", self);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//	NSLog(@"view did Appear \t %@", self);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//	NSLog(@"view Will disappear \t %@", self);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//	NSLog(@"view did disappear \t %@", self);
}

*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.menuList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [self.menuList objectAtIndex:indexPath.row];
//	cell.contentView.backgroundColor = [UIColor blackColor];
//	cell.textLabel.backgroundColor = [UIColor clearColor];
//	cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	MyViewController * aViewController = [[MyViewController alloc] initWithStyle:UITableViewStylePlain];
	if ([self.stackNavigationController.viewControllers count] == 0 || [self.stackNavigationController topViewController] == self)
		[self.stackNavigationController pushViewController:aViewController animated:YES];
	else
		[self.stackNavigationController pushViewController:aViewController byDismissingViewControllersBeyond:self animated:YES];
	[aViewController release];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
	self.menuList = nil;
}


- (void)dealloc {
//	NSLog(@"dealloc a myviewcontroller");
	self.menuList = nil;
    [super dealloc];
}


@end

