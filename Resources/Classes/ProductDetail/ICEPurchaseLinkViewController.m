//
//  ICEPurchaseLinkViewController.m
//  monMode
//
//  Created by Muthu Sabari on 7/30/14.
//  Copyright (c) 2014 MavinApps. All rights reserved.
//

#import "ICEPurchaseLinkViewController.h"

@interface ICEPurchaseLinkViewController ()
{
    CGFloat _panOriginX;
    CGPoint _panVelocity;
}
@end

@implementation ICEPurchaseLinkViewController
@synthesize backgroundImage_backview,backView,backViewImage,frontView,str_PurchaseLink,webviewShopping,activity,view_Header,btn_Back;

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
    webviewShopping.delegate = self;
    NSString *websiteaddress = [NSString stringWithFormat:@"%@",str_PurchaseLink];
    
    NSString *properlyEscapedURL = [websiteaddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ([data length] > 0 && error == nil) [webviewShopping loadRequest:request];
                               
                               else if (error != nil) NSLog(@"Error: %@", error);
                               
                           }];
    [self addSiginIn_gesture];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebView Delegate
//Called whenever the view starts loading something
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
//Called whenever the view finished loading something
- (void)webViewDidFinishLoad:(UIWebView *)webView_
{
    [activity stopAnimating];
    activity.hidden = YES;
}

#pragma mark - Back Screen Animation

-(UIImage *)takescreenshotes
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)addSiginIn_gesture
{
    backViewImage.image=backgroundImage_backview;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(siginIn_pan:)];
    pan.delegate = (id<UIGestureRecognizerDelegate>)self;
    [frontView addGestureRecognizer:pan];
    
}
- (void)siginIn_pan:(UIPanGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        _panOriginX = self.frontView.frame.origin.x;
        _panVelocity = CGPointMake(0.0f, 0.0f);
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint velocity = [gesture velocityInView:self.frontView];
        _panVelocity = velocity;
        CGPoint translation = [gesture translationInView:self.frontView];
        CGRect frame = self.frontView.frame;
        frame.origin.x = _panOriginX + translation.x;
        if (frame.origin.x > 0.0f )
        {
            self.frontView.frame = frame;
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled)
    {
        if(self.frontView.frame.origin.x>=50)
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.frontView.frame =  CGRectMake(320, self.frontView.frame.origin.y, self.frontView.frame.size.width, self.frontView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 [self dismissViewControllerAnimated:NO completion:nil];
                             }];
        }
        else
        {
            [UIView animateWithDuration:0.2
                                  delay:0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.frontView.frame =  CGRectMake(0, self.frontView.frame.origin.y, self.frontView.frame.size.width, self.frontView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 
                                 
                             }];
        }
    }
}

- (IBAction)act_Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
