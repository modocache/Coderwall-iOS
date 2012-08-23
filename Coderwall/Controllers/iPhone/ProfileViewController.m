//
//  ProfileViewController.m
//  Coderwall
//
//  Created by Will on 18/02/2012.
//  Copyright (c) 2012 Bearded Apps. All rights reserved.
//


#import "ProfileViewController.h"

#import "UIViewController+appDelegateUser.h"
#import "User.h"

#import "DejalActivityView.h"
#import "EGORefreshTableHeaderView.h"


@interface ProfileViewController () <UIScrollViewDelegate, EGORefreshTableHeaderDelegate>
@property (nonatomic, weak) IBOutlet UILabel *fullName;
@property (nonatomic, weak) IBOutlet UILabel *summary;
@property (nonatomic, weak) IBOutlet UIImageView *avatar;
@property (nonatomic, weak) IBOutlet UIImageView *profileBg;
@property (nonatomic, weak) IBOutlet UIScrollView *profileScrollView;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL reloading;
- (void)doneLoadingTableViewData;
@end


@implementation ProfileViewController

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadView)
                                                     name:@"UserChanged"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetReloading)
                                                     name:@"ConnectionError"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resetReloading)
                                                     name:@"ResponseError"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *profileBackgroundImage = [UIImage imageNamed:@"PanelBg.png"];
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsMake(15.0f, 0.0f, 15.0f, 0.0f);
    profileBackgroundImage = [profileBackgroundImage resizableImageWithCapInsets:imageEdgeInsets];
    self.profileBg.image = profileBackgroundImage;

    if (!self.refreshHeaderView) {
        CGRect headerRect = CGRectMake(0.0f,
                                       0.0f - self.profileScrollView.bounds.size.height,
                                       self.profileScrollView.frame.size.width,
                                       self.profileScrollView.bounds.size.height);
        self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:headerRect];
        self.refreshHeaderView.delegate = self;
        self.refreshHeaderView.backgroundColor = [UIColor clearColor];
        [self.profileScrollView addSubview:self.refreshHeaderView];
        
    }
    
    [self.refreshHeaderView refreshLastUpdatedDate];
    [self loadData];
}

- (void)loadData
{    
    User *user = [self currentUser];
    if (user.userName.length > 0) {
        self.fullName.text = user.name;

        NSString *summaryDetails = @"";
        if (user.title.length > 0 && user.company.length > 0) {
            NSString *formatString = NSLocalizedString(@"%@ at %@",
                                                       @"User summary, {title} at {company}.");
            summaryDetails = [NSString stringWithFormat:formatString, user.title, user.company];
        } else if (user.title.length > 0) {
            summaryDetails = user.title;
        } else if (user.company.length > 0) {
            summaryDetails = user.company;
        }
        
        if (summaryDetails.length > 0) {
            summaryDetails = [summaryDetails stringByAppendingString:@"\n"];
        }
        summaryDetails = [summaryDetails stringByAppendingString:user.location];
        
        CGSize maximumSize = CGSizeMake(self.summary.frame.size.width, 80.0f);
        UIFont *summaryFont = [UIFont fontWithName:@"Helvetica" size:14.0f];
        CGSize summaryStringSize = [summaryDetails sizeWithFont:summaryFont 
                                              constrainedToSize:maximumSize 
                                                  lineBreakMode:self.summary.lineBreakMode];
        
        self.summary.text = summaryDetails;
        CGRect summaryRect = self.summary.frame;
        self.summary.frame = CGRectMake(summaryRect.origin.x,
                                        summaryRect.origin.y,
                                        summaryStringSize.width,
                                        summaryStringSize.height);
        
        [self.avatar setImage:[UIImage imageNamed:@"defaultavatar.png"]];
        if(user.thumbnail != nil){
            [DejalBezelActivityView activityViewForView:self.avatar];
            dispatch_queue_t downloadQueue = dispatch_queue_create("avatar downloader", NULL);
            dispatch_async(downloadQueue,^{
                UIImage *userAvatar = [user getAvatar];
                [self performSelectorOnMainThread:@selector(setUserAvatar:) 
                                       withObject:userAvatar
                                    waitUntilDone:YES];
            });
            dispatch_release(downloadQueue);
        }
    } else {
        [self.summary setText:@""];
        [self.fullName setText:@""];
        [self.avatar setImage:[UIImage imageNamed:@"defaultavatar.png"]];
    }
}

- (void)setUserAvatar:(UIImage *)userAvatar
{
    if (userAvatar) {
        [self.avatar setImage:userAvatar];
    } else {
        [self.avatar setImage:[UIImage imageNamed:@"defaultavatar.png"]];
    }

    [DejalActivityView removeView];
}

-(void)reloadView
{
    self.reloading = NO;
    [self loadData];
}

-(void)resetReloading
{
    [self doneLoadingTableViewData];
    self.reloading = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}


#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    self.reloading = YES;
    [[self currentUser] refresh];
    [self doneLoadingTableViewData];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.reloading; // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed
}


#pragma mark - Internal Methods

- (void)doneLoadingTableViewData
{
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.profileScrollView];
}

@end
