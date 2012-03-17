//
//  ProfileViewController.m
//  Coderwall
//
//  Created by Will on 18/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegateProtocol.h"
#import "User.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (User*) currentUser;
{
	id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
	User* currentUser = (User*) theDelegate.currentUser;
	return currentUser;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView) name:@"UserChanged" object:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [profileBg setImage:[[UIImage imageNamed:@"PanelBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 0, 15, 0)]];
    User *user = [self currentUser];
    if(user != (id)[NSNull null] && user.userName != @"" && user.userName.length != 0){
        [fullName setText:[NSString stringWithFormat:user.name]];
        NSString *summaryDetails = [[NSString alloc] initWithString:@""];
        
        if(user.title != (id)[NSNull null])
            summaryDetails = [summaryDetails stringByAppendingString:user.title];
        
        if(summaryDetails.length != 0 && user.company != (id)[NSNull null] && user.company.length != 0)
            summaryDetails = [summaryDetails stringByAppendingString:@" at "];
        
        if(user.company != (id)[NSNull null])
            summaryDetails = [summaryDetails stringByAppendingString:user.company];
        
        if(summaryDetails.length != 0)
            summaryDetails = [summaryDetails stringByAppendingString:@"\n"];
        
        summaryDetails = [summaryDetails stringByAppendingString:user.location];       
        
        CGSize maximumSize = CGSizeMake(260, 80);
        UIFont *summaryFont = [UIFont fontWithName:@"Helvetica" size:14];
        CGSize summaryStringSize = [summaryDetails sizeWithFont:summaryFont 
                                              constrainedToSize:maximumSize 
                                                  lineBreakMode:summary.lineBreakMode];
        
        [summary setText:summaryDetails];
        [summary setFrame:CGRectMake(30, 265, 260, summaryStringSize.height)];
        [avatar setImage:nil];
        dispatch_queue_t downloadQueue = dispatch_queue_create("avatar downloader", NULL);
        dispatch_async(downloadQueue,^{
            UIImage *userAvatar = [user getAvatar];
            dispatch_async(dispatch_get_main_queue(), ^{
                [avatar setImage:userAvatar];
            });
        });
        dispatch_release(downloadQueue);
        
        if (_refreshHeaderView == nil) {
            
            EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - profileScrollView.bounds.size.height, profileScrollView.frame.size.width, profileScrollView.bounds.size.height)];
            view.delegate = self;
            view.backgroundColor = [UIColor clearColor];
            [profileScrollView addSubview:view];
            _refreshHeaderView = view;
            
        }
        
        //  update the last update date
        [_refreshHeaderView refreshLastUpdatedDate];
        
    } else {
        [summary setText:@""];
        [fullName setText:@""];
        [avatar setImage:Nil];
    }
    
    
}

-(void)reloadView
{
    _reloading = NO;
    [self viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:profileScrollView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
    _reloading = YES;
	User *user = [self currentUser];
    [user refresh];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
	
}

- (BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

@end
