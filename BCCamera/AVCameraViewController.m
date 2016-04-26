//
//  AVCameraViewController.m
//  BCCamera
//
//  Created by Jack on 16/4/26.
//  Copyright © 2016年 毕研超. All rights reserved.
//
#define BCWidth   [UIScreen mainScreen].bounds.size.width
#define BCHeight  [UIScreen mainScreen].bounds.size.height
#define BCScreen  [UIScreen mainScreen].bounds
#define BCTime 0.35

#import "AVCameraViewController.h"

@implementation AVCameraViewController


- (void)viewDidLoad {
    [super viewDidLoad];


    
    self.title = @"AVFoundation";
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                 initWithTitle:@"点击"
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(cameraType)];
    self.navigationItem.rightBarButtonItem = rightBtn;


    
    //初始化
    
    
    self.captureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:nil];

    
    //图片输出
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置

    
    //声音输出设置
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    _audioCaptureDeviceInput =[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:nil];
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    //显示图层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    _captureVideoPreviewLayer.frame = self.view.bounds;
     [self.view.layer addSublayer:_captureVideoPreviewLayer];
 
    [self initView];
   
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.captureSession) {
        [_captureSession startRunning];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.captureSession) {
        [self.captureSession stopRunning];
    }
    
    
}

//自定义相机样式，这里简单的按钮
- (void)initView {
    
    
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BCWidth, BCHeight - 50)];
    [self.view addSubview:_maskView];
    
    _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraButton.frame = CGRectMake(0, BCHeight - 50, BCWidth/2, 50);
    _cameraButton.hidden = YES;
    
    [_cameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cameraButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    _cameraButton.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_cameraButton];

    _cutCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cutCameraButton.frame = CGRectMake(BCWidth/2, BCHeight - 50, BCWidth/2, 50);
    [_cutCameraButton setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [_cutCameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _cutCameraButton.hidden = YES;
    _cutCameraButton.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:_cutCameraButton];
    
     [_cutCameraButton addTarget:self action:@selector(cutCamera) forControlEvents:UIControlEventTouchUpInside];

}
//切换摄像头
- (void)cutCamera {

    AVCaptureDevicePosition desiredPosition;
        if (isUsingFrontFacingCamera){
            desiredPosition = AVCaptureDevicePositionBack;
        }else{
            desiredPosition = AVCaptureDevicePositionFront;
        }
    
        for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if ([d position] == desiredPosition) {
                [self.captureVideoPreviewLayer.session beginConfiguration];
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
                for (AVCaptureInput *oldInput in self.captureVideoPreviewLayer.session.inputs) {
                    [[self.captureVideoPreviewLayer session] removeInput:oldInput];
                }
                [self.captureVideoPreviewLayer.session addInput:input];
                [self.captureVideoPreviewLayer.session commitConfiguration];
                break;
            }
        }
        
        isUsingFrontFacingCamera = !isUsingFrontFacingCamera;


}
- (void)cameraType {

    __weak typeof(self) weakSelf = self;
    
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:@"AVFoundation" message:@"使用AVFoundation拍照或者录像" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [self presentViewController:sheetController animated:YES completion:nil];

    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf cameraFromAVFounation:0];
    }];
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"录像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf cameraFromAVFounation:1];
     
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
   
    [sheetController addAction:pictureAction];
    [sheetController addAction:videoAction];
    [sheetController addAction:cancelAction];


}
- (void)cameraFromAVFounation:(NSUInteger)type {
    
    
        isUsingFrontFacingCamera = NO;
    
    if (type == 0) {//拍照
        
        //将设备输入添加到会话中
        if ([_captureSession canAddInput:_captureDeviceInput]) {
            [_captureSession addInput:_captureDeviceInput];
        }
        
        //将设备输出添加到会话中
        if ([_captureSession canAddOutput:_captureStillImageOutput]) {
            [_captureSession addOutput:_captureStillImageOutput];
        }

        _cameraButton.hidden = NO;
         _cutCameraButton.hidden = NO;
         [_cameraButton setTitle:@"拍照" forState:UIControlStateNormal];
        [_cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
        

    } else {//录像

        
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;//分辨率
        //将设备输入添加到会话中
            if ([_captureSession canAddInput:_captureDeviceInput]) {
                [_captureSession addInput:_captureDeviceInput];
                [_captureSession addInput:_audioCaptureDeviceInput];
                AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
                if ([captureConnection isVideoStabilizationSupported ]) {
                    captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
                }
            }
        
            //将设备输出添加到会话中
            if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
                [_captureSession addOutput:_captureMovieFileOutput];
            }
        _cameraButton.hidden = NO;
        _cutCameraButton.hidden = NO;
        [_cameraButton setTitle:@"开始录制" forState:UIControlStateNormal];
        [_cameraButton setTitle:@"停止录制" forState:UIControlStateSelected];
       
        [_cameraButton addTarget:self action:@selector(videoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
   
  

    
    
}


- (void)cameraAction {

    
    
    _maskView.backgroundColor = [UIColor blackColor];
    [UIView animateWithDuration:BCTime animations:^{
        _maskView.backgroundColor = [UIColor clearColor];
        
        
        AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        //根据连接取得设备输出的数据
        [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer) {
                
                NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                
                UIImage *image=[UIImage imageWithData:imageData];
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"havedImage" object:image];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
        

    }];
    
    
}

- (void)videoAction {

    
    _cameraButton.selected = !_cameraButton.selected;
    //根据设备输出获得连接
        AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        //根据连接取得设备输出的数据
        if (![self.captureMovieFileOutput isRecording]) {
            
            self.enableRotation=NO;
            //如果支持多任务则则开始多任务
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                self.backgroundTaskIdentifier=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            //预览图层和视频方向保持一致
            captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
            
            NSString *outputFielPath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
            
            NSLog(@"保存路径 :%@",outputFielPath);
            NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
           
            [self.captureMovieFileOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
        }
        else{
            
            [self.captureMovieFileOutput stopRecording];//停止录制
          
            NSLog(@"停止录制");
            
        }
        
    
    

}
    //视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
     
        
        
    }
}

#pragma mark - 视频输出代理
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"开始录制...");
}
-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"视频录制完成.");
    //视频录入完成之后在后台将视频存储到相簿
    self.enableRotation = YES;
    
    UIBackgroundTaskIdentifier lastBackgroundTaskIdentifier = self.backgroundTaskIdentifier;
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    
    if (lastBackgroundTaskIdentifier!=UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:lastBackgroundTaskIdentifier];
        
    //这里视频保存的地址，可以跟前面的一样，这里不再写
        UISaveVideoAtPathToSavedPhotosAlbum([outputFileURL path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        
    
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"havedVideo" object: [outputFileURL path]];
    [self.navigationController popViewControllerAnimated:YES];

  
}
//
- (void)dealloc {

    NSLog(@"已释放");

}

@end
