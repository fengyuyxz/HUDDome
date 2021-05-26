//
//  PHUDWaveLoadingView.m
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/24.
//

#import "PHUDWaveLoadingView.h"
@interface PHUDWaveLoadingView()<CAAnimationDelegate>
@property(nonatomic,strong) CAShapeLayer * circleLayer;
@property(nonatomic,strong) CAShapeLayer * backCircleLayer;
@property(nonatomic,strong) CAShapeLayer * arrowVerticalLineLayer;
@property(nonatomic,strong) CAShapeLayer * arrowLayer;

@property(nonatomic,strong) UIBezierPath * circlePath;
@property(nonatomic,strong) UIBezierPath * verticalLinePath;
@property(nonatomic,strong) UIBezierPath * arrowPath;

@property(nonatomic,strong) UIBezierPath * wavePath;


@property(nonatomic,strong) UIBezierPath * verticalLineEndPath;

@property (nonatomic, assign) CGFloat offset;
@end
@implementation PHUDWaveLoadingView
{
    float waveHeight;
}
static dispatch_once_t onceToken;
static PHUDWaveLoadingView *ration;
+(instancetype)HUD
{
    
    dispatch_once(&onceToken, ^{
        ration= [[PHUDWaveLoadingView alloc]initWithFrame:CGRectMake(0, 0, 120, 120)];
    });
    
    return ration;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
        self.layer.cornerRadius = 8;
        [self setDefault];
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
        [self startAnimation];
    }];
}
-(void)setDefault{
    self.backCircleLayer = [self getShapeLayer];
    self.backCircleLayer.strokeColor = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1].CGColor;
    self.backCircleLayer.path = self.circlePath.CGPath;
    
    self.arrowLayer = [self getShapeLayer];
    self.arrowLayer.path = self.arrowPath.CGPath;
    
    self.arrowVerticalLineLayer = [self getShapeLayer];
    self.arrowVerticalLineLayer.frame=self.bounds;
    self.arrowVerticalLineLayer.path = self.verticalLinePath.CGPath;
    
    [self.layer addSublayer:self.backCircleLayer];
    [self.layer addSublayer:self.arrowLayer];
    [self.layer addSublayer:self.arrowVerticalLineLayer];
    
}
-(void)startAnimation
{
    [self verticalLineAnimation];
    [self arrowLineAnimation];
}
-(void)arrowLineAnimation
{
    CAKeyframeAnimation *anim=[CAKeyframeAnimation animationWithKeyPath:@"path"];
    anim.values = @[(__bridge id)self.arrowPath.CGPath,(__bridge id)[self arrowDownPath].CGPath,(__bridge id)[self arrowMinPath].CGPath,(__bridge id)[self arrowEndPath].CGPath];
    anim.keyTimes =@[@0,@0.15,@0.25,@0.28];
    anim.duration  = 2;
    anim.repeatCount  = 1;
    anim.timingFunction  = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.arrowLayer addAnimation:anim forKey:nil];
}
-(void)verticalLineAnimation{
    // 下划竖线 缩短动画
    CAKeyframeAnimation *cutKeyAn=[CAKeyframeAnimation animationWithKeyPath:@"path"];
    cutKeyAn.values = @[(__bridge  id)self.verticalLinePath.CGPath,(__bridge  id)self.verticalLineEndPath.CGPath];
    cutKeyAn.keyTimes=@[@0,@0.15];
    
    //  点先上运动
    CASpringAnimation *lineUpAnimation=[CASpringAnimation animationWithKeyPath:@"position.y"];
    lineUpAnimation.toValue=@7;
    lineUpAnimation.damping = 10;
    lineUpAnimation.mass = 1;
    lineUpAnimation.initialVelocity = 0;
//    lineUpAnimation.duration = lineUpAnimation.settlingDuration;
    lineUpAnimation.beginTime= 0.5;
    lineUpAnimation.removedOnCompletion = NO;
    lineUpAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations=@[cutKeyAn,lineUpAnimation];
    group.duration = 1.5;
    group.repeatCount = 1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction  = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.delegate=self;
    [self.arrowVerticalLineLayer addAnimation:group forKey:@"kLineToPointUpAnimationKey"];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CAAnimation *lineA= [self.arrowVerticalLineLayer animationForKey:@"kLineToPointUpAnimationKey"];
    if (lineA==anim) {
        [self.arrowLayer removeAllAnimations];
        
//        self.arrowLayer=nil;
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(wave)];
        link.frameInterval=4;
        [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}
-(void)wave{
    CGFloat _progress=0.5;
    CGFloat progressWaveHeight = 10.0 * ( 0.5 - powf(0.5, 2)) ;
    //浪
    [self waveWithHeight:_progress < 0.5 ? waveHeight : progressWaveHeight];
}
- (void)waveWithHeight:(CGFloat)waveHeight {
    
    self.offset += 1;
    
    self.arrowLayer.path = [self getWavePathWithOffset:self.offset
                                                    WaveHeight:waveHeight
                                                 WaveCurvature:0.25].CGPath;
    
}
- (UIBezierPath *)getWavePathWithOffset:(CGFloat)offset
                             WaveHeight:(CGFloat)height
                          WaveCurvature:(CGFloat)curvature{
    
    waveHeight = height;
    
    CGFloat SW = CGRectGetWidth(self.frame);
    CGFloat midPointX = 15;
    CGFloat lineW = SW - 30;
    UIBezierPath * arrowWavePath = [UIBezierPath bezierPath];
    [arrowWavePath moveToPoint:CGPointMake(midPointX, SW/2)];
    CGFloat y = 0;
    for (CGFloat x = midPointX; x <= midPointX+lineW ; x++) {
        y = height * sinf(curvature * x + offset )+SW/2;
        [arrowWavePath addLineToPoint:CGPointMake(x, y)];
    }
    return arrowWavePath;
}

-(CAShapeLayer *)getShapeLayer{
    CAShapeLayer *layer=[CAShapeLayer layer];
    layer.lineWidth = 5;
    layer.lineJoin =kCALineCapRound;
    layer.lineCap=kCALineCapRound;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor greenColor].CGColor;
    return layer;
}
-(UIBezierPath *)verticalLinePath{
    if (!_verticalLinePath) {
        _verticalLinePath = [UIBezierPath bezierPath];
        CGSize size = self.bounds.size;
        CGPoint startPoint = CGPointMake(size.width*0.5-2.5, 35);
        CGPoint endPoint = CGPointMake(size.width*0.5-2.5, size.height*0.70+2.5);
        [_verticalLinePath moveToPoint:startPoint];
        [_verticalLinePath addLineToPoint:endPoint];
    }
    return _verticalLinePath;
}
-(UIBezierPath *)verticalLineEndPath{
    if (!_verticalLineEndPath) {
        _verticalLineEndPath = [UIBezierPath bezierPath];
        CGSize size = self.bounds.size;
        CGPoint startPoint = CGPointMake(size.width*0.5-2.5, size.height*0.50-2.5);
//        CGPoint endPoint = CGPointMake(size.width*0.5-2.5, size.height*0.5-2.5);
        [_verticalLineEndPath moveToPoint:startPoint];
        [_verticalLineEndPath addLineToPoint:startPoint];
    }
    return _verticalLineEndPath;
}
-(UIBezierPath *)circlePath
{
    if (!_circlePath) {
        _circlePath = [UIBezierPath bezierPath];
        CGSize size = self.bounds.size;
        CGFloat radius = MIN(size.height, size.width)*0.5-5;
        [_circlePath addArcWithCenter:CGPointMake(size.width*0.5, size.height*0.5) radius:radius startAngle:M_PI *3*0.5 endAngle:M_PI*7*0.5 clockwise:YES];
    }
    return _circlePath;
}
-(UIBezierPath *)arrowPath{
    if (!_arrowPath) {
        _arrowPath = [UIBezierPath bezierPath];
        CGSize size = self.bounds.size;
        CGPoint startPoint = CGPointMake(size.width*0.3-2.5, size.height*0.60);
        CGPoint mindPoint = CGPointMake(size.width*0.5-2.5, size.height*0.70+5);
        CGPoint endPoint = CGPointMake(size.width*0.7-2.5, size.height*0.60);
        [_arrowPath moveToPoint:startPoint];
        [_arrowPath addLineToPoint:mindPoint];
        [_arrowPath addLineToPoint:endPoint];
    }
    return _arrowPath;
}

