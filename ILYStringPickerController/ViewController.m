//
//  ViewController.m
//  ILYStringPickerController
//
//  Created by Teonardo on 2020/7/23.
//  Copyright © 2020 Teonardo. All rights reserved.
//

#import "ViewController.h"
#import "ILYStringPickerController.h"
#import "TestModel+ILYStringPicker.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *selectedStr;
@property (nonatomic, copy) SPModelArray *selectedItems;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - Action
- (IBAction)clickedStringTestButton:(UIButton *)sender {
    [self testWithString];
}


- (IBAction)clickedModelTestButton:(UIButton *)sender {
    [self testWithCustomModel];
}


#pragma mark - Example
- (void)testWithString {
    
    NSArray *arr = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g"];
    ILYStringPickerController *picker = [ILYStringPickerController stringPickerControllerWithTitle:@"字符串数组测试" multiple:NO dataSource:arr defaultSelection:(self.selectedStr ? @[self.selectedStr] : nil) doneAction:^(SPModelArray * _Nonnull arr) {
        self.selectedStr = arr.firstObject.sp_title;
    }];
    
    [picker.cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [picker.doneButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    picker.titleLabel.textColor = [UIColor blackColor];
    picker.itemFont = [UIFont systemFontOfSize:12.f];
    picker.itemTextColor = [UIColor blueColor];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)testWithCustomModel {
    
    NSMutableArray *tempArr = [NSMutableArray array];
    for (int i = 0; i < 10; i++) {
        TestModel *model = [TestModel new];
        model.name = [NSString stringWithFormat:@"Model-%@", @(i)];
        model.myID = @(i).stringValue;
        [tempArr addObject:model];
    }
    
    ILYStringPickerController *picker = [ILYStringPickerController stringPickerControllerWithTitle:@"模型数组测试" multiple:YES dataSource:tempArr defaultSelection:self.selectedItems doneAction:^(SPModelArray * _Nonnull arr) {
        
        self.selectedItems = arr;
        
        NSLog(@"----------完成选择----------");
        for (id<ILYStringPickerModel> model in arr) {
            NSLog(@"title:%@ ,identifier:%@", model.sp_title, model.sp_identifier);
        }
    }];
    
    picker.headerViewBackgroundColor = [UIColor systemPinkColor];
    picker.checkedStateImage = [UIImage imageNamed:@"select_1"];
    picker.uncheckedStateImage = [UIImage imageNamed:@"select_0"];
    
    picker.clickShadowToHide = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

@end
