//
//  EVNCameraController.m
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017 Ren Bian. All rights reserved.
//

#import "EVNCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import "CRCountdown.h"
//#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>

#define kEVNScreenWidth [UIScreen mainScreen].bounds.size.width
#define kEVNScreenHeight [UIScreen mainScreen].bounds.size.height

@interface EVNCameraController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate
>
{
    BOOL isflashOn; // Whether the flash is turned on
    BOOL isTimerOn;
    BOOL isGalleryImage;

    NSDictionary *galleryImageInfo;

    CRCountdownUpdate update;
    CRCountdownCompletion completion;
}

/**
 * Capture device, usually front camera, rear camera
 */
@property (nonatomic, strong) AVCaptureDevice *device;

/**
 * AVCaptureDeviceInput: input device, use AVCaptureDevice initialization
 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;

/**
 * Capture camera output
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;

/**
 * Start capture camera
 */
@property (nonatomic, strong) AVCaptureSession *session;

/**
 * Capture image layer in real time, image preview
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/**
 * White circle photo
 */
@property (nonatomic, strong) UIButton *photoButton;

@property (nonatomic, strong) UIButton *uploadButton;

@property (nonatomic, strong) UIButton *timerButton;
@property (nonatomic, strong) UIButton *timerOff;
@property (nonatomic, strong) UIButton *timer5s;
@property (nonatomic, strong) UIButton *timer10s;
@property (nonatomic, strong) UIButton *timerCounter;

@property (nonatomic, strong) UIButton *flipCameraButton;

@property (nonatomic, strong) UIButton *saveButton;
/**
 * Turn on the flash button
 */
@property (nonatomic, strong) UIButton *flashButton;

/**
 * Replay back to the screen after successful shooting
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 * Focus green frame
 */
@property (nonatomic, strong) UIView *focusView;

/**
 * Picture data taken
 */
@property (nonatomic, strong) UIImage *image;

/**
 * Whether to enable camera permissions
 */
@property (nonatomic, assign) BOOL canUseCamera;

/**
 * Cancel shooting
 */
@property (nonatomic, strong) UIButton *cancleButton;

/**
 * Front rear camera switching
 */
@property (nonatomic, strong) UIButton *swapButton;

/**
 * Retake
 */
@property (nonatomic, strong) UIButton *againTakePictureBtn;

/**
 * Use pictures
 */
@property (nonatomic, strong) UIButton *usePictureBtn;

@property (nonatomic, strong) UIImageView *tabImage;




@end

@implementation EVNCameraController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    if (self.isCanUseCamera)
//    {
//        [self customCamera];
//        [self customCameraView];
//    }
//    else
//    {
//      // @todo: ask the user for the camera permission.
//        NSLog(@"ask for camera permission");
//        return;
//    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%ld", (long)toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // MARK: Start autofocus for the first time
    [self focusAtPoint:CGPointMake(kEVNScreenWidth/2.0f, kEVNScreenHeight/2.0f)];

    NSLog(@"viewDidAppear");
    if(!self.isCanUseCamera) {
      NSLog(@"show custom ui asking for camera permission from settings");
      UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Camera Permissions" message:@"We need camera permission so you can take and share your pictures. Please go to the settings to allow the app to access your camera: Settings - Privacy - Camera" preferredStyle:UIAlertControllerStyleAlert];

      UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No need" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
           {
             [self cancleButtonAction];
           }
      ];

      UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Go to settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Jump to set open permission
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url])
        {
          [[UIApplication sharedApplication] openURL:url];
        }
      }];

      [alertController addAction:cancelAction];
      [alertController addAction:okAction];

      [self presentViewController:alertController animated:YES completion:nil];

    } else {
      [self customCamera];
      [self customCameraView];
    }

}

/**
 * MARK: Whether to enable camera permissions
 @return return canUseCamera
 */
