//
//  XHCameraSession.m
//  XHCameraSessionDemo
//
//  Created by 蔡相辉 on 15/7/14.
//  Copyright (c) 2015年 蔡相辉. All rights reserved.
//

#import "XHCameraSession.h"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface XHCameraSession ()

//AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic, strong)       AVCaptureSession            * session;

//AVCaptureDeviceInput对象是输入流
@property (nonatomic, strong)       AVCaptureDeviceInput        * videoInput;

//照片输出流对象，当然我的照相机只有拍照功能，所以只需要这个对象就够了
@property (nonatomic, strong)       AVCaptureStillImageOutput   * stillImageOutput;

//预览图层，来显示照相机拍摄到的画面
@property (nonatomic, strong)       AVCaptureVideoPreviewLayer  * previewLayer;

@property (nonatomic, strong)       UIView                      *showView;

@end

@implementation XHCameraSession

- (instancetype)initWithView:(UIView *)cameraView
{
    self = [super init];
    if (self)
    {
        self.showView = cameraView;
        
        [self initialSession];
        
        [self setUpCameraLayerWithView:cameraView];
        
        [self addGenstureRecognizer];
    }
    return self;
}

- (void) initialSession
{
    NSError *error=nil;
   
    self.session = [[AVCaptureSession alloc] init];
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
    
    if (error)
    {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
}

- (void) setUpCameraLayerWithView:(UIView *)cameraShowView
{
    if (self.previewLayer == nil)
    {
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        CALayer *layer=cameraShowView.layer;
        layer.masksToBounds=YES;
        self.previewLayer.frame=layer.bounds;
        self.previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
        [layer insertSublayer:self.previewLayer below:[[layer sublayers] objectAtIndex:0]];
    }
}

- (void)shutterCamera:(CameraSuccessBlock)success;
{
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection)
    {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
     {
         if (imageDataSampleBuffer == NULL)
         {
             return;
         }
         
         NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         UIImage * image = [UIImage imageWithData:imageData];
         success(image);
     }];
}

//切换摄像头
- (void)switchCamera
{
    [UIView transitionWithView:self.showView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromLeft+UIViewAnimationOptionCurveEaseInOut
                    animations:^
    {
        NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
        if (cameraCount > 1)
        {
            NSError *error;
            AVCaptureDeviceInput *newVideoInput;
            AVCaptureDevicePosition position = [[_videoInput device] position];
            
            if (position == AVCaptureDevicePositionBack)
            {
                newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
            }
            else if (position == AVCaptureDevicePositionFront)
            {
                newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
            }
            else
            {
                return;
            }
            
            if (newVideoInput != nil)
            {
                [self.session beginConfiguration];
                [self.session removeInput:self.videoInput];
                if ([self.session canAddInput:newVideoInput])
                {
                    [self.session addInput:newVideoInput];
                    [self setVideoInput:newVideoInput];
                }
                else
                {
                    [self.session addInput:self.videoInput];
                }
                [self.session commitConfiguration];
            }
            else if (error)
            {
                NSLog(@"toggle carema failed, error = %@", error);
            }
        }
    }
    completion:^(BOOL finished) {}];
}

- (void)startRunning
{
    if (self.session)
    {
        [self.session startRunning];
    }
}

- (void)stopRunning
{
    if (self.session)
    {
        [self.session stopRunning];
    }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//获取前摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//获取后摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

#pragma mark 自动闪光灯开启
- (void)flashAutoClick
{
    [self setFlashMode:AVCaptureFlashModeAuto];
}
#pragma mark 打开闪光灯
- (void)flashOnClick
{
    [self setFlashMode:AVCaptureFlashModeOn];
}
#pragma mark 关闭闪光灯
- (void)flashOffClick
{
    [self setFlashMode:AVCaptureFlashModeOff];
}

/**
 *  设置闪光灯模式
 *
 *  @param flashMode 闪光灯模式
 */
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}

/**
 *  设置聚焦模式
 *
 *  @param focusMode 聚焦模式
 */
-(void)setFocusMode:(AVCaptureFocusMode )focusMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
/**
 *  设置曝光模式
 *
 *  @param exposureMode 曝光模式
 */
-(void)setExposureMode:(AVCaptureExposureMode)exposureMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
/**
 *  设置聚焦点
 *
 *  @param point 聚焦点
 */
-(void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}

/**
 *  添加点按手势，点按时聚焦
 */
-(void)addGenstureRecognizer{
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    [self.showView addGestureRecognizer:tapGesture];
}
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.showView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint= [self.previewLayer captureDevicePointOfInterestForPoint:point];
//    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}

/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

- (void)dealloc
{
    
    
    
}


@end
