

# Screenshot

![example1 img](ImageTransform.gif?raw=true)


# Overview 

This is a project that was created as a result of a code challenge.

The challenge was to watch a video showing the manipulation of two images and implement this as an iOS app.  From the video I extracted the following requirements:

- Start out with first image zoomed into the upper right quadrant.
- Zoom out on first image until it is fully visible while simultaneously rotating the image clockwise.
- Flip the image on its Y axis.
- Halfway through the flip (only edge visible), swap in the second image.
- Once the second image is fully visible, zoom into the upper left quadrant of image while also rotating the image.


# Extension

I decided to go beyond the code challenge.  I created an extension for the Photo app that allows one to select multiple images and create the same manipulations as in the main code challenge.

The extension target is named SelectMultiple.   In Bundle display name parameter in Info.plist for target I use the value "ImageTransform", which is what will appear as the extension name in the photo app.

Once you have selected some photos in the Photo app and have invoked the Send To button, you will need to click on the More icon in the bottom row of actions to enable ImageTransform.



# Resources

[Camtasia 2] (http://www.techsmith.com/camtasia.html) was used to capture a video of the simulator screen when the app was launched.

[Gif Maker] (http://ezgif.com/maker) was used to convert the MP4 from Camtasia 2 into the animated GIF example above.







