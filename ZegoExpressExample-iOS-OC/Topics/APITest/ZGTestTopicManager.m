//
//  ZGTestTopicManager.m
//  ZegoExpressExample-iOS-OC
//
//  Created by Patrick Fu on 2019/10/24.
//  Copyright © 2019 Zego. All rights reserved.
//

#ifdef _Module_Test

#import "ZGTestTopicManager.h"
#import "ZGAppGlobalConfigManager.h"
#import "ZGUserIDHelper.h"

@interface ZGTestTopicManager () <ZegoEventHandler>

@property (nonatomic, strong) ZegoExpressEngine *engine;

@property (nonatomic, weak) id<ZGTestDataSource> dataSource;

@end

@implementation ZGTestTopicManager

- (void)dealloc {
    ZGLogInfo(@" 🏳️ Destroy the ZegoExpressEngine");
    [ZegoExpressEngine destroyEngine];
}

- (void)setZGTestDataSource:(id<ZGTestDataSource>)dataSource {
    self.dataSource = dataSource;
}

- (void)createEngineWithAppID:(unsigned int)appID appSign:(NSString *)appSign isTestEnv:(BOOL)isTestEnv scenario:(ZegoScenario)scenario {
    ZGLogInfo(@" 🚀 Initialize the ZegoExpressEngine");
    [self.dataSource onActionLog:@" 🚀 Initialize the ZegoExpressEngine"];
    self.engine = [ZegoExpressEngine createEngineWithAppID:appID appSign:appSign isTestEnv:isTestEnv scenario:scenario eventHandler:self];
}

- (void)destroyEngine {
    ZGLogInfo(@" 🏳️ Destroy the ZegoExpressEngine");
    [self.dataSource onActionLog:@" 🏳️ Destroy the ZegoExpressEngine"];
    [ZegoExpressEngine destroyEngine];
}

- (NSString *)getVersion {
    NSString *version = [ZegoExpressEngine getVersion];
    ZGLogInfo(@" ℹ️ Engine Version: %@", version);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ℹ️ Engine Version: %@", version]];
    return version;
}

- (void)uploadLog {
    [self.engine uploadLog];
    ZGLogInfo(@" 📬 Upload Log");
    [self.dataSource onActionLog:@" 📬 Upload Log"];
}

- (void)setDebugVerbose:(BOOL)enable language:(ZegoLanguage)language {
    [self.engine setDebugVerbose:enable language:language];
    ZGLogInfo(@" 📬 set debug verbose:%d, language:%@", enable, language == ZegoLanguageEnglish ? @"English" : @"中文");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 📬 set debug verbose:%d, language:%@", enable, language == ZegoLanguageEnglish ? @"English" : @"中文"]];
}


#pragma mark Room

- (void)loginRoom:(NSString *)roomID userID:(NSString *)userID {
    [self.engine loginRoom:roomID user:[ZegoUser userWithUserID:userID] config:nil];
    ZGLogInfo(@" 🚪 Login room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🚪 Login room"]];
}


- (void)logoutRoom:(NSString *)roomID {
    [self.engine logoutRoom:roomID];
    ZGLogInfo(@" 🚪 Exit the room. roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🚪 Exit the room. roomID: %@", roomID]];
}


#pragma mark Publish

- (void)startPublishing:(NSString *)streamID {
    [self.engine startPublishing:streamID];
    ZGLogInfo(@" 📤 Start publishing stream. streamID: %@", streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 📤 Start publishing stream. streamID: %@", streamID]];
}


- (void)stopPublishing {
    [self.engine stopPublishing];
    ZGLogInfo(@" 📤 Stop publishing stream");
    [self.dataSource onActionLog:@" 📤 Stop publishing stream"];
}


- (void)startPreview:(ZegoCanvas *)canvas {
    [self.engine startPreview:canvas];
    ZGLogInfo(@" 🔌 Start preview");
    [self.dataSource onActionLog:@" 🔌 Start preview"];
}


- (void)stopPreview {
    [self.engine stopPreview];
    ZGLogInfo(@" 🔌 Stop preview");
    [self.dataSource onActionLog:@" 🔌 Stop preview"];
}


- (void)setVideoConfig:(ZegoVideoConfig *)videoConfig {
    [self.engine setVideoConfig:videoConfig];
    ZGLogInfo(@" 🧷 Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🧷 Set video config. width: %d, height: %d, bitrate: %d, fps: %d", (int)videoConfig.captureResolution.width, (int)videoConfig.captureResolution.height, videoConfig.bitrate, videoConfig.fps]];
}


