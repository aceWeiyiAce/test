//
//  CZViewController.m
//  05-图片轮播器
//
//  Created by apple on 14-7-22.
//  Copyright (c) 2014年 itcast. All rights reserved.
//
#define CZImageCount 5

#import "CZViewController.h"

@interface CZViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scorllView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation CZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 1. 要想显示5张图片，得由5各UIImageView
    
    CGFloat imageW = self.scorllView.frame.size.width;
    CGFloat imageH = self.scorllView.frame.size.height;
    CGFloat imageY = 0;
    
    // 添加5个UIImageView
    for (int i = 0; i < CZImageCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        
        // 设置frame
        CGFloat imageX = i * imageW;
        imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        // 设置图片
        // 拼接图片名称
//        NSString *name = [NSString stringWithFormat:@"img_0%d", i + 1];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"img_0%d", i + 1]];
        
        // 添加到scorllView上
        [self.scorllView addSubview:imageView];
    }
    
    // 2. 设置内容尺寸
    CGFloat contentW = imageW * CZImageCount;
    self.scorllView.contentSize = CGSizeMake(contentW, 0);
    
    // 3. 隐藏水平滚动条
    self.scorllView.showsHorizontalScrollIndicator = NO;
    
    // 4.分页.scorllView的属性，分页原理，根据scorllView的宽度来进行分页的
    //              所以，我们一般会把一个图片的宽度和scorllView的宽度设置成一样
    self.scorllView.pagingEnabled = YES;
    
    // 5. 设置一共有多少页
    self.pageControl.numberOfPages = CZImageCount;
    // 要想显示当前在第几页，我需要手动设置pageControl的当前页。在scorllView的滚动代理里面进行设置
    
    // 6.添加定时器（每隔2秒调用一下nextImage）
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
//    self.timer = timer;
    [self addTimer];
}

// 每隔2秒钟，定时器就会调用一次这个方法
- (void)nextImage
{
    // 1. 设置pageControl的页码
//    if (self.pageControl.currentPage == CZImageCount - 1) {
//        self.pageControl.currentPage = 0;
//    }else{
//        self.pageControl.currentPage++;
//    }
//    NSLog(@"nextImage设置当前页%d", self.pageControl.currentPage);
    
    // 1. 需要知道当前的页码，但是不需要设置页码
    int page = 0;
    if (self.pageControl.currentPage == CZImageCount - 1) {
        page = 0;
    }else{
        page = self.pageControl.currentPage + 1;
    }
    
    // 2. 让scorllView进行滚动（设置scorllView的ContentOffset值就可以实现）
    CGFloat offSetX = page * self.scorllView.frame.size.width;
    CGPoint offSet = CGPointMake(offSetX, 0);
    
    [self.scorllView setContentOffset:offSet animated:YES];
}
// 当用户开始拖拽，拖住不放，停止定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

// 用户拖拽结束的时候，重新开启定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

// 滚动TextView的时候，就是在更新UI界面和接受用户的触摸事件
// 上面两者都需要在主线程进行完成
// 定时器的事件处理，也需要在主线程进行完成
// 添加一个定时器
- (void)addTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    self.timer = timer;
    
    // 消息循环loop 获得当前的run循环
    // 把定时器页添加到主线程里面
    // 一个线程同一个时间只能处理一个事件
    // 只要把定时器添加到主线程，那么主线程就会0.00001秒的时候处理UI更新，下一个0.000001秒处理定时器的事件
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer
{
    // 停止定时器(一旦停止了，定时器就在不能用了)
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 根据scrollView的滚动位置来设置当前pageControl的当前页
    CGFloat scrollW = scrollView.frame.size.width;
    int page = (scrollView.contentOffset.x + scrollW * 0.5)/ scrollW;
//    NSLog(@"scrollViewDidScroll设置当前第%d页",page);
    self.pageControl.currentPage = page;
}
@end
