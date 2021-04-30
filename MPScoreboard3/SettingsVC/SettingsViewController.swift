//
//  SettingsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/21.
//

import UIKit
import WebKit
import MessageUI

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate
{
    var logoutTouched = false
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    private var menuList1 = Array<String>()
    private var menuList2 = Array<String>()
    private var menuList3 = Array<String>()
    private var webVC: WebViewController?
    
    // MARK: - Mail VC Delegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        if (result == .sent)
        {
            print("Mail Sent")
        }
        
        self.dismiss(animated: true)
        {
            
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return menuList1.count
        }
        else if (section == 1)
        {
            return menuList2.count
        }
        else
        {
            return menuList3.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 22.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 2)
        {
            return 100
        }
        else
        {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        view.backgroundColor = UIColor.mpHeaderBackgroundColor()
            
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 2)
        {
            let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width - 40, height: 100))
            label.font = UIFont.mpRegularFontWith(size: 14)
            label.numberOfLines = 0
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.textColor = UIColor.mpDarkGrayColor()

            // Add some app information
            let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYear = dateFormatter.string(from: Date())
            
            label.text = "Version: " + shortVersion + " (Build " + version + ")\nCopyright 2015-" + currentYear + ", CBS MaxPreps, Inc."
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
            view.backgroundColor = UIColor.mpHeaderBackgroundColor()
            view.addSubview(label)
            
            return view
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 17)
        
        if (indexPath.section == 0)
        {
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            cell?.textLabel?.text = menuList1[indexPath.row]
            cell?.detailTextLabel?.text = ""
        }
        else if (indexPath.section == 1)
        {
            cell?.accessoryType = .disclosureIndicator
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            cell?.textLabel?.text = menuList2[indexPath.row]
            cell?.detailTextLabel?.text = ""
        }
        else
        {
            cell?.accessoryType = .none
            cell?.textLabel?.textColor = UIColor.mpRedColor()
            cell?.textLabel?.text = menuList3[indexPath.row]
            cell?.detailTextLabel?.textColor = UIColor.mpRedColor()
            cell?.detailTextLabel?.font = UIFont.mpItalicFontWith(size: 12)
            
            if (kUserDefaults.object(forKey: kServerModeKey) as! String == kServerModeBranch)
            {
                let branchValue = kUserDefaults.object(forKey: kBranchValue) as! String
                cell?.detailTextLabel?.text = "Branch-" + branchValue + " Server"
            }
            else if (kUserDefaults.object(forKey: kServerModeKey) as! String == kServerModeDev)
            {
                cell?.detailTextLabel?.text = "Dev Server"
            }
            else if (kUserDefaults.object(forKey: kServerModeKey) as! String == kServerModeStaging)
            {
                cell?.detailTextLabel?.text = "Staging Server"
            }
            else
            {
                cell?.detailTextLabel?.text = ""
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0)
        {
            if (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId)
            {
                if (indexPath.row == 0)
                {
                    // Show the Notifications VC
                    let notificationsVC = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
                    self.navigationController?.pushViewController(notificationsVC, animated: true)
                }
                else if (indexPath.row == 1)
                {
                    // Show the Video Settings VC
                    let videoSettingsVC = VideoSettingsViewController(nibName: "VideoSettingsViewController", bundle: nil)
                    self.navigationController?.pushViewController(videoSettingsVC, animated: true)
                }
                
            }
            else
            {
                // Only the video settings are shown
                let videoSettingsVC = VideoSettingsViewController(nibName: "VideoSettingsViewController", bundle: nil)
                self.navigationController?.pushViewController(videoSettingsVC, animated: true)
            }
        }
        else if (indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                // Show email
                if (MFMailComposeViewController.canSendMail())
                {
                    let feedbackEmailController = MFMailComposeViewController()
                    feedbackEmailController.mailComposeDelegate = self
                    feedbackEmailController.setSubject("MaxPreps App Feedback")
                    feedbackEmailController.setToRecipients(["support@maxpreps.com"])
                    //feedbackEmailController.setCcRecipients(["stoy@maxpreps.com"])
                    feedbackEmailController.setMessageBody("", isHTML: false)
                    feedbackEmailController.modalPresentationStyle = .fullScreen
                    self.present(feedbackEmailController, animated: true)
                    {
                        
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "This device can not send email.", lastItemCancelType: false) { (tag) in
                        
                    }
                }
            }
            else if (indexPath.row == 1)
            {
                // Show the legalVC
                let legalVC = LegalViewController(nibName: "LegalViewController", bundle: nil)
                self.navigationController?.pushViewController(legalVC, animated: true)
            }
            else if (indexPath.row == 2)
            {
                // Show support web view
                webVC = WebViewController(nibName: "WebViewController", bundle: nil)
                webVC?.titleString = "Support"
                webVC?.urlString = kTechSupportUrl
                webVC?.titleColor = UIColor.mpBlackColor()
                webVC?.navColor = UIColor.mpOffWhiteNavColor()
                webVC?.allowRotation = false
                webVC?.showShareButton = false
                webVC?.showNavControls = true
                webVC?.showScrollIndicators = true
                webVC?.showLoadingOverlay = false

                self.navigationController?.pushViewController(webVC!, animated: true)
            }
            else
            {
                // Show the UpdateSchoolsVC
                let updateSchoolsVC = UpdateSchoolsViewController(nibName: "UpdateSchoolsViewController", bundle: nil)
                self.navigationController?.pushViewController(updateSchoolsVC, animated: true)
            }
        }
        else
        {
            // Logout
            self.logoutUser()
        }
    }
    
    // MARK: - Clear User Preferences and Dismiss
    
    private func clearUserPrefsAndDismiss()
    {
        // Clear out the user's prefs
        kUserDefaults.setValue(kEmptyGuid, forKey: kUserIdKey)
        kUserDefaults.removeObject(forKey: kNewUserFavoriteTeamsArrayKey)
        kUserDefaults.removeObject(forKey: kNewSchoolInfoDictionaryKey)
        kUserDefaults.removeObject(forKey: kUserFavoriteAthletesArrayKey)
        kUserDefaults.removeObject(forKey: kUserAdminRolesDictionaryKey)
        kUserDefaults.setValue("", forKey: kUserEmailKey)
        kUserDefaults.setValue("", forKey: kUserFirstNameKey)
        kUserDefaults.setValue("", forKey: kUserLastNameKey)
        kUserDefaults.setValue("", forKey: kUserZipKey)
        kUserDefaults.setValue("", forKey: kTokenBusterKey)
        kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
        kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteSectionKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        
        /*
         [prefs setObject:kDefaultEmptyValue forKey:kUserObjectEmailKey];
         //[prefs setObject:kDefaultEmptyValue forKey:kUserObjectPasswordKey];
         [prefs setObject:kEmptyGuid forKey:kUserObjectUserIdKey];
         [prefs setObject:kDefaultEmptyValue forKey:kUserObjectRoleKey];
         [prefs setObject:@"" forKey:kUserObjectFirstNameKey];
         [prefs setObject:@"" forKey:kUserObjectLastNameKey];
         [prefs setObject:@"" forKey:kUserObjectZipKey];
         [prefs setObject:kDefaultSchoolState forKey:kUserObjectStateKey];
         [prefs setObject:kDefaultZipCode forKey:kUserObjectZipKey];
         [prefs setObject:kDefaultSchoolLocation forKey:kCurrentLocationKey];
         [prefs setObject:kDefaultEmptyValue forKey:kUserObjectRoleKey];
         [prefs removeObjectForKey:kUserObjectAdminRolesKey];
         [prefs removeObjectForKey:KCookieSaved_Key];
             
         [prefs setObject:@"" forKey:kTokenBusterKey];
         
         [prefs setObject:[NSNumber numberWithInt:0] forKey:kTeamsAppPromoEventCountKey];
         [prefs setObject:@"No" forKey:kTeamsAppPromoShownOnceKey];
         
         // Kill any live scoring data structures
         [prefs removeObjectForKey:kActiveGameInfoDictionary];
         [prefs removeObjectForKey:kActiveGamePreGameCommentary];
         [prefs removeObjectForKey:kActiveGameEvents];
         
         [prefs removeObjectForKey:kActiveTeamAInfo];
         [prefs removeObjectForKey:kActiveTeamBInfo];
         [prefs removeObjectForKey:kActiveTeamARoster];
         [prefs removeObjectForKey:kActiveTeamBRoster];
         */
        
        // Clear the cookie jar
        let cookieJar = HTTPCookieStorage.shared

        for cookie in cookieJar.cookies!
        {
            if cookie.domain.contains(".maxpreps.com")
            {
                cookieJar.deleteCookie(cookie)
            }
        }
        
        // Clear the WKWebView cookies
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
        { records in records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            print("Cookie ::: \(record) deleted")
            
        }}
        
        // Set the logoutTouched variable so the profileVC can pop to the root
        self.logoutTouched = true
        
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    // MARK: - Logout User
    
    private func logoutUser()
    {
        // Just Logout if a test drive user
        if (kUserDefaults .string(forKey: kUserIdKey) == kTestDriveUserId)
        {
            self.clearUserPrefsAndDismiss()
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { [self] action in
            
            alert.dismiss(animated: true) { [self] in
                
                self.clearUserPrefsAndDismiss()
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        alert.modalPresentationStyle = .fullScreen
        present(alert, animated: true)
      
    }
    
    // MARK: - Load Data Arrays
    
    private func loadDataArrays()
    {
        // Section 0
        if (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId)
        {
            menuList1.append("Notifications")
        }
        
        menuList1.append("Video Settings")
        
        // Section 1
        menuList2.append("Leave Feedback")
        menuList2.append("Legal")
        menuList2.append("Support")
        menuList2.append("Update School Database")
        
        // Section 2
        if (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId)
        {
            menuList3.append("Log Out")
        }
        else
        {
            menuList3.append("Sign up and Log in")
        }
    }
    
    // MARK: - Button Methods
    
    @objc func closeButtonTouched()
    {
        self.presentingViewController?.dismiss(animated: true, completion:
        {
            
        })
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        self.view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        settingsTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        self.navigationItem.title = "Settings"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "CloseButtonBlack"), style: .done, target: self, action: #selector(closeButtonTouched))
        closeBarButtonItem.tintColor = UIColor.mpBlackColor()
        self.navigationItem.leftBarButtonItem  = closeBarButtonItem
        
        self.loadDataArrays()
        
        // Test Staging, Dev, and Branch
        //kUserDefaults.setValue(kServerModeProduction, forKey: kServerModeKey)
        //kUserDefaults.setValue("", forKey: kBranchValueKey)
        
        /*
         // Test Code
        switch SharedData.deviceType
        {
        case DeviceType.iphone:
            deviceTypeLabel.text = "Device: iPhone"
        case DeviceType.ipad:
            deviceTypeLabel.text = "Device: iPad"
        default:
            deviceTypeLabel.text = "Unknown Device"
        }
        
        switch SharedData.deviceAspectRatio
        {
        case AspectRatio.low:
            deviceAspectRatioLabel.text = "Low Aspect Ratio"
        case AspectRatio.medium:
            deviceAspectRatioLabel.text = "Medium Aspect Ratio"
        case AspectRatio.high:
            deviceAspectRatioLabel.text = "High Aspect Ratio"
        default:
            deviceAspectRatioLabel.text = "Unknow Aspect Ratio"
        }
        */
        
  
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
