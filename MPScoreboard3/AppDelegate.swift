//
//  AppDelegate.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit
import DTBiOSSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate
{
    // MARK: - Master School List Method
    
    func getSchoolsFile()
    {
        SharedData.allSchools.removeAll()
        
        var filePath = Bundle.main.path(forResource: "ALL", ofType: "txt")
        
        
        // This code checks for a ALL.txt data file in the documents directory
        // Replace the path with the downloaded patch file if it exists
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        {
            
            let fileURL = documentsDirectory.appendingPathComponent("ALL.txt")
            
            do {
                if try fileURL.checkResourceIsReachable()
                {
                    print("School patch file exists")
                    filePath = fileURL.path
                }
                else
                {
                    print("School patch file doesnt exist")
                    
                }
            }
            catch
            {
                print("an error happened while checking for the file")
            }
        }
        
        // Read the file
        var wordstring = ""
        do {
                wordstring = try String(contentsOfFile: filePath!, encoding: .utf8)
            }
            catch
            {
                print("Couldn't read file")
            }
            
        // Split the string into an array
        let lineArray = wordstring.components(separatedBy: "\n")
                
        print("Initial School Count = " + String(lineArray.count))
    
        let centerLatitudeString = kUserDefaults.string(forKey: kLatitudeKey) ?? "0.0"
        let centerLongitudeString = kUserDefaults.string(forKey: kLongitudeKey) ?? "0.0"
        print("Latitude: " + centerLatitudeString + ", Longitude: " + centerLongitudeString)
        
        let centerLatitude = Float(centerLatitudeString) ?? 0.0
        let centerLongitude = Float(centerLongitudeString) ?? 0.0
        
        //for (index, line) in lineArray.enumerated()
        for (_, line) in lineArray.enumerated()
        {
            let schoolDataArray = line.components(separatedBy: "|")
            
            // The ALL.txt data is arranged as follows:
            // School(city, state) | GUID | URL | Name | Address | City | State | Zip | Phone | Longitude | Latitude
            
            if (schoolDataArray.count < 7)
            {
                //print("Error: Schools file line " + String(index) + " is missing elements")
                continue;
            }
            
            let state = schoolDataArray[6]
            
            // Remove schools with no state (international)
            if (state.count == 0)
            {
                //print("School Remove due to missing state.");
                continue;
            }
            
            let latitudeString = schoolDataArray[10]
            let longitudeString = schoolDataArray[9]
            
            let schoolLatitude = Float(latitudeString) ?? 0.0
            let schoolLongitude = Float(longitudeString) ?? 0.0
            
            let deltaLatitude = centerLatitude - schoolLatitude
            let deltaLongitude = centerLongitude - schoolLongitude
            
            let distanceSquared = (deltaLongitude * deltaLongitude) + (deltaLatitude * deltaLatitude)
            
            let school = School(fullName: schoolDataArray[0], name: schoolDataArray[3], schoolId: schoolDataArray[1], address: schoolDataArray[4], state: schoolDataArray[6], city: schoolDataArray[5], zip: schoolDataArray[7], searchDistance: distanceSquared, latitude: latitudeString, longitude: longitudeString)
            
            SharedData.allSchools.append(school)
            
        }
        print("Final School Count: " + String(SharedData.allSchools.count))
    }
    
    // MARK: - Get UTC Time
    
    private func getUTCTime()
    {
        LegacyFeeds.getUTCTime { (timeOffset, error) in
            if (error == nil)
            {
                SharedData.utcTimeOffset = timeOffset!
            }
            else
            {
                SharedData.utcTimeOffset = 0
            }
        }
    }
    
    // MARK: - Google Ad Ids
    
    private func loadGoolgeAdIds()
    {
        if (kUserDefaults.string(forKey: kServerModeKey) == kServerModeDev) || (kUserDefaults.string(forKey: kServerModeKey) == kServerModeBranch)
        {
            /*
            // Google Ad Ids for Dev from CBS
            [prefs setObject:@"/7336/appaw-maxpreps/loading-screen-logo" forKey:kLoadingScreenBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/now" forKey:kBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/scores" forKey:kScoresBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/teams" forKey:kTeamsBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/web" forKey:kWebBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/rankings" forKey:kWebAlternateBannerAdIdKey];
            */
            
            let googleTestId = "ca-app-pub-3940256099942544/2934735716"
            kUserDefaults.setValue(googleTestId, forKey: kNewsBannerAdIdKey)
            kUserDefaults.setValue(googleTestId, forKey: kScoresBannerAdIdKey)
            kUserDefaults.setValue(googleTestId, forKey: kTeamsBannerAdIdKey)
            kUserDefaults.setValue(googleTestId, forKey: kWebBannerAdIdKey)
        }
        else
        {
            kUserDefaults.setValue("/8264/appaw-maxpreps/now", forKey: kNewsBannerAdIdKey)
            kUserDefaults.setValue("/8264/appaw-maxpreps/scores", forKey: kScoresBannerAdIdKey)
            kUserDefaults.setValue("/8264/appaw-maxpreps/teams", forKey: kTeamsBannerAdIdKey)
            kUserDefaults.setValue("/8264/appaw-maxpreps/web", forKey: kWebBannerAdIdKey)
        }
    }
    
    // MARK: - Amazon Ad Init
    
    private func initializeAmazonAds()
    {
        DTBAds.sharedInstance().setAppKey(kAmazonAdAppKey)
        DTBAds.sharedInstance().setLogLevel(DTBLogLevelAll)
        DTBAds.sharedInstance().testMode = kAmazonTestMode
        DTBAds.sharedInstance().setAPSFrequencyCappingIdFeatureEnabled(true)
    }
    
    // MARK: - Register for Notifications
    
    func registerForNotifications()
    {
        // This called by the TabBarController after login is closed
        print("Register for Notifications called")
        
        let center  = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                        
            if error == nil
            {
                DispatchQueue.main.async
                {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // MARK: - Init Preferences
    
    func initPreferences()
    {
        // EDH is located here -121.070664, 38.679866
        if (kUserDefaults.object(forKey: kLatitudeKey) == nil)
        {
            kUserDefaults.setValue("38.679866", forKey: kLatitudeKey)
        }
        
        if (kUserDefaults.object(forKey: kLongitudeKey) == nil)
        {
            kUserDefaults.setValue("-121.070664", forKey: kLongitudeKey)
        }
        
        // Initialize the userId
        if (kUserDefaults.object(forKey: kUserIdKey) == nil)
        {
            kUserDefaults.setValue(kEmptyGuid, forKey: kUserIdKey)
        }
        
        // Initialize the user email
        if (kUserDefaults.object(forKey: kUserEmailKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserEmailKey)
        }
        
        // Initialize the user first name
        if (kUserDefaults.object(forKey: kUserFirstNameKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserFirstNameKey)
        }
        
        // Initialize the user last name
        if (kUserDefaults.object(forKey: kUserLastNameKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserLastNameKey)
        }
        
        // Initialize the user zip
        if (kUserDefaults.object(forKey: kUserZipKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserZipKey)
        }
                
        // Initialize the token buster
        if (kUserDefaults.object(forKey: kTokenBusterKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kTokenBusterKey)
        }
        
        // Force Production Server
        if (kUserDefaults.object(forKey: kServerModeKey) == nil)
        {
            kUserDefaults.setValue(kServerModeProduction, forKey: kServerModeKey)
        }
        
        // Set the initial branch value
        if (kUserDefaults.object(forKey: kBranchValue) == nil)
        {
            kUserDefaults.setValue("", forKey: kBranchValue)
        }
        
        // Video Autoplay
        if (kUserDefaults.object(forKey: kVideoAutoplayModeKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(value: 1), forKey: kVideoAutoplayModeKey)
        }
        
        // Debug Dialogs
        if (kUserDefaults.object(forKey: kDebugDialogsKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kDebugDialogsKey)
        }
        
        // Notification Master Enable
        if (kUserDefaults.object(forKey: kNotificationMasterEnableKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kNotificationMasterEnableKey)
        }
        
        // SelectedFavoriteIndex
        if (kUserDefaults.object(forKey: kSelectedFavoriteIndexKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
        }
        
        // SelectedFavoriteSection
        if (kUserDefaults.object(forKey: kSelectedFavoriteSectionKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kSelectedFavoriteSectionKey)
        }
    }
    
    // MARK: - Global Appearance
    
    func setupGlobalAppearance()
    {
        // Global Appearance settings
        
        // Change the back button to use a better arrow
        let backImage = UIImage(named: "BackArrowBlack")
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UINavigationBar.appearance().backItem?.backButtonDisplayMode = .minimal

        // Change the tab bar colors and font
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.mpDarkGrayColor(), NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 12)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.mpRedColor(), NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 12)], for: .selected)
        
        // This doesn't work
        //UINavigationBar.appearance().titleTextAttributes = ([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)])
        
        //UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19)], for: .normal)
        //UITextField.appearance().substituteFontName = Constants.App.regularFont
        //UILabel.appearance().substituteFontName = Constants.App.regularFont
        //UILabel.appearance().substituteFontNameBold = Constants.App.boldFont
      }
    
    // MARK: - App Lifecycle Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        Thread.sleep(forTimeInterval: 1)
        
        let kRootDirectory = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("").path
        print("Application Root: " + kRootDirectory);
        
        // Set the global device type
        let deviceType = UIDevice.current.model.lowercased()
        
        if (deviceType == "ipad")
        {
            SharedData.deviceType = DeviceType.ipad
        }
        else
        {
            SharedData.deviceType = DeviceType.iphone
        }
        
        // Set the device aspect ratio
        
        // iPhone 4s - 640 x 960 (@2x) (320 x 480) Aspect = 1.5
        // iPhone 5 - 640 x 1136 (@2x) (320 x 568) Aspect = 1.775
        // iPhone 6 - 750 x 1334 (@2x) (375 x 667) Aspect = 1.778
        // iPhone 6+  1242 × 2208 (@3x) (414 x 736) Aspect = 1.777
        // iPhone X, 12 Mini - 1125 x 2436 (@3x) (375 x 812) Aspect = 2.165
        // iPhone Xr - 828 x 1792 (@2x) (414 x 896) Aspect = 2.164
        // iPhone Xs Max - 1242 x 2688 (@3x) (414 x 896) Aspect = 2.164
        // iPhone 12 Pro - 1170 x 2532 (@3x) (390 x 844) Aspect = 2.164
        // iPhone 12 Pro Max - 1284 x 2788 (@3x) (428 x 926) Aspect = 2.163
        
        let aspectRatio: CGFloat = kDeviceHeight / kDeviceWidth
        
        if (aspectRatio <= 1.5)
        {
            SharedData.deviceAspectRatio = AspectRatio.low
        }
        else if ((aspectRatio > 1.5) && (aspectRatio < 2))
        {
            SharedData.deviceAspectRatio = AspectRatio.medium
        }
        else
        {
            SharedData.deviceAspectRatio = AspectRatio.high
        }
        
        // Init the user prefs
        self.initPreferences()
        
        // Setup global appearance
        self.setupGlobalAppearance()
        
        // Get the UTC time from the server
        self.getUTCTime()

        // Load the schools file
        self.getSchoolsFile()
        
        // Initialize Amazon Ads
        self.initializeAmazonAds()
        
        // Load the Google Ad IDs
        self.loadGoolgeAdIds()
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

