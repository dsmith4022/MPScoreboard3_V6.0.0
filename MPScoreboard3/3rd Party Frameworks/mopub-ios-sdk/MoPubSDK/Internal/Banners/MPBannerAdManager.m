//
//  MPBannerAdManager.m
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

#import "MPBannerAdManager.h"
#import "MPAdServerURLBuilder.h"
#import "MPAdTargeting.h"
#import "MPCoreInstanceProvider.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPError.h"
#import "MPTimer.h"
#import "MPConstants.h"
#import "MPLogging.h"
#import "MPStopwatch.h"
#import "MPViewabilityManager.h"
#import "NSMutableArray+MPAdditions.h"
#import "NSDate+MPAdditions.h"
#import "NSError+MPAdditions.h"

@interface MPBannerAdManager ()

@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPInlineAdAdapter *onscreenAdapter;
@property (nonatomic, strong) MPInlineAdAdapter *requestingAdapter;
@property (nonatomic, strong) UIView *requestingAdapterAdContentView;
@property (nonatomic, strong) MPAdConfiguration *requestingConfiguration;
@property (nonatomic, strong) MPAdTargeting *targeting;
@property (nonatomic, strong) NSMutableArray<MPAdConfiguration *> *remainingConfigurations;
@property (nonatomic, strong) MPTimer *refreshTimer;
@property (nonatomic, strong) NSURL *mostRecentlyLoadedURL; // ADF-4286: avoid infinite ad reloads
@property (nonatomic, assign) BOOL adActionInProgress;
@property (nonatomic, assign) BOOL automaticallyRefreshesContents;
@property (nonatomic, assign) BOOL hasRequestedAtLeastOneAd;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, strong) MPStopwatch *loadStopwatch;

- (void)loadAdWithURL:(NSURL *)URL;
- (void)applicationWillEnterForeground;
- (void)scheduleRefreshTimer;
- (void)refreshTimerDidFire;

@end

@implementation MPBannerAdManager

- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;

        self.communicator = [[MPAdServerCommunicator alloc] initWithDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];

        self.automaticallyRefreshesContents = YES;
        self.currentOrientation = MPInterfaceOrientation();
        
        _loadStopwatch = MPStopwatch.new;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.communicator cancel];
    [self.communicator setDelegate:nil];

    [self.refreshTimer invalidate];
}

- (BOOL)loading
{
    return self.communicator.loading || self.requestingAdapter;
}

- (void)loadAdWithTargeting:(MPAdTargeting *)targeting
{
    MPLogAdEvent(MPLogEvent.adLoadAttempt, self.delegate.adUnitId);
    
    if (!self.hasRequestedAtLeastOneAd) {
        self.hasRequestedAtLeastOneAd = YES;
    }
    
    if (self.loading) {
        MPLogEvent([MPLogEvent error:NSError.adAlreadyLoading message:nil]);
        return;
    }

    self.targeting = targeting;
    [self loadAdWithURL:nil];
}

- (void)forceRefreshAd
{
    [self loadAdWithURL:nil];
}

- (void)applicationWillEnterForeground
{
    if (self.automaticallyRefreshesContents && self.hasRequestedAtLeastOneAd) {
        [self loadAdWithURL:nil];
    }
}

- (void)applicationDidEnterBackground
{
    [self pauseRefreshTimer];
}

- (void)pauseRefreshTimer
{
    if ([self.refreshTimer isValid]) {
        [self.refreshTimer pause];
    }
}

- (void)resumeRefreshTimer
{
    if ([self.refreshTimer isValid]) {
        [self.refreshTimer resume];
    }
}

- (void)stopAutomaticallyRefreshingContents
{
    self.automaticallyRefreshesContents = NO;

    [self pauseRefreshTimer];
}

- (void)startAutomaticallyRefreshingContents
{
    self.automaticallyRefreshesContents = YES;

    if ([self.refreshTimer isValid]) {
        [self.refreshTimer resume];
    } else if (self.refreshTimer) {
        [self scheduleRefreshTimer];
    }
}

