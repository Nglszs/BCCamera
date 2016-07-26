//
//  ViewController.m
//  BCCamera
//
//  Created by Jack on 16/4/25.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import "ViewController.h"
#import "AVCameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
 BOOL isUsingFrontFacingCamera;
    AVPlayerLayer *playerLayer;

}
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImageView *photo;//照片展示视图
@property (strong, nonatomic) AVPlayer *player;//播放器，用于录制完视频后播放视频
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _photo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200,200)];
    _photo.center = self.view.center;
    _photo.backgroundColor = [UIColor grayColor];
    [self.view addSubview:_photo];
   
    self.title = @"拍照/视频";
    
    //使用UIImagePickerController
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]
                                initWithTitle:@"UIImagePicker"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(imagePickerView)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    
    //跳转使用AVFoundtion的界面
   
        UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]
                                     initWithTitle:@"AVFoundtion"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(AVFoundationView)];
        self.navigationItem.rightBarButtonItem = rightBtn;
    
    
    
    
    
    
   
    //监听AVFoundation界面传过来的数据
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(havedImage:) name:@"havedImage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(havedVideo:) name:@"havedVideo" object:nil];

    
}

- (void)AVFoundationView {
    
    AVCameraViewController *avCameraVC = [[AVCameraViewController alloc] init];
    [self.navigationController pushViewController:avCameraVC animated:NO];


}
- (void)imagePickerView {

    __weak typeof(self) weakSelf = self;
    
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:@"UIImagePickerController" message:@"使用UIImagePickerController" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [self presentViewController:sheetController animated:YES completion:nil];

    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
     
         [weakSelf cameraFromUIImagePickerController:0];
        
    }];
    UIAlertAction *pictureAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf cameraFromUIImagePickerController:1];
        
    }];
    UIAlertAction *videoAction = [UIAlertAction actionWithTitle:@"录像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        [weakSelf cameraFromUIImagePickerController:2];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [sheetController addAction:albumAction];
    [sheetController addAction:pictureAction];
    [sheetController addAction:videoAction];
    [sheetController addAction:cancelAction];
    
    
}
- (void)cameraFromUIImagePickerController:(NSUInteger)type {
    
    
    //声明
    
    if (!self.imagePicker) {
        
        self.imagePicker = [[UIImagePickerController alloc] init];
        
    }
    
    
    if (type == 0) {//相册
        
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      
        //默认会只打开图片，如果加上下面代码可以两者都打开
        //_imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        
        
    } else {//拍照或视频
        
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        _imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        
        if (type == 1) {//拍照
            
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            
        } else {//视频
            
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            _imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            
            
        }
        
        
    }
    
    
        _imagePicker.delegate = self;
   
    //可以用来定制自定义相机
    //    _imagePicker.showsCameraControls  = NO;
    //    UIView *backView = [[UIView alloc] initWithFrame:self.view.bounds];
    //
    //
    //
    //    UIButton *btb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    btb.frame = CGRectMake(100, 100, 100, 100);
    //    [btb setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
    //    [btb setTitle:@"拍照" forState:UIControlStateNormal];
    //    [backView addSubview:btb];
    //
    //    _imagePicker.cameraOverlayView = backView;

    
   
    [self presentViewController:_imagePicker animated:YES completion:nil];
}


- (NSString *)filePath {//设置文件保存路劲，这里都是先保存到相册中

    if (!_filePath) {
        
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        _filePath = [[path firstObject] stringByAppendingPathComponent:@"imageFile"];
        
    }

    return _filePath;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        _photo.image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
    } else {//拍照还是录像
        
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];

    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//拍照
        
        UIImage *newImage;
        if (self.imagePicker.allowsEditing) {//如果可以编辑
            
            newImage = [info objectForKey:UIImagePickerControllerEditedImage];
            
        } else {
        
            newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
            
        
        [self.photo setImage:newImage];
      
       
        
        //三种保存方式，这是第一种，下面视频同理
        UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
       
       
        //第二种，保存到某个文件夹
        //   NSData *data;
        //        //判断图片是不是png格式的文件
        //        if (UIImagePNGRepresentation(newImage)) {
        //            //返回为png图像。
        //            data = UIImagePNGRepresentation(newImage);
        //        }else {
        //            //返回为JPEG图像。
        //            data = UIImageJPEGRepresentation(newImage, 1.0);
        //        }
        //
        //        [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:data attributes:nil];
        //        _photo.image = [UIImage imageWithContentsOfFile:self.filePath];
        
        
        
         //第三种，使用ALAssetsLibrary来保存，此方法在9以后被拒绝
         //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
       
        
    } else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {//视频
    
        NSLog(@"this a video");
        
        
        NSURL *url  = [info objectForKey:UIImagePickerControllerMediaURL];//视频路劲
        
        NSString *str = [url path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(str)) {
            
            NSLog(@"已保存到相册");
          UISaveVideoAtPathToSavedPhotosAlbum(str, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
      
        }
    
 
    
    }
    
    }


    [self dismissViewControllerAnimated:YES completion:nil];

}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"取消");
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark 视频保存后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
        
    }else{
        
        NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:videoPath error:nil];
        NSInteger size = [dict[@"NSFileSize"] integerValue];
        
        
        
       NSLog(@"视频大小%.2fM",size/(1000.00f * 1000.00f));
        
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url = [NSURL fileURLWithPath:videoPath];
        _player = [AVPlayer playerWithURL:url];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        playerLayer.frame = self.photo.frame;
        [self.view.layer addSublayer:playerLayer];
        [_player play];
       
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
    }
}

- (void)moviePlayDidEnd:(NSNotification *)notification
{
    
    NSLog(@"播放完了");
    
    [playerLayer removeFromSuperlayer];
    _photo.image = nil;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//拍照
- (void)havedImage:(NSNotification *)note {
    
    if (note.object) {
        _photo.image = note.object;
    }
    
    
}

//视频
- (void)havedVideo:(NSNotification *)note {
    
    if (note.object) {
        [self video:note.object didFinishSavingWithError:nil contextInfo:nil];
    }
    
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
@end
