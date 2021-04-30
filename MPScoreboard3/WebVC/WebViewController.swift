//
//  WebViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/8/21.
//

import UIKit
import WebKit
import GoogleMobileAds
import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, DTBAdCallback, GADBannerViewDelegate
{
    var allowRotation = false
    var urlString = ""
    var titleString = ""
    var navColor = UIColor.mpWhiteColor()
    var titleColor = UIColor.mpBlackColor()
    var showShareButton = false
    var showNavControls = false
    var showScrollIndicators = false
    var showLoadingOverlay = false
    var showBannerAd = false
            
    private var browserView: WKWebView = WKWebView()
    private var loadingContainer : UIView = UIView()
    private var loadingLabel: UILabel = UILabel()
    
    private var backButtonItem: UIBarButtonItem!
    private var forwardButtonItem: UIBarButtonItem!
    private var shareButtonItem: UIBarButtonItem!
    
    private var googleBannerAdView: DFPBannerView!
    private var bannerBackgroundView: UIImageView!
    
    private var trackingGuid = ""
    private var browserHeight = 0
    
    private let kIndicatorHeight = 20
    
    // MARK: - UI Delegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        if navigationAction.targetFrame == nil
        {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    // MARK: - Navigaton Delegates
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let urlString = navigationAction.request.url?.absoluteString
        {
            //print("Decide Policy for URL: " + urlString);
            if urlString.contains("about:blank")
            {
               // print("Rejected URL, about:blank")
                decisionHandler(.cancel)
                return
            }
        }
        /*
        if let host = navigationAction.request.url?.host
        {
            if host.contains("maxpreps.com")
            {
                print("Allowed")
                decisionHandler(.allow)
                return
            }
        }
        */
        
        /*
         if host.contains("maxpreps.com")
         {
             var navigationType = "";
             switch (navigationAction.navigationType)
             {
                 case 0:
                     navigationType = "Link with an href attribute"
                 case 1:
                     navigationType = "Form submitted";
                 case 2:
                     navigationType = "An item from the back-forward list was requested"
                 case 3:
                     navigationType = "The webpage was reloaded";
                 case 4:
                     navigationType = "A form was resubmitted"
                 case -1:
                     navigationType = "Other"
                 default:
                     break
             }
             
             print("NavigationType: " + navigationType);
             print("SourceFrame: " + navigationAction.sourceFrame)
             print("TargetFrame: " + navigationAction.targetFrame)
         }
         */
        
        //print("Allowed")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
    {
        print("Did Commit")
        
        if (self.showLoadingOverlay)
        {
            self.animateLoadingContainer(show: true)
            
            // Deadman timer for the overlay view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
            { [self] in
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                }
            }
        }
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print("Did Finish")
        
        if (self.showLoadingOverlay)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                }
            }
        }
        
        if (browserView.canGoBack == true)
        {
            backButtonItem.isEnabled = true
        }
        else
        {
            backButtonItem.isEnabled = false
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButtonItem.isEnabled = true
        }
        else
        {
            forwardButtonItem.isEnabled = false
        }
        
        /*
        let backForwardList: WKBackForwardList = browserView.backForwardList
        
        if (backForwardList.backList.count > 0)
        {
            backButtonItem.isEnabled = true
        }
        else
        {
            backButtonItem.isEnabled = false
        }
        
        if (backForwardList.forwardList.count > 0)
        {
            forwardButtonItem.isEnabled = true
        }
        else
        {
            forwardButtonItem.isEnabled = false
        }
 */
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error)
    {
        print("Did Fail")
        
        if (self.showLoadingOverlay)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                }
            }
        }
        
        if (browserView.canGoBack == true)
        {
            backButtonItem.isEnabled = true
        }
        else
        {
            backButtonItem.isEnabled = false
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButtonItem.isEnabled = true
        }
        else
        {
            forwardButtonItem.isEnabled = false
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        print("Did Fail")
        
        if (self.showLoadingOverlay)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                }
            }
        }
        
        if (browserView.canGoBack == true)
        {
            backButtonItem.isEnabled = true
        }
        else
        {
            backButtonItem.isEnabled = false
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButtonItem.isEnabled = true
        }
        else
        {
            forwardButtonItem.isEnabled = false
        }
    }
    
    // MARK: - Button Methods
    
    @objc func shareButtonTouched()
    {
        // Get the current URL from the browser
        let currentUrlString = browserView.url?.absoluteString
        
        // Call the Bitly feed to compress the URL
        NewFeeds.getBitlyUrl(currentUrlString!) { (dictionary, error) in
  
            var dataToShare = [] as! Array<String>
            
            if (error == nil)
            {
                print("Done")
                if let shortUrl = dictionary!["data"] as? String
                {
                    if (shortUrl.count > 0)
                    {
                        let bitlyString = "Here is something from MaxPreps I thought you would like: " + shortUrl
                        dataToShare = [bitlyString]
                    }
                    else
                    {
                        dataToShare = ["Here is something from MaxPreps I thought you would like: " + self.urlString]
                    }
                }
                else
                {
                    dataToShare = ["Here is something from MaxPreps I thought you would like: " + self.urlString]
                }
            }
            else
            {
                dataToShare = ["Here is something from MaxPreps I thought you would like: " + self.urlString]
            }
            
            let activityVC = UIActivityViewController(activityItems: dataToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
            activityVC.modalPresentationStyle = .fullScreen
            self.present(activityVC, animated: true)
        }
    }
    
    @objc func backButtonTouched()
    {
        if (browserView.canGoBack == true)
        {
            browserView.goBack()
        }
    }
    
    @objc func forwardButtonTouched()
    {
        if (browserView.canGoForward == true)
        {
            browserView.goForward()
        }
    }

    // MARK: - Loading Container
    
    private func animateLoadingContainer(show: Bool)
    {
        if (show)
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.loadingContainer.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
        else
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.loadingContainer.transform = CGAffineTransform(translationX: 0, y: CGFloat(-kIndicatorHeight))
            }
        }
        
    }
    
    // MARK: - Amazon Banner Ad Methods
    
    private func loadAmazonBannerAd()
    {
        let adSize = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID)
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([adSize!])
        adLoader.loadAd(self)
    }
    
    func onSuccess(_ adResponse: DTBAdResponse!)
    {
        var adResponseDictionary = adResponse.customTargeting()
        
        adResponseDictionary!.updateValue(trackingGuid, forKey: "vguid")
        
        print("Received Amazon Banner Ad")
        
        let request = DFPRequest()
        request.customTargeting = adResponseDictionary
        
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        
        googleBannerAdView.load(request)
    }
    
    func onFailure(_ error: DTBAdError)
    {
        print("Amazon Banner Ad Failed")
        
        let request = DFPRequest()
        
        var customTargetDictionary = [:] as! Dictionary<String, Any>
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        customTargetDictionary.updateValue(trackingGuid, forKey: "vguid")
        customTargetDictionary.updateValue(idfaString, forKey: "idtype")
        
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status
        {
        case .notDetermined:
            customTargetDictionary.updateValue("not_determined", forKey: "attmas")
        case .denied:
            customTargetDictionary.updateValue("denied", forKey: "attmas")
        case .restricted:
            customTargetDictionary.updateValue("restricted", forKey: "attmas")
        case .authorized:
            customTargetDictionary.updateValue("authorized", forKey: "attmas")
        default:
            break
        }
        
        request.customTargeting = customTargetDictionary
        
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        
        // Add MoPub
        let extras = GADMoPubNetworkExtras()
        extras.privacyIconSize = 20
        request.register(extras)
        
        googleBannerAdView.load(request)
    }
    
    // MARK: - Google Ad Methods
    
    private func loadBannerViews()
    {
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.removeFromSuperview()
            googleBannerAdView = nil
            
            if (bannerBackgroundView != nil)
            {
                bannerBackgroundView.removeFromSuperview()
                bannerBackgroundView = nil
            }
            
            browserView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: browserHeight)
        }
        
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ab075279b6aba4510e894e3563b029dc"]
        let adId = kUserDefaults.value(forKey: kWebBannerAdIdKey) as! String
        print("AdID: ", adId)
        
        googleBannerAdView = DFPBannerView(adSize: kGADAdSizeBanner, origin: CGPoint(x: (kDeviceWidth - kGADAdSizeBanner.size.width) / 2.0, y: 6.0))
        googleBannerAdView.delegate = self
        googleBannerAdView.adUnitID = adId
        googleBannerAdView.rootViewController = self
        
        self.loadAmazonBannerAd()
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("Received Google Banner Ad")
        
        bannerBackgroundView = UIImageView(frame: CGRect(x: 0, y: browserHeight - Int(kGADAdSizeBanner.size.height) - 12, width: Int(kDeviceWidth), height: Int(kGADAdSizeBanner.size.height) + 12))
        bannerBackgroundView.isUserInteractionEnabled = true
        bannerBackgroundView.image = UIImage(named: "BannerBackground")
        
        // Add a shadow to the bannerBackgroundView
        let shadowPath = UIBezierPath(rect: bannerBackgroundView.bounds)
        bannerBackgroundView.layer.masksToBounds = false
        bannerBackgroundView.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        bannerBackgroundView.layer.shadowOffset = CGSize(width: 0, height: -5)
        bannerBackgroundView.layer.shadowOpacity = 0.5
        bannerBackgroundView.layer.shadowPath = shadowPath.cgPath
        
        // Add the background to the view and the banner ad to the background
        self.view.addSubview(bannerBackgroundView)
        bannerBackgroundView.addSubview(googleBannerAdView)
        
        // Move it down so it is hidden
        bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: bannerBackgroundView.frame.size.height + 5)
        
        // Animate the ad
        UIView.animate(withDuration: 0.25, animations: {self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)})
        { (finished) in
            self.browserView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: self.browserHeight - Int(self.bannerBackgroundView.frame.size.height))
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
    {
        print("Google Banner Ad Failed")
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let guid = NSUUID()
        trackingGuid = guid.uuidString

        self.title = titleString
        
        self.navigationController?.navigationBar.barTintColor = navColor
        self.navigationController?.navigationBar.tintColor = titleColor
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: titleColor, .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)  
        
        backButtonItem = UIBarButtonItem(image: UIImage(named: "ArrowLeftGray"), style: .done, target: self, action: #selector(backButtonTouched))
        backButtonItem.tintColor = titleColor
        backButtonItem.isEnabled = false
        
        forwardButtonItem = UIBarButtonItem(image: UIImage(named: "ArrowRightGray"), style: .done, target: self, action: #selector(forwardButtonTouched))
        forwardButtonItem.tintColor = titleColor
        forwardButtonItem.isEnabled = false
        
        shareButtonItem = UIBarButtonItem.init(barButtonSystemItem:.action, target: self, action: #selector(shareButtonTouched))
        shareButtonItem.tintColor = titleColor
        
        if (showNavControls && showShareButton)
        {
            self.navigationItem.rightBarButtonItems  = [shareButtonItem, forwardButtonItem, backButtonItem]
        }
        else if (showNavControls && !showShareButton)
        {
            self.navigationItem.rightBarButtonItems  = [forwardButtonItem, backButtonItem]
        }
        else if (!showNavControls && showShareButton)
        {
            self.navigationItem.rightBarButtonItem = shareButtonItem
        }
        
        /*
         WKUserContentController *controller = [[WKUserContentController alloc] init];
         [controller addScriptMessageHandler:self name:@"vcplay"];
         
         WKWebViewConfiguration  *configuration = [[WKWebViewConfiguration alloc] init];
         configuration.userContentController = controller;
         configuration.applicationNameForUserAgent = @"MaxPrepsApp";
         //configuration.mediaTypesRequiringUserActionForPlayback = NO;

         wkBrowserView = [[WKWebView alloc]initWithFrame:CGRectMake(0.0, kNavBarHeight + kStatusBarHeight, kDeviceWidth, kDeviceHeight - kNavBarHeight - kStatusBarHeight - bottomTabBarPad - [SharedData sharedInstance].bottomSafeAreaHeight) configuration:configuration];
         wkBrowserView.autoresizingMask = UIViewContentModeScaleToFill;
         wkBrowserView.UIDelegate = self;
         wkBrowserView.navigationDelegate = self;
         [self.view insertSubview:wkBrowserView belowSubview:webNavContainer];
         */
        
        var bottomTabBarPad = 0
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }
        
        // We need to explicitly calculate the browser's height without ads for use elesewhere
        browserHeight = Int(kDeviceHeight) - SharedData.topNotchHeight - SharedData.bottomSafeAreaHeight - kStatusBarHeight - kNavBarHeight - bottomTabBarPad
        
        browserView.frame = CGRect(x: 0.0, y: 0.0, width: Double(kDeviceWidth), height: Double(browserHeight))
        browserView.navigationDelegate = self
        browserView.uiDelegate = self
        browserView.scrollView.showsVerticalScrollIndicator = showScrollIndicators
        browserView.scrollView.showsHorizontalScrollIndicator = showScrollIndicators
        self.view.addSubview(browserView)
        
        // Add the loading container
        loadingContainer.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kIndicatorHeight)
        loadingContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.33)
        self.view.addSubview(loadingContainer)
        
        loadingContainer.transform = CGAffineTransform(translationX: 0, y: -CGFloat(kIndicatorHeight))
        
        loadingLabel.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kIndicatorHeight)
        loadingLabel.backgroundColor = .clear
        loadingLabel.textColor = UIColor.mpWhiteColor()
        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
        loadingLabel.font = .systemFont(ofSize: 11)
        loadingContainer.addSubview(loadingLabel)
        
        // Append some items to the URL
        if (urlString.contains("?"))
        {
            urlString = urlString + "&" + kAppIdentifierQueryParam
        }
        else
        {
            urlString = urlString + "?" + kAppIdentifierQueryParam
        }
        
        // Load the browser
        let url = URL(string: urlString)!
        browserView.load(URLRequest(url: url))
        browserView.allowsBackForwardNavigationGestures = true
        
        // Initialize the ads
        if (self.showBannerAd)
        {
            self.loadBannerViews()
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        //browserView.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.size.width), height: Int(self.view.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight)))
   
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        if (titleColor == UIColor.mpWhiteColor())
        {
            return UIStatusBarStyle.lightContent
        }
        else
        {
            return UIStatusBarStyle.default
        }
    }

    override var shouldAutorotate: Bool
    {
        return self.allowRotation
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if (self.allowRotation)
        {
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        else
        {
            return .portrait
        }
    }

}
