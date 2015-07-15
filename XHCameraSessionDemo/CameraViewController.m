//
//  CameraViewController.m
//  XHCameraSessionDemo
//
//  Created by 蔡相辉 on 15/7/15.
//  Copyright (c) 2015年 蔡相辉. All rights reserved.
//

#import "CameraViewController.h"

#import "XHCameraSession.h"

@interface CameraViewController ()

@property (weak, nonatomic) IBOutlet UIView *showView;

@property (nonatomic, strong)       XHCameraSession            *cameraManager;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.cameraManager = [[XHCameraSession alloc]initWithView:self.showView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.cameraManager) {
        [self.cameraManager startRunning];
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear: animated];
    
    if (self.cameraManager) {
        [self.cameraManager stopRunning];
    }
}

- (IBAction)takePhoto:(id)sender
{
    [self.cameraManager shutterCamera:^(UIImage *image) {
        
        //do something
        
    }];
}

- (IBAction)OnFlash:(id)sender
{
    [self.cameraManager flashOnClick];
}

- (IBAction)OffFlash:(id)sender
{
    [self.cameraManager flashOffClick];
}

- (IBAction)automaticFlash:(id)sender
{
    [self.cameraManager flashAutoClick];
}

- (IBAction)switchCamera:(id)sender
{
    [self.cameraManager switchCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
