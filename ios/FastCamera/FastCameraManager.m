#import "FastCameraManager.h"
#import "FastCamera.h"

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>

@implementation FastCameraManager

@synthesize bridge = _bridge;

FastCamera *_advancedView;

RCT_EXPORT_MODULE(FastCamera)

- (UIView *)view
{

  // instanciate the new cam component.
  _advancedView = [[FastCamera alloc] initWithEventDispatcher:self.bridge.eventDispatcher];
  // _advancedView.backgroundColor = [UIColor orangeColor];
  // _advancedView.frame = CGRectMake(0, 0, 375, 667);
  // _advancedView.userInteractionEnabled = YES;

  return _advancedView;

//  return [[RoaaCamera alloc] initWithEventDispatcher:self.bridge.eventDispatcher];
}


RCT_EXPORT_METHOD(addEvent:(NSString *)name location:(NSString *)location)
{
  RCTLogInfo(@"Pretending to create an event %@ at %@", name, location);

}

RCT_EXPORT_METHOD(flipCamera)
{

  RCTLogInfo(@"camera will be flipped");
  [_advancedView flipCamera];
}

RCT_EXPORT_METHOD(pickImage)
{

  RCTLogInfo(@"pickImage");
  [_advancedView pickImage];
}

RCT_EXPORT_METHOD(toggleFlash)
{

  RCTLogInfo(@"toggleFlash");
  [_advancedView toggleFlash];
}

RCT_EXPORT_METHOD(timer)
{

  RCTLogInfo(@"timer");
  [_advancedView timer];
}

RCT_EXPORT_METHOD(takePicture)
{
  RCTLogInfo(@"takePicture");
  [_advancedView takePicture];
}

RCT_EXPORT_VIEW_PROPERTY(onSaveSuccess, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onGalleryImage, RCTBubblingEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onFlashToggle, RCTBubblingEventBlock);

@end

