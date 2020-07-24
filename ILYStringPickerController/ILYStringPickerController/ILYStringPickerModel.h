//
//  ILYStringPickerModel.h
//  ILYStringPickerController
//
//  Created by Teonardo on 2020/7/23.
//  Copyright © 2020 Teonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ILYStringPickerModel <NSObject>
@required
@property (nonatomic, copy, readonly)NSString *sp_title;
@property (nonatomic, assign)BOOL sp_selected;

@optional
@property (nonatomic, copy, readonly)NSString *sp_identifier;

@end

NS_ASSUME_NONNULL_END