- (void)setVideoMirrorMode:(ZegoVideoMirrorMode)mirrorMode {
    [self.engine setVideoMirrorMode:mirrorMode];
    ZGLogInfo(@" ⚙️ Set video mirror mode. Mode: %d", (int)mirrorMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⚙️ Set video mirror mode. Mode: %d", (int)mirrorMode]];
}


- (void)setCaptureOrientation:(UIInterfaceOrientation)orientation {
    [self.engine setCaptureOrientation:orientation];
    ZGLogInfo(@" ⚙️ Set capture orientation: %d", (int)orientation);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⚙️ Set capture orientation: %d", (int)orientation]];
}


- (void)setLatencyMode:(ZegoLatencyMode)latencyMode {
    [self.engine setLatencyMode:latencyMode];
    ZGLogInfo(@" ⚙️ Set latency mode: %d", (int)latencyMode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⚙️ Set latency mode: %d", (int)latencyMode]];
}


- (void)setAudioBitrate:(int)bitrate {
    [self.engine setAudioBitrate:bitrate];
    ZGLogInfo(@" ⚙️ Set audio bitrate: %d", (int)bitrate);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⚙️ Set audio bitrate: %d", (int)bitrate]];
}


- (void)mutePublishStreamAudio:(BOOL)mute {
    [self.engine mutePublishStreamAudio:mute];
    ZGLogInfo(@" 🙊 Mute publish stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🙊 Mute publish stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePublishStreamVideo:(BOOL)mute {
    [self.engine mutePublishStreamVideo:mute];
    ZGLogInfo(@" 🙈 Mute publish stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🙈 Mute publish stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)setCaptureVolume:(int)volume {
    [self.engine setCaptureVolume:volume];
    ZGLogInfo(@" ⛏ Set capture volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⛏ Set capture volume: %d", volume]];
}


- (void)addPublishCDNURL:(NSString *)targetURL stream:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCDNURLCallback)callback {
    [self.engine addPublishCDNURL:targetURL stream:streamID callback:^(int errorCode, NSString * _Nonnull streamID) {
        if (callback) {
            callback(errorCode, streamID);
        }
    }];
    ZGLogInfo(@" 🔗 Add publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔗 Add publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)removePublishCDNURL:(NSString *)targetURL stream:(NSString *)streamID callback:(nullable ZegoPublisherUpdateCDNURLCallback)callback {
    [self.engine removePublishCDNURL:targetURL stream:streamID callback:^(int errorCode, NSString * _Nonnull streamID) {
        if (callback) {
            callback(errorCode, streamID);
        }
    }];
    ZGLogInfo(@" 🔗 Remove publish cdn url: %@, streamID: %@", targetURL, streamID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔗 Remove publish cdn url: %@, streamID: %@", targetURL, streamID]];
}


- (void)enableHardwareEncoder:(BOOL)enable {
    [self.engine enableHardwareEncoder:enable];
    ZGLogInfo(@" 🔧 Enable hardware encoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable hardware encoder: %@", enable ? @"YES" : @"NO"]];
}


#pragma mark Player

- (void)startPlayingStream:(NSString *)streamID canvas:(ZegoCanvas *)canvas {
    [self.engine startPlayingStream:streamID canvas:canvas];
    ZGLogInfo(@" 📥 Start playing stream");
    [self.dataSource onActionLog:@" 📥 Start playing stream"];
}


- (void)stopPlayingStream:(NSString *)streamID {
    [self.engine stopPlayingStream:streamID];
    ZGLogInfo(@" 📥 Stop playing stream");
    [self.dataSource onActionLog:@" 📥 Stop playing stream"];
}


- (void)setPlayVolume:(int)volume stream:(NSString *)streamID {
    [self.engine setPlayVolume:volume stream:streamID];
    ZGLogInfo(@" ⛏ Set play volume: %d", volume);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⛏ Set play volume: %d", volume]];
}


- (void)mutePlayStreamAudio:(BOOL)mute stream:(NSString *)streamID {
    ZGLogInfo(@" 🙊 Mute play stream audio: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🙊 Mute play stream audio: %@", mute ? @"YES" : @"NO"]];
}


- (void)mutePlayStreamVideo:(BOOL)mute stream:(NSString *)streamID {
    [self.engine mutePlayStreamVideo:mute stream:streamID];
    ZGLogInfo(@" 🙈 Mute play stream video: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🙈 Mute play stream video: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableHarewareDecoder:(BOOL)enable {
    [self.engine enableHardwareDecoder:enable];
    ZGLogInfo(@" 🔧 Enable hardware decoder: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable hardware decoder: %@", enable ? @"YES" : @"NO"]];
}


#pragma mark PreProcess

- (void)enableAEC:(BOOL)enable {
    [self.engine enableAEC:enable];
    ZGLogInfo(@" 🔧 Enable AEC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable AEC: %@", enable ? @"YES" : @"NO"]];
}


- (void)setAECMode:(ZegoAECMode)mode {
    [self.engine setAECMode:mode];
    ZGLogInfo(@" ⛏ Set AEC mode: %d", (int)mode);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⛏ Set AEC mode: %d", (int)mode]];
}


- (void)enableAGC:(BOOL)enable {
    [self.engine enableAGC:enable];
    ZGLogInfo(@" 🔧 Enable AGC: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable AGC: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableANS:(BOOL)enable {
    [self.engine enableANS:enable];
    ZGLogInfo(@" 🔧 Enable ANS: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable ANS: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableBeautify:(int)feature {
    [self.engine enableBeautify:feature];
    ZGLogInfo(@" ⛏ Enable beautify: %d", (int)feature);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" ⛏ Enable beautify: %d", (int)feature]];
}


- (void)setBeautifyOption:(ZegoBeautifyOption *)option {
    [self.engine setBeautifyOption:option];
    ZGLogInfo(@" 🔧 Set eautify option. polishStep: %f, polishFactor: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.polishFactor, option.whitenFactor, option.sharpenFactor);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Set eautify option. polishStep: %f, polishFactor: %f, whitenFactor: %f, sharpenFactor: %f", option.polishStep, option.polishFactor, option.whitenFactor, option.sharpenFactor]];
}


