//
//  LoginHomeViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/18/21.
//

import UIKit

protocol LoginHomeViewControllerDelegate: AnyObject
{
    func loginHomeFinished()
}

class LoginHomeViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    weak var delegate: LoginHomeViewControllerDelegate?
    
    @IBOutlet weak var serverSegmentControl: UISegmentedControl!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var daveButton1: UIButton!
    @IBOutlet weak var daveButton2: UIButton!
    @IBOutlet weak var daveButton3: UIButton!
    
    let branchValues = ["A", "B", "C", "D", "E", "F", "G"]
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        kUserDefaults.setValue(title, forKey: kBranchValue)
        
        serverSegmentControl.setTitle("Branch-" + title!, forSegmentAt: 3)
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        serverSegmentControl.selectedSegmentIndex = 0
        kUserDefaults.setValue(kServerModeProduction, forKey: kServerModeKey)
    }
    
    // MARK: - Text Field Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Segment Control
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl)
    {
        if (sender.selectedSegmentIndex == 0)
        {
            kUserDefaults.setValue(kServerModeProduction, forKey: kServerModeKey)
            serverSegmentControl.setTitle("Branch", forSegmentAt: 3)
            kUserDefaults.setValue("", forKey: kBranchValue)
        }
        else if (sender.selectedSegmentIndex == 1)
        {
            kUserDefaults.setValue(kServerModeStaging, forKey: kServerModeKey)
            serverSegmentControl.setTitle("Branch", forSegmentAt: 3)
            kUserDefaults.setValue("", forKey: kBranchValue)
        }
        else if (sender.selectedSegmentIndex == 2)
        {
            kUserDefaults.setValue(kServerModeDev, forKey: kServerModeKey)
            serverSegmentControl.setTitle("Branch", forSegmentAt: 3)
            kUserDefaults.setValue("", forKey: kBranchValue)
        }
        else
        {
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            
            let picker = IQActionSheetPickerView(title: "Select Branch", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpRedColor()
            picker.titlesForComponents = [branchValues]
            picker.show()
        }
        
        kUserDefaults.synchronize()
    }
    
    // MARK: - Login Feed
    
    private func loginUser(email: String, password: String)
    {

            // Show the busy indicator
            MBProgressHUD.showAdded(to: self.view, animated: true)
            
            LegacyFeeds.getUserInfo(email: email, password: password, userId: "") { (result, error) in
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
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
                    
                    // Save to prefs
                    kUserDefaults.setValue(roleDictionary, forKey: kUserAdminRolesDictionaryKey)
                        
                    self.delegate?.loginHomeFinished()                    
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Login Error", message: "There is a problem with your email or password", lastItemCancelType: false) { (tag) in
                        
                    }
                }
            
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func loginButtonTouched(_ sender: UIButton)
    {
        if (emailTextField.text?.count == 0) || (passwordTextField.text?.count == 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Error", message: "Please enter your email and password", lastItemCancelType: false) { (tag) in
                
            }
            
            return
        }
        
        // Call the login feed
        self.loginUser(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func loginDaveButtonTouched(_ sender: UIButton)
    {
        self.loginUser(email: kDaveEmail, password: kDavePassword)
    }
    
    @IBAction func loginDave120ButtonTouched(_ sender: UIButton)
    {
        self.loginUser(email: kDave120Email, password: kDave120Password)
    }
    
    @IBAction func loginDave122ButtonTouched(_ sender: UIButton)
    {
        self.loginUser(email: kDave122Email, password: kDave122Password)
    }
    
    @IBAction func loginTestDriveUser(_ sender: UIButton)
    {
        kUserDefaults.setValue(kTestDriveUserId, forKey: kUserIdKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        
        // Set the token buster
        let now = NSDate()
        let timeInterval = Int(now.timeIntervalSinceReferenceDate)
        kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
        
        self.delegate?.loginHomeFinished()
    }
    
    @IBAction func loginTestDriveUserWithOneFavorite(_ sender: UIButton)
    {
        kUserDefaults.setValue(kTestDriveUserId, forKey: kUserIdKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        
        // Set the token buster
        let now = NSDate()
        let timeInterval = Int(now.timeIntervalSinceReferenceDate)
        kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
        
        let notifications = [] as Array
        
        let schoolId = "74c1621c-e0cf-4821-b5e1-3c8170c8125a"
        let allSeasonId = "22e2b335-334e-4d4d-9f67-a0f716bb1ccd"
        
        let newFavorite = [kNewGenderKey:"Boys", kNewSportKey:"Football", kNewLevelKey:"Varsity", kNewSeasonKey:"Fall", kNewSchoolIdKey:schoolId, kNewSchoolNameKey:"Oak Ridge", kNewSchoolFormattedNameKey:"Oak Ridge (El Dorado Hills, CA", kNewSchoolStateKey:"CA", kNewSchoolCityKey:"El Dorado Hills", kNewSchoolMascotUrlKey:"", kNewUserfavoriteTeamIdKey:0, kNewAllSeasonIdKey:allSeasonId, kNewNotificationSettingsKey:notifications] as [String : Any]
        
        let favorites = [newFavorite]
        kUserDefaults.setValue(favorites, forKey: kNewUserFavoriteTeamsArrayKey)
        
        self.delegate?.loginHomeFinished()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        
        self.navigationItem.title = "Login"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        
        /*
        let closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "CloseButtonBlack"), style: .done, target: self, action: #selector(closeButtonTouched))
        closeBarButtonItem.tintColor = .black
        self.navigationItem.leftBarButtonItem  = closeBarButtonItem
         */
        
        daveButton1.isEnabled = false
        daveButton2.isEnabled = false
        daveButton3.isEnabled = false

        #if DEBUG
        daveButton1.isEnabled = true
        daveButton2.isEnabled = true
        daveButton3.isEnabled = true
        #endif

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let selectedServer = kUserDefaults.value(forKey: kServerModeKey) as! String
        if (selectedServer == kServerModeProduction)
        {
            serverSegmentControl.selectedSegmentIndex = 0
        }
        else if (selectedServer == kServerModeStaging)
        {
            serverSegmentControl.selectedSegmentIndex = 1
        }
        else if (selectedServer == kServerModeDev)
        {
            serverSegmentControl.selectedSegmentIndex = 2
        }
        else
        {
            serverSegmentControl.selectedSegmentIndex = 3
            let branchValue = kUserDefaults.value(forKey: kBranchValue) as! String
            serverSegmentControl.setTitle("Branch-" + branchValue, forSegmentAt: 3)
        }
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
