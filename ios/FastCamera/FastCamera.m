#import <Foundation/Foundation.h>
#import "FastCamera.h"

// import RCTEventDispatcher

#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>
#import <React/RCTConvert.h>

#import "EVNCameraController.h"

@implementation FastCamera : UIView  {

  RCTEventDispatcher *_eventDispatcher;

  EVNCameraController *_cameraController;

}


- (void)sendEvent:(UIEvent *)event {
  NSLog(@"event type: %@", event.type);
}

-(void)pickImage{
  [_cameraController pickImage];
}
-(void)toggleFlash{
  [_cameraController toggleFlash];
}
-(void)takePicture {
  [_cameraController takePicture];
}

-(void)timer{
  NSLog(@"step2");
//  [_cameraController toggleTimer];
  [_cameraController privateToggleTimer];
}

- (void)flipCamera {
  NSLog(@"flipCamera called!!!");
  [_cameraController flipMyCamera];
}


- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher
{
  if ((self = [super init])) {
    _eventDispatcher = eventDispatcher;

    // add initializations if needed here
    // CGRect frame = CGRectMake(0.0, 0.0, 200.0, 10.0);

  }

  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];


  NSLog(@"uiview dimensions: %f %f",self.bounds.size.height, self.bounds.size.height);

  float deviceWidth = [UIScreen mainScreen].bounds.size.width;
  float deviceHeight = [UIScreen mainScreen].bounds.size.height;

//  self.bounds = CGRectMake(0, 0, 375, 667);

  // @important: this is needed so the cam take the whole device dimensions.
  self.bounds = [UIScreen mainScreen].bounds;


  _cameraController = [[EVNCameraController alloc] init];
  _cameraController.cameraControllerDelegate = self;

  // @todo: make sure the bounds of the cam are respecting its parent view.
  // cameraController.view.bounds = self.bounds;

  [self addSubview: _cameraController.view];

}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
}

- (void)setNeedsFocusUpdate {
}

- (void)updateFocusIfNeeded {
}

// @todo: check if the folowing method needs to be removed
- (NSArray<NSString *> *)supportedEvents {
  return @[@"onSaveSuccess", @"onGalleryImage", @"onFlashToggle"];
}

-(void)flashDidFinishToggle:(NSDictionary *) status{
  if(self.onFlashToggle){
    self.onFlashToggle(status);
  }
  NSLog(@"flash toggled %@", status);
}

- (void)cameraDidFinishShootWithCameraImage:(UIImage *)cameraImage {
  NSLog(@"taken image is: %@", cameraImage);

  // Create paths to output images
  NSString *newFilePath = [NSString stringWithFormat:@"%s%@%s","Documents/", self.customFormattedDate, ".jpg"];
  NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:newFilePath];
  NSString *folderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];

  [UIImageJPEGRepresentation(cameraImage, 1.0) writeToFile:jpgPath atomically:YES];

  NSError *error;
  NSFileManager *fileMgr = [NSFileManager defaultManager];


  // Point to Document directory
  NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

  // Write out the contents of home directory to console
  NSArray *filesArray = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
  NSLog(@"Documents directory: %@", filesArray);

  // handle filemanager errosp
  if(error != nil) {
    NSLog(@"Error in reading files: %@", [error localizedDescription]);
    return;
  }


  // check if the new file was saved successfully.
  BOOL fileExists = [fileMgr fileExistsAtPath:jpgPath];
  if(fileExists){
    NSLog(@"new file saved successfully %@", jpgPath);
    NSLog(@"%@", jpgPath);

    NSDictionary *imageInfo = @{
      // @important: add `file://` prefix fo the file to work.
      @"image": [NSString stringWithFormat:@"%@%@", @"file://", jpgPath],
    };

    // @important, the following check is needed to avoid the app crashing
    if(self.onSaveSuccess) {
      self.onSaveSuccess(imageInfo);
    }

  //    [self sendEventWithName:@"onSaveSuccess" body:imageInfo];

  }

}


- (void)didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  NSString  *jpgPath = info[UIImagePickerControllerImageURL];
  // @important: weird behavior when passed `jpgPath` js side received undefined and I
  // had to use a string formatter to fix that!.

  //  [self sendEventWithName:@"onGalleryImage" body: [NSString stringWithFormat:@"%@", jpgPath]];


  NSLog(@"gallery image -> RN:%@", jpgPath);

  NSDictionary *imageInfo = @{
                              //@"image": jpgPath,
                              // @important: use `[NSString stringWithFormat:@"%@", jpgPath]`
                              // to avoid `jpgPath` returning empty `null` for the js side
                              @"image": [NSString stringWithFormat:@"%@", jpgPath],
                              @"target": self.reactTag, //@important: needed for `_eventDispatcher`
                              };

//  [self setOnGalleryImage: @imageInfo];
//  [_eventDispatcher sendInputEventWithName:@"onGalleryImage1" body:imageInfo];

// @important: we need to check if `self.onGalleryImage`
// otherwise an exception is thrown.
  if(self.onGalleryImage){
    NSLog(@"check if onGalleryImage is available");
    self.onGalleryImage(imageInfo);
  }

}

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
  //You can retrieve the actual UIImage
  UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
  //Or you can get the image url from AssetsLibrary
  NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];


  NSURL *imagePath = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
  NSString *imageName = [imagePath lastPathComponent];
  NSLog(@"image url: %@ ", imageName);
  [picker dismissViewControllerAnimated:YES completion:nil];

}

- (NSString *)customFormattedDate{
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"dd-MM-yyyy_HH:mm"];

  NSDate *currentDate = [NSDate date];
  NSString *dateString = [formatter stringFromDate:currentDate];
  return dateString;
}

//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//  CGFloat radius = 100.0;
//  CGRect frame = CGRectMake(-radius, -radius,
//                            self.frame.size.width + radius,
//                            self.frame.size.height + radius);
//
//  NSLog(@"hitTest: %f %f %@", point.x, point.y, event);
//
//  if (CGRectContainsPoint(frame, point)) {
//    return self;
//  }
//  return nil;
//}



@end
