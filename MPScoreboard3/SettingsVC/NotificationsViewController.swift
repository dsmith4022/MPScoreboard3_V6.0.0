//
//  NotificationsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/18/21.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private var systemNotificationsEnabled = false
    private var favoritesArray = [] as Array
    //private var selectedFavorite = [:] as Dictionary<String, Any>
    //private var selectedItemIndex = 0
    private var notificationEditorVC : NotificationEditorViewController?
    
    @IBOutlet weak var padView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var notificationEnableSwitch: UISwitch!
    @IBOutlet weak var favoritesTableView: UITableView!
    
    // MARK: - Update Notifications Database
    
    private func updateNotificationsDatabase()
    {
        return
    }
    
    // MARK: - Get User Favorite Teams
    
    private func getUserFavoriteTeamsFromDatabase()
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        NewFeeds.getUserFavoriteTeams(completionHandler: { error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            if error == nil
            {
                self.updateNotificationsDatabase()
            }
            else
            {
                print("Download user favorites error")
            }
        })
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoritesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.font = UIFont.mpSemiBoldFontWith(size: 17)
        cell?.detailTextLabel?.font = UIFont.mpRegularFontWith(size: 13)
        
        if (favoritesArray.count > 0)
        {
            let favorite = favoritesArray[indexPath.row] as! Dictionary<String, Any>
            let name = favorite[kNewSchoolNameKey] as! String
            let gender = favorite[kNewGenderKey] as! String
            let sport = favorite[kNewSportKey] as! String
            let level = favorite[kNewLevelKey] as!String
            let season = favorite[kNewSeasonKey] as! String
            
            cell?.textLabel?.text = name
            cell?.detailTextLabel?.text = String(format: "%@ %@ %@ (%@)", gender, level, sport, season)   
            
            let switchStatus = (kUserDefaults.value(forKey: kNotificationMasterEnableKey)) as! Bool
            if ((switchStatus == true) && (self.systemNotificationsEnabled == true))
            {
                cell?.accessoryType = .disclosureIndicator
                cell?.selectionStyle = .gray
                cell?.textLabel?.textColor = UIColor.mpBlackColor()
                cell?.detailTextLabel?.textColor = UIColor.mpDarkGrayColor()
            }
            else
            {
                cell?.accessoryType = .none
                cell?.selectionStyle = .none
                cell?.textLabel?.textColor = UIColor.mpLightGrayColor()
                cell?.detailTextLabel?.textColor = UIColor.mpLightGrayColor()
            }
        }
        else
        {
            cell?.accessoryType = .none
            cell?.selectionStyle = .none
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            cell?.detailTextLabel?.textColor = UIColor.mpDarkGrayColor()
            cell?.textLabel?.text = "No Faavorite Teams"
            cell?.detailTextLabel?.text = ""
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (favoritesArray.count > 0)
        { 
            let switchStatus = (kUserDefaults.value(forKey: kNotificationMasterEnableKey)) as! Bool
            if ((switchStatus == true) && (self.systemNotificationsEnabled == true))
            {
                //selectedItemIndex = indexPath.row
                
                let favorite = favoritesArray[indexPath.row] as! Dictionary<String, Any>
                
                // Open the Notification Editor
                notificationEditorVC = NotificationEditorViewController(nibName: "NotificationEditorViewController", bundle: nil)
                notificationEditorVC?.favorite = favorite
                self.navigationController?.pushViewController(notificationEditorVC!, animated: true)
            }
        }
    }
    
    // MARK: - Return from Background Notification
    
    @objc private func returningFromBackground()
    {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
            }
            
            DispatchQueue.main.async
            {
                self.favoritesTableView.reloadData()
                
                if (((kUserDefaults.value(forKey: kNotificationMasterEnableKey) != nil) == true) && self.systemNotificationsEnabled == true)
                {
                    self.notificationEnableSwitch.isOn = true
                }
                else
                {
                    self.notificationEnableSwitch.isOn = false
                }
            }
        })
    }
    
    // MARK: - Switch Methods
    
    @IBAction func notificationsSwitchChanged(_ sender: UISwitch)
    {
        // Let the user know that the system notifications are disabled
        if (systemNotificationsEnabled == false)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "System notifications are disabled.", lastItemCancelType: false) { (tag) in
                self.notificationEnableSwitch.isOn = false
                return
            }
        }
        
        if (sender.isOn)
        {
            kUserDefaults.setValue(NSNumber(booleanLiteral: true), forKey: kNotificationMasterEnableKey)
        }
        else
        {
            kUserDefaults.setValue(NSNumber(booleanLiteral: false), forKey: kNotificationMasterEnableKey)
        }
        
        // This dims the table
        favoritesTableView.reloadData()
        
        // Update the notifications database
        self.updateNotificationsDatabase()
    }
    
    // MARK: - Button Methods
    
    @IBAction func systemSettingsButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Open Settings", "Cancel"], title: "MaxPreps App", message: "The application needs to open the Settings app to change notification preferences.", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else
                {
                    return
                }

                if UIApplication.shared.canOpenURL(settingsUrl)
                {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        
                    })
                }
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.title = "Notifications"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        padView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        headerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(returningFromBackground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        favoritesArray = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)!
        
        // Update the notifications DB if something changed in the notification editor
        if let value = notificationEditorVC?.valueChanged
        {
            if (value == true)
            {
                self.getUserFavoriteTeamsFromDatabase()
            }
        }
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
            }
            
            DispatchQueue.main.async
            {
                let switchStatus = (kUserDefaults.value(forKey: kNotificationMasterEnableKey)) as! Bool
                if ((switchStatus == true) && (self.systemNotificationsEnabled == true))
                {
                    self.notificationEnableSwitch.isOn = true
                }
                else
                {
                    self.notificationEnableSwitch.isOn = false
                }
                
                self.favoritesTableView.reloadData()
            }
        })
        
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