- (void)loadAdWithURL:(NSURL *)URL
{
    URL = [URL copy]; //if this is the URL from the requestingConfiguration, it's about to die...
    // Cancel the current request/requesting adapter
    self.requestingConfiguration = nil;
    self.requestingAdapter = nil;
    self.requestingAdapterAdContentView = nil;

    [self.communicator cancel];

    URL = (URL) ? URL : [MPAdServerURLBuilder URLWithAdUnitID:[self.delegate adUnitId] targeting:self.targeting];

    self.mostRecentlyLoadedURL = URL;
    
    [self.communicator loadURL:URL];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    self.currentOrientation = orientation;
    [self.requestingAdapter rotateToOrientation:orientation];
    [self.onscreenAdapter rotateToOrientation:orientation];
}

- (BOOL)isMraidAd
{
    return self.requestingConfiguration.isMraidAd;
}

#pragma mark - Internal

- (void)scheduleRefreshTimer
{
    [self.refreshTimer invalidate];
    NSTimeInterval timeInterval = self.requestingConfiguration ? self.requestingConfiguration.refreshInterval : DEFAULT_BANNER_REFRESH_INTERVAL;

    if (self.automaticallyRefreshesContents && timeInterval > 0) {
        __typeof__(self) __weak weakSelf = self;
        self.refreshTimer = [MPTimer timerWithTimeInterval:timeInterval repeats:NO block:^(MPTimer * _Nonnull timer) {
            __typeof__(self) strongSelf = weakSelf;
            [strongSelf refreshTimerDidFire];
        }];
        
        [self.refreshTimer scheduleNow];
        MPLogDebug(@"Scheduled the autorefresh timer to fire in %.1f seconds (%p).", timeInterval, self.refreshTimer);
    }
}

- (void)refreshTimerDidFire
{
    if (!self.loading) {
        // Instead of reusing the existing `MPAdTargeting` that is potentially outdated, ask the
        // delegate to provide the `MPAdTargeting` so that it's the latest.
        [self loadAdWithTargeting:self.delegate.adTargeting];
    }
}

- (void)fetchAdWithConfiguration:(MPAdConfiguration *)configuration {
    MPLogInfo(@"Banner ad view is fetching ad type: %@", configuration.adType);
    
    if (configuration.adUnitWarmingUp) {
        MPLogInfo(kMPWarmingUpErrorLogFormatWithAdUnitID, self.delegate.adUnitId);
        [self didFailToLoadAdapterWithError:[NSError errorWithCode:MOPUBErrorAdUnitWarmingUp]];
        return;
    }
    
    if ([configuration.adType isEqualToString:kAdTypeClear]) {
        MPLogInfo(kMPClearErrorLogFormatWithAdUnitID, self.delegate.adUnitId);
        [self didFailToLoadAdapterWithError:[NSError errorWithCode:MOPUBErrorNoInventory]];
        return;
    }
    
    // Notify Ad Server of the ad fetch attempt. This is fire and forget.
    [self.communicator sendBeforeLoadUrlWithConfiguration:configuration];
    
    // Start the stopwatch for the adapter load.
    [self.loadStopwatch start];
    
    if (configuration.adapterClass == nil) {
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }

    Class<MPAdAdapter> adapterClass = (Class<MPAdAdapter>)(configuration.adapterClass);
    id<MPAdAdapter> adapter = [[adapterClass class] new];
    
    if (![adapter isKindOfClass:[MPInlineAdAdapter class]]) {
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }
    
    self.requestingAdapter = (MPInlineAdAdapter *)adapter;
    if (self.requestingAdapter == nil) {
        [self adapter:nil didFailToLoadAdWithError:nil];
        return;
    }
    
    self.requestingAdapter.adUnitId = self.adUnitId;
    self.requestingAdapter.adapterDelegate = self;
    
    [self.requestingAdapter getAdWithConfiguration:configuration targeting:self.targeting];
}

#pragma mark - <MPAdServerCommunicatorDelegate>

