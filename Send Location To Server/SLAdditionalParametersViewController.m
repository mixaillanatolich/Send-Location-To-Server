//
//  SLAdditionalParametersViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 7/2/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLAdditionalParametersViewController.h"
#import "SLUserParameterViewController.h"

@interface SLAdditionalParametersViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSDictionary *additionalParam;

@end

@implementation SLAdditionalParametersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.additionalParam = [UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING];
    if (!_additionalParam) {
        _additionalParam = [NSDictionary new];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

#pragma mark - Table view data source

 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     return _additionalParam.count;
 }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParameterCell"];
    UILabel *label = (UILabel*)[cell viewWithTag:100];
    
    NSString *key = _additionalParam.allKeys[indexPath.row];
    NSString *value = [_additionalParam objectForKey:key];
    
    label.text = [NSString stringWithFormat:@"%@ = %@", key, value];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = _additionalParam.allKeys[indexPath.row];
    [self performSegueWithIdentifier:@"showCustomParameter" sender:key];
}

#pragma mark - 
- (IBAction)addNewParameterButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"showCustomParameter" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showCustomParameter"]) {
        SLUserParameterViewController *slupvc = (SLUserParameterViewController*)segue.destinationViewController;
        if ([sender isKindOfClass:[NSString class]]) {
            slupvc.key = sender;
        }
    }
}
@end