- (BOOL)isCanUseCamera
{
    if (!_canUseCamera)
    {
        _canUseCamera = [self validateCanUseCamera];
    }
    return _canUseCamera;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

  if (alertView.tag == 199) {
    if (buttonIndex == 1) {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    return;
  }
}


- (void) setButtonShadow:(UIButton *) button{
  [button.layer setShadowOffset:CGSizeMake(0, 6)];
  [button.layer setShadowColor:[[UIColor blackColor] CGColor]];
  [button.layer setShadowOpacity: 1];
  [button.layer setShadowRadius: 12];
}

-(void)toggleFlash{
  if ([_device lockForConfiguration:nil])
  {
      if (isflashOn)
      {
          if ([_device isFlashModeSupported:AVCaptureFlashModeOff])
          {
              [_device setFlashMode:AVCaptureFlashModeOff];
              isflashOn = NO;
              NSLog(@"change flash icon to off");
          }
      }
      else
      {
          if ([_device isFlashModeSupported:AVCaptureFlashModeOn])
          {
              [_device setFlashMode:AVCaptureFlashModeOn];
              isflashOn = YES;
              NSLog(@"change flash icon to on");
          }
      }
      [_device unlockForConfiguration];
      NSLog(@"flash is %s", isflashOn ? "true" : "false");
  }
  NSLog(@"toggle flash called");
  if ([self.cameraControllerDelegate respondsToSelector:@selector(flashDidFinishToggle:)])
  {
    NSDictionary *info = @{
      @"isflashOn": isflashOn ? @YES : @NO
    };
    
    [self.cameraControllerDelegate flashDidFinishToggle:info];
  }
  
}
-(void)takePicture {
  // @important: same logic as in `shatterCamera` method
  AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
  if (!videoConnection)
  {
      NSLog(@"Photo failure!");
      return;
  }

  [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){

      if (imageDataSampleBuffer == NULL) return;

      NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
      self.image = [UIImage imageWithData:imageData];

      UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(cameraImage:didFinishSavingWithError:contextInfo:), NULL);


      [self.session stopRunning]; // stop session

      return;
  }];
}

-(void)timer{

}

- (void)flipMyCamera{
  // @note: same logic used in `swapCamera` method.
  // use `dispatch_async` to make sure the code is executed in the main thread
  // and the animation is executed properly.
  dispatch_async(dispatch_get_main_queue(), ^{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1)
    {
        NSError *error;

        CATransition *animation = [CATransition animation];

        animation.duration = .5f;

        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }

        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil)
        {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput])
            {
                [self.session addInput:newInput];
                self.input = newInput;
            }
            else
            {
                [self.session addInput:self.input];
            }

            [self.session commitConfiguration];

        }
        else if (error)
        {
            NSLog(@"Switching camera failed, error = %@", error);
        }
    }
  });
}

/**
 * MARK: Initialize the view required by the camera
 */
- (void)customCameraView
{

    isTimerOn = NO;

    CGFloat device_width = [UIScreen mainScreen].bounds.size.width;

    _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];

    if(isflashOn) {
      [_flashButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/flashOn.png"] forState:UIControlStateNormal];
    } else {
      [_flashButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/flashOff.png"] forState:UIControlStateNormal];
    }

    [_flashButton addTarget:self action:@selector(flashOn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];

    _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 0.51;
    _focusView.backgroundColor = [UIColor clearColor];
    _focusView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;

    _timerOff = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timerOff setTitle:@"Off" forState:UIControlStateNormal];
    _timerOff.frame = CGRectMake(10, 40, 60, 30);
    [_timerOff.titleLabel setFont:[UIFont boldSystemFontOfSize: 15]];
    [_timerOff setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_timerOff setBackgroundColor: [UIColor colorWithRed:0.36 green:0.36 blue:0.41 alpha:1.0]];
    [_timerOff addTarget:self action:@selector(turnOffTimer:) forControlEvents:UIControlEventTouchUpInside];
    _timerOff.layer.cornerRadius = 5;
    _timerOff.clipsToBounds = YES;
    _timerOff.hidden = YES;
    [self.view addSubview: _timerOff];

    _timer5s = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timer5s setTitle:@"5s" forState:UIControlStateNormal];
    _timer5s.frame = CGRectMake(10 + 10 + 60, 40, 60, 30);
    [_timer5s.titleLabel setFont:[UIFont boldSystemFontOfSize: 15]];
    [_timer5s setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_timer5s setBackgroundColor: [UIColor colorWithRed:0.36 green:0.36 blue:0.41 alpha:1.0]];
    [_timer5s addTarget:self action:@selector(setTimer5Sec:) forControlEvents:UIControlEventTouchUpInside];
    _timer5s.layer.cornerRadius = 5;
    _timer5s.clipsToBounds = YES;
    _timer5s.hidden = YES;
    [self.view addSubview: _timer5s];

    _timer10s = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timer10s setTitle:@"10s" forState:UIControlStateNormal];
    _timer10s.frame = CGRectMake(10 + 10 + 60 + 10 + 60, 40, 60, 30);
    [_timer10s.titleLabel setFont:[UIFont boldSystemFontOfSize: 15]];
    [_timer10s setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_timer10s setBackgroundColor: [UIColor colorWithRed:0.36 green:0.36 blue:0.41 alpha:1.0]];
    [_timer10s addTarget:self action:@selector(setTimer10Sec:) forControlEvents:UIControlEventTouchUpInside];
    _timer10s.layer.cornerRadius = 5;
    _timer10s.clipsToBounds = YES;
    _timer10s.hidden = YES;
    [self.view addSubview: _timer10s];

    _timerCounter = [UIButton buttonWithType:UIButtonTypeCustom];
    [_timerCounter setTitle:@"0" forState:UIControlStateNormal];
    _timerCounter.frame = CGRectMake(10, 40, 60, 30);
    [_timerCounter.titleLabel setFont:[UIFont boldSystemFontOfSize: 15]];
    [_timerCounter setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_timerCounter setBackgroundColor: [UIColor colorWithRed:0.36 green:0.36 blue:0.41 alpha:1.0]];
    _timerCounter.layer.cornerRadius = 5;
    _timerCounter.clipsToBounds = YES;
    _timerCounter.hidden = YES;
    [self.view addSubview: _timerCounter];

    self->update = ^(NSUInteger ticks) {
//      self.infoLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)ticks];
      [_timerCounter setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)ticks] forState:UIControlStateNormal];
      NSLog(@"update timer");
    };

    self->completion = ^{
//      self.infoLabel.hidden = YES;
      _timerCounter.hidden = YES;
      isTimerOn = NO;
      // do whatever else you want
      NSLog(@"timer finished");

      // trigger camera button
      [self takePicture];
    };

    CGFloat DEVICE_WIDTH = [UIScreen mainScreen].bounds.size.width;
    CGFloat DEVICE_HEIGHT = [UIScreen mainScreen].bounds.size.height;

    NSLog(@"Device info %f %f", DEVICE_WIDTH, DEVICE_HEIGHT);


    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}


