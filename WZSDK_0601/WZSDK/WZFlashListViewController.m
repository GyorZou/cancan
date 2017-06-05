//
//  WZFlashListViewController.m
//  WZSDK
//
//  Created by 生生 on 2017/4/24.
//  Copyright © 2017年 生生. All rights reserved.
//

#import "WZFlashListViewController.h"

@interface WZFlashListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tabelView;

@end

@implementation WZFlashListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tabelView.delegate = self;
    self.tabelView.dataSource = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (IBAction)closeButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.postureArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *postureDict = self.postureArray[section];
    NSArray *array = postureDict.allValues[0];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 15)];
    label.backgroundColor = [UIColor whiteColor];
    NSDictionary *postureDict = self.postureArray[section];
    label.text = postureDict.allKeys.firstObject;
    
    return label;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"WZFlashListViewControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *postureDict = self.postureArray[indexPath.section];
    NSArray *array = postureDict.allValues[0];
    NSDictionary *dict = array[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"hour:%@,  minute%@, status:%@", [dict valueForKey:@"hour"], [dict valueForKey:@"minute"], [dict valueForKey:@"status"]];
    
    return cell;
}

@end
