#import "BannerView.h"
#import <React/RCTBridgeModule.h>
#import <React/UIView+React.h>
#import <React/RCTLog.h>

@implementation BannerView {
  GADBannerView  *_bannerView;
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
  RCTLogError(@"AdMob Banner cannot have any subviews");
  return;
}

- (void)removeReactSubview:(UIView *)subview
{
  RCTLogError(@"AdMob Banner cannot have any subviews");
  return;
}

- (GADAdSize)getAdSizeFromString:(NSString *)bannerSize
{
  if ([bannerSize isEqualToString:@"banner"]) {
    return kGADAdSizeBanner;
  } else if ([bannerSize isEqualToString:@"largeBanner"]) {
    return kGADAdSizeLargeBanner;
  } else if ([bannerSize isEqualToString:@"mediumRectangle"]) {
    return kGADAdSizeMediumRectangle;
  } else if ([bannerSize isEqualToString:@"fullBanner"]) {
    return kGADAdSizeFullBanner;
  } else if ([bannerSize isEqualToString:@"leaderboard"]) {
    return kGADAdSizeLeaderboard;
  } else if ([bannerSize isEqualToString:@"smartBannerPortrait"]) {
    return kGADAdSizeSmartBannerPortrait;
  } else if ([bannerSize isEqualToString:@"smartBannerLandscape"]) {
    return kGADAdSizeSmartBannerLandscape;
  }
  else {
    return kGADAdSizeBanner;
  }
}

-(void)loadBanner {
  if (_adUnitID && _bannerSize) {
    GADAdSize size = [self getAdSizeFromString:_bannerSize];
    _bannerView = [[GADBannerView alloc] initWithAdSize:size];
    if(!CGRectEqualToRect(self.bounds, _bannerView.bounds)) {
      [self callOnSizeChange];
    }
    _bannerView.delegate = self;
    _bannerView.adUnitID = _adUnitID;
    _bannerView.rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    GADRequest *request = [GADRequest request];
    if (_testDeviceIDs) {
      NSMutableArray *testDevices = [NSMutableArray new];
      for (NSString* testDeviceID in _testDeviceIDs){
        if ([testDeviceID isEqualToString:@"EMULATOR"]) {
          [testDevices addObject:kGADSimulatorID];
        } else {
          [testDevices addObject:testDeviceID];
        }
      }
      request.testDevices = testDevices;
    }

    [_bannerView loadRequest:request];
  }
}

-(void)callOnSizeChange {
  if (self.onSizeChange) {
    self.onSizeChange(@{
      @"width": [NSNumber numberWithFloat: _bannerView.bounds.size.width],
      @"height": [NSNumber numberWithFloat: _bannerView.bounds.size.height]
    });
  }
}

- (void)setBannerSize:(NSString *)bannerSize
{
  if(![bannerSize isEqual:_bannerSize]) {
    _bannerSize = bannerSize;
    if (_bannerView) {
      [_bannerView removeFromSuperview];
    }
    [self loadBanner];
  }
}



- (void)setAdUnitID:(NSString *)adUnitID
{
  if(![adUnitID isEqual:_adUnitID]) {
    _adUnitID = adUnitID;
    if (_bannerView) {
      [_bannerView removeFromSuperview];
    }

    [self loadBanner];
  }
}
- (void)setTestDeviceIDs:(NSString *)testDeviceIDs
{
  if(![testDeviceIDs isEqual:_testDeviceIDs]) {
    for (NSString* testDeviceID in testDeviceIDs){
      if (testDeviceID == (id)[NSNull null] || testDeviceID.length == 0) {
        RCTLogError(@"Test device ID cannot be null.");
        return;
      }
    }
    _testDeviceIDs = testDeviceIDs;
    if (_bannerView) {
      [_bannerView removeFromSuperview];
    }

    [self loadBanner];
  }
}

- (void)setOnSizeChange:(RCTBubblingEventBlock)onSizeChange
{
  _onSizeChange = onSizeChange;
  if (_bannerView) {
    [self callOnSizeChange];
  }
}

-(void)layoutSubviews
{
  [super layoutSubviews ];

  self.frame = CGRectMake(
    self.bounds.origin.x,
    self.bounds.origin.x,
    _bannerView.frame.size.width,
    _bannerView.frame.size.height);

  [self addSubview:_bannerView];
}

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  if (self.onAdViewDidReceiveAd) {
    self.onAdViewDidReceiveAd(@{});
  }
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView
didFailToReceiveAdWithError:(GADRequestError *)error {
  if (self.onDidFailToReceiveAdWithError) {
    self.onDidFailToReceiveAdWithError(@{@"error": [error localizedDescription]});
  }
}

/// Tells the delegate that a full screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
  if (self.onAdViewWillPresentScreen) {
    self.onAdViewWillPresentScreen(@{});
  }
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
  if (self.onAdViewWillDismissScreen) {
    self.onAdViewWillDismissScreen(@{});
  }
}

/// Tells the delegate that the full screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
  if (self.onAdViewDidDismissScreen) {
    self.onAdViewDidDismissScreen(@{});
  }
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
  if (self.onAdViewWillLeaveApplication) {
    self.onAdViewWillLeaveApplication(@{});
  }
}

@end
