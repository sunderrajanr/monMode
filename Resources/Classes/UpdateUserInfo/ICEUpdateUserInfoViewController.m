//
//  ICEUpdateUserInfoViewController.m
//  monMode
//
//  Created by Muthu Sabari on 7/29/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "ICEUpdateUserInfoViewController.h"

@interface ICEUpdateUserInfoViewController ()
{
    Reachability *reachability;
    DateTimePicker* datePicker;
    
    NSString *str_APIKey;
    NSString *str_DateOfBirth;
    NSString *str_FullName;
    NSString *str_FirstName;
    NSString *str_LastName;
    NSString *str_MobileNumber;
    
    BOOL isDatePicked;
}
@end

@implementation ICEUpdateUserInfoViewController
@synthesize btn_Edit,btn_Update,txt_Email,txt_FullName,txt_MobileNumber,btn_Birthday,datePicker_Birthday;

#pragma mark - ViewLifeCycle
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
    // Do any additional setup after loading the view from its nib.
    
    
    txt_Email.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"useremail"]];
    txt_FullName.text = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"userfirstname"],[[NSUserDefaults standardUserDefaults] valueForKey:@"userlastname"]];
    str_APIKey = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"api_key"]];
    isDatePicked = NO;
    str_DateOfBirth = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userDateOfBirth"]];
    str_MobileNumber = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userMobileNumber"]];
    
    if ([str_MobileNumber isEqualToString:@"(null)"])
    {
        txt_MobileNumber.text = @"Mobile Number";
    }
    else
    {
        NSMutableString *mutStr_MobileNumber = [NSMutableString stringWithString:str_MobileNumber];
        [mutStr_MobileNumber insertString:@"-" atIndex:3];
        [mutStr_MobileNumber insertString:@"-" atIndex:7];
        txt_MobileNumber.text = [NSString stringWithFormat:@"%@",mutStr_MobileNumber];
    }
    if ([str_DateOfBirth isEqualToString:@"(null)"])
    {
        [btn_Birthday setTitle:@"BirthDay" forState:UIControlStateNormal];
    }
    else
    {
        [btn_Birthday setTitle:str_DateOfBirth forState:UIControlStateNormal];
    }
    
    txt_Email.userInteractionEnabled = NO;
    txt_FullName.userInteractionEnabled = NO;
    txt_MobileNumber.userInteractionEnabled = NO;
    btn_Birthday.userInteractionEnabled = NO;
    btn_Update.hidden = YES;
    txt_MobileNumber.delegate = self;
    //Set Number Pad for PhoneNumber TextField
    UIToolbar* numberToolbar1 = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    numberToolbar1.items = [NSArray arrayWithObjects:
                            [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc]initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                            nil];
    txt_MobileNumber.inputAccessoryView = numberToolbar1;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField Delegate
- (IBAction)act_DismissKeyboard:(id)sender
{
    [txt_Email resignFirstResponder];
    [txt_FullName resignFirstResponder];
    [txt_MobileNumber resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == txt_MobileNumber)
    {
        txt_MobileNumber.text = @"";
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField == txt_MobileNumber)
    {
        str_MobileNumber=txt_MobileNumber.text;
        int length = [self getLength:textField.text];
        NSRange range;
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"%@",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 10)
        {
            NSString *num = [self formatNumber:textField.text];
            str_MobileNumber=num;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==txt_MobileNumber)
    {
        int length = [self getLength:textField.text];
        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"%@-",num];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            
            textField.text = [NSString stringWithFormat:@"%@-%@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@-%@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
        return YES;
    }
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
    }
    return mobileNumber;
}

-(int)getLength:(NSString*)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)[mobileNumber length];
    return length;
}

#pragma mark - Edit & Update
- (IBAction)act_Edit:(id)sender
{
    btn_Update.hidden = NO;
    btn_Edit.hidden = YES;
    txt_Email.userInteractionEnabled = YES;
    txt_FullName.userInteractionEnabled = YES;
    txt_MobileNumber.userInteractionEnabled = YES;
    btn_Birthday.userInteractionEnabled = YES;
}

