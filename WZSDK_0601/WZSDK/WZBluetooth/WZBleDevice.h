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

@property (nonatomic,strong) CBPeripheral * periral;
@property (nonatomic,strong) NSDictionary * advertisment;
@property (nonatomic,strong) WZBleData * data;

-(NSString*)name;
-(NSNumber*)rssi;
-(NSArray*)services;
@end
