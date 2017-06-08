//
//  WZBleDeviceTools.m
//  WZSDK
//
//  Created by zougyor on 2017/6/7.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "WZBleDeviceTools.h"

@implementation WZBleDeviceTools

+(NSString *)postureString:(NSInteger)code
{
    NSInteger status = code;
    NSString *statusString;
    if (status == 0) {
        statusString = @"未知";
    } else if (status == 1) {
        statusString = @"坐/站立";
    } else if (status == 2) {
        statusString = @"躺";
    } else if (status == 3) {
        statusString = @"走";
    } else if (status == 4) {
        statusString = @"跑";
    }
    return statusString;

}

+(NSString *)sitStringWithStatus:(NSInteger)sitting
{
    
    NSString * sittingString =@"";
    if (sitting == 0) {
        sittingString = @"未知";
    } else if (sitting == 1) {
        sittingString = @"正坐";
    } else if (sitting == 2) {
        sittingString = @"偏左";
    } else if (sitting == 3) {
        sittingString = @"偏右";
    } else if (sitting == 4) {
        sittingString = @"偏前";
    } else if (sitting == 5) {
        sittingString = @"偏后";
    }

    return sittingString;
}
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
