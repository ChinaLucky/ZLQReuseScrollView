//
//  ResueScrollView.m
//  StoreDemo
//
//  Created by Luqiang on 16/1/19.
//  Copyright © 2016年 Luqiang. All rights reserved.
//

#import "ReuseScrollView.h"

@interface ReuseScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableSet *reusePageSet;
@property (nonatomic, strong) NSMutableSet *visiblePageSet;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isUserScroll;

@end

@implementation ReuseScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initProperties];
    }
    return self;
}

- (void)p_initProperties {
    self.delegate = self;
    self.bounces = NO;
    self.pagingEnabled = YES;
    self.reusePageSet = [[NSMutableSet alloc] init];
    self.visiblePageSet = [[NSMutableSet alloc] init];
    self.pageCount = 0;
    self.currentPage = 0;
    self.isUserScroll = YES;
}

- (void)loadVisiablePages {
    //获得总页码
    self.pageCount=[self.delegateResue numberOfPagesInReuseScrollView:self];
    //计算可见页码
    CGRect visibleBounds = self.bounds;
    //self.contentOffset
    //NSLog(@"cur:%@",NSStringFromCGRect(visibleBounds));
    //跟据左下角x和右上角x计算当前可见页码
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / self.size.width);
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds) - 1) / self.size.width);
    //保存当前页码
    self.currentPage = firstNeededPageIndex;
    //预加载当前页的前后页
    firstNeededPageIndex = MAX(firstNeededPageIndex - 1, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex + 1, (int)self.pageCount - 1);
    // 收藏不再可见页,以备复用
    for (id<ReuseScrollViewSubDelegate> page in self.visiblePageSet) {
        //如果当前页不再是可见页,将它回收
        if ([page currentPageIndex] < firstNeededPageIndex || [page currentPageIndex] > lastNeededPageIndex) {
            //清除旧数据,回收复用
            [page clearData];
            [self.reusePageSet addObject:page];
            //从屏幕上将它移除
            UIView<ReuseScrollViewSubDelegate> *view=[self p_viewWithPage:page];
            [view removeFromSuperview];
            
        }
    }
    //从可见集合中去掉回收集合包含的内容
    [self.visiblePageSet minusSet:self.reusePageSet];
    //添加新可见页
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        //不是可见页再处理，否则不处理
        if (![self p_isVisiblePageAtIndex:index]) {
            //是否存在可复用的实例
            id<ReuseScrollViewSubDelegate> page = [self p_getReusePage];
            //不存在就创建
            if (page == nil) {
                //从委拖对象获得某页对象
                page = [self.delegateResue reuseScrollView:self pageObjectWithPageIndex:index];
            }
            
            //设置新的页码
            [page updatePageIndex:index];
            
            //设置新的位置
            CGRect frame = CGRectMake(self.size.width * index, 0, self.size.width,self.size.height);
            UIView <ReuseScrollViewSubDelegate> *view=[self p_viewWithPage:page];
            view.frame  = frame;
            //将当前页的视图添加到滚动视图上(自己上)
            [self addSubview:view];
            //更新内容
            [self p_configPage:page atIndex:index];
            //加入可见集合
            [self.visiblePageSet addObject:page];
            
        }
    }

}

- (UIView<ReuseScrollViewSubDelegate> *)p_viewWithPage:(id<ReuseScrollViewSubDelegate>)page {
    if ([page isKindOfClass:[UIView class]]) {
        return (UIView<ReuseScrollViewSubDelegate> *)page;
    }
    if ([page isKindOfClass:[UIViewController class]]) {
        UIViewController *pageController = (UIViewController *)page;
        return (UIView<ReuseScrollViewSubDelegate> *)(pageController.view);
    }
    NSLog(@"error:不支持的类型");
    return (UIView<ReuseScrollViewSubDelegate> *)page;
}

- (BOOL)p_isVisiblePageAtIndex:(NSInteger)index {
    BOOL isVisible = NO;
    for (UIView<ReuseScrollViewSubDelegate> *page in self.visiblePageSet) {
        if ([page currentPageIndex] == index) {
            isVisible = YES;
            break;
        }
    }
    return isVisible;
}

- (id<ReuseScrollViewSubDelegate>)p_getReusePage {
    id<ReuseScrollViewSubDelegate> page = [self.reusePageSet anyObject];
    if (page) {
        [self.reusePageSet removeObject:page];
    }
    return page;
}

- (void)p_configPage:(id<ReuseScrollViewSubDelegate>)page atIndex:(NSInteger)index {
    id dataObject = [self.delegateResue reuseScrollView:self dataObjectWithPageIndex:index];
    [page updateDataWithObject:dataObject pageIndex:index];
}

- (void)changePageToIndex:(NSInteger)index animated:(BOOL)animated {
    self.pageCount = [self.delegateResue numberOfPagesInReuseScrollView:self];
    if (index < 0 || index > self.pageCount) {
        return;
    }
    self.isUserScroll = NO;
    CGPoint point = CGPointMake(index * self.size.width, 0);
    [self setContentOffset:point animated:YES];
}


#pragma mark - scrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _isUserScroll = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadVisiablePages];
    if (self.isUserScroll) {
        [self.delegateResue changeIndexToIndex:_currentPage animated:YES];
    }
}

@end


















