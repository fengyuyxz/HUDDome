//
//  PencelLoadingProgressView.m
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/24.
//

#import "PencilLoadingProgressView.h"

@interface PencilLoadingProgressView()<CAAnimationDelegate>
@property(nonatomic,strong) CAShapeLayer * circleLayer;
@property(nonatomic,strong) CAShapeLayer * arrowLayer;//箭头 -》铅笔
@property(nonatomic,strong) CAShapeLayer * progressLayer;

@property(nonatomic,assign)BOOL isAnimation;

@end
const float lineWidth = 2.0;
const float radius = 40.0;
const float pencelWidth = 4;
const float pencelHight = radius*0.5;
const float pencilArrowH = 4;
@implementation PencilLoadingProgressView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaultUI];
    }
    return self;
}

-(void)setDefaultUI
{
    self.circleLayer = [self getDefaultShapeLayer];
    self.arrowLayer = [self getDefaultShapeLayer];
    self.progressLayer = [self getDefaultShapeLayer];
    self.progressLayer.frame = self.bounds;
    self.progressLayer.strokeColor = [UIColor greenColor].CGColor;
    self.circleLayer.frame = self.bounds;
    self.arrowLayer.frame = self.bounds;
    
    self.circleLayer.path = [self circlePath].CGPath;
    self.arrowLayer.path = [self arrowPath].CGPath;
    self.progressLayer.path = [self straightLinePath].CGPath;
    self.progressLayer.hidden = YES;
    [self.layer addSublayer:self.circleLayer];
    [self.layer addSublayer:self.progressLayer];
    [self.layer addSublayer:self.arrowLayer];
}
-(CAShapeLayer *)getDefaultShapeLayer
{
    CAShapeLayer *shape = [CAShapeLayer layer];
    shape.lineWidth = lineWidth;
    shape.lineJoin = kCALineCapRound;
    shape.lineCap = kCALineCapRound;
    shape.fillColor = [UIColor clearColor].CGColor;
    shape.strokeColor = [UIColor whiteColor].CGColor;
    return shape;
}

-(void)start
{
    if (_isAnimation) {
        return;
    }
    _isAnimation = YES;
    [self arrowChangeToPencil];
    [self circleChnageLine];
}
#pragma mark - 圆圈变换
-(void)circleChnageLine
{
    
    
    CAKeyframeAnimation *waveAn = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    CGFloat offset = 15.f;
    waveAn.values = @[(__bridge  id)[self concaveLinePathWithOffset:offset*2].CGPath,
                      (__bridge  id)[self concaveLinePathWithOffset:offset].CGPath,
                      (__bridge  id)[self convexLinePath:offset].CGPath,
                      (__bridge  id)[self convexLinePath:offset*2].CGPath,
                     (__bridge  id)[self convexLinePath:offset].CGPath,(__bridge id)[self straightLinePath].CGPath];
    waveAn.removedOnCompletion=NO;
    waveAn.fillMode = kCAFillModeForwards;
    waveAn.keyTimes=@[@0,@0.1,@0.15,@0.35,@0.45,@0.60];
//    waveAn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.60;
    group.animations = @[waveAn];
    group.removedOnCompletion=NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate  = self;
    [self.circleLayer addAnimation:group forKey:@"circleChange"];
}
-(void)arrowChangeToPencil
{
    CAKeyframeAnimation *pencilAni = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    pencilAni.values=@[(__bridge  id)[self pencilPath].CGPath];
    pencilAni.duration = 0.15;
    pencilAni.removedOnCompletion=NO;
    pencilAni.fillMode = kCAFillModeForwards;
    
    
    CABasicAnimation *positioAni=[CABasicAnimation animationWithKeyPath:@"position.y"];
    
    CGSize size = self.bounds.size;
    CGFloat lineLen = M_PI*radius*2;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    CGPoint midPoint = CGPointMake(center.x, center.y+radius);
    CGPoint startPoint = CGPointMake(midPoint.x-lineLen*0.5+_progress*lineLen, midPoint.y);
    positioAni.duration = 0.1;
    positioAni.beginTime = 0.15;
    positioAni.toValue = @(self.arrowLayer.position.y-100);
    positioAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    positioAni.removedOnCompletion=NO;
    positioAni.fillMode = kCAFillModeForwards;
    
    
    CAKeyframeAnimation *movePencil=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    movePencil.path = [self pencilMovePath].CGPath;
    movePencil.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    movePencil.duration = 0.25;
    movePencil.beginTime = 0.3;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.55;
    group.animations = @[pencilAni,positioAni,movePencil];
    group.removedOnCompletion=NO;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    [self.arrowLayer addAnimation:group forKey:@"pencilChangeMove"];
    
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CAAnimation *stopAnim = [self.circleLayer animationForKey:@"circleChange"];
    if (stopAnim==anim) {
//        [self.arrowLayer removeAllAnimations];
//        [self.circleLayer removeAllAnimations];
        self.progressLayer.strokeEnd=_progress;
        self.progressLayer.hidden=NO;
    }
}
-(UIBezierPath *)circlePath
{
    CGSize size = self.bounds.size;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    
    
    [path addArcWithCenter:center radius:radius startAngle:M_PI*3*0.5 endAngle:M_PI*7*0.5 clockwise:YES];
    return path;
}
-(UIBezierPath *)arrowPath
{
    CGSize size = self.bounds.size;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat space = radius*0.5;
    
    CGPoint lineStart = CGPointMake(center.x, center.y-radius+space);
    CGPoint lineEnd = CGPointMake(center.x, center.y+radius-space);
    CGPoint arrowLTPoint =CGPointMake(center.x-10, center.y+5);
    CGPoint arrowRTPoint =CGPointMake(center.x+10, center.y+5);
    
    [path moveToPoint:lineStart];
    [path addLineToPoint:lineEnd];
    
    [path moveToPoint:arrowLTPoint];
    [path addLineToPoint:lineEnd];
    [path addLineToPoint:arrowRTPoint];
    
    
    return path;
}

