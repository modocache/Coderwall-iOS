//
//  SettingsViewController.h
//  Coderwall
//
//  Created by Will on 25/02/2012.
//  Copyright (c) 2012 Bearded Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    IBOutlet UIImageView *settingsBg;   
    IBOutlet UITextField *userNameInput;
}
-(IBAction) userNameChanged: (id) sender;
@end
