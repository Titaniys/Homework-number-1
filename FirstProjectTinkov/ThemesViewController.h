//
//  ThemesViewController.h
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 22.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Themes;
@class ThemesViewController;

@protocol ThemesViewControllerDelegate <NSObject>

@required
-(void)themesViewController:(ThemesViewController *)controller
			 didSelectTheme:(UIColor *)selectedTheme;

@end


@interface ThemesViewController : UIViewController

@property (nonatomic, assign) id<ThemesViewControllerDelegate> delegate;
@property (nonatomic, retain, readonly) Themes *model;

@property (retain, nonatomic) IBOutlet UIButton *themeOneButton;
@property (retain, nonatomic) IBOutlet UIButton *themeTwoButton;
@property (retain, nonatomic) IBOutlet UIButton *themeThreeButton;

@end
