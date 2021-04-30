//
//  NewsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit

class NewsViewController: UIViewController
{
    private var profileButton : UIButton?
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    
    // MARK: - Load User Image
    
    func loadUserImage()
    {
        // Get the user image
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            let image = UIImage.init(named: "SettingsButton")
            profileButton?.setImage(image, for: .normal)
            return
        }
        
        LegacyFeeds.getUserImage(userId: userId!) { (data, error) in
            
            if (error == nil)
            {
                let image = UIImage.init(data: data!)
                
                if (image != nil)
                {
                    self.profileButton?.setImage(image, for: .normal)
                }
                else
                {
                    let image = UIImage.init(named: "EmptyProfileButton")
                    self.profileButton?.setImage(image, for: .normal)
                }
            }
            else
            {
                let image = UIImage.init(named: "EmptyProfileButton")
                self.profileButton?.setImage(image, for: .normal)
            }
        }
    }
    
    // MARK: - Show Settings VC
    
    private func showSettingsVC()
    {
        let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        let settingsNav = TopNavigationController()
        settingsNav.viewControllers = [settingsVC] as Array
        settingsNav.modalPresentationStyle = .fullScreen
        self.present(settingsNav, animated: true)
        {
            
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func profileButtonTouched()
    {
        // Show the SettingsVC is a test drive user
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kTestDriveUserId)
        {
            self.showSettingsVC()
        }
        else
        {
            self.hidesBottomBarWhenPushed = true
                        
            let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
            self.navigationController?.pushViewController(profileVC, animated: true)
            
            self.hidesBottomBarWhenPushed = false
        } 
    }
    
    // MARK: - View Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // This VC uses it's own Navigation bar
        
        self.view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Add the profile button. The image will be updated later
        profileButton = UIButton(type: .custom)
        profileButton?.frame = CGRect(x: 20, y: 4, width: 34, height: 34)
        profileButton?.layer.cornerRadius = (profileButton?.frame.size.width)! / 2.0
        profileButton?.clipsToBounds = true
        //profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        profileButton?.addTarget(self, action: #selector(self.profileButtonTouched), for: .touchUpInside)
        navView?.addSubview(profileButton!)
        
        // Set the image to the settings icon if a Test Drive user right away
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            profileButton?.setImage(UIImage.init(named: "SettingsButton"), for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.loadUserImage()
            
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
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
