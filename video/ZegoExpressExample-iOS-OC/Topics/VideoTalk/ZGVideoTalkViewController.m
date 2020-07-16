//
//  ZGVideoTalkViewController.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/30.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_VideoTalk

#import "ZGVideoTalkViewController.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"
#import "ZGVideoTalkViewObject.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

// The number of displays per row of the stream view
NSInteger const ZGVideoTalkStreamViewColumnPerRow = 3;
// Stream view spacing
CGFloat const ZGVideoTalkStreamViewSpacing = 8.f;


@interface ZGVideoTalkViewController () <ZegoEventHandler>

/// Login room ID
@property (nonatomic, copy) NSString *roomID;

/// User canvas object of participating video call users
@property (nonatomic, strong) NSMutableArray<ZGVideoTalkViewObject *> *allUserViewObjectList;

/// Local user view object
@property (nonatomic, strong) ZGVideoTalkViewObject *localUserViewObject;

/// Local user ID
@property (nonatomic, copy) NSString *localUserID;

/// Local stream ID
@property (nonatomic, copy) NSString *localStreamID;

/// Label
@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStateLabel;

/// Container
@property (nonatomic, weak) IBOutlet UIView *containerView;

/// Whether to enable the camera
@property (nonatomic, assign) BOOL enableCamera;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;

/// Whether to mute the microphone
@property (nonatomic, assign) BOOL muteMicrophone;
@property (weak, nonatomic) IBOutlet UISwitch *microphoneSwitch;

/// Whether to enable audio output
@property (nonatomic, assign) BOOL muteSpeaker;
@property (weak, nonatomic) IBOutlet UISwitch *speakerSwitch;

///是否切换前后置摄像头按钮 true 前置  false 后置
@property (nonatomic, assign) BOOL isFront;

@end

@implementation ZGVideoTalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //切换前后置摄像头按钮
    self.isFront = true;
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchBtn.frame = CGRectMake(0, 0, 30, 30);
    switchBtn.backgroundColor = [UIColor redColor];
    [switchBtn addTarget:self action:@selector(switchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:switchBtn];
    
    self.roomID = @"VideoTalkRoom-1";
    
    // Use user ID as stream ID
    self.localUserID = ZGUserIDHelper.userID;
    self.localStreamID = [NSString stringWithFormat:@"s-%@", _localUserID];
    
    self.allUserViewObjectList = [NSMutableArray<ZGVideoTalkViewObject *> array];
    
    self.enableCamera = YES;
    self.muteMicrophone = [[ZegoExpressEngine sharedEngine] isMicrophoneMuted];
    self.muteSpeaker = [[ZegoExpressEngine sharedEngine] isSpeakerMuted];
    
    [self setupUI];
    
    [self createEngine];
    
    [self joinTalkRoom];
}

//切换前后置摄像头
- (void)switchBtnClick {
    [[ZegoExpressEngine sharedEngine] useFrontCamera:self.isFront];
    self.isFront = !self.isFront;
}

- (void)setupUI {
    self.cameraSwitch.on = _enableCamera;
    self.microphoneSwitch.on = !_muteMicrophone;
    self.speakerSwitch.on = !_muteSpeaker;
    self.title = @"VideoTalk";
    
    self.roomIDLabel.text = [NSString stringWithFormat:@"RoomID: %@", _roomID];
    self.roomStateLabel.text = @"Not Connected 🔴";
    
    // Add local user video view object
    [self.allUserViewObjectList addObject:self.localUserViewObject];
    [self rearrangeVideoTalkViewObjects];
}

#pragma mark - Actions

- (void)createEngine {
    ZGAppGlobalConfig *appConfig = [[ZGAppGlobalConfigManager sharedManager] globalConfig];
    
    ZGLogInfo(@" 🚀 Create ZegoExpressEngine");
    [ZegoExpressEngine createEngineWithAppID:appConfig.appID appSign:appConfig.appSign isTestEnv:appConfig.isTestEnv scenario:appConfig.scenario eventHandler:self];
}

