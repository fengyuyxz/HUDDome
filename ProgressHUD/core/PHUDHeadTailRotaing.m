//
//  PHUDHeadTailRotaing.m
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/21.
//

#import "PHUDHeadTailRotaing.h"
@interface PHUDHeadTailRotaing()<CAAnimationDelegate>
@property(nonatomic,strong) CAShapeLayer * shapeLayer;
@property(nonatomic,strong) CAShapeLayer * rightLayer;
@property(nonatomic,strong) CAShapeLayer * failLayer;
@end
@implementation PHUDHeadTailRotaing
static dispatch_once_t onceToken;
static PHUDHeadTailRotaing *ration;
+(instancetype)HUD
{
    
    dispatch_once(&onceToken, ^{
        ration= [[PHUDHeadTailRotaing alloc]initWithFrame:CGRectMake(0, 0, 120, 120)];
    });
    
    return ration;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
        self.layer.cornerRadius = 8;
    }
    return self;
}
-(void)startLoading:(UIView *)container
{
    
    self.frame = CGRectMake(CGRectGetWidth(container.frame)*0.5-60, CGRectGetHeight(container.frame)*0.5-60, 120, 120);
    __weak typeof(self) weakSelf = self;
    [container addSubview:self];
    self.alpha=0;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.alpha = 1;
        
    } completion:^(BOOL finished) {
        [weakSelf circleAnimation];
    }];
}
-(void)loadSUC{
    [self rightAnimation];
}
-(void)loadFail{
    [self failAnimation];
}
-(void)circleAnimation
{
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.fillColor=[UIColor clearColor].CGColor;
    shape.strokeColor = [UIColor greenColor].CGColor;
    shape.lineWidth = 5;
    shape.path = [self circlePath].CGPath;
    [self.layer addSublayer:shape];
    
    CABasicAnimation *strokeStartAnimation=[CABasicAnimation animation];
    strokeStartAnimation.keyPath=@"strokeStart";
    strokeStartAnimation.fromValue=@(0);
    strokeStartAnimation.toValue=@(1);
    strokeStartAnimation.duration = 1.5;
    strokeStartAnimation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    CABasicAnimation *strokeEndAnimation=[CABasicAnimation animation];
    strokeEndAnimation.keyPath=@"strokeEnd";
    strokeEndAnimation.fromValue=@(0);
    strokeEndAnimation.toValue=@(1);
    strokeEndAnimation.duration = 1.5;
    strokeEndAnimation.beginTime=1.5;//延迟1.5秒，等待strokeStartAnimation执行完在开锁执行该动画
    
    strokeEndAnimation.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations=@[strokeStartAnimation,strokeEndAnimation];
    group.duration=3;
    group.repeatDuration = INFINITY;
    [shape addAnimation:group forKey:@"circleAnimation"];
    _shapeLayer = shape;
}
-(void)rightAnimation
{
    
    if (!self.superview) {
        return;
    }
    
    [self.shapeLayer removeAllAnimations];
    
    self.shapeLayer.path = [self rightPath].CGPath;
    
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue=@(0);
    animation.toValue=@(1);
    animation.duration = 0.75;
    animation.delegate = self;
    [animation setValue:@"rightAnimation" forKey:@"animationKey"];
    [self.self.shapeLayer addAnimation:animation forKey:@"rightAnimation"];
    
}

-(void)failAnimation
{
    
    if (!self.superview) {
        return;
    }
    
    [self.shapeLayer removeAllAnimations];
    CAShapeLayer *failLayer = [CAShapeLayer layer];
    failLayer.fillColor=[UIColor clearColor].CGColor;
    failLayer.strokeColor = [UIColor greenColor].CGColor;
    failLayer.lineWidth = 5;
    failLayer.path = [self failPath].CGPath;
    [self.layer addSublayer:failLayer];
    self.failLayer=failLayer;
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue=@(0);
    animation.toValue=@(1);
    animation.duration = 0.75;
    animation.delegate = self;
    [animation setValue:@"failLayer" forKey:@"animationKey"];
    [self.failLayer addAnimation:animation forKey:nil];
    
}

-(UIBezierPath *)rightPath
{
    
    UIBezierPath *circlePath=[self circlePath];
    
    CGSize size = self.bounds.size;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(size.width*0.2, size.height*0.55f)];
    [path addLineToPoint:CGPointMake(size.width*0.35, size.height*0.8)];
    CGFloat radius = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame))*0.5f;
    CGFloat x = sin(45)*radius+radius+5;
    CGFloat y= sin(45)*radius;
    [path addLineToPoint:CGPointMake(x, y)];
    [circlePath appendPath:path];
    return circlePath;
}
-(UIBezierPath *)failPath
{
    
    UIBezierPath *circlePath=[self circlePath];
    CGSize size = self.bounds.size;
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat radius = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame))*0.5f;
    CGFloat line = cos(45)*(radius);
    
    CGFloat x = radius - line -5,y=radius - line -5;
    
    [path moveToPoint:CGPointMake(x, y)];
    [path addLineToPoint:CGPointMake(size.width-x, size.height-y)];
    
    [path moveToPoint:CGPointMake(size.width-x, y)];
    [path addLineToPoint:CGPointMake(x, size.height-y)];
    [circlePath appendPath:path];
    return circlePath;
}
-(UIBezierPath *)circlePath
{
    CGFloat radius = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame))*0.5f-5;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(60, 60) radius:radius startAngle:M_PI*3/2 endAngle:M_PI*7/2 clockwise:YES];
    return path;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSString *key = [anim valueForKey:@"animationKey"];
        if ([@"rightAnimation" isEqualToString:key]) {
            [self closeView];
        }else if ([@"failLayer" isEqualToString:key]){
            [self closeView];
        }
    }
}
-(void)closeView
{
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
            [weakSelf.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            [weakSelf removeFromSuperview];
            [PHUDHeadTailRotaing destoryHUD];
            
        }];
}
-(void)cancel{
    
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeAllAnimations)];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.alpha = 0;
        } completion:^(BOOL finished) {
            
            [weakSelf removeFromSuperview];
            [PHUDHeadTailRotaing destoryHUD];
            
        }];
}
-(void)dealloc{
    NSLog(@"dealloc");
}
+(void)destoryHUD
{
    onceToken = 0;
    ration=nil;
}
@end