#pragma mark Device

- (void)enableMicrophone:(BOOL)enable {
    [self.engine enableMicrophone:enable];
    ZGLogInfo(@" 🔧 Enable microphone: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable microphone: %@", enable ? @"YES" : @"NO"]];
}


- (void)muteAudioOutput:(BOOL)mute {
    [self.engine muteAudioOutput:mute];
    ZGLogInfo(@" 🔧 Mute audio output: %@", mute ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Mute audio output: %@", mute ? @"YES" : @"NO"]];
}


- (void)enableCamera:(BOOL)enable {
    [self.engine enableCamera:enable];
    ZGLogInfo(@" 🔧 Enable camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)useFrontCamera:(BOOL)enable {
    [self.engine useFrontCamera:enable];
    ZGLogInfo(@" 🔧 Use front camera: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Use front camera: %@", enable ? @"YES" : @"NO"]];
}


- (void)enableAudioCaptureDevice:(BOOL)enable {
    [self.engine enableAudioCaptureDevice:enable];
    ZGLogInfo(@" 🔧 Enable audio capture device: %@", enable ? @"YES" : @"NO");
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 🔧 Enable audio capture device: %@", enable ? @"YES" : @"NO"]];
}

#pragma mark Mixer

- (void)startMixerTask:(ZegoMixerTask *)task {
    ZGLogInfo(@" 🧬 Start mixer task");
    [self.engine startMixerTask:task callback:^(ZegoMixerStartResult * _Nonnull result) {
        ZGLogInfo(@" 🚩 🧬 Start mixer task result errorCode: %d", result.errorCode);
    }];
}

- (void)stopMixerTask:(NSString *)taskID {
    ZGLogInfo(@" 🧬 Stop mixer task");
    [self.engine stopMixerTask:taskID];
}

#pragma mark IM

- (void)sendBroadcastMessage:(NSString *)message roomID:(NSString *)roomID {
    [self.engine sendBroadcastMessage:message roomID:roomID callback:^(int errorCode) {
        ZGLogInfo(@" 🚩 ✉️ Send broadcast message result errorCode: %d", errorCode);
    }];
}

- (void)sendCustomCommand:(NSString *)command toUserList:(nullable NSArray<ZegoUser *> *)toUserList roomID:(NSString *)roomID {
    [self.engine sendCustomCommand:command toUserList:nil roomID:roomID callback:^(int errorCode) {
        ZGLogInfo(@" 🚩 ✉️ Send custom command (to all user) result errorCode: %d", errorCode);
    }];
}


#pragma mark - Callback

- (void)onDebugError:(int)errorCode funcName:(NSString *)funcName info:(NSString *)info {
    ZGLogInfo(@" 🚩 ❓ Debug Error Callback: errorCode: %d, FuncName: %@ Info: %@", errorCode, funcName, info);
}

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode room:(NSString *)roomID {
    ZGLogInfo(@" 🚩 🚪 Room State Update Callback: %lu, errorCode: %d, roomID: %@", (unsigned long)state, (int)errorCode, roomID);
}


- (void)onRoomUserUpdate:(ZegoUpdateType)updateType userList:(NSArray<ZegoUser *> *)userList room:(NSString *)roomID {
    ZGLogInfo(@" 🚩 🕺 Room User Update Callback: %lu, UsersCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)userList.count, roomID);
}

- (void)onRoomStreamUpdate:(ZegoUpdateType)updateType streamList:(NSArray<ZegoStream *> *)streamList room:(NSString *)roomID {
    ZGLogInfo(@" 🚩 🌊 Room Stream Update Callback: %lu, StreamsCount: %lu, roomID: %@", (unsigned long)updateType, (unsigned long)streamList.count, roomID);
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📤 Publisher State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📈 Publisher Quality Update Callback: FPS:%f, Bitrate:%f, Width: %f, Height: %f, streamID: %@", quality.videoSendFPS, quality.videoKBPS, quality.videoResolution.width, quality.videoResolution.height, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPublisherQualityUpdate:)]) {
        [self.dataSource onPublisherQualityUpdate:quality];
    }
}

- (void)onPublisherRecvFirstFrameEvent:(ZegoPublisherFirstFrameEvent)event {
    ZGLogInfo(@" 🚩 ✨ Publisher Recv First Frame Event Callback: %lu", (unsigned long)event);
}

- (void)onPublisherVideoSizeChanged:(CGSize)size {
    ZGLogInfo(@" 🚩 📐 Publisher Video Size Changed Callback: Width: %f, Height: %f", size.width, size.height);
}

- (void)onPublisherRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)infoList stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📡 Publisher Relay CDN State Update Callback: Relaying CDN Count: %lu, streamID: %@", (unsigned long)infoList.count, streamID);
}

