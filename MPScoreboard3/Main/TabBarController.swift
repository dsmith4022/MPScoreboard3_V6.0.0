//
//  TabBarController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate, LoginHomeViewControllerDelegate
{
    private var loginHomeVC: LoginHomeViewController!
    private var loginHomeNav: TopNavigationController!
    
    // MARK: - Web Login
    
    private func webLogin()
    {
        // Test code for Pranata
        let fakeFavorite = [kNewSchoolIdKey:kDefaultSchoolId, kNewAllSeasonIdKey: kEmptyGuid, kNewSeasonKey: "Spring"]

        NewFeeds.loadCookie(fakeFavorite) { error in
            
            if (error == nil)
            {
                print("success")
                
                let cookieJar = HTTPCookieStorage.shared

                for cookie in cookieJar.cookies!
                {
                   if cookie.name == "CookieTest"
                   {
                      let cookieValue = cookie.value

                      print("COOKIE VALUE = \(cookieValue)")
                   }
                }
            }
        }
        
        LegacyFeeds.webLogin(completionHandler:{ post, error in
            if error == nil
            {
                print("Web login successful")
                
                // Get the user favorites if a real user
                if ((kUserDefaults.string(forKey: kUserIdKey) != kEmptyGuid) && (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId))
                {
                    self.getUserInfo()
                    self.getUserFavoriteAthletes()
                    self.getUserFavoriteTeams() 
                }
            }
            else
            {
                print("Web login error")
            }
        })
    }
    
    // MARK: - Get User Info (old feed)
    
    private func getUserInfo()
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        LegacyFeeds.getUserInfo(email: "", password: "", userId: userId!) { (result, error) in
            
            if (error == nil)
            {
                print("Login Success")
                let email = result!["Email"] as! String
                let firstName = result!["FirstName"] as! String
                let lastName = result!["LastName"] as! String
                let userId = result!["UserId"] as! String
                let zip = result!["Zip"] as! String
                
                kUserDefaults.setValue(userId, forKey: kUserIdKey)
                kUserDefaults.setValue(email, forKey: kUserEmailKey)
                kUserDefaults.setValue(firstName, forKey: kUserFirstNameKey)
                kUserDefaults.setValue(lastName, forKey: kUserLastNameKey)
                kUserDefaults.setValue(zip, forKey: kUserZipKey)
                
                let location = ZipCodeHelper.location(forZipCode: zip)
                kUserDefaults.setValue(location, forKey: kCurrentLocationKey)
                
                // Set the token buster
                let now = NSDate()
                let timeInterval = Int(now.timeIntervalSinceReferenceDate)
                kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
                
                //print(kUserDefaults.value(forKey: kTokenBusterKey) as! String)
                
                // Fill the admin roles array
                let adminRoles = result!["AdminRoles"] as! Array<Dictionary<String,Any>>
                var roleDictionary = [:] as! Dictionary<String,Dictionary<String,String>>
                /*
                 let kUserAdminRolesArrayKey = "UserAdminRolesArray"    // Array
                 let kRoleNameKey = "RoleName"
                 let kRoleSchoolIdKey = "SchoolId"
                 let kRollAllSeasonIdKey = "AccessId2"
                 let kRoleSchoolNameKey = "SchoolName"
                 let kRoleSportKey = "Sport"
                 let kRoleGenderKey = "Gender"
                 let kRoleTeamLevelKey = "TeamLevel"
                 */
                for role in adminRoles
                {
                    let roleName = role[kRoleNameKey] as! String
                    let schoolId = role[kRoleSchoolIdKey] as! String
                    let allSeasonId = role[kRollAllSeasonIdKey] as! String
                    let schoolName = role[kRoleSchoolNameKey] as! String
                    let sport = role[kRoleSportKey] as! String
                    let gender = role[kRoleGenderKey] as! String
                    let teamLevel = role[kRoleTeamLevelKey] as! String
                    
                    let refactoredRole = [kRoleNameKey:roleName, kRoleSchoolIdKey:schoolId, kRollAllSeasonIdKey: allSeasonId, kRoleSchoolNameKey: schoolName, kRoleSportKey:sport, kRoleGenderKey:gender, kRoleTeamLevelKey:teamLevel]
                    
                    // Create a unique key for each role using schoolId and allSeasonId
                    let roleKey = schoolId + "_" + allSeasonId
                    
                    roleDictionary.updateValue(refactoredRole, forKey: roleKey)
                }
                
                // Clear out existing roles
                kUserDefaults.removeObject(forKey: kUserAdminRolesDictionaryKey)
                
                // Save the new roles to prefs
                kUserDefaults.setValue(roleDictionary, forKey: kUserAdminRolesDictionaryKey)
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "User Info Error", message: "There was a problem getting your user info from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    // MARK: - Get User Favorite Athletes
    
    private func getUserFavoriteAthletes()
    {
        NewFeeds.getUserFavoriteAthletes { (error) in
            
            if (error == nil)
            {
                // Check if the favorites have been written
                if let favs = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
                {
                    print ("Saved favorites count: " + String(favs.count))
                    
                    if (favs.count > 0)
                    {
                        print("Favorite Athlete Count: " + String(favs.count))
                    }
                }
                else
                {
                    print ("No Favorite Athletes")
                }
            }
            else
            {
                print("User Favorite Athletes Failed")
            }
        }
    }

    // MARK: - Get User Favorite Teams
    
    private func getUserFavoriteTeams()
    {
        NewFeeds.getUserFavoriteTeams { (error) in
            
            if (error == nil)
            {
                // Check if the favorites have been written
                if let favs = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
                {
                    print ("Saved favorite teams count: " + String(favs.count))
                    
                    if (favs.count > 0)
                    {
                        // Get the school info for each favorite to save into prefs
                        self.getNewSchoolInfo(favs)
                    }
                }
                else
                {
                    print ("No Favorites Team")
                }
            }
            else
            {
                print("User Favorite Teams Failed")
            }
        }
    }

    // MARK: - Get School Info

    private func getNewSchoolInfo(_ teams : Array<Any>)
    {
        // Build an array of schoolIds
        var schoolIds = [] as Array<String>
        
        for team in teams
        {
            let item = team  as! Dictionary<String, Any>
            let schoolId  = item[kNewSchoolIdKey] as! String
            
            schoolIds.append(schoolId)
        }

        NewFeeds.getSchoolInfoForSchoolIds(schoolIds) { error in
            if error == nil
            {
                print("Download school info success")
            }
            else
            {
                print("Download school info error")
            }
        }
    }

    /*
    // MARK: - Tab Bar Delegate Methods
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        if (tabBarController.selectedIndex == 1)
        {
            teamButtonOverlayView.isHidden = false
            self.loadSelectedTeamImage()
        }
        else
        {
            teamButtonOverlayView.isHidden = true
        }
    }
    */

    // MARK: - Login Home VC Delegate
    
    func loginHomeFinished()
    {
        let firstVC = self.viewControllers?[0]
        firstVC?.dismiss(animated: true, completion: {
            
            // Notify the rest of the app that login is finished
            NotificationCenter.default.post(name: Notification.Name("InitializeFavoriteVCData"), object: nil)
        })
    }
    
    // MARK: - Show Login Home VC
    
    func showLoginHomeVC()
    {
        // Set the selected tab to 0
        self.selectedIndex = 0
        
        // Show the login page on top of the first VC
        loginHomeVC = LoginHomeViewController(nibName: "LoginHomeViewController", bundle: nil)
        loginHomeVC.delegate = self
        loginHomeNav = TopNavigationController()
        loginHomeNav.viewControllers = [loginHomeVC]
        loginHomeNav.modalPresentationStyle = .fullScreen
        
        let firstVC = self.viewControllers?[0]
        firstVC?.present(loginHomeNav, animated: true)
        {
            
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.delegate = self
        
        // Calculate the top and bottom safe areas for use elsewhere in the app
        let window = UIApplication.shared.windows[0]
        if (window.safeAreaInsets.top > 0)
        {
            SharedData.topNotchHeight = Int(window.safeAreaInsets.top) - kStatusBarHeight;
        }
        else
        {
            SharedData.topNotchHeight = 0;
        }
        
        SharedData.bottomSafeAreaHeight = Int(window.safeAreaInsets.bottom)
        
        // Set the overall window background color so navigation looks better
        window.backgroundColor = UIColor.mpOffWhiteNavColor()

        // Load the tab bar icons and text color
        let tabBarItem0 = self.tabBar.items![0]
        let tabBarItem1 = self.tabBar.items![1]
        let tabBarItem2 = self.tabBar.items![2]
        
        let unselectedImage0 = UIImage(named: "LatestIcon")
        let selectedImage0 = UIImage(named: "LatestIconSelected")
        let unselectedImage1 = UIImage(named: "FollowingIcon")
        let selectedImage1 = UIImage(named: "FollowingIconSelected")
        let unselectedImage2 = UIImage(named: "ScoresIcon")
        let selectedImage2 = UIImage(named: "ScoresIconSelected")
        
        tabBarItem0.image = unselectedImage0!.withRenderingMode(.alwaysOriginal)
        tabBarItem0.selectedImage = selectedImage0!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem1.image = unselectedImage1!.withRenderingMode(.alwaysOriginal)
        tabBarItem1.selectedImage = selectedImage1!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem2.image = unselectedImage2!.withRenderingMode(.alwaysOriginal)
        tabBarItem2.selectedImage = selectedImage2!.withRenderingMode(.alwaysOriginal)

    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        // Add the center button's overlay container
        //self.addOverlayContainer()

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (kUserDefaults.string(forKey: kUserIdKey) == kEmptyGuid)
        {
            // Show the Login Home VC
            self.showLoginHomeVC()
        }
        else if (kUserDefaults.string(forKey: kUserIdKey) == kTestDriveUserId)
        {
            // Just get the School Info
            if let favs = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
            {
                print ("Test Drive user favorites count: " + String(favs.count))
                
                if (favs.count > 0)
                {
                    // Get the school info for each favorite to save into prefs
                    self.getNewSchoolInfo(favs)
                }
            }
        }
        else
        {
            // Login to the web
            self.webLogin()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerForNotifications()
            
            /*
            // Test the ZipCodeHelper
            let myZipCode = kUserDefaults.value(forKey: kUserZipKey) as! String
            let myState = ZipCodeHelper.state(forZipCode: myZipCode)
            let myLocation = ZipCodeHelper.location(forZipCode: myZipCode) as! Dictionary<String, String>
            print("Done")
             */
        }
    }
    
    override var shouldAutorotate: Bool
    {
        return ((self.selectedViewController?.shouldAutorotate) != nil)
        //return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return self.selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
        //return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return self.selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
