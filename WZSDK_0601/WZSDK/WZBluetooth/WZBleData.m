//
//  WZBleData.m
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "WZBleData.h"

@implementation WZBleData

-(NSString *)postureStatusString
{
    NSInteger status = _postureStatus;
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

-(NSString *)sitStatusString
{
    NSInteger status = _postureStatus;
    NSInteger sitting = _sitStatus;
    NSString *sittingString = @"未知";
    if (status == 1) {
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
    }
    return sittingString;
}

@end
