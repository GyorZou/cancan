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


+(NSString*)postureString:(NSInteger)posState;

+(NSString*)sitStringWithStatus:(NSInteger)sitState;
@end