-(UIBezierPath *)arrowDownPath
{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGSize size = self.bounds.size;
    CGPoint startPoint = CGPointMake(size.width*0.3-2.5, size.height*0.60+4);
    CGPoint mindPoint = CGPointMake(size.width*0.5-2.5, size.height*0.70+9);
    CGPoint endPoint = CGPointMake(size.width*0.7-2.5, size.height*0.60+4);
    [arrowPath moveToPoint:startPoint];
    [arrowPath addLineToPoint:mindPoint];
    [arrowPath addLineToPoint:endPoint];
    return arrowPath;
}
-(UIBezierPath *)arrowEndPath
{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGSize size = self.bounds.size;
    CGPoint startPoint = CGPointMake(14, size.height*0.50);
    CGPoint mindPoint = CGPointMake(size.width*0.5-2.5, size.height*0.50);
    CGPoint endPoint = CGPointMake(size.width-14, size.height*0.50);
    [arrowPath moveToPoint:startPoint];
    [arrowPath addLineToPoint:mindPoint];
    [arrowPath addLineToPoint:endPoint];
    return arrowPath;
}
-(UIBezierPath *)arrowMinPath
{
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    CGSize size = self.bounds.size;
    CGPoint startPoint = CGPointMake(14, size.height*0.50);
    CGPoint mindPoint = CGPointMake(size.width*0.5-2.5, size.height*0.50-20);
    CGPoint endPoint = CGPointMake(size.width-14, size.height*0.50);
    [arrowPath moveToPoint:startPoint];
    [arrowPath addLineToPoint:mindPoint];
    [arrowPath addLineToPoint:endPoint];
    return arrowPath;
    return arrowPath;
}
@end
