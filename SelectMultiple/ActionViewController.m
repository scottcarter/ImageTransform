//
//  ActionViewController.m
//  SelectMultiple
//
//  Created by Scott Carter on 2/12/15.
//  Copyright (c) 2015 Scott Carter. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>


/*
 
 Notes:
 
 In Info.plist:
 
 Add the NSExtensionActivationRule:
 NSExtensionActivationSupportsImageWithMaxCount = 60
 
 
 Set CFBundleDisplayName = ImageTransform (what displays in Action menu)
 
 */


@interface ActionViewController ()


@property (weak, nonatomic) IBOutlet UIView *containerView;

@property(strong,nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSMutableArray *imageQueue;  // Queue of images to animate.

@end

@implementation ActionViewController


typedef void(^completion_t)(void);


- (NSMutableArray *)imageQueue
{
    if(!_imageQueue){
        _imageQueue = [[NSMutableArray alloc] init];
    }
    return _imageQueue;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    
    // Look for an image and place it in our queue.
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                
                // This is an image. We'll load it into imageQueue.
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [self queuePush:image];
                            
                        }];
                    }
                }];
                
            }
        }
        
        
    }
    
    
}


// We wish to wait until views have been laid out before load and animating.
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    // Prime the transitions with first image.
    //
    if([self queueEmpty]){
        return;
    }
    
    // Load an image, and then zoom into a section of it.
    // This will involve a scale and translate.
    //
    // Note that we need to make sure that Clip Subviews is checked on container on Storyboard!
    //
    self.imageView.image = [self queuePop];
    
    
    // From the source video it appears that the scale factor is 2.5 and the new center is roughly in the
    // center of the upper right quadrant (tweaked this a little).
    self.imageView.transform = [self transformWithScaleFactor:2.5 newCenterFractionX:0.78 newCenterFractionY:0.38];
    
    
    
    // Animate images.  Start by zooming out.
    [self zoomOut:^{
        // Any code to execute after all animations are complete
        NSLog(@"All images animated");
    }];
    
    
}


- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}



// Recursive entry point to animate images.  We start by zooming out until full image is visible.
- (void)zoomOut:(completion_t)completionBlock {
    
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
        
        // If there are no more images, we are done.
        if ([self queueEmpty]) {
            completionBlock();
            return;
        }

        [self flipAndZoomOut:NO completionBlock:completionBlock];
    }];
    
}

// Flip to next image.  Called by animate
- (void)flipAndZoomOut:(BOOL)nextFlipIsZoomOut  completionBlock:(completion_t)completionBlock {
    
    // Now flip the image to face the left on its edge and then continuing flipping
    // until the reverse side with a new image is visible.  Transition occurs over the course of 4 seconds.
    //
    // We swap the image halfway through the transition.
    //
    // Cleaner to flip the containerView rather than the imageView.
    // I had an issue while flipping imageView while we were zoomed in.
    [UIView transitionWithView:self.containerView
                      duration:4.0
                       options:UIViewAnimationOptionTransitionFlipFromRight //  | UIViewAnimationOptionAllowAnimatedContent
                    animations:^{
                        self.imageView.image = [self queuePop];
                        
                    } completion:^(BOOL finished) {
                        
                        if(nextFlipIsZoomOut){
                            [self zoomOut:completionBlock];
                        }
                        else {
                            [self zoomIn:completionBlock];
                        }
                    }];
}



- (void)zoomIn:(completion_t)completionBlock {
    
    // Finish by zooming in to the upper left quadrant of the second image.  The zoom is linear
    // over 7 seconds.   We will rotate 360 degrees as we zoom.
    //
    [UIView animateKeyframesWithDuration:7.0 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        
        // From the source video it appears that the scale factor is 4.0 and the new center is roughly in the
        // center of the upper left quadrant (tweaked this a little).
        self.imageView.transform = [self transformWithScaleFactor:4.0 newCenterFractionX:0.16 newCenterFractionY:0.12];
        
        [self addKeyFramesForContainerRotation];
        
    } completion:^(BOOL finished) {
        
        // If there are no more images, we are done.
        if ([self queueEmpty]) {
            completionBlock();
            return;
        }

        [self flipAndZoomOut:YES completionBlock:completionBlock];
        
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



// Implement a first in, first out queue for images.
- (void)queuePush:(UIImage *)anObject {
    [self.imageQueue insertObject:anObject atIndex:0];
}

- (UIImage *)queuePop {
    UIImage *anObject = [self.imageQueue lastObject];
    
    if(anObject){
        [self.imageQueue removeLastObject];
    }
    return anObject;
}

- (BOOL)queueEmpty
{
    if([self.imageQueue count] == 0){
        return YES;
    }
    return NO;

}



@end
