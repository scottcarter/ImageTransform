//
//  ImageTransformViewController.m
//  ImageTransform
//
//  Created by Scott Carter on 2/5/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "ImageTransformViewController.h"

@interface ImageTransformViewController ()

// A container for our imageView that we can position.
@property (weak, nonatomic) IBOutlet UIView *containerView;


// Our imageView contains a succession of two images that we animate.
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageTransformViewController




//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//}



// We wish to wait until views have been laid out before load and animating.
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self loadImage];
    
    [self animateImages];
    
}



// Load our initial image, and then zoom into a section of it.
// This will involve a scale and translate.
//
// Note that we need to make sure that Clip Subviews is checked on container on Storyboard!
//
- (void)loadImage {
    
    self.imageView.image = [UIImage imageNamed:@"image1"];
    
  
    
    // From the source video it appears that the scale factor is 2.5 and the new center is roughly in the
    // center of the upper right quadrant (tweaked this a little).
    self.imageView.transform = [self transformWithScaleFactor:2.5 newCenterFractionX:0.78 newCenterFractionY:0.38];
    
}


- (void)animateImages {
    
    // We wish to zoom out until the full image is visible again.  The zoom is linear
    // over 7 seconds. We will rotate 360 degrees as we zoom.
    //
    // Reference for how to rotate:
    // http://stackoverflow.com/questions/19406166/ios-a-complete-360-degree-rotation-using-block-not-cabasicanimation
    //
    [UIView animateKeyframesWithDuration:7.0 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
                             
        self.imageView.transform = CGAffineTransformIdentity;
        
        [self addKeyFramesForContainerRotation];
        
    } completion:^(BOOL finished) {
        
        // Now flip the image to face the left on its edge and then continuing flipping
        // until the reverse side with a new image is visible.  Transition occurs over the course of 4 seconds.
        //
        // We swap the image halfway through the transition.
        //
        // Note: We no longer need the UIViewAnimationOptionAllowAnimatedContent option after
        //       moving away from the NSTimer approach.
        //
        [UIView transitionWithView:self.imageView
                          duration:4.0
                           options:UIViewAnimationOptionTransitionFlipFromRight //  | UIViewAnimationOptionAllowAnimatedContent
                        animations:^{
                            self.imageView.image = [UIImage imageNamed:@"image2"];
                            
                        } completion:^(BOOL finished) {
                            
                            // Finish by zooming in to the upper left quadrant of the second image.  The zoom is linear
                            // over 7 seconds.   We will rotate 360 degrees as we zoom.
                            //
                            [UIView animateKeyframesWithDuration:7.0 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
                                
                                // From the source video it appears that the scale factor is 4.0 and the new center is roughly in the
                                // center of the upper left quadrant (tweaked this a little).
                                self.imageView.transform = [self transformWithScaleFactor:4.0 newCenterFractionX:0.16 newCenterFractionY:0.12];
                                
                                [self addKeyFramesForContainerRotation];
                                
                            } completion:^(BOOL finished) {
                                ;
                            }];
                            
                            
                        }];
        
        
    }];
    
    
}


// Called from within animateKeyframesWithDuration: method to cause our containerView to rotate 360 degrees.
//
// We can set all start times and durations to 0 since we are using the UIViewKeyframeAnimationOptionCalculationModePaced
// option in animateKeyframesWithDuration: to compute intermediate keyframe values using a simple pacing algorithm
// and create an evenly paced animation.
//
- (void)addKeyFramesForContainerRotation
{
    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.0 animations:^{
        self.containerView.transform = CGAffineTransformMakeRotation(120 * M_PI/180.0); // M_PI  * 2.0f / 3.0f);
    }];
    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.0 animations:^{
        self.containerView.transform = CGAffineTransformMakeRotation(240 * M_PI/180.0); // M_PI * 4.0f / 3.0f);
    }];
    [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.0 animations:^{
        self.containerView.transform = CGAffineTransformIdentity;
    }];
}



// Method will return a transform with the specified scale factor and
// the center translated.
//
// We express the new center location as a fraction of image dimensions after scaling.
// Center of upper right quadrant will have fractions 0.75, 0.25 (x=0, y=0 is upper left corner of image).
//
- (CGAffineTransform)transformWithScaleFactor:(CGFloat)scaleFactor
                           newCenterFractionX:(CGFloat)newCenterFractionX
                           newCenterFractionY:(CGFloat)newCenterFractionY
{
    // Dimensions of container of image (UIImageView)
    CGFloat containerWidth = self.containerView.bounds.size.width;
    CGFloat containerHeight = self.containerView.bounds.size.height;
    
    
    // Dimensions of scaled image (UIImageView).
    CGFloat imageWidth = containerWidth * scaleFactor;
    CGFloat imageHeight = containerHeight * scaleFactor;
    
    
    // Calculate deltas needed to translate to new center.  If we move to center of upper right
    // quadrant for example, we would need to shift down and to the left (postive y delta, negative x delta).
    //
    CGFloat deltaX = imageWidth * 0.5 - imageWidth * newCenterFractionX;
    CGFloat deltaY = imageHeight * 0.5 - imageHeight * newCenterFractionY;
    
    CGAffineTransform scaleTransform = CGAffineTransformScale(self.imageView.transform, scaleFactor, scaleFactor);
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(deltaX, deltaY);
    
    // Order of transforms matters!
    CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, translateTransform);
    
    return transform;
}




@end
