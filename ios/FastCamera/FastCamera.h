#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTComponent.h>


#import "EVNCameraController.h"

@class RCTEventDispatcher;

@interface FastCamera : UIView<EVNCameraControllerDelegate>
// Define view properties here with @property
// @property (nonatomic, assign) NSString* btnColor;
@property (nonatomic, copy) RCTDirectEventBlock onChange;
@property (nonatomic, copy) RCTDirectEventBlock onSaveSuccess;
@property (nonatomic, copy) RCTDirectEventBlock onGalleryImage;
@property (nonatomic, copy) RCTDirectEventBlock onFlashToggle;

- (NSString *)customFormattedDate;

-(void)pickImage;
-(void)toggleFlash;
-(void)takePicture;
-(void)timer;
-(void)flipCamera;

// Initializing with the event dispatcher allows us to communicate with JS
- (instancetype)initWithEventDispatcher:(RCTEventDispatcher *)eventDispatcher NS_DESIGNATED_INITIALIZER;

@end
