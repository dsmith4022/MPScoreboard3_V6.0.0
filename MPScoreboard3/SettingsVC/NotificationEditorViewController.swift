//
//  NotificationEditorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/23/21.
//

import UIKit

class NotificationEditorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var favorite = [:] as Dictionary<String, Any>
    var valueChanged = false
    var alerts = [] as Array
    
    @IBOutlet weak var notificationTableView: UITableView!
    
    // MARK: - Update Database Method
    
    private func updateDatabase(alert: Dictionary<String,Any>)
    {
        let alertId = alert[kNewNotificationUserFavoriteTeamNotificationSettingIdKey] as! Int
        let isEnabled = alert[kNewNotificationIsEnabledForAppKey] as! Bool
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        NewFeeds.updateTeamNotificationSetting(alertId, switchValue: isEnabled) { (error) in
            
            DispatchQueue.main.async
            {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            if (error == nil)
            {
                print("Update Notification Success")
            }
            else
            {
                print("Update Notification Failed")
            }
        }
    }
    
    // MARK: - Switch Changed Method
    
    @objc private func switchChanged(_ sender: UISwitch)
    {
        let index = sender.tag - 100
        let currentAlerts = self.favorite[kNewNotificationSettingsKey] as! Array<Any>
        var newAlerts = self.favorite[kNewNotificationSettingsKey] as! Array<Any>
        var newAlert = currentAlerts[index] as! Dictionary<String, Any>
        
        newAlert.updateValue(NSNumber(booleanLiteral: sender.isOn), forKey: kNewNotificationIsEnabledForAppKey)
        newAlerts[index] = newAlert
        
        self.favorite.updateValue(newAlerts, forKey: kNewNotificationSettingsKey)
        self.valueChanged = true
        
        self.updateDatabase(alert: newAlert)
    }
    
    // MARK: - Button Method
    
    @objc private func infoButtonTouched()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Game Reporter Status", message: "This will send you a notification when the game has a Reporter, when the Reporter has checked-in at the game, or if the Reporter cancels.", lastItemCancelType: false) { (tag) in
            
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return alerts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 22.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 22.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 22))
        view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 17)
        
        // Remove any switches and the info button in case the cell is recycled
        for view in cell!.contentView.subviews
        {
            if ((view.tag == (100 + indexPath.row)) || (view.tag == 200))
            {
                view.removeFromSuperview()
            }
        }
        
        let alert = alerts[indexPath.row] as! Dictionary<String, Any>
        
        var title = alert[kNewNotificationNameKey] as! String
        
        if (title == "Game Scorer Status")
        {
            title = "Game Reporter Status"
        }
        
        cell?.textLabel?.text = title
        
        // Add an info button next to "Game Reporter Status"
        if (title == "Game Reporter Status")
        {
            let infoButton = UIButton(type: .custom)
            infoButton.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
            infoButton.center = CGPoint(x: 206.0, y: 24.0)
            infoButton.setBackgroundImage(UIImage(named: "InfoButton"), for: .normal)
            infoButton.addTarget(self, action: #selector(infoButtonTouched), for: .touchUpInside)
            cell?.contentView.addSubview(infoButton)
        }
        
        // Add a notification switch
        let notificationSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        notificationSwitch.center = CGPoint(x: tableView.frame.size.width - (notificationSwitch.bounds.size.width / 2.0) - 12, y: 24.0)
        notificationSwitch.backgroundColor = .clear
        notificationSwitch.tag = 100 + indexPath.row
        notificationSwitch.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        notificationSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        cell?.contentView.addSubview(notificationSwitch)
        
        let switchEnabled = alert[kNewNotificationIsEnabledForAppKey] as! Bool
        
        if (switchEnabled == true)
        {
            notificationSwitch.isOn = true
        }
        
        // Disable the "Rankings" switch if not Varsity, set the valueChanged flag to YES
        let teamLevel = self.favorite[kNewLevelKey] as! String
        
        if ((teamLevel != "Varsity") && (title == "Rankings"))
        {
            notificationSwitch.isOn = false
            notificationSwitch.isEnabled = false
            cell?.textLabel?.alpha = 0.4
            cell?.textLabel?.text = "Rankings (Varsity Only)"
            self.valueChanged = true
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.title = "Notification Settings"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        notificationTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        self.view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        alerts = self.favorite[kNewNotificationSettingsKey] as! Array
        //let alertsCopy = alerts
        //print("Alert Count:" + String(alertsCopy.count))
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
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