- (void)onPlayerStateUpdate:(ZegoPlayerState)state errorCode:(int)errorCode stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📥 Player State Update Callback: %lu, errorCode: %d, streamID: %@", (unsigned long)state, (int)errorCode, streamID);
}

- (void)onPlayerQualityUpdate:(ZegoPlayStreamQuality *)quality stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📉 Player Quality Update Callback: FPS:%f, Bitrate:%f, Width: %f, Height: %f, streamID: %@", quality.videoRecvFPS, quality.videoKBPS, quality.videoResolution.width, quality.videoResolution.height, streamID);
    
    if ([self.dataSource respondsToSelector:@selector(onPlayerQualityUpdate:)]) {
        [self.dataSource onPlayerQualityUpdate:quality];
    }
}

- (void)onPlayerMediaEvent:(ZegoPlayerMediaEvent)event stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 🎊 Player Media Event Callback: %lu, streamID: %@", (unsigned long)event, streamID);
}

- (void)onPlayerRecvFirstFrameEvent:(ZegoPlayerFirstFrameEvent)event stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 ⚡️ Player Recv First Frame Event Callback: %lu, streamID: %@", (unsigned long)event, streamID);
}

- (void)onPlayerVideoSizeChanged:(CGSize)size stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📏 Player Video Size Changed Callback: Width: %f, Height: %f, streamID: %@", size.width, size.height, streamID);
}

