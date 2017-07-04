//
//  HistoryViewController.m
//  WZSDK
//
//  Created by jp007 on 2017/6/8.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryInfoCell.h"
#import "WZBleSDK.h"
@interface HistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITableView * tab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
    tab.delegate = self;
    tab.dataSource=self;
    tab.frame = self.view.bounds;
    [self.view addSubview:tab];
    
    [tab registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell1"];
   
    [tab registerNib:[UINib nibWithNibName:@"HistoryInfoCell" bundle:nil] forCellReuseIdentifier:@"cell2"];
    tab.rowHeight = 100;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_tag==100||_tag==103||_tag == 104) {
        return _data.count;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_tag==100||_tag==103 ||_tag==104) {
        NSDictionary  * dataDict = [_data objectAtIndex:section];
        
        NSArray * keys =[dataDict allKeys];
        
        return  [keys firstObject];
    }

    return nil;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_tag==100||_tag==103 || _tag==104) {
        NSDictionary  * key = [_data objectAtIndex:section];
        
        NSArray * keys =[key allKeys];
        
        return  [key[[keys firstObject]] count];
    }
    return [_data count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HistoryInfoCell * cell =[tableView dequeueReusableCellWithIdentifier:@"cell2"];
    

    
    
    if (_tag==100||_tag==103) {
        NSDictionary  * key = [_data objectAtIndex:indexPath.section];
        
        NSArray * keys =[key allKeys];
        
         NSArray * datas = key[[keys firstObject]];
        
        WZHistoryModel * model = [datas objectAtIndex:indexPath.row];
        cell.dateLabel.text = model.date;
        
        
        NSArray * t =[model.value componentsSeparatedByString:@"-"];
        if (t.count==3) {
            
            NSString * s = [NSString stringWithFormat:@"%@时%@分 %@",t[0],t[1],[WZBleDeviceTools postureString:[t[2] intValue]]];
           cell.valueLabel.text =s;
        }
        
        
    }else if (_tag==101) {
        
        WZHistoryModel * model = [_data objectAtIndex:indexPath.row];
        
        cell.dateLabel.text = model.date;
        cell.valueLabel.text =model.value;
        
    }else if (_tag==102) {
        WZHistoryModel * model = [_data objectAtIndex:indexPath.row];
        
        cell.dateLabel.text = model.date;
        cell.valueLabel.text =model.value;
        
    }else if (_tag==104) {
        NSDictionary  * key = [_data objectAtIndex:indexPath.section];
        
        NSArray * keys =[key allKeys];
        
        NSArray * datas = key[[keys firstObject]];
        
        NSString * model = [datas objectAtIndex:indexPath.row];
        cell.dateLabel.text = nil;
        cell.valueLabel.text =model;
        
    }
    return cell;

}

@end
