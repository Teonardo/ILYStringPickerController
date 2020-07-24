//
//  ILYStringPickerController.h
//
//
//  Created by Teonardo on 2020/6/3.
//  Copyright © 2020 huajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+ILYStringPicker.h"

@class ILYStringPickerController;

NS_ASSUME_NONNULL_BEGIN

@protocol ILYStringPickerControllerDelegate <NSObject>
@optional
/// 决定是否可以选中指定项.返回NO,则无法选中该项.
- (BOOL)ily_stringPicker:(ILYStringPickerController *)picker shouldSelectItemAtIndex:(NSInteger)index;

@end

typedef NSArray <id<ILYStringPickerModel>> SPModelArray;
typedef void(^ILYStringPickerAction)(SPModelArray * arr);


@interface ILYStringPickerController : UIViewController
/// 点击阴影隐藏
@property (nonatomic, assign) BOOL clickShadowToHide;
@property (nullable, nonatomic, copy) NSString *title;

// 方便自定义配置
@property (nonatomic, strong, readonly) UIButton *cancelButton;
@property (nonatomic, strong, readonly) UIButton *doneButton;
@property (nonatomic, strong, readonly) UILabel *titleLabel;
/// 设置勾选转态的图片
@property (nonatomic, strong) UIImage *checkedStateImage;
/// 设置未勾选转态的图片
@property (nonatomic, strong) UIImage *uncheckedStateImage;
/// 字符串的字体
@property (nonatomic, strong) UIFont *itemFont;
/// 字符串的文本颜色
@property (nonatomic, strong) UIColor *itemTextColor;
/// 头部视图的背景色
@property (nonatomic, strong) UIColor *headerViewBackgroundColor;

@property (nonatomic, weak) id<ILYStringPickerControllerDelegate> delegate;

/// 创建一个字符串选择器
/// @param title 标题
/// @param multiple NO:单选;YES:多选
/// @param dataSource 数据源
/// @param selection 默认选中项
/// @param action 完成选择回调
+ (instancetype)stringPickerControllerWithTitle:(NSString * _Nullable)title multiple:(BOOL)multiple dataSource:(SPModelArray *)dataSource defaultSelection:(SPModelArray * _Nullable)selection doneAction:(ILYStringPickerAction)action;

@end

NS_ASSUME_NONNULL_END