- (void)communicatorDidReceiveAdConfigurations:(NSArray<MPAdConfiguration *> *)configurations
{
    self.remainingConfigurations = [configurations mutableCopy];
    self.requestingConfiguration = [self.remainingConfigurations removeFirst];
    
    // There are no configurations to try. Consider this a clear response by the server.
    if (self.remainingConfigurations.count == 0 && self.requestingConfiguration == nil) {
        MPLogInfo(kMPClearErrorLogFormatWithAdUnitID, self.delegate.adUnitId);
        [self didFailToLoadAdapterWithError:[NSError errorWithCode:MOPUBErrorNoInventory]];
        return;
    }
    
    [self fetchAdWithConfiguration:self.requestingConfiguration];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    [self didFailToLoadAdapterWithError:error];
}

- (void)didFailToLoadAdapterWithError:(NSError *)error
{
    [self.delegate managerDidFailToLoadAdWithError:error];
    [self scheduleRefreshTimer];
}

- (BOOL)isFullscreenAd {
    return NO;
}

- (NSString *)adUnitId {
    return [self.delegate adUnitId];
}

#pragma mark - <MPBannerAdapterDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (MPNativeAdOrientation)allowedNativeAdsOrientation
{
    return [self.delegate allowedNativeAdsOrientation];
}

- (BOOL)requestingAdapterIsReadyToBePresented
{
    return !!self.requestingAdapterAdContentView;
}

- (void)presentRequestingAdapter
{
    if (!self.adActionInProgress && self.requestingAdapterIsReadyToBePresented) {
        // End the Viewability session and schedule the onscreen adapter for
        // deallocation if it exists since it is going offscreen.
        if (self.onscreenAdapter != nil) {
            [MPViewabilityManager.sharedManager scheduleAdapterForDeallocation:self.onscreenAdapter];
        }
        
        self.onscreenAdapter = self.requestingAdapter;
        self.requestingAdapter = nil;

        [self.onscreenAdapter rotateToOrientation:self.currentOrientation];
        [self.delegate managerDidLoadAd:self.requestingAdapterAdContentView];
        [self.onscreenAdapter didPresentInlineAd];

        self.requestingAdapterAdContentView = nil;
    }
}

- (void)adAdapter:(id<MPAdAdapter>)adapter handleInlineAdEvent:(MPInlineAdEvent)inlineAdEvent {
    switch (inlineAdEvent) {
        case MPInlineAdEventUserActionWillBegin:
            [self userActionWillBeginForAdapter:adapter];
            break;
        case MPInlineAdEventUserActionDidEnd:
            [self userActionDidFinishForAdapter:adapter];
            break;
        case MPInlineAdEventWillLeaveApplication:
            [self userWillLeaveApplicationFromAdapter:adapter];
            break;
        case MPInlineAdEventWillExpand:
            [self adWillExpandForAdapter:adapter];
            break;
        case MPInlineAdEventDidCollapse:
            [self adDidCollapseForAdapter:adapter];
            break;
        default:
            NSAssert(NO, @"Should not reach this point");
            break;
    }
}

- (void)inlineAdAdapter:(id<MPAdAdapter>)adapter didLoadAdWithAdView:(UIView *)adView
{
    if (self.requestingAdapter == adapter) {
        self.remainingConfigurations = nil;
        self.requestingAdapterAdContentView = adView;
        
        // Record the end of the adapter load and send off the fire and forget after-load-url tracker.
        NSTimeInterval duration = [self.loadStopwatch stop];
        [self.communicator sendAfterLoadUrlWithConfiguration:self.requestingConfiguration adapterLoadDuration:duration adapterLoadResult:MPAfterLoadResultAdLoaded];
        
        MPLogAdEvent(MPLogEvent.adDidLoad, self.delegate.banner.adUnitId);
        [self presentRequestingAdapter];
    }
}

