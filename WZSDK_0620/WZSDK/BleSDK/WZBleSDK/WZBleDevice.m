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
-(NSData *)mac
{
    return [_advertisment valueForKey:@"kCBAdvDataManufacturerData"];;
}

-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]]) {
        WZBleDevice * temp = (WZBleDevice*)object;
        return [temp.periral.identifier.UUIDString isEqual:self.periral.identifier.UUIDString];
    }
    
    return [super isEqual:object];
}

-(NSOperationQueue *)workQueue
{
    static NSOperationQueue * queue;
    //static dispatch_once_t token;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        [queue setSuspended:YES];
        queue.maxConcurrentOperationCount = 1;
    });
    return queue;
}
@end