-(UIBezierPath *)pencilPath
{
    
    CGPoint pencilStartPoint = self.arrowLayer.position;
    
    
    
    
    CGSize size = self.bounds.size;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat space = pencelHight;
    
    CGPoint startPoint = CGPointMake(center.x+pencelWidth, center.y+radius-space-pencilArrowH);
    
    
    CGPoint point1 = CGPointMake(startPoint.x, center.y-radius+space);
    CGPoint point2 = CGPointMake(center.x-pencelWidth, point1.y);
    CGPoint point3 =CGPointMake(point2.x, startPoint.y);
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:startPoint];
    
    [path moveToPoint:point3];
    [path addLineToPoint:CGPointMake(center.x, startPoint.y+pencilArrowH)];
    [path addLineToPoint:startPoint];
    
    return path;
}
-(UIBezierPath *)straightLinePath
{
    CGSize size = self.bounds.size;
    CGFloat halflineLen = M_PI*radius;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    
    CGPoint midPoint = CGPointMake(center.x, center.y+radius);
    CGPoint startPoint = CGPointMake(midPoint.x-halflineLen, midPoint.y);
    CGPoint endPoint = CGPointMake(midPoint.x+halflineLen, midPoint.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:midPoint];
    [path addLineToPoint:endPoint];
    return path;
}
-(UIBezierPath *)arcLinePath:(CGFloat)offset offsetY:(CGFloat)offsetY
{
    CGSize size = self.bounds.size;
    CGFloat halflineLen = M_PI*radius;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    
    CGPoint midPoint = CGPointMake(center.x, center.y+radius);
    CGPoint startPoint = CGPointMake(midPoint.x-halflineLen, midPoint.y);
    CGPoint endPoint = CGPointMake(midPoint.x+halflineLen, midPoint.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:CGPointMake(midPoint.x+offset, midPoint.y-radius-offsetY)];
    return path;
}

/// 凸弧
/// @param offset x
/// @param offsetY y
-(UIBezierPath *)convexLinePath:(CGFloat)offset
{
    CGSize size = self.bounds.size;
    CGFloat halflineLen = M_PI*radius;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    
    CGPoint midPoint = CGPointMake(center.x, center.y+radius);
    CGPoint startPoint = CGPointMake(midPoint.x-halflineLen, midPoint.y-offset*0.5);
    CGPoint endPoint = CGPointMake(midPoint.x+halflineLen, midPoint.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:CGPointMake(midPoint.x, startPoint.y-offset)];
    return path;
}

- (UIBezierPath *)concaveLinePathWithOffset:(CGFloat)offset
{
    
    CGSize size = self.bounds.size;
    CGFloat halflineLen = M_PI*radius;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    
    CGPoint midPoint = CGPointMake(center.x, center.y+radius);
    CGPoint startPoint = CGPointMake(midPoint.x-halflineLen, midPoint.y+offset*0.5);
    CGPoint endPoint = CGPointMake(midPoint.x+halflineLen, midPoint.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:CGPointMake(midPoint.x, startPoint.y+offset)];
    return path;
}
-(UIBezierPath *)pencilMovePath
{
    CGSize size = self.bounds.size;
    CGFloat halflineLen = M_PI*radius;
    
    
    
    
    
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    
    CGFloat offset = self.arrowLayer.position.y - center.y;
    
    CGPoint midPoint = CGPointMake(center.x, center.y+radius);
    
    CGPoint startPoint = CGPointMake(self.arrowLayer.position.x, self.arrowLayer.position.y-100);
    
    CGPoint endPoint = CGPointMake(midPoint.x-halflineLen+halflineLen*_progress, midPoint.y+offset-pencelHight-pencilArrowH);
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    
    CGPoint ctrPoint = CGPointMake(startPoint.x+(endPoint.x-startPoint.x)*0.6, startPoint.y-10);
    
    [path moveToPoint:startPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:ctrPoint];
    return path;
}
-(void)setProgress:(float)progress
{
    _progress = progress;
    CGSize size = self.bounds.size;
    CGFloat lineLen = M_PI*radius*2;
    CGPoint center = CGPointMake(size.width*0.5, size.height*0.5);
    CGPoint point = CGPointMake(center.x-radius+lineLen*_progress, self.arrowLayer.position.y);
//    self.arrowLayer.position=point;
    CATransform3D transform = CATransform3DMakeTranslation(progress*lineLen, 0, 0);
    self.arrowLayer.transform = CATransform3DRotate(transform, -M_PI/15, 0, 0, 1);
    self.progressLayer.strokeEnd = _progress;
}
@end