- (IBAction)act_Update:(id)sender
{
    if (txt_FullName.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter your Name"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else if (txt_Email.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter your Email"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else if (str_DateOfBirth.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please select your Birthday"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    
    else if (str_MobileNumber.length<10 ||str_MobileNumber.length>10)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Please Enter valid Mobile Number"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    else if (str_MobileNumber.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"monMode" message:@"Mobile Number should have minimum 10 digits"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
    }
    
    else
    {
        
        NSArray *fullNamearr = [txt_FullName.text componentsSeparatedByString:@" "];
        str_FirstName = [NSString stringWithFormat:@"%@",[fullNamearr objectAtIndex:0]];
        NSMutableArray *mut = [NSMutableArray arrayWithArray:fullNamearr];
        
        [mut removeObjectAtIndex:0];
        NSString *str = @"";
        for (int i = 0; i<[mut count]; i++)
        {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%@ ",[mut objectAtIndex:i]]];
        }
        str_LastName = [NSString stringWithFormat:@"%@",str];
        
        btn_Update.hidden = YES;
        btn_Edit.hidden = NO;
        txt_Email.userInteractionEnabled = NO;
        txt_FullName.userInteractionEnabled = NO;
        txt_MobileNumber.userInteractionEnabled = NO;
        btn_Birthday.userInteractionEnabled = NO;
        
        [self updateEmail];
        [self updateProfile];
    }
    
}

- (void)cancelNumberPad
{
    [txt_MobileNumber resignFirstResponder];
    txt_MobileNumber.text = @"";
}

- (void)doneWithNumberPad
{
    [txt_MobileNumber resignFirstResponder];
}


- (void)updateEmail
{
    
    NSString *urlAsString = @"https://www.monmode.today/api/v1/users";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user[email]=%@",txt_Email.text]];
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"Update Email : %@",url);
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"PUT"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:&response
                                                     error:&error];
    if ([data length] >0  && error == nil)
    {
        error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (jsonObject != nil && error == nil)
        {
            NSLog(@"Update Email Response : %@",jsonObject);
        }
    }
    else
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.tag = 1;
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
    
}

- (void)updateProfile
{
    NSString *urlAsString = @"https://www.monmode.today/api/v1/me/profile";
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?api_key=%@",str_APIKey]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&profile[first_name]=%@",str_FirstName]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&profile[last_name]=%@",str_LastName]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&profile[mobile_number]=%@",txt_MobileNumber.text]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&profile[birthday]=%@",str_DateOfBirth]];
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSLog(@"Update Profile : %@",url);
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"PUT"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                         returningResponse:&response
                                                     error:&error];
    if ([data length] >0  && error == nil)
    {
        error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (jsonObject != nil && error == nil)
        {
            NSLog(@"Update Profile Response : %@",jsonObject);
            [[NSUserDefaults standardUserDefaults] setObject:str_DateOfBirth forKey:@"userDateOfBirth"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSUserDefaults standardUserDefaults] setObject:str_MobileNumber forKey:@"userMobileNumber"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *str_FirstNameRes = (NSString *)[jsonObject valueForKey:@"first_name"];
            [[NSUserDefaults standardUserDefaults] setObject:str_FirstNameRes forKey:@"userfirstname"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSString *str_LastNameRes = (NSString *)[jsonObject valueForKey:@"last_name"];
            [[NSUserDefaults standardUserDefaults] setObject:str_LastNameRes forKey:@"userlastname"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"Unable to connect with the server" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try again", nil];
        alertsuccess.tag = 1;
        alertsuccess.delegate = self;
        [alertsuccess show];
    }
    
}

#pragma mark - Birthday

- (IBAction)act_Birthday:(id)sender
{
    txt_Email.userInteractionEnabled = NO;
    txt_FullName.userInteractionEnabled = NO;
    txt_MobileNumber.userInteractionEnabled = NO;
    btn_Birthday.userInteractionEnabled = NO;
    btn_Update.userInteractionEnabled = NO;
    datePicker = [[DateTimePicker alloc] initWithFrame:CGRectMake(0, 310, 320,162)];
    
    UIView *view = [[datePicker subviews] objectAtIndex:0];
    [view setBackgroundColor:[UIColor whiteColor]];
    [datePicker addTargetForDoneButton:self action:@selector(datePickerDonePressed)];
    [datePicker addTargetForCancelButton:self action:@selector(datePickerCancelPressed)];
    
    [self.view addSubview:datePicker];
    datePicker.hidden = NO;
    [datePicker setMode:UIDatePickerModeDate];
    [datePicker.picker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)pickerChanged:(id)sender
{
    isDatePicked = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    str_DateOfBirth = [NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[(UIDatePicker*)sender date]]];
}

-(void)datePickerDonePressed
{
    if (isDatePicked == YES)
    {
        txt_Email.userInteractionEnabled = YES;
        txt_FullName.userInteractionEnabled = YES;
        txt_MobileNumber.userInteractionEnabled = YES;
        btn_Birthday.userInteractionEnabled = YES;
        btn_Update.userInteractionEnabled = YES;
        [btn_Birthday setTitle:str_DateOfBirth forState:UIControlStateNormal];
        datePicker.hidden = YES;
        isDatePicked = NO;
    }
    else
    {
        txt_Email.userInteractionEnabled = YES;
        txt_FullName.userInteractionEnabled = YES;
        txt_MobileNumber.userInteractionEnabled = YES;
        btn_Birthday.userInteractionEnabled = YES;
        btn_Update.userInteractionEnabled = YES;
        [btn_Birthday setTitle:@"Birthday" forState:UIControlStateNormal];
        datePicker.hidden = YES;
        isDatePicked = NO;
    }
}

-(void)datePickerCancelPressed
{
    txt_Email.userInteractionEnabled = YES;
    txt_FullName.userInteractionEnabled = YES;
    txt_MobileNumber.userInteractionEnabled = YES;
    btn_Birthday.userInteractionEnabled = YES;
    btn_Update.userInteractionEnabled = YES;
    [btn_Birthday setTitle:@"Birthday" forState:UIControlStateNormal];
    datePicker.hidden = YES;
}


- (IBAction)act_Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
