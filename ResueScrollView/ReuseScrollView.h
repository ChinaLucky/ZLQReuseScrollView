//
//  ResueScrollView.h
//  StoreDemo
//
//  Created by Luqiang on 16/1/19.
//  Copyright © 2016年 Luqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ReuseScrollView;

@protocol ReuseScrollViewSubDelegate <NSObject>

//清除数据
- (void)clearData;
//更新数据
- (void)updateDataWithObject:(id)dataObject pageIndex:(NSInteger)pageIndex;
//设置新页码
- (void)updatePageIndex:(NSInteger)pageIndex;
//获得当前页码
- (NSInteger)currentPageIndex;

@end

@protocol ReuseScrollViewDelegate <NSObject>
//总页数
- (NSInteger)numberOfPagesInReuseScrollView:(ReuseScrollView *)reuseScrollView;
//指定页的实例
- (id<ReuseScrollViewSubDelegate>)reuseScrollView:(ReuseScrollView *)reuseScrollView pageObjectWithPageIndex:(NSInteger)pageIndex;
//指定页数据源
- (id)reuseScrollView:(ReuseScrollView *)reuseScrollView dataObjectWithPageIndex:(NSInteger)pageIndex;
//滚动页面,改变按钮
- (void)changeIndexToIndex:(NSInteger)index animated:(BOOL)animated;

@end


@interface ReuseScrollView : UIScrollView

@property (nonatomic, weak) id<ReuseScrollViewDelegate> delegateResue;
//@property (nonatomic, weak) id<ReuseScrollViewSubDelegate> delegateSub;

//加载可见页
- (void)loadVisiablePages;
//移动到指定页面
- (void)changePageToIndex:(NSInteger)index animated:(BOOL)animated;
@end








