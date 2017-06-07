//
//  WZBleDevice.m
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "WZBleDevice.h"

@implementation WZBleDevice
-(WZBleData *)data
{
    if (_data==nil) {
        _data =[[WZBleData alloc] init];
    }
    return _data;
}



-(NSString*)name
{
    
    NSString * name = _advertisment[@"kCBAdvDataLocalName"];
    if (name==nil) {
        name = _periral.name;
        
    }
    return name;
}


-(NSNumber*)rssi
{
    return _data.rssi;
}
-(NSArray*)services
{
return _advertisment[@"kCBAdvDataServiceUUIDs"];
}

@end
