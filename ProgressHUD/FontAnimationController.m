//
//  FontAnimationController.m
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/25.
//

#import "FontAnimationController.h"
#import <CoreText/CoreText.h>
@interface FontAnimationController ()
@property(nonatomic,strong) CAShapeLayer * pathLayer;
@property(nonatomic,strong) CALayer * animationLayer;

@end

@implementation FontAnimationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animationLayer = [CALayer layer];
    self.animationLayer.frame = CGRectMake(20.0f, 64.0f,
                                           CGRectGetWidth(self.view.layer.bounds) - 40.0f,
                                           CGRectGetHeight(self.view.layer.bounds) - 84.0f);
    [self.view.layer addSublayer:self.animationLayer];
    
    for (NSString *fontName in [UIFont familyNames]) {
//        NSLog(@"  %@  ",fontName);
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}
- (void) setupTextLayer
{
    if (self.pathLayer != nil) {
        
        [self.pathLayer removeFromSuperlayer];
        self.pathLayer = nil;
        
    }
    
    CGMutablePathRef letters = CGPathCreateMutable();
   //获取字体轨迹
    CFStringRef fontName = (__bridge  CFStringRef)[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:26].fontName;    CTFontRef font = CTFontCreateWithName(fontName, 26, NULL);
    NSDictionary *attr = [NSDictionary dictionaryWithObject:(__bridge id)(font) forKey:(NSString *)kCTFontAttributeName];
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:@"字体动画" attributes:attr];
    // 获得一行字体
    CTLineRef line = CTLineCreateWithAttributedString((__bridge  CFAttributedStringRef)string);
    //返回组成一行字的字迹数组
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    
    //循环遍历每一个字迹
    for (CFIndex runIndex=0; runIndex<CFArrayGetCount(runArray); runIndex++) {
       // 获取每一个字的字迹，并通过字迹获得对应字体
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        //循环每一个字迹，获取每一个字的笔画
        for (CFIndex runGlyphIndex = 0; runGlyphIndex < CTRunGetGlyphCount(run); runGlyphIndex++) {
            //获取字的笔画轨迹
            CFRange thisGlyphRange = CFRangeMake(runGlyphIndex, 1);
            CGGlyph glyph;
            CGPoint position;
            CTRunGetGlyphs(run, thisGlyphRange, &glyph);
            CTRunGetPositions(run, thisGlyphRange, &position);
            
            //获取每一笔的外部轨迹
            {
                CGPathRef letter = CTFontCreatePathForGlyph(runFont, glyph, NULL);
                CGAffineTransform t = CGAffineTransformMakeTranslation(position.x, position.y);
                CGPathAddPath(letters, &t, letter);
                CGPathRelease(letter);
            }
        }
    }
    
    
    CFRelease(line);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
    CFRelease(font);
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.frame = self.animationLayer.bounds;
    pathLayer.bounds = CGPathGetBoundingBox(path.CGPath);
    //pathLayer.backgroundColor = [[UIColor yellowColor] CGColor];
    pathLayer.geometryFlipped = YES;
    pathLayer.path = path.CGPath;
    pathLayer.strokeColor = [[UIColor blackColor] CGColor];
    pathLayer.fillColor = nil;
    pathLayer.lineWidth = 1.0f;
    pathLayer.lineJoin = kCALineJoinBevel;
    
    [self.animationLayer addSublayer:pathLayer];
    
    self.pathLayer = pathLayer;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setupTextLayer];
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 14;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    
    CABasicAnimation *Animation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    Animation.duration = 14;
    Animation.beginTime = 0.15;
    Animation.fromValue = [NSNumber numberWithFloat:0.0f];
    Animation.toValue = [NSNumber numberWithFloat:1.0f];


    
    CAAnimationGroup *group=[CAAnimationGroup animation];
    group.animations=@[pathAnimation,Animation];
    group.duration = 14.15;
    [self.pathLayer addAnimation:group forKey:nil];
}

@end
