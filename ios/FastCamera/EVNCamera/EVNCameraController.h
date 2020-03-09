//
//  EVNCameraController.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Camera shooting agent
 */
@protocol EVNCameraControllerDelegate <NSObject, UIImagePickerControllerDelegate>

- (void)cameraDidFinishShootWithCameraImage:(UIImage *)cameraImage;
- (void)didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)sendPictureWithLocation:(NSArray *) info;
- (void)flashDidFinishToggle:(NSArray *) info;

@end


/**
 * Custom camera view controller
 */
@interface EVNCameraController : UIViewController


@property (weak, nonatomic) id<EVNCameraControllerDelegate> cameraControllerDelegate;
- (void)flipMyCamera;
- (void)pickImage;
- (void)toggleFlash;
- (void)takePicture;
- (void)toggleTimer;
- (void)privateToggleTimer;

@end

