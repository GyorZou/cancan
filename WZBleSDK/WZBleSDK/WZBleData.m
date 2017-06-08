//
//  WZBleData.m
//  WZSDK
//
//  Created by jp007 on 2017/6/5.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "WZBleData.h"
#import "WZBleDeviceTools.h"

@interface WZBleData()
{
    NSMutableArray * _historyPos;
    NSMutableArray * _historySit;
    NSMutableArray * _historySteps;
}

@end

@implementation WZBleData

-(instancetype)init
{
    self = [super init];
    _historyPos = [[NSMutableArray alloc] initWithCapacity:20];
    _historySit = [[NSMutableArray alloc] initWithCapacity:20];
    _historySteps = [[NSMutableArray alloc] initWithCapacity:20];
    return  self;
}

-(NSString *)postureStatusString
{
    
    return [WZBleDeviceTools postureString:_postureStatus];
}

-(NSString *)sitStatusString
{
    NSInteger status = _postureStatus;
    NSInteger sitting = _sitStatus;
    NSString *sittingString = @"未知";
    if (status == 1) {
        sittingString = [WZBleDeviceTools sitStringWithStatus:sitting];
    }
    return sittingString;
}

-(void)setSteps:(NSUInteger)steps{
    _steps = steps;
    
    WZHistoryModel * model = [self stepModelAtTime:_stepTime];
    
    if (model == nil) {
        model =  [[WZHistoryModel alloc] init];
        [_historySteps addObject:model];
    }
   
    model.date = _stepTime;
    
    
    
    model.value = @(steps).stringValue;
    
   
}
-(void)setSynTime:(NSString *)synTime
{
    _synTime = synTime;
    
    WZHistoryModel * model = [self sitModelAtTime:synTime];
    
    if (model == nil) {
        model =  [[WZHistoryModel alloc] init];
         [_historySit addObject:model];
    }
    model.date = synTime;
    NSString * value = [NSString stringWithFormat:@"%ld-%ld-%ld-%ld-%ld",_sitTime,_forwardSitTime,_rightSitTime,_backwardSitTime,_leftSitTime];//总-前-右-后-左
    model.value = value;
    
   

    
}
-(WZHistoryModel*)stepModelAtTime:(NSString*)time
{

    for (WZHistoryModel * his in _historySteps) {
        if ([his.date isEqual:time]) {
            return his;
        }
    }
    
    return nil;
}

-(WZHistoryModel*)sitModelAtTime:(NSString*)time
{
    
    for (WZHistoryModel * his in _historySit) {
        if ([his.date isEqual:time]) {
            return his;
        }
    }
    
    return nil;
}

-(NSArray<WZHistoryModel *> *)historyPos{
    
    NSDictionary * dict= _postures;
    
    NSArray * keys = [dict allKeys];
    
    [_historyPos removeAllObjects];
    for (NSString * key in keys) {
        NSMutableDictionary * thisDict = [NSMutableDictionary new];
        
        NSMutableArray * temp =[NSMutableArray new];
       
        NSArray * arr = dict[key];
        
        for (NSDictionary * d in arr) {
            NSNumber * h = d[@"hour"];
            NSNumber * m = d[@"minute"];
            NSNumber * s = d[@"status"];
            NSString * v = [NSString stringWithFormat:@"%@-%@-%@",h.stringValue,m.stringValue,s.stringValue];
            
            WZHistoryModel * model = [WZHistoryModel new];
            model.value=v;
            [temp addObject:model];
            
        }
       
        thisDict[key] = [temp copy];
        [_historyPos addObject:thisDict];
        
    }
    
    return [_historyPos copy];
}
-(NSArray<WZHistoryModel *> *)historySit
{
    return [_historySit copy];
}

-(NSArray<WZHistoryModel *> *)historySteps
{
    return [_historySteps copy];
}



@end
