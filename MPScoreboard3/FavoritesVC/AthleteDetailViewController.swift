//
//  AthleteDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/23/21.
//

import UIKit

class AthleteDetailViewController: UIViewController
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var saveFavoriteButton: UIButton!
    @IBOutlet weak var removeFavoriteButton: UIButton!
    
    var selectedAthlete : Athlete?
    var showSaveFavoriteButton = false
    var showRemoveFavoriteButton = false
    var athleteChanged = false
    
    private var browserView: FavoritesBrowserView!
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveFavoriteButtonTouched(_ sender: UIButton)
    {
        let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        
        if (favoriteAthletes != nil) && (favoriteAthletes!.count >= kMaxFavoriteAthletesCount)
        {
            let messageTitle = String(kMaxFavoriteTeamsCount) + " Athlete Limit"
            let messageText = "The maximum number of favorites allowed is " + String(kMaxFavoriteAthletesCount) + ".  You must remove an athlete in order to add another."
            
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: messageTitle, message: messageText, lastItemCancelType: false) { (tag) in
                
            }
            return
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Ok"], title: "Save Athlete", message: "Do you want to save this athlete to your favorites?", lastItemCancelType: false) { (tag) in
            
            if (tag == 1)
            {
                // Save athlete code goes here
                let careerProfileId = self.selectedAthlete?.careerId
                
                MBProgressHUD.showAdded(to: self.view, animated: true)
                
                NewFeeds.saveUserFavoriteAthlete(careerProfileId!) { (error) in
                    
                    if error == nil
                    {
                        self.athleteChanged = true
                        
                        // Get the user favorites so the prefs get updated
                        NewFeeds.getUserFavoriteAthletes(completionHandler: { error in
                            
                            // Hide the busy indicator
                            DispatchQueue.main.async
                            {
                                MBProgressHUD.hide(for: self.view, animated: true)
                            }
                            
                            if (error == nil)
                            {
                                OverlayView.showCheckmarkOverlay(withMessage: "Success")
                                {
                                    
                                }
                                print("Download user favorite athletes success")
                                
                                self.saveFavoriteButton.isHidden = true
                                self.removeFavoriteButton.isHidden = false
                                self.showSaveFavoriteButton = false
                                self.showRemoveFavoriteButton = true
                            }
                            else
                            {
                                print("Download user favorite athletes error")
                            }
                        })
                        
                        //self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        print("Save user favorite athletes error")
                        
                        // Hide the busy indicator
                        DispatchQueue.main.async
                        {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                        
                        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Error", message: "There was a server error when saving this athlete.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func removeFavoriteButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Ok"], title: "Remove Athlete", message: "Do you want to remove this athlete from your favorites?", lastItemCancelType: false) { (tag) in
            
            if (tag == 1)
            {
                // Show the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                }
                
                let careerProfileId = self.selectedAthlete?.careerId
                
                NewFeeds.deleteUserFavoriteAthlete(careerProfileId!) { (error) in
                    
                    if error == nil
                    {       
                        self.athleteChanged = true
                        
                        // Get the user favorites so the prefs get updated
                        NewFeeds.getUserFavoriteAthletes(completionHandler: { error in
                            
                            // Hide the busy indicator
                            DispatchQueue.main.async
                            {
                                MBProgressHUD.hide(for: self.view, animated: true)
                            }
                            
                            if (error == nil)
                            {
                                //self.navigationController?.popViewController(animated: true)
                                print("Download user favorite athletes success")
                                
                                self.saveFavoriteButton.isHidden = false
                                self.removeFavoriteButton.isHidden = true
                                self.showSaveFavoriteButton = true
                                self.showRemoveFavoriteButton = false
                            }
                            else
                            {
                                print("Download user favorite athletes error")
                            }
                        })
                    }
                    else
                    {
                        // Hide the busy indicator
                        DispatchQueue.main.async
                        {
                            MBProgressHUD.hide(for: self.view, animated: true)
                        }
                                                
                        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "There was a problem removing this athlete from your favorites.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // This VC uses it's own Navigation bar
        
        var bottomTabBarPad = 0
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }

        // Explicitly set the header view size. The items within the view are pinned to the bottom
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + kNavBarHeight)
                
        let browserHeight = Int(kDeviceHeight) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - bottomTabBarPad
        
        // We need to create a new browser
        browserView = FavoritesBrowserView(frame: CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: browserHeight))
        self.view.addSubview(browserView)
        
        if (self.showSaveFavoriteButton == false)
        {
            saveFavoriteButton.isHidden = true
        }
        
        if (self.showRemoveFavoriteButton == false)
        {
            removeFavoriteButton.isHidden = true
        }
        
        //let schoolColorString = self.oldSelectedAthlete[kAthleteCareerProfileSchoolColor1Key] as! String
        let schoolColorString = self.selectedAthlete?.schoolColor
        let schoolColor = ColorHelper.color(fromHexString: schoolColorString)!
        
        navView.backgroundColor = schoolColor

        //let firstName = self.oldSelectedAthlete[kAthleteCareerProfileFirstNameKey] as! String
        //let lastName = self.oldSelectedAthlete[kAthleteCareerProfileLastNameKey] as! String
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        titleLabel.text = firstName! + " " + lastName!
        
        // Load the browser
        let careerProfileId = self.selectedAthlete?.careerId
        
        var subDomain = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            let branchValue = kUserDefaults.string(forKey: kBranchValue)
            subDomain = String(format: "branch-%@.fe", branchValue!.lowercased())
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            subDomain = "dev"
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            subDomain = "staging"
        }
        else
        {
            subDomain = "www"
        }
        
        var urlString = String(format: kCareerProfileHostGeneric, subDomain, careerProfileId!)
        
        // Add the app's custom query parameter
        urlString = urlString + "&" + kAppIdentifierQueryParam
        
        // Add the Omniture tracking query parameter
        urlString = ADBMobile.visitorAppend(to: URL(string: urlString))!.absoluteString
        
        browserView.loadUrl(urlString)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
    
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }

}
