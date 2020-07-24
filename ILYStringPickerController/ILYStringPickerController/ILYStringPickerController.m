//
//  ILYStringPickerController.m
//  
//
//  Created by Teonardo on 2020/6/3.
//  Copyright © 2020 huajie. All rights reserved.
//

#import "ILYStringPickerController.h"

#define ILY_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define ILY_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define ILYStringPickerCellHeight 50
#define ILYStringPickerContentViewHeight 300
#define ILYStringPickerButtonTextColor [UIColor colorWithRed:77/255.f green:77/255.f blue:77/255.f alpha:1.0]
#define ILYStringPickerTitleTextColor [UIColor colorWithRed:88/255.f green:88/255.f blue:88/255.f alpha:1.0]

@interface ILYStringPickerController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, copy) ILYStringPickerAction doneAction;

@property (nonatomic, copy) SPModelArray *defaultSelection;
@property (nonatomic, strong) NSMutableArray <id<ILYStringPickerModel>>*modelArr;
@property (nonatomic, strong) NSMutableArray <id<ILYStringPickerModel>>*selectedModelArr;

@end

@implementation ILYStringPickerController {
    UITapGestureRecognizer *_coverViewTap;
    NSString *_title;
    BOOL _multiple;
    NSIndexPath *_lastSelectedIndexPath;
}

@dynamic title;

#pragma mark - Init

- (instancetype)initWithTitle:(NSString *)title multiple:(BOOL)multiple dataSource:(SPModelArray *)dataSource defaultSelection:(SPModelArray*)selection doneAction:(ILYStringPickerAction)action
{
    self = [super init];
    if (self) {
        
        NSAssert([dataSource.firstObject conformsToProtocol:@protocol(ILYStringPickerModel)], @"ILYStringPickerController - dataSource中的对象必须遵守<ILYStringPickerModel>协议!请为你的Model新建一个分类,在分类中使其遵守<ILYStringPickerModel>协议,并实现相应方法");
        
        _itemFont = [UIFont systemFontOfSize:15.f];
        _itemTextColor = [UIColor colorWithRed:66/255.f green:66/255.f blue:66/255.f alpha:1.0];
        
        _title = [title copy];
        _multiple = multiple;
        _modelArr = [dataSource copy];
        _defaultSelection = [selection copy];
        _doneAction = [action copy];
        
        [self prepareData];
        
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

+ (instancetype)stringPickerControllerWithTitle:(NSString * _Nullable)title multiple:(BOOL)multiple dataSource:(SPModelArray *)dataSource defaultSelection:(SPModelArray * _Nullable)selection doneAction:(ILYStringPickerAction)action {
    
    return [[self alloc] initWithTitle:title multiple:multiple dataSource:dataSource defaultSelection:selection doneAction:action];
}

#pragma mark - View Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildInterface];
    self.title = _title;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.coverView.alpha = 1.f;
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _coverView.frame = self.view.bounds;
    [self updateContentViewFrame];
}

#pragma mark - UI
- (void)buildInterface {
    //
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_coverView];
    _coverView.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    _coverView.alpha = 0.f;
    
    _coverViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedCoverView:)];
    [_coverView addGestureRecognizer:_coverViewTap];
    
    //
    [self.view addSubview:self.contentView];
}

#pragma mark - Action
- (void)tapedCoverView:(UITapGestureRecognizer *)sender {
    if (_clickShadowToHide) {
        [self dismiss];
    }
}

- (void)clickedCancelButton:(UIButton *)buttton {
    [self dismiss];
}

- (void)clickedConfirmButton:(UIButton *)buttton {
    !self.doneAction ? : self.doneAction(self.selectedModelArr);
    [self dismiss];
}

#pragma mark - Delegate

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id<ILYStringPickerModel> model = self.modelArr[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(ily_stringPicker:shouldSelectItemAtIndex:)]) {
        if (![self.delegate ily_stringPicker:self shouldSelectItemAtIndex:indexPath.row]) {
            return;
        }
    }
    
    if (_multiple) {
        // 多选
        model.sp_selected = !model.sp_selected;
        if (model.sp_selected) {
            [self.selectedModelArr addObject:model];
        } else {
            [self.selectedModelArr removeObject:model];
        }
    }
    else {
        // 单选
        if (_lastSelectedIndexPath) {
            if (_lastSelectedIndexPath.row == indexPath.row) {
                return;
            } else {
                id<ILYStringPickerModel> lastSelectedModel = self.modelArr[_lastSelectedIndexPath.row];
                lastSelectedModel.sp_selected = NO;
            }
        }
        
        
        model.sp_selected = YES;
        [self.selectedModelArr removeAllObjects];
        [self.selectedModelArr addObject:model];
        
        _lastSelectedIndexPath = indexPath;
    }
    
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    id<ILYStringPickerModel> model = self.modelArr[indexPath.row];
    [self configureCell:cell withModel:model];
    
    return cell;
}