- (AVCaptureSession *)extracted {
    return self.session;
}

/**
 * Custom camera
 */
- (void)customCamera
{
    self.view.backgroundColor = [UIColor whiteColor];

    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; // use AVMediaTypeVideo Specify self.device Represents the video, which is initialized by default with the rear camera.

    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil]; // Use device initialization input

    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];

    self.session = [[AVCaptureSession alloc] init]; // Generate a session to combine input and output
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input])
    {
        [[self extracted] addInput:self.input];
    }

    if ([self.session canAddOutput:self.imageOutPut])
    {
        [self.session addOutput:self.imageOutPut];
    }

    // use self.session，Initialize the preview layer，self.session Driven input Collecting information，layer Responsible for rendering the image
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kEVNScreenWidth, kEVNScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];

    [self.session startRunning]; // Start up
    if ([_device lockForConfiguration:nil])
    {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto])
        {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
      if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) // Automatic white balance

        {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}


/**
 * MARK: Turn off the flash
 @param sender Flash Button
 */
- (void)flashOn:(UIButton *)sender
{
    if ([_device lockForConfiguration:nil])
    {
        if (isflashOn)
        {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff])
            {
                sender.selected = NO;
                sender.tintColor = [UIColor whiteColor];
                [_device setFlashMode:AVCaptureFlashModeOff];
                isflashOn = NO;
                [_flashButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/flashOff.png"] forState:UIControlStateNormal];
                NSLog(@"change flash icon to off");
            }
        }
        else
        {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn])
            {
                sender.selected = YES;
                sender.tintColor = [UIColor yellowColor];
                [_device setFlashMode:AVCaptureFlashModeOn];
                isflashOn = YES;
                [_flashButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/flashOn.png"] forState:UIControlStateNormal];
                NSLog(@"change flash icon to on");

            }
        }
        [_device unlockForConfiguration];
        NSLog(@"flash is %s", isflashOn ? "true" : "false");
    }
}

/**
 * Switch camera, front/rear
 */
- (void)swapCamera:(UIButton *)sender
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1)
    {
        NSError *error;

        CATransition *animation = [CATransition animation];

        animation.duration = .5f;

        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }

        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil)
        {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput])
            {
                [self.session addInput:newInput];
                self.input = newInput;
            }
            else
            {
                [self.session addInput:self.input];
            }

            [self.session commitConfiguration];

        }
        else if (error)
        {
            NSLog(@"Switching camera failed, error = %@", error);
        }
    }
}


