//
//  WZBleSDKInterface.h
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZBleData.h"
#import "WZBluetooh.h"
#import "WZBleDevice.h"
typedef enum{
    WZBluetoohCommandRestartDevice,//重启设备
    WZBluetoohCommandGetBattery,//电池
    WZBluetoohCommandSynSteps,//同步步数
    WZBluetoohCommandSynStatus,//同步设备
     WZBluetoohCommandSynPostures,//同步历史坐姿
    WZBluetoohCommandActivateDevice,//激活设备
    WZBluetoohCommandCancelActivateDevice,//取消设备激活
    WZBluetoohCommandCloseMotor,//马达关闭
    WZBluetoohCommandAdjustPosture,//坐姿校正
    WZBluetoohCommandCancelAdjustPosture,//取消坐姿矫正
    WZBluetoohCommandUploadDFUData,//空中升级
    WZBluetoohCommandGetRTPosture,//刷新实时坐姿
    
    WZBluetoohCommandSetName,//设置名字
    WZBluetoohCommandSetMotorDuration,//马达震动时长，单位s
    WZBluetoohCommandSetLeftAngel,//左倾角
    WZBluetoohCommandSetRightAngel,//右
    WZBluetoohCommandSetForwardAngel,//前
    WZBluetoohCommandSetBackwardAngel,//后
    WZBluetoohCommandClearData,//清除缓存
    WZBluetoohCommandNone,//空指令
} WZBluetoohCommand;

typedef enum{
    WZErrorNone,//无错误
    
}WZErrorCode;

typedef enum{
    WZBleStatusPowerOn,//
    WZBleStatusPowerOff,//
    WZBleStatusUnauthorized,//
}WZBleStatus;

@protocol WZBleSDKInterfaceListener;

@interface WZBleSDKInterface : NSObject

+(instancetype)sharedInterface;

-(NSArray<WZBleDevice*>*)devices;
-(void)clearDevices;
-(WZErrorCode)startScan;
-(void)stopScan;


-(void)connectDevice:(WZBleDevice*)device;
-(void)disConnectDevice:(WZBleDevice*)device;




-(void)addListner:(id<WZBleSDKInterfaceListener>)listener;
-(void)removeListener:(id<WZBleSDKInterfaceListener>)listener;


-(void)bleDevice:(WZBleDevice*)device sendCommandCode:(WZBluetoohCommand)command extraData:(id)data;

@end



@protocol WZBleSDKInterfaceListener <NSObject>

@optional
-(void)bleStatusChanged:(WZBleStatus)state;





-(void)bleDevicesChanged:(WZBleDevice*)device;
-(void)bleDevice:(WZBleDevice*)device didRefreshData:(WZBleData*)data comandCode:(WZBluetoohCommand)command;
-(void)bleDevice:(WZBleDevice *)device didDisconneted:(NSError*)error;


@end