#pragma mark - Private Method
- (void)prepareData {
    
    [self.selectedModelArr removeAllObjects];

    // 需要重置字符串的选中状态
    if ([self.modelArr.firstObject isKindOfClass:[NSString class]]) {
        [self.modelArr enumerateObjectsUsingBlock:^(id<ILYStringPickerModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.sp_selected = NO;
        }];
    }

    [_defaultSelection enumerateObjectsUsingBlock:^(id<ILYStringPickerModel>  _Nonnull obj0, NSUInteger idx0, BOOL * _Nonnull stop0) {
        
        [self.modelArr enumerateObjectsUsingBlock:^(id<ILYStringPickerModel>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    
            if ([obj0.sp_title isEqualToString:obj.sp_title]) {
                obj.sp_selected = YES;
                [self.selectedModelArr addObject:obj];
                _lastSelectedIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                *stop = YES;
            }
        }];
        
    }];
}

- (void)configureCell:(UITableViewCell *)cell withModel:(id<ILYStringPickerModel>)model {
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.itemFont) cell.textLabel.font = self.itemFont;
    if (self.itemTextColor) cell.textLabel.textColor = self.itemTextColor;
    cell.textLabel.text = model.sp_title;

    if (model.sp_selected) {
        if (self.checkedStateImage) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:self.checkedStateImage];
        } else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        if (self.uncheckedStateImage) {
            cell.accessoryView = [[UIImageView alloc] initWithImage:self.uncheckedStateImage];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

- (void)dismiss {
    self.coverView.alpha = 0.f;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)updateContentViewFrame {
    _contentView.frame = CGRectMake(0, ILY_SCREEN_HEIGHT - ILYStringPickerContentViewHeight, ILY_SCREEN_WIDTH, ILYStringPickerContentViewHeight);
}

- (UIButton *)createButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:ILYStringPickerButtonTextColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Setter
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    
    UILabel *titleLabel = _titleLabel;
    if (title.length > 0) {
        titleLabel = self.titleLabel;
    }
    titleLabel.text = title;
}

- (void)setHeaderViewBackgroundColor:(UIColor *)headerViewBackgroundColor {
    _headerViewBackgroundColor = headerViewBackgroundColor;
    _headerView.backgroundColor = headerViewBackgroundColor;
}

#pragma mark - Getter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self updateContentViewFrame];
    
        //
        [_contentView addSubview:self.headerView];
        [_contentView addSubview:self.tableView];
        
        //
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [[self.headerView.topAnchor constraintEqualToAnchor:_contentView.topAnchor] setActive:YES];
        [[self.headerView.leftAnchor constraintEqualToAnchor:_contentView.leftAnchor] setActive:YES];
        [[self.headerView.rightAnchor constraintEqualToAnchor:_contentView.rightAnchor] setActive:YES];
        [[self.headerView.heightAnchor constraintEqualToConstant:45] setActive:YES];
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [[self.tableView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor] setActive:YES];
        [[self.tableView.leftAnchor constraintEqualToAnchor:_contentView.leftAnchor] setActive:YES];
        [[self.tableView.rightAnchor constraintEqualToAnchor:_contentView.rightAnchor] setActive:YES];
        [[self.tableView.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor] setActive:YES];
    }
    
    return _contentView;
}

- (UIView *)headerView {
    if (!_headerView) {
        UIView *headerView = [UIView new];
        _headerView = headerView;
        headerView.backgroundColor = self.headerViewBackgroundColor;
        
        //
        [headerView addSubview:self.cancelButton];
        [headerView addSubview:self.doneButton];
        
        //
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [[self.cancelButton.leftAnchor constraintEqualToAnchor:headerView.leftAnchor constant:18] setActive:YES];
        [[self.cancelButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor] setActive:YES];
        [self.cancelButton setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];

        self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
        [[self.doneButton.rightAnchor constraintEqualToAnchor:headerView.rightAnchor constant:-18] setActive:YES];
        [[self.doneButton.centerYAnchor constraintEqualToAnchor:headerView.centerYAnchor] setActive:YES];
        [self.doneButton setContentCompressionResistancePriority:1000 forAxis:UILayoutConstraintAxisHorizontal];

    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView = tableView;
        
        tableView.delegate = self;
        tableView.dataSource = self;
        
        tableView.rowHeight = ILYStringPickerCellHeight;
        tableView.tableFooterView = [UIView new];
        tableView.showsVerticalScrollIndicator = NO;
        
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    return _tableView;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        self.cancelButton = [self createButtonWithTitle:@"取消" action:@selector(clickedCancelButton:)];
    }
    return _cancelButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        self.doneButton = [self createButtonWithTitle:@"确定" action:@selector(clickedConfirmButton:)];
    }
    return _doneButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.headerView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = ILYStringPickerTitleTextColor;
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [[titleLabel.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor] setActive:YES];
        [[titleLabel.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor] setActive:YES];
        [[titleLabel.leftAnchor constraintGreaterThanOrEqualToAnchor:self.cancelButton.rightAnchor constant:10] setActive:YES];
        [[titleLabel.rightAnchor constraintLessThanOrEqualToAnchor:self.doneButton.leftAnchor constant:-10] setActive:YES];
        [titleLabel setContentCompressionResistancePriority:999 forAxis:UILayoutConstraintAxisHorizontal];
    }
    
    return _titleLabel;
}

- (NSString *)title {
    return _title;
}

- (NSMutableArray *)modelArr {
    if (!_modelArr) {
        _modelArr = @[].mutableCopy;
    }
    return _modelArr;
}

- (NSMutableArray *)selectedModelArr {
    if (!_selectedModelArr) {
        _selectedModelArr = @[].mutableCopy;
    }
    return _selectedModelArr;
}

@end
