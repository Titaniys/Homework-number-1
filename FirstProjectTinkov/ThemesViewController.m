//
//  ThemesViewController.m
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 22.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

#import "ThemesViewController.h"
#import "Themes.h"


@interface ThemesViewController ()

@property (nonatomic, retain) Themes *model;

@end

@implementation ThemesViewController

@synthesize model = _model;

- (void)viewDidLoad {
	
	[super viewDidLoad];
	self.model = [Themes new];
}

- (IBAction)themeButtons:(id)sender {
	
	UIButton *selectedButton = (id)sender;
	
	if ([selectedButton isEqual:self.themeOneButton]) {
		[self changeBackgroundColor:self.model.themeOne];
	} else if ([selectedButton isEqual:self.themeTwoButton]) {
		[self changeBackgroundColor:self.model.themeTwo];
	} else {
		[self changeBackgroundColor:self.model.themeThree];
	}
}
- (IBAction)exitThemesVC:(id)sender {
	[self dismissViewControllerAnimated:YES completion:^{
	}];
}

- (void)changeBackgroundColor:(UIColor *)color {
	self.view.backgroundColor = color;
	
	[self.delegate themesViewController:self didSelectTheme:color];
}

#pragma mark - Setter and Getter

- (void)setModel:(Themes *)model{
	if (model != _model) {
		[model retain];
		[_model release];
		_model = model;
	}
}

- (Themes *)model{
	return _model;
}

- (void)dealloc {
	[_model release];
	[_themeOneButton release];
	[_themeTwoButton release];
	[_themeThreeButton release];
	[super dealloc];
}

@end
