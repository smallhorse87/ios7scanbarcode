//
//  ViewController.m
//  ios7scanbarcode
//
//  Created by Apple on 15/7/31.
//  Copyright (c) 2015年 Zhitian Network Tech. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    IBOutlet UIView *captureV;
    IBOutlet UIView *captureWindow;
    
    NSString *stringValue;
}
@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    upOrdown = NO;
    num =0;
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 212, 13)];
    _line.center = captureWindow.center;
    _line.image = [UIImage imageNamed:@"scan_line.png"];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        if (2*num > captureWindow.frame.size.height - _line.frame.size.height) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        if (num == 0) {
            upOrdown = NO;
        }
    }

    _line.frame = CGRectMake(captureWindow.center.x - (212.0/2), captureWindow.frame.origin.y + 2*num, 212, 13);

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self setupCamera];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)setupCamera{
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input =  [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    _output.rectOfInterest = CGRectMake((124)/screenH, ((screenW-220)/2)/screenW, 220/screenH, 220/screenW);
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    _preview.frame =CGRectMake(0, 0, size.width, size.height);
    
    [captureV.layer insertSublayer:self.preview atIndex:0];
    
    // Start
    [_session startRunning];
    
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];
    [timer invalidate];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"扫码成功" message:[NSString stringWithFormat:@"扫码结果：%@", stringValue] delegate:self cancelButtonTitle:@"继续" otherButtonTitles:nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [_session startRunning];
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
