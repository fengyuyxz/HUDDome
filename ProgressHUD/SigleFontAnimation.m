//
//  SigleFontAnimation.m
//  ProgressHUD
//
//  Created by yanxuezhou on 2021/5/26.
//

#import "SigleFontAnimation.h"
#import <CoreText/CoreText.h>
@interface SigleFontAnimation ()
@property(nonatomic,strong) CALayer * animaitonLayer;
@property(nonatomic,strong) CAShapeLayer * fontLayer;


@end

@implementation SigleFontAnimation

- (void)viewDidLoad {
    [super viewDidLoad];
    _animaitonLayer = [CALayer layer];
    _animaitonLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.animaitonLayer];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.fontLayer) {
        [self.fontLayer removeAllAnimations];
        [self.fontLayer removeFromSuperlayer];
        self.fontLayer = nil;
    }
    NSMutableArray<UIBezierPath *> * list= [self getSigleChartPath:@"得物" fontName:@"HelveticaNeue-UltraLight" fontSize:40];
    for (UIBezierPath *path in list) {
        CAShapeLayer *font=[self getShapeLayer];
        font.path = path.CGPath;
        [self.animaitonLayer addSublayer:font];
    }
}
-(CAShapeLayer *)getShapeLayer
{
    CAShapeLayer *fontLayer = [CAShapeLayer layer];
    fontLayer.frame = CGRectMake(50, 200, 300, 400);
    fontLayer.fillColor = [UIColor clearColor].CGColor;
    fontLayer.strokeColor = [UIColor blackColor].CGColor;
    fontLayer.lineWidth = 1;
    fontLayer.geometryFlipped = YES;
    fontLayer.lineJoin = kCALineCapSquare;
    fontLayer.lineCap = kCALineCapSquare;
    return fontLayer;
}
-(NSMutableArray<UIBezierPath *> *)getSigleChartPath:(NSString *)text fontName:(NSString *)fontName fontSize:(CGFloat)fontSize
{
    NSMutableArray *mArray=[NSMutableArray array];
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)fontName, fontSize, NULL);
    
    NSDictionary *att =[NSDictionary dictionaryWithObject:(__bridge  id)font forKey:(NSString *)kCTFontAttributeName];
    
    NSAttributedString *str = [[NSAttributedString alloc]initWithString:text attributes:att];
    // 获得一行字体
    CTLineRef line = CTLineCreateWithAttributedString((__bridge  CFAttributedStringRef)str);
    //返回组成一行字的字迹数组
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    for (CFIndex runIndex = 0; runIndex<CFArrayGetCount(runArray); runIndex++) {
        // 获取每一个字的字迹，并通过字迹获得对应字体
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);
        //循环每一个字迹，获取每一个字的笔画
        CGMutablePathRef letters = CGPathCreateMutable();
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
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointZero];
            [path appendPath:[UIBezierPath bezierPathWithCGPath:letters]];
            [mArray addObject:path];
        }
    }
    
    CFRelease(line);
    CFRelease(font);
    return mArray;
}

@end