/**
 * MARK: Camera switching operation
 @param position Camera position，front:AVCaptureDevicePositionFront end:AVCaptureDevicePositionBack
 @return AVCaptureDevice
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

/**
 * MARK: Focus gesture, get focus coordinates
 @param gesture tap
 */
- (void)focusGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}


/**
 * MARK: Focus
 @param point Coordinate point of focus
 */
- (void)focusAtPoint:(CGPoint)point
{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error])
    {

        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }

        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ])
        {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }

        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
}

/**
 * MARK: screenshot
 */
- (void)shutterCamera:(UIButton *)sender
{
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection)
    {
        NSLog(@"Photo failure!");
        return;
    }

    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){

        if (imageDataSampleBuffer == NULL) return;

        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];

        UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(cameraImage:didFinishSavingWithError:contextInfo:), NULL);


        [self.session stopRunning]; // stop session
        return;
    }];
}

- (void)saveImage:(UIButton *)sender
{
    NSLog(@"image to save:");
    if(isGalleryImage){
//      self.image = [UIImage imageWithContentsOfFile: [galleryImageInfo objectForKey:@"UIImagePickerControllerReferenceURL"]];

      UIAlertController *alertController = [UIAlertController
                                            alertControllerWithTitle:@"Warning"
                                            message:@"This Image Already exists on your gallery."
                                            preferredStyle:UIAlertControllerStyleAlert];
      //We add buttons to the alert controller by creating UIAlertActions:
      UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil]; //You can use a block here to handle a press on this button
      [alertController addAction:actionOk];
      [self presentViewController:alertController animated:YES completion:nil];


    } else {
      // save the newly taken image.
      UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(cameraImage:didFinishSavingAlert:contextInfo:), NULL);
    }
}

- (void)cameraImage:(UIImage *)cameraImage didFinishSavingAlert:(NSError *)error contextInfo:(NSDictionary<NSString *,id> *)contextInfo
{
  if(error != NULL)
  {
    NSLog(@"error image!");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Warning" message:@"Failed to save image" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
  }
  else
  {
    // image saved successfully.
    NSLog(@"image saved!");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"The image was saved successfully" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
  }

}

- (void)pickImage
{

  UIImagePickerController *pickerView = [[UIImagePickerController alloc] init];
//   pickerView.allowsEditing = YES;
  pickerView.delegate = self;
  [pickerView setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//   [self presentModalViewController:pickerView animated:YES];

  NSLog(@"@pickImage method");
  [self presentViewController:pickerView animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

  // get image selected when using `pickerView.allowsEditing = YES;`
//   UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
  UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
  NSString  *jpgPath = info[UIImagePickerControllerImageURL];

  NSLog(@"image path: %@", jpgPath);


  isGalleryImage = YES;
  galleryImageInfo = info;

  NSMutableDictionary* imageInfoDict;
  imageInfoDict = [[NSMutableDictionary alloc] initWithCapacity:5];
  [imageInfoDict setValue:jpgPath forKey:@"imagePath"];
  [imageInfoDict setValue:jpgPath forKey:@"UIImagePickerControllerImageURL"];

  // check if `RoaaCamera` has `didFinishPickingMediaWithInfo` method.
  // @note: don't call `self.cameraControllerDelegate didFinishPickingMediaWithInfo:info`
  // it is used only when the user needs clicks on upload and the js part, will push the share screen
  // if we call this then the js part will push the share screen 2times which is not desired!.

  [picker dismissViewControllerAnimated:YES completion:NULL];

  if ([self.cameraControllerDelegate respondsToSelector:@selector(didFinishPickingMediaWithInfo:)])
  {
    [self.cameraControllerDelegate didFinishPickingMediaWithInfo:imageInfoDict];
  }


  return;

}


/**
 * MARK: Retake
 @param sender Retake button
 */
- (void)againTakePictureBtn:(UIButton *)sender
{

}

/**
 * MARK: Retake
 @param sender sender
 */
- (void)usePictureBtn:(UIButton *)sender
{

  if(isGalleryImage) {
    // the user picked an image from gallery
    NSLog(@"gallery image info: %@", galleryImageInfo);
    if ([self.cameraControllerDelegate respondsToSelector:@selector(didFinishPickingMediaWithInfo:)])
    {
      [self.cameraControllerDelegate didFinishPickingMediaWithInfo: galleryImageInfo];
    }

  } else {
    NSLog(@"image info:", self.image);
    // MARK: Save to album
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(cameraImage:didFinishSavingWithError:contextInfo:), NULL);
  }
    [self cancleButtonAction];
}

/**
 * MARK: Specify callback method
 @param cameraImage image
 @param error error
 @param contextInfo contextInfo
 */
- (void)cameraImage:(UIImage *)cameraImage didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary<NSString *,id> *)contextInfo
{
    if(error != NULL)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"prompt" message:@"Failed to save image" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"determine" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alertController animated:NO completion:nil];
    }
    else
    {
        if ([self.cameraControllerDelegate respondsToSelector:@selector(cameraDidFinishShootWithCameraImage:)])
        {
            [self.cameraControllerDelegate cameraDidFinishShootWithCameraImage:cameraImage];
        }
        NSLog(@"image::: %@", cameraImage);
        // @important: the following line is needed to re-activate the cam when a user takes a camera shot.
        [self.session startRunning];
    }
}

