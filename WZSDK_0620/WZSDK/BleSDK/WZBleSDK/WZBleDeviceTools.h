//
//  WZBleDeviceTools.h
//  WZSDK
//
//  Created by zougyor on 2017/6/7.
//  Copyright © 2017年 生生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WZBleSDKBaseInterface.h"
@interface WZBleDeviceTools : NSObject

/**
 命令描述

 @param cmd 命令的枚举值
 @return 该命令的描述
 */
+(NSString*)descriptionOfCMD:(WZBluetoohCommand)cmd;



/**
 根据设备传递的数字值，转化为中文描述

 @param posState 设备传出来的对应姿态的数值
 @return 这个数值的中文描述，比如设备传的0，就是状态未知
 */
+(NSString*)postureString:(NSInteger)posState;


/**
 根据设备传递的数字值，转化为中文描述
 
 @param sitState 设备传出来的对应坐姿的数值
 @return 这个数值的中文描述，比如设备传的0，就是坐姿未知
 */
+(NSString*)sitStringWithStatus:(NSInteger)sitState;
@end