- (void)adapter:(id<MPAdAdapter>)adapter didFailToLoadAdWithError:(NSError *)error
{
    // Record the end of the adapter load and send off the fire and forget after-load-url tracker
    // with the appropriate error code result.
    NSTimeInterval duration = [self.loadStopwatch stop];
    MPAfterLoadResult result = (error.isAdRequestTimedOutError ? MPAfterLoadResultTimeout : (adapter == nil ? MPAfterLoadResultMissingAdapter : MPAfterLoadResultError));
    [self.communicator sendAfterLoadUrlWithConfiguration:self.requestingConfiguration adapterLoadDuration:duration adapterLoadResult:result];
    
    if (self.requestingAdapter == adapter) {
        // There are more ad configurations to try.
        if (self.remainingConfigurations.count > 0) {
            self.requestingConfiguration = [self.remainingConfigurations removeFirst];
            [self fetchAdWithConfiguration:self.requestingConfiguration];
        }
        // No more configurations to try. Send new request to Ads server to get more Ads.
        else if (self.requestingConfiguration.nextURL != nil
                 && [self.requestingConfiguration.nextURL isEqual:self.mostRecentlyLoadedURL] == false) {
            [self loadAdWithURL:self.requestingConfiguration.nextURL];
        }
        // No more configurations to try and no more pages to load.
        else {
            NSError * clearResponseError = [NSError errorWithCode:MOPUBErrorNoInventory localizedDescription:[NSString stringWithFormat:kMPClearErrorLogFormatWithAdUnitID, self.delegate.banner.adUnitId]];
            MPLogAdEvent([MPLogEvent adFailedToLoadWithError:clearResponseError], self.delegate.banner.adUnitId);
            [self didFailToLoadAdapterWithError:clearResponseError];
        }
    }

    if (self.onscreenAdapter == adapter && adapter != nil) {
        // the onscreen adapter has failed.  we need to:
        // 1) remove it
        // 2) and note that there can't possibly be a modal on display any more
        [self.delegate invalidateContentView];
        self.onscreenAdapter = nil;
        if (self.adActionInProgress) {
            [self.delegate userActionDidFinish];
            self.adActionInProgress = NO;
        }
        if (self.requestingAdapterIsReadyToBePresented) {
            [self presentRequestingAdapter];
        } else {
            [self loadAdWithTargeting:self.targeting];
        }
    }
}

- (void)adapter:(id<MPAdAdapter>)adapter didFailToPlayAdWithError:(NSError *)error {
    [self adapter:adapter didFailToLoadAdWithError:error];
}

- (void)adDidReceiveImpressionEventForAdapter:(id<MPAdAdapter>)adapter {
    if (self.onscreenAdapter == adapter) {
        [self scheduleRefreshTimer];
    }
    
    [self.delegate impressionDidFireWithImpressionData:self.requestingConfiguration.impressionData];
}

- (void)userActionWillBeginForAdapter:(id<MPAdAdapter>)adapter
{
    if (self.onscreenAdapter == adapter) {
        self.adActionInProgress = YES;
        
        MPLogAdEvent(MPLogEvent.adTapped, self.delegate.banner.adUnitId);
        MPLogAdEvent(MPLogEvent.adWillPresentModal, self.delegate.banner.adUnitId);
        [self.delegate userActionWillBegin];
    }
}

- (void)userActionDidFinishForAdapter:(id<MPAdAdapter>)adapter
{
    if (self.onscreenAdapter == adapter) {
        MPLogAdEvent(MPLogEvent.adDidDismissModal, self.delegate.banner.adUnitId);
        [self.delegate userActionDidFinish];
        
        self.adActionInProgress = NO;
        [self presentRequestingAdapter];
    }
}

- (void)userWillLeaveApplicationFromAdapter:(id<MPAdAdapter>)adapter
{
    if (self.onscreenAdapter == adapter) {
        MPLogAdEvent(MPLogEvent.adTapped, self.delegate.banner.adUnitId);
        MPLogAdEvent(MPLogEvent.adWillLeaveApplication, self.delegate.banner.adUnitId);
        [self.delegate userWillLeaveApplication];
    }
}

- (void)adWillExpandForAdapter:(id<MPAdAdapter>)adapter
{
    // While the banner ad is in an expanded state, the refresh timer should be paused
    // since the user is interacting with the ad experience.
    [self pauseRefreshTimer];
}

- (void)adDidCollapseForAdapter:(id<MPAdAdapter>)adapter
{
    // Once the banner ad is collapsed back into its default state, the refresh timer
    // should be resumed to queue up the next ad.
    [self resumeRefreshTimer];
}

@end


