//
//  GuideController.m
//  magicworld
//
//  Created by 苏智 on 16/5/10.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "GuideController.h"

@interface GuideController ()

@property (weak, nonatomic) UINavigationController *frameNavi;

@property (assign, nonatomic) BOOL guideInShown;
@property (assign, nonatomic) BOOL inLandMode;

@property (strong, nonatomic) IBOutlet UIView *guideTalk;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideTalkHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideTalkLeading;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideTalkTailing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideTalkBottom;

@property (strong, nonatomic) IBOutlet UILabel *guideText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideTextTailing;

@property (strong, nonatomic) IBOutlet UIView *guideArea;
@property (strong, nonatomic) IBOutlet UIImageView *guideAvator;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideAreaTailing;

@property (strong, nonatomic) IBOutlet UIButton *guideConfirmButton;
@property (strong, nonatomic) IBOutlet UIButton *guideBeast;

@end

@implementation GuideController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _guideInShown = YES;
    self.guideInShown = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGuideInformation:) name:NotiShowGuideInfo object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.inLandMode = (kScreenWidth > kScreenHeight);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.inLandMode = (size.width > size.height);
    
    if (self.guideInShown)
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiShowGuideInfo
                                                            object:(size.width < size.height ?
                                                                    @"侬可以把屏幕横过来看嘛，这样俺就可说更多字了～\n没事儿记得摸摸俺的头o(>_<)o"
                                                                    : @"嗯，不错，俺的位置不会太碍事儿～\n没什么事儿，就摸摸俺的头o(>_<)o")];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.frameNavi.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.frameNavi.topViewController;
}

#pragma mark - Properties & Inner fucntions

- (void)setInLandMode:(BOOL)inLandMode
{
    if (_inLandMode == inLandMode)
        return;
    _inLandMode = inLandMode;
    
    self.guideTextTailing.constant = inLandMode ? 158.0f : 150.0f;
    self.guideAreaTailing.constant = inLandMode ? 8.0f : -20.0f;
    
    self.guideTalkLeading.constant = inLandMode ? 100.0f : 0.0f;
    self.guideTalkTailing.constant = inLandMode ? 8.0f : 0.0f;
    self.guideTalkHeight.constant = inLandMode ? 88.0f : 148.0f;
    self.guideTalkBottom.constant = inLandMode ? 8.0f : 0.0f;
    self.guideTalk.layer.cornerRadius = inLandMode ? 16.0f : 0.0f;
}

- (void)setGuideInShown:(BOOL)guideInShown
{
//    if (_guideInShown == guideInShown)
//        return;
    _guideInShown = guideInShown;
    
    self.guideTalk.transform = _guideInShown ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, 320.0f);
    self.guideArea.transform = _guideInShown ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, 320.0f);
    
    if (!_guideInShown)
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiHideGuideInfo object:nil];
}

- (void)showGuide:(BOOL)show withInformation:(NSString *)info completion:(void (^)(BOOL finished))completion
{
    // 第一层动画 淡出之前的文本
    [UIView animateWithDuration:0.5f
                     animations:^{ self.guideText.alpha = 0.0f; }
                     completion:^(BOOL finished)
     {
         if (!finished) return;
         [self.guideText setText:info];
         // 第二层动画 淡入新文本
         [UIView animateWithDuration:0.5f
                          animations:^{ self.guideText.alpha = 1.0f; }
                          completion:^(BOOL finished)
          {
              if (!finished) return;
              // 第三层动画 根据显示还是隐藏执行界面切换动画。对于隐藏的情况，延迟一段时间等用户看完新文本后再执行动画
              [UIView animateWithDuration:0.5f
                                    delay:show ? 0.0f : 1.0f
                                  options:UIViewAnimationOptionTransitionNone
                               animations:^{
                                   self.guideInShown = show;
                               }
                               completion:completion];
          }];
     }];
}

#pragma mark - User operations

- (void)showGuideInformation:(NSNotification *)notification
{
    NSString *stringInfo = notification.object;
    [self showGuide:YES withInformation:stringInfo completion:nil];
}

- (IBAction)pressAvator:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button == self.guideConfirmButton)
        [self showGuide:NO withInformation:@"嗯，那么再见了吆～" completion:nil];
    else if (button == self.guideBeast)
        [self showGuide:YES withInformation:@"往哪儿摸呢？\n我是说摸、摸、俺、的、头！……说不清了真是的～" completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toFrame"])
        self.frameNavi = segue.destinationViewController;
}

@end
