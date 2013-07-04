//
//  SLServerViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 7/3/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

#import "SLServerViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SLServerViewController () {
    BOOL doNotSaveHostname;
}

@property (weak, nonatomic) IBOutlet UITextView *serverTextField;

@end

@implementation SLServerViewController

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
	
    _serverTextField.layer.cornerRadius = 10;
    _serverTextField.layer.borderWidth = 2;
    _serverTextField.layer.borderColor = (__bridge CGColorRef)([UIColor darkGrayColor]);
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _serverTextField.text = ([UserDefaults objectForKey:SERVER_NAME_SETTING] ? [UserDefaults objectForKey:SERVER_NAME_SETTING] : @"");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (!doNotSaveHostname) {
        NSString *hostname = _serverTextField.text;

        if (hostname && [hostname isKindOfClass:[NSString class]]) {
            [UserDefaults setObject:hostname forKey:SERVER_NAME_SETTING];
            [UserDefaults synchronize];
        }
    }
}

- (void)viewDidUnload {
    [self setServerTextField:nil];
    [super viewDidUnload];
}


- (IBAction)cancelButtonClicked:(id)sender {
    
    doNotSaveHostname = YES;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
