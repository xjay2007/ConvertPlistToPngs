//
//  AppDelegate.h
//  ConvertPlistToPngs_v2
//
//  Created by JunXie on 14-7-1.
//  Copyright xiejun 2014年. All rights reserved.
//

#import "cocos2d.h"

@interface ConvertPlistToPngs_v2AppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	CCGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet CCGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
