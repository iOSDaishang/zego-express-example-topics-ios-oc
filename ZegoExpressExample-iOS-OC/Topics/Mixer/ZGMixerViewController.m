//
//  ZGMixerViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/11/21.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Mixer

#import "ZGMixerViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

NSString* const ZGMixerTopicKey_OutputTarget = @"kOutputTarget";

@interface ZGMixerViewController () <ZegoEventHandler, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, strong) NSMutableArray<ZegoStream *> *remoteStreamList;

@property (nonatomic, assign) BOOL isMixing;
@property (nonatomic, assign) ZegoPlayerState playerState;

@property (nonatomic, strong) ZegoMixerTask *mixerTask;

@property (nonatomic, strong) ZegoStream *selectFirstStream;
@property (weak, nonatomic) IBOutlet UILabel *selectFirstStreamLabel;
@property (nonatomic, strong) ZegoStream *selectSecondStream;
@property (weak, nonatomic) IBOutlet UILabel *selectSecondStreamLabel;

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UIPickerView *selectStreamsPicker;
@property (weak, nonatomic) IBOutlet UITextField *outputTargetTextField;

@property (weak, nonatomic) IBOutlet UIButton *startMixerTaskButton;
@property (weak, nonatomic) IBOutlet UIButton *startPlayButton;

@end

@implementation ZGMixerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roomID = @"MixerRoom-1";
    
    self.remoteStreamList = [NSMutableArray array];
    
    [self setupUI];
    
    [self createEngineAndLoginRoom];
}

- (void)setupUI {
    self.isMixing = NO;
    self.playerState = ZegoPlayerStateNoPlay;
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", self.roomID];
    
    self.outputTargetTextField.text = [self savedValueForKey:ZGMixerTopicKey_OutputTarget];
    
    
    // Set up stream picker
    
    self.selectStreamsPicker.dataSource = self;
    self.selectStreamsPicker.delegate = self;
    
    [self.selectStreamsPicker selectRow:0 inComponent:0 animated:YES];
    [self.selectStreamsPicker selectRow:0 inComponent:1 animated:YES];
    
    [self pickerView:self.selectStreamsPicker didSelectRow:0 inComponent:0];
    [self pickerView:self.selectStreamsPicker didSelectRow:0 inComponent:1];
}

