//
//  TestModel+ILYStringPicker.m
//  ILYStringPickerController
//
//  Created by Teonardo on 2020/7/23.
//  Copyright © 2020 Teonardo. All rights reserved.
//

#import "TestModel+ILYStringPicker.h"
#import <objc/runtime.h>

@implementation TestModel (ILYStringPicker)

- (NSString *)sp_title {
    return self.name;
}

- (void)setSp_selected:(BOOL)sp_selected {
    objc_setAssociatedObject(self, @selector(sp_selected), @(sp_selected), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sp_selected {
    NSNumber *value = objc_getAssociatedObject(self, @selector(sp_selected));
    return value.boolValue;
}

- (NSString *)sp_identifier {
    return self.myID;
}

@end
