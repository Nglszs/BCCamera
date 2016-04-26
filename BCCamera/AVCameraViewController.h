//
//  AVCameraViewController.h
//  BCCamera
//
//  Created by Jack on 16/4/26.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface AVCameraViewController : UIViewController<AVCaptureFileOutputRecordingDelegate>
{
    BOOL isUsingFrontFacingCamera;
}

@property (strong, nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频
@property (strong, nonatomic) UIImageView *photo;//照片展示视图
@property (strong, nonatomic) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (strong, nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据

@property (strong, nonatomic) AVCaptureDeviceInput *audioCaptureDeviceInput;//音频输入
@property (strong, nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (strong, nonatomic) AVCaptureMovieFileOutput *captureMovieFileOutput;//视频输出流
@property (strong, nonatomic)  UIButton *takeButton;//拍照按钮
@property (assign, nonatomic) BOOL enableRotation;//是否允许旋转（注意在视频录制过程中禁止屏幕旋转）
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;//后台任务标识
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UIButton *cutCameraButton;
@property (strong, nonatomic) UIView *maskView;
@end
