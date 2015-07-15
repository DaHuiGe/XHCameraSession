//
//  XHCameraSession.h
//  XHCameraSessionDemo
//
//  Created by 蔡相辉 on 15/7/14.
//  Copyright (c) 2015年 蔡相辉. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>

typedef void(^CameraSuccessBlock)(UIImage *image);

@interface XHCameraSession : NSObject
/**
 *  初始化
 *
 *  @param cameraView 展示摄像头获取成像的视图
 *
 *  @return 类对象
 */
- (instancetype)initWithView:(UIView *)cameraView;
//拍照
- (void)shutterCamera:(CameraSuccessBlock)success;
//切换摄像头
- (void)switchCamera;
//开始运行设备 在试图将要出现时调用
- (void)startRunning;
//停止运行设备 在试图将要消失时调用
- (void)stopRunning;
//自动闪光灯开启
- (void)flashAutoClick;
//打开闪光灯
- (void)flashOnClick;
//关闭闪光灯
- (void)flashOffClick;

@end