- (void)joinTalkRoom {
    // Login room
    ZGLogInfo(@" 🚪 Login room, roomID: %@", _roomID);
    [[ZegoExpressEngine sharedEngine] loginRoom:_roomID user:[ZegoUser userWithUserID:_localUserID]];
    
    // Set the publish video configuration
    [[ZegoExpressEngine sharedEngine] setVideoConfig:[ZegoVideoConfig configWithPreset:ZegoVideoConfigPreset360P]];
    
    // Get the local user's preview view and start preview
    ZegoCanvas *previewCanvas = [ZegoCanvas canvasWithView:self.localUserViewObject.view];
    previewCanvas.viewMode = ZegoViewModeAspectFill;
    ZGLogInfo(@" 🔌 Start preview");
    [[ZegoExpressEngine sharedEngine] startPreview:previewCanvas];
    
    // Local user start publishing
    ZGLogInfo(@" 📤 Start publishing stream, streamID: %@", _localStreamID);
    [[ZegoExpressEngine sharedEngine] startPublishingStream:_localStreamID];
}

// It is recommended to logout room when stopping the video call.
// And you can destroy the engine when there is no need to call.
- (void)exitRoom {
    ZGLogInfo(@" 🚪 Logout room, roomID: %@", _roomID);
    [[ZegoExpressEngine sharedEngine] logoutRoom:_roomID];
    ZGLogInfo(@" 🏳️ Destroy ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine:nil];
}

/// Exit room when VC dealloc
- (void)dealloc {
    [self exitRoom];
}

- (IBAction)onToggleCameraSwitch:(UISwitch *)sender {
    _enableCamera = sender.on;
    [[ZegoExpressEngine sharedEngine] enableCamera:_enableCamera];
}

- (IBAction)onToggleMicrophoneSwitch:(UISwitch *)sender {
    _muteMicrophone = !sender.on;
    [[ZegoExpressEngine sharedEngine] muteMicrophone:_muteMicrophone];
}

- (IBAction)onToggleEnableSpeakerSwitch:(UISwitch *)sender {
    _muteSpeaker = !sender.on;
    [[ZegoExpressEngine sharedEngine] muteSpeaker:_muteSpeaker];
}

#pragma mark - ViewObject Methods

/// Rearrange participant flow view
- (void)rearrangeVideoTalkViewObjects {
    for (ZGVideoTalkViewObject *obj in _allUserViewObjectList) {
        if (obj.view != nil) {
            [obj.view removeFromSuperview];
        }
    }
    
    NSInteger columnPerRow = ZGVideoTalkStreamViewColumnPerRow;
    CGFloat viewSpacing = ZGVideoTalkStreamViewSpacing;
    CGFloat screenWidth = CGRectGetWidth(UIScreen.mainScreen.bounds);
    CGFloat playViewWidth = (screenWidth - (columnPerRow + 1)*viewSpacing) /columnPerRow;
    CGFloat playViewHeight = 1.5f * playViewWidth;
    
    NSInteger i = 0;
    for (ZGVideoTalkViewObject *obj in _allUserViewObjectList) {
        if (obj.view == nil) {
            continue;
        }
        
        NSInteger cloumn = i % columnPerRow;
        NSInteger row = i / columnPerRow;
        
        CGFloat x = viewSpacing + cloumn * (playViewWidth + viewSpacing);
        CGFloat y = viewSpacing + row * (playViewHeight + viewSpacing);
        obj.view.frame = CGRectMake(x, y, playViewWidth, playViewHeight);
        
        //远端调整为大窗口
        if (i == 1) {
            obj.view.frame = self.containerView.bounds;
            [self.containerView addSubview:obj.view];
            [self.containerView sendSubviewToBack:obj.view];
        }else {
            [self.containerView addSubview:obj.view];
            [self.containerView bringSubviewToFront:obj.view];
        }
        
        
        i++;
    }
}

- (ZGVideoTalkViewObject *)getViewObjectWithStreamID:(NSString *)streamID {
    __block ZGVideoTalkViewObject *existObj = nil;
    [self.allUserViewObjectList enumerateObjectsUsingBlock:^(ZGVideoTalkViewObject * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.streamID isEqualToString:streamID]) {
            existObj = obj;
            *stop = YES;
        }
    }];
    return existObj;
}

