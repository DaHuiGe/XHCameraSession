# XHCameraSession
导入XHCameraSession.h 

初始化时 使用  - (instancetype)initWithView:(UIView *)cameraView;

参数传入要显示相机拍摄到内容的view；

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

点击展示相机的view 可以更换曝光模式

可以扩展，有兴趣的朋友在添加聚焦图片，进行显示，调整坐标的代码已经完成，只需添加图片，设置坐标即可
