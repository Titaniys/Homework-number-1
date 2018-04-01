//
//  Themes.m
//  FirstProjectTinkov
//
//  Created by Вадим Чистяков on 22.03.18.
//  Copyright © 2018 Вадим Чистяков. All rights reserved.
//

#import "Themes.h"

@implementation Themes

@synthesize themeOne = _themeOne;
@synthesize themeTwo = _themeTwo;
@synthesize themeThree = _themeThree;

- (instancetype)init
{
	self = [super init];
	if (self) {
		_themeOne = [UIColor blackColor];
		_themeTwo = [UIColor grayColor];
		_themeThree = [UIColor brownColor];
	}
	return self;
}

- (void)setThemeOne:(UIColor *)themeOne{
	if (themeOne != _themeOne) {
		[themeOne retain];
		[_themeOne release];
		_themeOne = themeOne;
	}
}

- (UIColor *)themeOne {
	return _themeOne;
}

- (void)setThemeTwo:(UIColor *)themeTwo{
	if (themeTwo != _themeTwo) {
		[themeTwo retain];
		[_themeTwo release];
		_themeTwo = themeTwo;
	}
}

- (UIColor *)themeTwo {
	return _themeTwo;
}

- (void)setThemeThree:(UIColor *)themeThree{
	if (themeThree != _themeThree) {
		[themeThree retain];
		[_themeThree release];
		_themeThree = themeThree;
	}
}

- (UIColor *)themeThree {
	return _themeThree;
}

@end
