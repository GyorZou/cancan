//
//  WZBleSDKInterface.h
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZBleData.h"
#import "WZBleDevice.h"

/*
 所有指令枚举值
 */
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
    WZErrorBleNotPrepared,//蓝牙不可用
}WZErrorCode;

typedef enum{
    WZBleStatusUnSupport,//不支持，比如模拟器，iPhone4等
    WZBleStatusPowerOn,//可用
    WZBleStatusPowerOff,//未打开
    WZBleStatusUnauthorized,//打开未授权
}WZBleStatus;

@protocol WZBleSDKInterfaceListener;

@interface  WZBleSDKBaseInterface: NSObject
{
    NSMutableArray<WZBleDevice*> * _devices;
    NSMutableArray<id<WZBleSDKInterfaceListener>> * _listeners;
    BOOL _markForScan;

}

@property (nonatomic,assign) WZBleStatus status;

/**
 单例

 @return 共享单例
 */
+(instancetype)sharedInterface;
/**
 添加事件监听者对象

 @param listener 监听者
 */
-(void)addListner:(id<WZBleSDKInterfaceListener>)listener;


/**
 页面关闭时，移除监听者，避免内存泄漏

 @param listener 监听者
 */
-(void)removeListener:(id<WZBleSDKInterfaceListener>)listener;



/**
 获取扫描到的所有设备

 @return 所有设备
 */
-(NSArray<WZBleDevice*>*)devices;


/**
 清空扫描到的设备，
 */
-(void)clearDevices;



/**
 开始扫描设备

 @return 操作码，如果蓝牙不可用，会返回错误代码
 */
-(WZErrorCode)startScan;


/**
 停止扫描
 */
-(void)stopScan;



/**
 连接设备

 @param device 被连接的设备
 */
-(void)connectDevice:(WZBleDevice*)device;


/**
 主动断开连接

 @param device 当前设备
 */
-(void)disConnectDevice:(WZBleDevice*)device;




-(void)bleDevice:(WZBleDevice*)device sendCommandCode:(WZBluetoohCommand)command extraData:(id)data;

@end



@protocol WZBleSDKInterfaceListener <NSObject>

@optional

/**
 手机蓝牙状态变更，用户需要根据状态的变化做出相应的提示

 @param state 蓝牙硬件状态
 */
-(void)bleStatusChanged:(WZBleStatus)state;





/**
 蓝牙设备的变更，可能是新增，可能是消失

 @param device 变化的设备，可能为nil
 */
-(void)bleDevicesChanged:(WZBleDevice*)device;


/**
 对应的设备，接收到某指令的回复后，更新了用户数据
 
 @param device 当前连接的设备
 @param data 数据模型
 @param command 指令代码
 */
-(void)bleDevice:(WZBleDevice*)device didRefreshData:(WZBleData*)data comandCode:(WZBluetoohCommand)command;


/**
 手机成功连接到设备的回调，用户可在此方法后进行发相关指令

 @param device 设备
 */
-(void)bleDidConnectDevice:(WZBleDevice*)device;


/**
 连接设备失败

 @param device 失败的设备
 @param err 错误原因
 */
-(void)bleFailConnectDevice:(WZBleDevice *)device error:(NSError*)err;


/**
 设备断开连接的回调

 @param device 设备
 @param error 断开的原因
 */
-(void)bleDevice:(WZBleDevice *)device didDisconneted:(NSError*)error;


@end
