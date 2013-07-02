//
//  SLRequestFormatViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 7/1/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLRequestFormatViewController.h"

@interface SLRequestFormatViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *requestFormatSwitch;

@end

@implementation SLRequestFormatViewController

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
    
    _requestFormatSwitch.selectedSegmentIndex = [UserDefaults integerForKey:TYPE_OF_REQUEST_SETTING];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setRequestFormatSwitch:nil];
    [super viewDidUnload];
}

- (IBAction)requestFormatChanged:(id)sender {
    [UserDefaults setInteger:_requestFormatSwitch.selectedSegmentIndex forKey:TYPE_OF_REQUEST_SETTING];
    [UserDefaults synchronize];
}


@end
