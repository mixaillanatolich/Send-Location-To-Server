//
//  SLSettingsViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 6/26/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLSettingsViewController.h"

@interface SLSettingsViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *backgroundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *notSleepSwitch;

@end

@implementation SLSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [_backgroundSwitch setOn:[UserDefaults boolForKey:SEND_LOCATION_IN_BACKGROUND_SETTING]];
    [_notSleepSwitch setOn:[UserDefaults boolForKey:NOT_TURN_OFF_DISPLAY_SETTING]];
    
}

- (void)viewDidUnload {
    [self setBackgroundSwitch:nil];
    [self setNotSleepSwitch:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.section == 1 && indexPath.row == 2) {
        NSInteger loginInterval = [UserDefaults integerForKey:LOGGIN_INTERVAL_SETTING];
        if (loginInterval <= 0) {
            loginInterval = DEFAULT_LOGGIN_INTERVAL;
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Set to %i sec",loginInterval];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - switch delegate

- (IBAction)backgroundSwitchChangeState:(id)sender {
    [UserDefaults setBool:_backgroundSwitch.isOn forKey:SEND_LOCATION_IN_BACKGROUND_SETTING];
    [UserDefaults synchronize];
}

- (IBAction)notSleepSwitchChangeState:(id)sender {
    [UserDefaults setBool:_notSleepSwitch.isOn forKey:NOT_TURN_OFF_DISPLAY_SETTING];
    [UserDefaults synchronize];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:[UserDefaults boolForKey:NOT_TURN_OFF_DISPLAY_SETTING]];
}

@end