/// Add a view of user who has entered the room and play the user stream
- (void)addRemoteViewObjectIfNeedWithStreamID:(NSString *)streamID {
    ZGVideoTalkViewObject *viewObject = [self getViewObjectWithStreamID:streamID];
    if (!viewObject) {
        viewObject = [ZGVideoTalkViewObject new];
        viewObject.isLocal = NO;
        viewObject.streamID = streamID;
        viewObject.view = [UIView new];
        [self.allUserViewObjectList addObject:viewObject];
    }
    
    ZegoCanvas *playCanvas = [ZegoCanvas canvasWithView:viewObject.view];
    playCanvas.viewMode = ZegoViewModeAspectFill;
    
    [[ZegoExpressEngine sharedEngine] startPlayingStream:streamID canvas:playCanvas];
    ZGLogInfo(@" 📥 Start playing stream, streamID: %@", streamID);
}

/// Remove view of user who has left the room and stop playing stream
- (void)removeViewObjectWithStreamID:(NSString *)streamID {
    ZGVideoTalkViewObject *obj = [self getViewObjectWithStreamID:streamID];
    if (obj) {
        [self.allUserViewObjectList removeObject:obj];
        [obj.view removeFromSuperview];
    }
    
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:streamID];
    ZGLogInfo(@" 📥 Stop playing stream, streamID: %@", streamID);
}

#pragma mark - ZegoEventHandler

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    if (errorCode != 0) {
        ZGLogError(@" 🚩 ❌ 🚪 Room state error, errorCode: %d", errorCode);
    } else {
        if (state == ZegoRoomStateConnected) {
            ZGLogInfo(@" 🚩 🚪 Login room success");
            self.roomStateLabel.text = @"Connected 🟢";
        } else if (state == ZegoRoomStateConnecting) {
            ZGLogInfo(@" 🚩 🚪 Requesting login room");
            self.roomStateLabel.text = @"Connecting 🟡";
        } else if (state == ZegoRoomStateDisconnected) {
            ZGLogInfo(@" 🚩 🚪 Logout room");
            self.roomStateLabel.text = @"Not Connected 🔴";
        }
    }
}

/// Refresh the remote streams list
- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList roomID:(NSString *)roomID {
    ZGLogInfo(@" 🚩 🌊 Room stream update, updateType:%lu, streamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
    NSArray<NSString *> *allStreamIDList = [_allUserViewObjectList valueForKeyPath:@"streamID"];
    
    if (updateType == ZegoUpdateTypeAdd) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@" 🚩 🌊 --- [Add] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            if (![allStreamIDList containsObject:stream.streamID]) {
                [self addRemoteViewObjectIfNeedWithStreamID:stream.streamID];
            }
        }
    } else if (updateType == ZegoUpdateTypeDelete) {
        for (ZegoStream *stream in streamList) {
            ZGLogInfo(@" 🚩 🌊 --- [Delete] StreamID: %@, UserID: %@", stream.streamID, stream.user.userID);
            [self removeViewObjectWithStreamID:stream.streamID];
        }
    }
    
    [self rearrangeVideoTalkViewObjects];
}

/// This method is called back every 30 seconds, can be used to show the current number of online user in the room
- (void)onRoomOnlineUserCountUpdate:(int)count roomID:(NSString *)roomID {
    ZGLogInfo(@" 🚩 👥 Room online user count update, count: %d, roomID: %@", count, roomID);
}

#pragma mark - Getter

- (ZGVideoTalkViewObject *)localUserViewObject {
    if (!_localUserViewObject) {
        _localUserViewObject = [ZGVideoTalkViewObject new];
        _localUserViewObject.isLocal = YES;
        _localUserViewObject.streamID = _localStreamID;
        _localUserViewObject.view = [UIView new];
    }
    return _localUserViewObject;
}

@end

#endif