- (void)createEngineAndLoginRoom {
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    
    ZGLogInfo(@" 🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];
    
    ZegoUser *user = [ZegoUser userWithUserID:[ZGUserIDHelper userID] userName:[ZGUserIDHelper userName]];
    
    ZGLogInfo(@" 🚪 Login room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:user config:[ZegoRoomConfig defaultConfig]];
}

#pragma mark - Start Mixer Task

- (IBAction)startMixerTaskButtonClick:(UIButton *)sender {
    if (self.isMixing) {
        [self stopMixerTask];
    } else {
        [self startMixerTask];
    }
}

- (void)startMixerTask {
    if (!self.selectFirstStream || !self.selectSecondStream) {
        ZGLogWarn(@" ❕ Please select streams first");
        [ZegoHudManager showMessage:@" ❕ Please select streams first"];
        return;
    } else if (self.selectFirstStream == self.selectSecondStream) {
        ZGLogWarn(@" ❕ Please select two different streams");
        [ZegoHudManager showMessage:@" ❕ Please select two different streams"];
        return;
    } else if (self.outputTargetTextField.text.length <= 0) {
        ZGLogWarn(@" ❕ Please enter output target");
        [ZegoHudManager showMessage:@" ❕ Please enter output target"];
        return;
    }
    
    ZGLogInfo(@" 🧬 Start mixer task");
    
    NSString *taskID = [NSString stringWithFormat:@"%@%@", self.selectFirstStream.streamID, self.selectSecondStream.streamID];
    
    CGSize resolution = CGSizeMake(1080, 1920);
    
    
    // ① (Required): Create a ZegoMixerTask object
    ZegoMixerTask *task = [[ZegoMixerTask alloc] initWithTaskID:taskID];
    
    
    
    // ② (Required): Set mixer input
    CGRect firstRect = CGRectMake(0, 0, resolution.width, resolution.height/2);
    ZegoMixerInput *firstInput = [[ZegoMixerInput alloc] initWithStreamID:self.selectFirstStream.streamID contentType:ZegoMixerInputContentTypeVideo layout:firstRect];
    
    CGRect secondRect = CGRectMake(0, resolution.height/2, resolution.width, resolution.height/2);
    ZegoMixerInput *secondInput = [[ZegoMixerInput alloc] initWithStreamID:self.selectSecondStream.streamID contentType:ZegoMixerInputContentTypeVideo layout:secondRect];
    
    NSArray<ZegoMixerInput *> *inputArray = @[firstInput, secondInput];
    [task setInputList:inputArray];
    
    
    
    // ③ (Required): Set mixer output
    ZegoMixerOutput *output = [[ZegoMixerOutput alloc] initWithTarget:self.outputTargetTextField.text];
    
    // ③-1 (Optional): Set video config for the output
    ZegoMixerVideoConfig *videoConfig = [[ZegoMixerVideoConfig alloc] initWithResolution:resolution fps:15 bitrate:3000];
    output.videoConfig = videoConfig;
    
    // ③-2 (Optional): Set audio config for the output
    output.audioConfig = [ZegoMixerAudioConfig defaultConfig];
    
    NSArray<ZegoMixerOutput *> *outputArray = @[output];
    [task setOutputList:outputArray];
    

    
    // ④ (Optional): Set watermark
    ZegoWatermark *watermark = [[ZegoWatermark alloc] initWithImageURL:@"preset-id://zegowp.png" layout:CGRectMake(0, 0, resolution.width/2, resolution.height/20)];
    [task setWatermark:watermark];
    

    
    // ⑤ (Optional): Set background image
    [task setBackgroundImageURL:@"preset-id://zegobg.png"];
    
    
    
    // ⑥ Start Mixer Task
    [ZegoHudManager showNetworkLoading];

    [[ZegoExpressEngine sharedEngine] startMixerTask:task callback:^(int errorCode, NSDictionary * _Nullable extendedData) {
        ZGLogInfo(@" 🚩 🧬 Start mixer task result errorCode: %d", errorCode);
        
        [ZegoHudManager hideNetworkLoading];
        
        if (errorCode == 0) {
            self.isMixing = YES;
            
        } else {
            [ZegoHudManager showMessage:[NSString stringWithFormat:@" 🚩 🧬 Start mixer errorCode: %d", errorCode]];
        }
    }];
    
    // Save the task object
    self.mixerTask = task;
    
    // Save the output target text field
    [self saveValue:self.outputTargetTextField.text forKey:ZGMixerTopicKey_OutputTarget];
}

- (void)stopMixerTask {
    ZGLogInfo(@" 🧬 Stop mixer task");
    [[ZegoExpressEngine sharedEngine] stopMixerTask:self.mixerTask callback:^(int errorCode) {
        ZGLogInfo(@" 🚩 🧬 Stop mixer task result errorCode: %d", errorCode);
    }];
    
    self.isMixing = NO;
}

#pragma mark - Play the Mixed Stream

- (IBAction)playMixedStreamButtonClick:(UIButton *)sender {
    if (self.playerState == ZegoPlayerStatePlaying) {
        [self stopPlaying];
    } else {
        [self startPlaying];
    }
}

- (void)startPlaying {
    if (self.outputTargetTextField.text.length > 0) {
        ZGLogInfo(@" 📥 Start playing stream: %@", self.outputTargetTextField.text);
        
        [[ZegoExpressEngine sharedEngine] startPlayingStream:self.outputTargetTextField.text canvas:[ZegoCanvas canvasWithView:self.playView]];
    } else {
        ZGLogWarn(@" ❕ Please enter output target");
        [ZegoHudManager showMessage:@" ❕ Please enter output target"];
    }
}

- (void)stopPlaying {
    ZGLogInfo(@" 📥 Stop playing stream: %@", self.outputTargetTextField.text);
    
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:self.outputTargetTextField.text];
}

#pragma mark - ZegoEventHandler

// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZGLogInfo(@" 🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@" 🚩 🌊 --- [Add] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            if (![self.remoteStreamList containsObject:stream]) {
                [self.remoteStreamList addObject:stream];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@" 🚩 🌊 --- [Delete] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            __block ZegoStream *delStream = nil;
            [self.remoteStreamList enumerateObjectsUsingBlock:^(ZegoStream * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.streamID isEqualToString:stream.streamID] && [obj.user.userID isEqualToString:stream.user.userID]) {
                    delStream = obj;
                    *stop = YES;
                }
            }];
            [self.remoteStreamList removeObject:delStream];
        }
    }
    // Refresh stream picker
    [self.selectStreamsPicker reloadAllComponents];
}

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    ZGLogInfo(@" 🚩 🚪 Room State Update Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)state, (int)errorCode, roomID);
}

// Refresh the player state
- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📥 Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
    self.playerState = state;
}

#pragma mark - Setter, Manage UI State

- (void)setIsMixing:(BOOL)isMixing {
    _isMixing = isMixing;
    
    self.title = _isMixing ? @"🧬 Mixing" : @"Mixer";
    [self.startMixerTaskButton setTitle:_isMixing ? @"🎉 Stop Mixer Task" : @"Step 2️⃣: Start Mixer Task" forState:UIControlStateNormal];
}

- (void)setPlayerState:(ZegoPlayerState)playerState {
    _playerState = playerState;
    
    [self.startPlayButton setTitle:_playerState == ZegoPlayerStatePlaying ? @"🎉 Stop Playing" : @"Step 3️⃣: Play the Mixed Stream" forState:UIControlStateNormal];
}

#pragma mark - UIPickerView DataSource & Delegate

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.remoteStreamList.count + 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (row == 0) {
        if (component == 0) {
            self.selectFirstStream = nil;
            self.selectFirstStreamLabel.text = @"Not selected";
        } else if (component == 1) {
            self.selectSecondStream = nil;
            self.selectSecondStreamLabel.text = @"Not selected";
        }
    } else if (row > 0) {
        if (component == 0) {
            self.selectFirstStream = self.remoteStreamList[row - 1];
            self.selectFirstStreamLabel.text = self.remoteStreamList[row - 1].streamID;
        } else if (component == 1) {
            self.selectSecondStream = self.remoteStreamList[row - 1];
            self.selectSecondStreamLabel.text = self.remoteStreamList[row - 1].streamID;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (row == 0) {
        return @"Not selected";
    } else if (row > 0) {
        return self.remoteStreamList[row - 1].streamID;
    } else {
        return @"NULL";
    }
}

#pragma mark - Exit

- (void)dealloc {
    ZGLogInfo(@" 🚪 Exit the room. roomID: %@", self.roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    
    // Can destroy the engine when you don't need audio and video calls
    ZGLogInfo(@" 🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end

#endif
