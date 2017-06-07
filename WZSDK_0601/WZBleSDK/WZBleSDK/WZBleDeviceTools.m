//
//  WZBleDeviceTools.m
//  WZSDK
//
//  Created by zougyor on 2017/6/7.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "WZBleDeviceTools.h"

@implementation WZBleDeviceTools
+(NSString *)descriptionOfCMD:(WZBluetoohCommand)cmd
{
    NSString * value = @"";
    switch (cmd) {
        case WZBluetoohCommandSetName:
            value =@"设置名字";
            break;
            
        case WZBluetoohCommandSynSteps:
            value =@"同步步数";
            break;
        case WZBluetoohCommandSynStatus:
            value =@"同步状态";
            break;
        case WZBluetoohCommandCloseMotor:
            value =@"关闭马达";
            break;
        case WZBluetoohCommandGetBattery:
            value =@"获取电池";
            break;
        case WZBluetoohCommandSynPostures:
            value =@"同步历史坐姿";
            break;
        case WZBluetoohCommandGetRTPosture:
            value =@"实时坐姿";
            break;
        case WZBluetoohCommandSetLeftAngel:
            value =@"设置左倾角";
            break;
        case WZBluetoohCommandAdjustPosture:
            value =@"矫正坐姿";
            break;
        case WZBluetoohCommandRestartDevice:
            value =@"重启设备";
            break;
        case WZBluetoohCommandSetRightAngel:
            value =@"设置右倾角";
            break;
        case WZBluetoohCommandUploadDFUData:
            value =@"上传dfu";
            break;
        case WZBluetoohCommandActivateDevice:
            value =@"激活设备";
            break;
        case WZBluetoohCommandSetForwardAngel:
            value =@"设置前倾角";
            break;
        case WZBluetoohCommandSetBackwardAngel:
            value =@"设置后倾角";
            break;
        case WZBluetoohCommandSetMotorDuration:
            value =@"马达时长";
            break;
        case WZBluetoohCommandCancelAdjustPosture:
            value =@"取消矫正坐姿";
            break;
        case WZBluetoohCommandCancelActivateDevice:
            value =@"取消激活设备";
            break;
        case WZBluetoohCommandClearData:
            value = @"清除缓存";
        default:
            break;
    }
    return value;
}

@end
