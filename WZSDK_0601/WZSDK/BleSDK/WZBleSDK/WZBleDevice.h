//
//  WZBleDevice.h
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "WZBleData.h"
@interface WZBleDevice : NSObject

/**
 当前保存的蓝牙设备模型对象
 */
@property (nonatomic,strong) CBPeripheral * periral;

/**
 当前保存的蓝牙设备广播的内容
 */
@property (nonatomic,strong) NSDictionary * advertisment;

/**
 当前保存的蓝牙设备交互产生的一些数据，具体查看WZBleData的定义
 */
@property (nonatomic,strong) WZBleData * data;


/**
 当前设备的名称

 @return 名称
 */
-(NSString*)name;

/**
 当前设备的信号强度
 
 @return 信号强度
 */
-(NSNumber*)rssi;

/**
 当前设备的提供的服务UUID列表
 
 @return uuid列表
 */
-(NSArray*)services;
@end
