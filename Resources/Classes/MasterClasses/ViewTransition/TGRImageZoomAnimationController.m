// TGRImageZoomAnimationController.m
// 
// Copyright (c) 2013 Guillermo Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TGRImageZoomAnimationController.h"
#import "ICEDetailViewController.h"
#import "UIImage+AspectFit.h"

@implementation TGRImageZoomAnimationController

- (id)initWithReferenceImageView:(UIImageView *)referenceImageView {
    if (self = [super init]) {
        NSAssert(referenceImageView.contentMode == UIViewContentModeScaleAspectFill, @"*** referenceImageView must have a UIViewContentModeScaleAspectFill contentMode!");
        _referenceImageView = referenceImageView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    return viewController.isBeingPresented ? 0.5 : 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *viewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (viewController.isBeingPresented) {
        [self animateZoomInTransition:transitionContext];
    }
    else {
        [self animateZoomOutTransition:transitionContext];
    }
}

- (void)animateZoomInTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the view controllers participating in the transition
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ICEDetailViewController *toViewController = (ICEDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([toViewController isKindOfClass:ICEDetailViewController.class], @"*** toViewController must be a TGRImageViewController!");
    UIView *BackgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
    [BackgroundView setBackgroundColor:[UIColor whiteColor]];
    [transitionContext.containerView addSubview:BackgroundView];
    
    // Create a temporary view for the zoom in transition and set the initial frame based
    // on the reference image view
    UIImageView *transitionView = [[UIImageView alloc] initWithImage:self.referenceImageView.image];
    
//    transitionView.frame= CGRectMake(0, 35, 320, 460);
    
    transitionView.contentMode = UIViewContentModeScaleAspectFill;
    transitionView.clipsToBounds = YES;
    transitionView.frame = [transitionContext.containerView convertRect:self.referenceImageView.bounds
                                                               fromView:self.referenceImageView];
    [transitionContext.containerView addSubview:transitionView];
    
    // Compute the final frame for the temporary view
    CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
    CGRect transitionViewFinalFrame = [self.referenceImageView.image tgr_aspectFitRectForSize:finalFrame.size];
    NSLog(@"Reference Image : Width : %f, Height : %f",transitionViewFinalFrame.size.width,transitionViewFinalFrame.size.height);
    // Perform the transition using a spring motion effect
//    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    self.referenceImageView.alpha = 0;
    if (transitionViewFinalFrame.size.width != 0.0)
    {
     CGFloat newHeight = transitionViewFinalFrame.size.height * (320/transitionViewFinalFrame.size.width);
    
    NSLog(@"New Height : %f",newHeight);
    
    
    [UIView animateWithDuration:1.2
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         fromViewController.view.alpha = 0;
                         transitionView.frame = CGRectMake(0, 0, 320,  newHeight);
                        // transitionView.frame = finalFrame;// transitionViewFinalFrame;
                         
                     }
                     completion:^(BOOL finished) {
                         fromViewController.view.alpha = 1;
                         
                         [transitionView removeFromSuperview];
                         [transitionContext.containerView addSubview:toViewController.view];
                         
                         [transitionContext completeTransition:YES];
                     }];
    }
    else
    {
        [UIView animateWithDuration:1.2
                              delay:0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             fromViewController.view.alpha = 0;
                             transitionView.frame = CGRectMake(0, 0, 320,  transitionViewFinalFrame.size.height);
                             // transitionView.frame = finalFrame;// transitionViewFinalFrame;
                             
                         }
                         completion:^(BOOL finished) {
                             fromViewController.view.alpha = 1;
                             
                             [transitionView removeFromSuperview];
                             [transitionContext.containerView addSubview:toViewController.view];
                             
                             [transitionContext completeTransition:YES];
                         }];
    }
}

- (void)animateZoomOutTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the view controllers participating in the transition
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    ICEDetailViewController *fromViewController = (ICEDetailViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    NSAssert([fromViewController isKindOfClass:ICEDetailViewController.class], @"*** fromViewController must be a TGRImageViewController!");
    
    // The toViewController view will fade in during the transition
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.alpha = 0;
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView sendSubviewToBack:toViewController.view];
    
    // Compute the initial frame for the temporary view based on the image view
    // of the TGRImageViewController
    CGRect transitionViewInitialFrame = [fromViewController.detailImage.image tgr_aspectFitRectForSize:fromViewController.detailImage.bounds.size];
    transitionViewInitialFrame = [transitionContext.containerView convertRect:transitionViewInitialFrame
                                                                     fromView:fromViewController.detailImage];
    
    // Compute the final frame for the temporary view based on the reference
    // image view
    CGRect transitionViewFinalFrame = [transitionContext.containerView convertRect:self.referenceImageView.bounds
                                                                          fromView:self.referenceImageView];
    
    if (UIApplication.sharedApplication.isStatusBarHidden && ![toViewController prefersStatusBarHidden]) {
        transitionViewFinalFrame = CGRectOffset(transitionViewFinalFrame, 0, 20);
    }
    
    // Create a temporary view for the zoom out transition based on the image
    // view controller contents
    UIImageView *transitionView = [[UIImageView alloc] initWithImage:fromViewController.detailImage.image];
    transitionView.contentMode = UIViewContentModeScaleAspectFill;
    transitionView.clipsToBounds = YES;
    transitionView.frame = transitionViewInitialFrame;
    [transitionContext.containerView addSubview:transitionView];
    [fromViewController.view removeFromSuperview];
    
    // Perform the transition
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         toViewController.view.alpha = 1;
                         transitionView.frame = transitionViewFinalFrame;
                     } completion:^(BOOL finished) {
                         self.referenceImageView.alpha = 1;
                         [transitionView removeFromSuperview];
                         [transitionContext completeTransition:YES];
                     }];
}

@end
