//
//  GuideController.m
//  magicworld
//
//  Created by 苏智 on 16/5/10.
//  Copyright © 2016年 Suzic. All rights reserved.
//

#import "GuideController.h"

@interface GuideController ()

@property (strong, nonatomic) IBOutlet UIView *guideTalk;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideTalkHeight;

@property (strong, nonatomic) IBOutlet UIView *guideArea;
@property (strong, nonatomic) IBOutlet UIImageView *guideAvator;
@property (strong, nonatomic) IBOutlet UILabel *guideText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *guideTextLeading;

@property (strong, nonatomic) IBOutlet UIButton *guideConfirmButton;
@property (strong, nonatomic) IBOutlet UIButton *guideBeast;

@end

@implementation GuideController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.guideTalkHeight.constant = kScreenWidth < kScreenHeight ? 140.0f : 80.0f;
    self.guideTextLeading.constant = kScreenWidth < kScreenHeight ? 10.0f : 80.0f;

    self.guideTalk.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, 200.0f);
    self.guideArea.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, 200.0f);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showGuideInformation:) name:NotiShowGuideInfo object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    self.guideTalkHeight.constant = size.width < size.height ? 140.0f : 80.0f;
    self.guideTextLeading.constant = size.width < size.height ? 10.0f : 80.0f;

    [[NSNotificationCenter defaultCenter] postNotificationName:NotiShowGuideInfo object:(size.width < size.height ?
                                                                                         @"侬可以把屏幕横过来看嘛，这样俺就可说更多字了～\n没事儿记得摸摸俺的头o(>_<)o"
                                                                                         : @"嗯，这样不错，俺的位置不会太碍事儿～\n如果没什么事儿，就摸摸俺的头o(>_<)o")];
}

- (void)showGuide:(BOOL)show withInformation:(NSString *)info completion:(void (^ __nullable)(BOOL finished))completion
{
    [UIView animateWithDuration:0.5f animations:^{
        self.guideText.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (!finished) return;
        [self.guideText setText:info];
        [UIView animateWithDuration:0.5 animations:^{
            self.guideText.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if (!finished) return;
            [UIView animateWithDuration:0.5f
                                  delay:show ? 0.0f : 1.5f
                                options:UIViewAnimationOptionTransitionNone
                             animations:^{
                                 self.guideTalk.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, 200.0f);
                                 self.guideArea.transform = show ? CGAffineTransformIdentity : CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0f, 200.0f);
                             } completion:completion];
        }];
    }];
}

- (IBAction)pressAvator:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button == self.guideConfirmButton)
        [self showGuide:NO withInformation:@"嗯，那么再见了吆～" completion:nil];
    else if (button == self.guideBeast)
        [self showGuide:YES withInformation:@"往哪儿摸呢？\n我是说摸、摸、俺、的、头！……说不清了真是的～" completion:nil];
}

- (void)showGuideInformation:(NSNotification *)notification
{
    NSString *stringInfo = notification.object;
    [self showGuide:YES withInformation:stringInfo completion:nil];
}

@end