/**
 * MARK: Cancel shooting
 */
- (void)cancleButtonAction
{
    [self.imageView removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];


    [_swapButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    NSLog(@"cancel button clicked!");
}

/**
 * MARK: Check camera permissions
 @return Whether to check camera permissions
 */
- (BOOL)validateCanUseCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Please turn on camera permissions" message:@"Please go to the settings to allow the app to access your camera: Settings - Privacy - Camera" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No need" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"determine" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // Jump to set open permission
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];

        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alertController animated:NO completion:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)turnOffTimer:(UIButton *)sender
{
  NSLog(@"turn off timer");
  isTimerOn = NO;
  _timerOff.hidden = YES;
  _timer5s.hidden = YES;
  _timer10s.hidden = YES;
}

- (void)toggleTimer:(UIButton *)sender
{
    if(isTimerOn) {
        isTimerOn = NO;
      [_timerOff sendActionsForControlEvents: UIControlEventTouchUpInside];
    } else {
        isTimerOn = YES;

        _timerOff.hidden = NO;
        _timer5s.hidden = NO;
        _timer10s.hidden = NO;
    }
    NSLog(@"toggle timer");
}

- (void)privateToggleTimer
{
    if(isTimerOn) {
        isTimerOn = NO;

        NSLog(@"turn off timer");
        isTimerOn = NO;

        dispatch_async(dispatch_get_main_queue(), ^{
          // @important `dispatch_async` is needed because UI operations
          // must be performed in the main thread.
          _timerOff.hidden = YES;
          _timer5s.hidden = YES;
          _timer10s.hidden = YES;
        });


    } else {
        isTimerOn = YES;

      dispatch_async(dispatch_get_main_queue(), ^{
        // @important `dispatch_async` is needed because UI operations
        // must be performed in the main thread.
        _timerOff.hidden = NO;
        _timer5s.hidden = NO;
        _timer10s.hidden = NO;

      });


    }
    NSLog(@"toggle timer");
}

- (void)setTimer5Sec:(UIButton *)sender
{
  NSLog(@"set timer 5sec");
  [_timerCounter setTitle:@"5" forState:UIControlStateNormal];

  CRCountdown *countdown = [[CRCountdown alloc] init];
  [countdown startCountdownWithInterval:1.0
                                  ticks:5
                             completion: self->completion
                                update: self->update];
  _timerCounter.hidden = NO;
  _timerOff.hidden = YES;
  _timer5s.hidden = YES;
  _timer10s.hidden = YES;

}

- (void)setTimer10Sec:(UIButton *)sender
{
  NSLog(@"set timer 10sec");
  [_timerCounter setTitle:@"10" forState:UIControlStateNormal];

  CRCountdown *countdown2 = [[CRCountdown alloc] init];
  [countdown2 startCountdownWithInterval:1.0
                                  ticks:10
                             completion: self->completion
                                 update: self->update];
  _timerCounter.hidden = NO;
  _timerOff.hidden = YES;
  _timer5s.hidden = YES;
  _timer10s.hidden = YES;

}

// Triggered when starting to shake
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"Start shaking");
}

// Triggered when the end shakes
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"End of shaking");
}

// Triggered when shake is interrupted
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"Cancel the shaking, stop the shaking");
}

- (void)dealloc
{
    NSLog(@"%@, %s", NSStringFromClass([self class]), __func__);
}






@end