- (void)onDeviceError:(int)errorCode deviceName:(NSString *)deviceName {
    ZGLogInfo(@" 🚩 💻 Device Error Callback: errorCode: %d, DeviceName: %@", errorCode, deviceName);
}

- (void)onRemoteCameraStateUpdate:(ZegoRemoteDeviceState)state stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 📷 Remote Camera State Update Callback: state: %lu, DeviceName: %@", (unsigned long)state, streamID);
}

- (void)onRemoteMicStateUpdate:(ZegoRemoteDeviceState)state stream:(NSString *)streamID {
    ZGLogInfo(@" 🚩 🎙 Remote Mic State Update Callback: state: %lu, DeviceName: %@", (unsigned long)state, streamID);
}

- (void)onMixerRelayCDNStateUpdate:(NSArray<ZegoStreamRelayCDNInfo *> *)infoList taskID:(NSString *)taskID {
    ZGLogInfo(@" 🚩 🧬 Mixer Relay CDN State Update Callback: taskID: %@", taskID);
    for (int idx = 0; idx < infoList.count; idx ++) {
        ZegoStreamRelayCDNInfo *info = infoList[idx];
        ZGLogInfo(@" 🚩 🧬 --- %d: state: %lu, URL: %@, reason: %lu", idx, (unsigned long)info.state, info.URL, (unsigned long)info.updateReason);
    }
}

- (void)onIMRecvBroadcastMessage:(NSArray<ZegoMessageInfo *> *)messageInfoList roomID:(NSString *)roomID {
    ZGLogInfo(@" 🚩 📩 IM Recv Broadcast Message Callback: roomID: %@", roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 📩 Received Broadcast Message"]];
    for (int idx = 0; idx < messageInfoList.count; idx ++) {
        ZegoMessageInfo *info = messageInfoList[idx];
        ZGLogInfo(@" 🚩 📩 --- %d: message: %@, fromUserID: %@, sendTime: %llu", idx, info.message, info.fromUser.userID, info.sendTime);
        [self.dataSource onActionLog:[NSString stringWithFormat:@" 📩 [%@] --- from %@, time: %llu", info.message, info.fromUser.userID, info.sendTime]];
    }
}

- (void)onIMRecvCustomCommand:(NSString *)command fromUser:(ZegoUser *)fromUser roomID:(NSString *)roomID {
    ZGLogInfo(@" 🚩 📩 IM Recv Custom Command Callback: command: %@, fromUserID: %@, roomID: %@", command, fromUser.userID, roomID);
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 📩 Received Custom Command"]];
    [self.dataSource onActionLog:[NSString stringWithFormat:@" 📩 [%@] --- from %@", command, fromUser.userID]];
}


@end

#endif