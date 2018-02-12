//
//  RecordLuckyViewController.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/24.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "RecordLuckyViewController.h"
#import <Speech/Speech.h>
#import "CustomAlertView.h"

@interface RecordLuckyViewController () <SFSpeechRecognizerDelegate, CustomAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) SFSpeechRecognizer *recognizer;
@property (weak, nonatomic) UIButton *recordingBtn;
@property (weak, nonatomic) UIButton *photoButton;
@property (weak, nonatomic) UITextView *inPutTextView;

@property (nonatomic, strong) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic, strong) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic, strong) AVAudioEngine *audioEngine;

@end

@implementation RecordLuckyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupData];
}

#pragma mark - viewDidLoad
- (void)setupUI {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"存" style:UIBarButtonItemStylePlain target:self action:@selector(saveLucky)];
    
    self.title = @"日常记录";
    self.view.backgroundColor = GlobalBGColor;
    
    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    photoButton.frame = CGRectMake(10, 20, 300, 200);
    [photoButton setTitle:@"上传照片" forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(uploadImg) forControlEvents:UIControlEventTouchUpInside];
    [photoButton setTitleColor:TextDardColor forState:UIControlStateNormal];
    photoButton.backgroundColor = [UIColor whiteColor];
    photoButton.layer.cornerRadius = 5;
    photoButton.clipsToBounds = YES;
    [self.view addSubview:photoButton];
    _photoButton = photoButton;
    
    [photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(200);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat recordY = CGRectGetMaxY(photoButton.frame) + 18;
    recordButton.frame = CGRectMake(10, recordY, 30, 200);
    [recordButton setTitle:@"录\n\n音" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    recordButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    recordButton.backgroundColor = RGBCOLOR(190, 105, 110);
    recordButton.enabled = NO;
    [self.view addSubview:recordButton];
    _recordingBtn = recordButton;
    
    CGFloat textViewX = CGRectGetMaxX(recordButton.frame) + 10;
    CGFloat textViewW = SCREEN_WIDTH - 10 - textViewX;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(textViewX, recordY, textViewW, 200)];
    textView.font = [UIFont systemFontOfSize:15.0];
    textView.textColor = TextDardColor;
    textView.layer.borderColor = GlobalBGColor.CGColor;
    textView.layer.borderWidth = 1;
    [self.view addSubview:textView];
    _inPutTextView = textView;
}

- (void)uploadImg {
    
    CustomAlertView *customAlert = [[CustomAlertView alloc] initWithTitle:@"" subButtons:@[@"拍照", @"从相册选取图片", @"取消"]];;
    customAlert.delegate = self;
    customAlert.frame = [UIScreen mainScreen].bounds;
    [customAlert appearAlertView];
}

#pragma CustomAlertView的button的点击事件
- (void)alertView:(CustomAlertView *)customAlertView clickedButton:(NSString *)title {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.navigationBar.tintColor = TextDardColor;
    
    if([title isEqualToString:@"拍照"]){
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.modalPresentationCapturesStatusBarAppearance = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }else if([title containsString:@"相册"]){
        NSLog(@"从相册获取图片了");
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        
        //先把图片转成NSData
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        _photoButton.imageView.contentMode = UIViewContentModeScaleToFill;
        [_photoButton setImage:image forState:UIControlStateNormal];
        [_photoButton setTitle:@"" forState:UIControlStateNormal];
        
        //关闭相册界面
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)setupData {
    
    if (_luckyDict) {
        
        _inPutTextView.text = _luckyDict[@"content"];
        NSData *data = _luckyDict[@"imgData"];
        [_photoButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        _photoButton.imageView.contentMode = UIViewContentModeScaleToFill;
        [_photoButton setTitle:@"" forState:UIControlStateNormal];
    }
    
    NSLocale *cale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"];
    self.recognizer = [[SFSpeechRecognizer alloc] initWithLocale:cale];
    self.recognizer.delegate = self;
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        bool isButtonEnabled = false;
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                isButtonEnabled = true;
                NSLog(@"可以语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                isButtonEnabled = false;
                NSLog(@"用户被拒绝访问语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                isButtonEnabled = false;
                NSLog(@"不能在该设备上进行语音识别");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                isButtonEnabled = false;
                NSLog(@"没有授权语音识别");
                break;
            default:
                break;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recordingBtn.enabled = isButtonEnabled;
        });
    }];
    self.audioEngine = [[AVAudioEngine alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

#pragma mark - private method
- (void)buttonClicked:(UIButton *)sender {
    
    if ([self.audioEngine isRunning]) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
        self.recordingBtn.enabled = YES;
        [self.recordingBtn setTitle:@"开始录制" forState:UIControlStateNormal];
    }else{
        [self startRecording];
        [self.recordingBtn setTitle:@"停止录制" forState:UIControlStateNormal];
    }
}

- (void)startRecording {
    
    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    bool audioBool = [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    bool audioBool1 = [audioSession setMode:AVAudioSessionModeMeasurement error:nil];
    bool audioBool2 = [audioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (audioBool || audioBool1||  audioBool2) {
        NSLog(@"可以使用");
    }else{
        NSLog(@"这里说明有的功能不支持");
    }
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    
    self.recognitionRequest.shouldReportPartialResults = true;
    
    //开始识别任务
    self.recognitionTask = [self.recognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        bool isFinal = false;
        if (result) {
            self.inPutTextView.text = [[result bestTranscription] formattedString]; //语音转文本
            isFinal = [result isFinal];
        }
        if (error || isFinal) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            self.recordingBtn.enabled = true;
        }
    }];
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    [self.audioEngine prepare];
    bool audioEngineBool = [self.audioEngine startAndReturnError:nil];
    NSLog(@"%d",audioEngineBool);
    self.inPutTextView.text = @"";
}

#pragma mark - SFSpeechRecognizerDelegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    
    if (available) {
        self.recordingBtn.enabled = YES;
    }else {
        self.recordingBtn.enabled = NO;
    }
}

- (void)saveLucky {
    
    [self presentLoadingTips:@""];
    NSString *text = _inPutTextView.text;
    UIImage *image = [_photoButton imageForState:UIControlStateNormal];
    NSData *data = UIImageJPEGRepresentation(image, 0.4);
    [YJTool addLucky:text image:data];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"luckyAdded" object:nil];
    [self dismissTips];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
