#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define Notify_Call "com.ichitaso.opa334.changed"

BOOL isBirthdayMessageDisplayed = NO;
UIWindow *keyWindow = nil;
UILabel *label = nil;

@interface SpringBoard : UIApplication
+ (id)sharedApplication;
- (void)checkAndDisplayLabel;
- (void)setupBirthdayLabel:(UILabel *)label;
- (void)applyRandomEffectToKeyWindow:(UIWindow *)window;
- (void)addSparkleEffectToKeyWindow:(UIWindow *)window;
- (void)addBalloonEffectToKeyWindow:(UIWindow *)window;
@end

@interface SBFTouchPassThroughView : UIView
@end

%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    %orig;
    // keyWindowの取得
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    #pragma clang diagnostic pop
    if (!keyWindow) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                keyWindow = scene.windows.firstObject;
                break;
            }
        }
    }

    // ダークモード変更時の通知を追加
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAndDisplayLabel)
                                                 name:@Notify_Call
                                               object:label];

    [self checkAndDisplayLabel];
}
// ラベルがない時にシェイクすると表示
%new
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        if (label == nil || ![keyWindow.subviews containsObject:label]) {
            [self checkAndDisplayLabel];
        }
    }
}
// 現在の日付を取得
%new
- (void)checkAndDisplayLabel {
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:currentDate];
    NSInteger month = [components month];
    NSInteger day = [components day];

    // 6月28日から6月30日の間にラベルを表示
    if (month == 6 && day >= 28 && day <= 30) {
        [self setupBirthdayLabel:label];
    } else {
        for (label in keyWindow.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                [label removeFromSuperview];
            }
        }
    }
}
// ラベルの作成と設定
%new
- (void)setupBirthdayLabel:(UILabel *)label {
    for (label in keyWindow.subviews) {
        if ([label isKindOfClass:[UILabel class]]) {
            [label removeFromSuperview];
        }
    }

    isBirthdayMessageDisplayed = NO;
    label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 50)];
    label.text = @"June 29 ❓";
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = YES;
    label.layer.cornerRadius = 10.0;  // 角丸にする半径
    label.clipsToBounds = YES;  // 角丸を効かせるために必要

    // タップジェスチャーの追加
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [label addGestureRecognizer:tapGesture];
    // パンジェスチャーの追加
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [label addGestureRecognizer:panGesture];
    // ロングプレスジェスチャーの追加
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 2.0; // 2 sec
    [label addGestureRecognizer:longPressGesture];

    // iOS 13 - 16
    UIUserInterfaceStyle userInterfaceStyle = [UIScreen mainScreen].traitCollection.userInterfaceStyle;
    if (userInterfaceStyle == UIUserInterfaceStyleDark) {
        label.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];  // Dark Mode
        label.textColor = [UIColor whiteColor];
    } else {
        label.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];  // Light Mode
        label.textColor = [UIColor blackColor];
    }
    [keyWindow addSubview:label];
}
// タップジェスチャー
%new
- (void)handleTap:(UITapGestureRecognizer *)gesture {
    UILabel *label = (UILabel *)gesture.view;

    if (isBirthdayMessageDisplayed) {
        label.text = @"June 29 ❓";
    } else {
        label.text = @"Happy Birthday, opa334! 🎉";
    }

    isBirthdayMessageDisplayed = !isBirthdayMessageDisplayed;

    // Haptic feedback
    UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [generator impactOccurred];

    // バウンスアニメーション
    [UIView animateWithDuration:0.2 animations:^{
        label.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            label.transform = CGAffineTransformIdentity;
        }];
    }];

    // ランダムのエフェクトを追加
    if (isBirthdayMessageDisplayed) {
        [self applyRandomEffectToKeyWindow:keyWindow];
    }
}
// パンジェスチャー
%new
- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *label = gesture.view;
    CGPoint translation = [gesture translationInView:label.superview];
    label.center = CGPointMake(label.center.x + translation.x, label.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:label.superview];
}
// LongPress
%new
- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        for (label in keyWindow.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                [label removeFromSuperview];
            }
        }
    }
}
// ランダムにエフェクトを適用
%new
- (void)applyRandomEffectToKeyWindow:(UIWindow *)window {
    NSUInteger randomEffect = arc4random_uniform(2);
    
    if (randomEffect == 0) {
        [self addSparkleEffectToKeyWindow:window];
    } else {
        [self addBalloonEffectToKeyWindow:window];
    }
}
// 光のエフェクト
%new
- (void)addSparkleEffectToKeyWindow:(UIWindow *)window {
    CGFloat screenWidth = CGRectGetWidth(window.bounds);
    CGFloat screenHeight = CGRectGetHeight(window.bounds);
    CGFloat sparkleSize = 100.0;
    
    // 光のエフェクトを描画するためのビューを作成
    UIView *sparkleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    sparkleView.backgroundColor = [UIColor clearColor];
    sparkleView.userInteractionEnabled = NO;
    [window addSubview:sparkleView];
    
    // 光のパーティクルをランダムに配置する
    for (int i = 0; i < 50; i++) {
        CGFloat sparkleX = arc4random_uniform(screenWidth);
        CGFloat sparkleY = arc4random_uniform(screenHeight);
        UIView *sparkle = [[UIView alloc] initWithFrame:CGRectMake(sparkleX, sparkleY, sparkleSize, sparkleSize)];
        
        // HSLカラーを使用してカラフルに
        CGFloat hue = arc4random_uniform(256) / 255.0; // 0.0から1.0の範囲で色相をランダムに設定
        CGFloat saturation = 1.0; // 彩度を高く設定
        CGFloat brightness = 1.0; // 明度を最大に設定
        sparkle.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.5];
        sparkle.layer.cornerRadius = sparkleSize / 2.0;
        [sparkleView addSubview:sparkle];
        
        // アニメーションを追加
        [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            sparkle.transform = CGAffineTransformMakeScale(0.01, 0.01);
        } completion:^(BOOL finished) {
            [sparkle removeFromSuperview];
        }];
    }
}
// 風船のアニメーション
%new
- (void)addBalloonEffectToKeyWindow:(UIWindow *)window {
    CGFloat screenWidth = CGRectGetWidth(window.bounds);
    CGFloat screenHeight = CGRectGetHeight(window.bounds);
    NSInteger numberOfBalloons = 30; // 風船の数
    CGFloat minBalloonSize = 40.0; // 風船の最小サイズ
    CGFloat maxBalloonSize = 80.0; // 風船の最大サイズ
    
    for (int i = 0; i < numberOfBalloons; i++) {
        // 風船のランダムなサイズを決定
        CGFloat balloonSize = minBalloonSize + arc4random_uniform(maxBalloonSize - minBalloonSize);
        
        // 風船の開始位置を画面の下部にランダムに配置
        CGFloat balloonX = arc4random_uniform(screenWidth - balloonSize);
        CGFloat balloonY = screenHeight;
        UIView *balloon = [[UIView alloc] initWithFrame:CGRectMake(balloonX, balloonY, balloonSize, balloonSize)];
        
        // HSLカラーを使用して風船の色をランダムに設定
        CGFloat hue = arc4random_uniform(256) / 255.0;
        CGFloat saturation = 1.0;
        CGFloat brightness = 1.0;
        balloon.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:0.8];
        balloon.layer.cornerRadius = balloonSize / 2.0;
        [window addSubview:balloon];
        
        // 風船のアニメーション（下から上に移動）
        CGFloat endY = -balloonSize; // 画面上部外に移動
        NSTimeInterval duration = 1.5 + arc4random_uniform(2000) / 1000.0; // アニメーション時間をランダムに設定
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            balloon.frame = CGRectMake(balloon.frame.origin.x, endY, balloon.frame.size.width, balloon.frame.size.height);
        } completion:^(BOOL finished) {
            [balloon removeFromSuperview];
        }];
    }
}
%end

%hook SBFTouchPassThroughView
// traitCollection の変更時に呼ばれるメソッド
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    %orig;

    UIUserInterfaceStyle currentStyle = self.traitCollection.userInterfaceStyle;
    UIUserInterfaceStyle previousStyle = previousTraitCollection.userInterfaceStyle;
    if (currentStyle != previousStyle) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@Notify_Call object:label];
    }
}
%end

%ctor {
    %init;
    // 初回のチェックを実行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[%c(SpringBoard) sharedApplication] checkAndDisplayLabel];
    });

    // タイマーを使用して1日ごとにラベルの表示状態をチェック
    NSTimeInterval secondsInDay = 24 * 60 * 60;
    [NSTimer scheduledTimerWithTimeInterval:secondsInDay
                                     repeats:YES
                                       block:^(NSTimer * _Nonnull timer) {
         [[%c(SpringBoard) sharedApplication] checkAndDisplayLabel];
    }];
}
