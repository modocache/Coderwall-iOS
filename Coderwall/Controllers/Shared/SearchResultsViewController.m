//
//  SearchResultsViewController.m
//  Coderwall
//
//  Created by Will on 02/03/2012.
//  Copyright (c) 2012 Bearded Apps. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "User.h"
#import "UIViewController+appDelegateUser.h"

@interface SearchResultsViewController ()

@end

@implementation SearchResultsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Get current User
    User *user = [self currentUser];
    if(user != (id)[NSNull null] && user.userName != @"" && user.userName.length != 0)
        self.navigationItem.title = [[NSString alloc] initWithString:user.userName];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //load
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults stringForKey:@"UserName"];
    [self setCurrentUser:[[User alloc] initWithUsername:userName]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserChanged" object:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
