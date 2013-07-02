//
//  SLUserParameterViewController.m
//  Send Location To Server
//
//  Created by Mixaill Anatolich on 7/2/13.
//  Copyright (c) 2013 Mixaill Anatolich. All rights reserved.
//

/*
 imei=013411001582430
 acct=testandr&dev=test01
 */

#import "SLUserParameterViewController.h"

@interface SLUserParameterViewController () {
    BOOL removeClicked;
}
@property (weak, nonatomic) IBOutlet UITextField *keyTextField;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeButton;

@end

@implementation SLUserParameterViewController

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
    
    if ([self editMode]) {
        _keyTextField.text = _key;
        _valueTextField.text = [[UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING] objectForKey:_key];
        [_removeButton setTitle:@"Remove"];
    } else {
        [_removeButton setTitle:@"Add"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self editMode] && !removeClicked) {
        NSString *key = _keyTextField.text;
        NSString *value = _valueTextField.text;
        
        if (!key || !key.length || !value) {

        } else {
            NSMutableDictionary *parameters;
            if ([UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING]) {
                parameters = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING]];
            } else {
                parameters = [NSMutableDictionary new];
            }
            [parameters removeObjectForKey:_key];
            [parameters setObject:value forKey:key];
            [UserDefaults setObject:parameters forKey:ADDITIONAL_PARAMETERS_SETTING];
            [UserDefaults synchronize];
        }
    }
}


- (void)viewDidUnload {
    [self setKeyTextField:nil];
    [self setValueTextField:nil];
    [self setRemoveButton:nil];
    [super viewDidUnload];
}


- (BOOL)editMode {
    return (_key && _key.length);
}

- (IBAction)removeButtonClicked:(id)sender {
    
    if ([self editMode]) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING]];
        [parameters removeObjectForKey:_key];
        [UserDefaults setObject:parameters forKey:ADDITIONAL_PARAMETERS_SETTING];
        [UserDefaults synchronize];
        removeClicked = YES;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        NSString *key = _keyTextField.text;
        NSString *value = _valueTextField.text;
        
        if (!key || !key.length || !value) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Key can not be empty" message:@"Please enter the Key or click Back for return without saving" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            NSMutableDictionary *parameters;
            if ([UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING]) {
                parameters = [NSMutableDictionary dictionaryWithDictionary:[UserDefaults dictionaryForKey:ADDITIONAL_PARAMETERS_SETTING]];
            } else {
                parameters = [NSMutableDictionary new];
            }
            [parameters setObject:value forKey:key];
            [UserDefaults setObject:parameters forKey:ADDITIONAL_PARAMETERS_SETTING];
            [UserDefaults synchronize];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    
}

@end
