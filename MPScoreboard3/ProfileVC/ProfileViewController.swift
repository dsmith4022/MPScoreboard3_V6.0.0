//
//  ProfileViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/19/21.
//

import UIKit
import AVFoundation

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    private var photoPicker : UIImagePickerController?
    private var cameraPicker : UIImagePickerController?
    
    private var settingsVC : SettingsViewController?
    private var webVC: WebViewController?
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    
    // MARK: - Delete Photo
    
    private func deleteUserImage()
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        LegacyFeeds.deleteUserImage(userId: userId) { (post, error) in
            if (error == nil)
            {
                self.userImageView.image = nil
            }
        }
    }
    
    // MARK: - Choose Photo from Library
    
    private func choosePhotoFromLibrary()
    {
        photoPicker = UIImagePickerController()
        photoPicker?.delegate = self
        photoPicker?.allowsEditing = true
        photoPicker?.sourceType = .photoLibrary
        photoPicker?.modalPresentationStyle = .fullScreen
        self.present(photoPicker!, animated: true)
        {
            
        }
    }
    
    // MARK: - Take Photo from Camera
    
    private func takePhotoFromCamera()
    {
        if (UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            if (authStatus == .authorized)
            {
                self.showCameraPicker()
            }
            else if (authStatus == .notDetermined)
            {
                // Requst access
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if (granted)
                    {
                        DispatchQueue.main.async
                        {
                            self.showCameraPicker()
                        }
                    }
                    else
                    {
                        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Oops...", message: "This app does not have access to the Camera.\nYou can enable access in the device's Privacy Settings.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                }
            }
            else if (authStatus == .restricted)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Oops...", message: "You've been restricted from using the camera on this device. Without camera access this feature won't work. Please contact the device owner so they can give you access.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Oops...", message: "This app does not have access to the Camera.\nYou can enable access in the device's Privacy Settings.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Oops...", message: "Camera is not available on this device.", lastItemCancelType: false) { (tag) in
                
            }
        }
    }
    
    private func showCameraPicker()
    {
        cameraPicker = UIImagePickerController()
        cameraPicker?.delegate = self
        cameraPicker?.allowsEditing = false
        cameraPicker?.sourceType = .camera
        cameraPicker?.showsCameraControls = false
        
        
        // iPhone 12s move the camera towards the middle of the view, so the transform is different
        // This is bad coding technique, but there is currently no workaround
        let deviceName = UIDevice.current.name.lowercased()
        
        if (deviceName.contains("iphone 12"))
        {
            // The -76 value was empirically calculated
            cameraPicker?.cameraViewTransform = CGAffineTransform.init(translationX: 0, y: -76.0)
        }
        else
        {
            // Non-iPhone12 devices set the capture view to the top of the screen
            // Shift the camera rect down so it is below the notch and status bar
            cameraPicker?.cameraViewTransform = CGAffineTransform.init(translationX: 0, y: CGFloat(SharedData.topNotchHeight + kStatusBarHeight))
        }
        
        self.addCameraOverlay(cameraPicker!)
        self.cameraPicker?.modalPresentationStyle = .fullScreen
        
        self.present(self.cameraPicker!, animated: true) {
            
        }
    }
    
    private func addCameraOverlay(_ imagePicker : UIImagePickerController)
    {
        let frameWidth = (imagePicker.cameraOverlayView?.frame.size.width)!
        let frameHeight = frameWidth * 1.333
        
        let outlineViewWidth = frameWidth
        let outlineViewHeight = outlineViewWidth
        
        let overlayContainer = UIView(frame: CGRect(x: 0, y: kStatusBarHeight + SharedData.topNotchHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - kStatusBarHeight - SharedData.topNotchHeight - SharedData.bottomSafeAreaHeight))
        overlayContainer.backgroundColor = .clear
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        cancelButton.setImage(UIImage(named: "StopVideo"), for: .normal)
        cancelButton.addTarget(self, action: #selector(self.cancelCameraButtonTouched), for: .touchUpInside)
        overlayContainer.addSubview(cancelButton)
        
        let outlineView = UIView(frame: CGRect(x: (frameWidth - outlineViewWidth) / 2.0, y: (frameHeight - outlineViewHeight) / 2.0, width: outlineViewWidth, height: outlineViewHeight))
        outlineView.backgroundColor = .clear
        outlineView.layer.cornerRadius = frameWidth / 2.0
        outlineView.layer.borderWidth = 2.0
        outlineView.layer.borderColor = UIColor.mpLightGrayColor().cgColor
        outlineView.clipsToBounds = true
        overlayContainer.addSubview(outlineView)
        
        let helperLabel = UILabel(frame: CGRect(x: 30.0, y: frameHeight + 20, width: overlayContainer.frame.size.width - 60, height: 20.0))
        helperLabel.font = .systemFont(ofSize: 13)
        helperLabel.textColor = UIColor.mpLightGrayColor()
        helperLabel.textAlignment = .center
        helperLabel.adjustsFontSizeToFitWidth = true
        helperLabel.minimumScaleFactor = 0.5
        helperLabel.text = "Adjust your camera so the image fills the circle"
        overlayContainer.addSubview(helperLabel)
        
        let takePictureButton = UIButton(type: .custom)
        takePictureButton.frame = CGRect(x: (overlayContainer.frame.size.width - 200) / 2, y: frameHeight + 70, width: 200, height: 40)
        takePictureButton.setTitle("TAKE PICTURE", for: .normal)
        takePictureButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        takePictureButton.backgroundColor = UIColor.mpWhiteColor()
        takePictureButton.layer.cornerRadius = 5.0
        takePictureButton.clipsToBounds = true
        takePictureButton.addTarget(self, action: #selector(self.takePictureTouched), for: .touchUpInside)
        overlayContainer.addSubview(takePictureButton)
        
        imagePicker.cameraOverlayView = overlayContainer
    }
    
    @objc private func cancelCameraButtonTouched()
    {
        self.dismiss(animated: true){
            
        }
    }
    
    @objc private func takePictureTouched()
    {
        cameraPicker?.takePicture()
    }
    
    // MARK: - Image Picker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (picker == cameraPicker)
        {
            // Scale the image to 300 x 300 so it can be used elsewhere on the website and still look good.
            let userImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let croppedImageWidth = userImage.size.width
            let croppedImageHeight = croppedImageWidth
            
            let croppedImage = ImageHelper.cropImage(userImage, in: CGRect(x: (userImage.size.width - croppedImageWidth) / 2.0, y: (userImage.size.height - croppedImageHeight) / 2.0, width: croppedImageWidth, height: croppedImageHeight))
            
            let scaledImage = ImageHelper.image(with: croppedImage, scaledTo:  CGSize(width: 300, height: 300))
            userImageView.image = scaledImage
            
            guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }
            
            // Call the feed to save the image to the DB
            LegacyFeeds.saveUserImage(userId: userId!, imageData: data) { (post, error) in
                
                self.dismiss(animated: true, completion:{
         
                    self.cameraPicker = nil;
                })
            }
        }
        else
        {
            // Scale the image to 300 x 300 so it can be used elsewhere on the website and still look good.
            let userImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
            let scaledImage = ImageHelper.image(with: userImage, scaledTo:  CGSize(width: 300, height: 300))
            userImageView.image = scaledImage
            
            guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }
            
            // Call the feed to save the image to the DB
            LegacyFeeds.saveUserImage(userId: userId!, imageData: data) { (post, error) in
                
                self.dismiss(animated: true, completion:{
         
                    self.photoPicker = nil;
                })
            }
            
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion:{
 
            self.photoPicker = nil;
        })
    }
    
    // MARK: - Load User Image
    
    func loadUserImage()
    {
        // Get the user image
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        self.userImageView.image = nil
        
        LegacyFeeds.getUserImage(userId: userId!) { (data, error) in
            
            if (error == nil)
            {
                let image = UIImage.init(data: data!)
                
                if (image != nil)
                {
                    self.userImageView.image = image
                }
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let label = UILabel(frame: CGRect(x: 16, y: 22, width: tableView.frame.size.width - 32, height: 20))
        label.font = UIFont.mpRegularFontWith(size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.mpDarkGrayColor()
        label.text = "ACCOUNT INFO"
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 17)
        cell?.accessoryType = .disclosureIndicator
        cell?.textLabel?.textColor = UIColor.mpBlackColor()
        
        if (indexPath.row == 0)
        {
            cell?.textLabel?.text = "Personal Information"
        }
        else
        {
            cell?.textLabel?.text = "Communication Preferences"
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var urlString : String = ""
        var titleString : String = ""
        
        if (indexPath.row == 0)
        {
            titleString = "Personal Info"
            
            if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
            {
                urlString = kMemberProfileHostDev
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
            {
                urlString = kMemberProfileHostDev
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
            {
                urlString = kMemberProfileHostStaging
            }
            else
            {
                urlString = kMemberProfileHostProduction
            }
        }
        else
        {
            titleString = "Preferences"
            
            if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
            {
                urlString = kSubscriptionsUrlDev
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
            {
                urlString = kSubscriptionsUrlDev
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
            {
                urlString = kSubscriptionsUrlStaging
            }
            else
            {
                urlString = kSubscriptionsUrlProduction
            }
        }
        
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = titleString
        webVC?.urlString = urlString
        webVC?.titleColor = UIColor.mpBlackColor()
        webVC?.navColor = UIColor.mpWhiteColor()
        webVC?.allowRotation = false
        webVC?.showShareButton = false
        webVC?.showNavControls = true
        webVC?.showScrollIndicators = true
        webVC?.showLoadingOverlay = false

        self.navigationController?.pushViewController(webVC!, animated: true)
        
    }
    
    // MARK: - Show Settings VC
    
    private func showSettingsVC()
    {
        settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        let settingsNav = TopNavigationController()
        settingsNav.viewControllers = [settingsVC] as! Array
        settingsNav.modalPresentationStyle = .fullScreen
        self.present(settingsNav, animated: true)
        {
            
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func settingsButtonTouched(_ sender: UIButton)
    {
        self.showSettingsVC()
    }
    
    @IBAction func backButtontouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Photo Library", "Use Camera", "Delete Photo", "Cancel"], title: "Select Photo Source", message: "", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                self.choosePhotoFromLibrary()
            }
            else if (tag == 1)
            {
                self.takePhotoFromCamera()
            }
            else if (tag == 2)
            {
                self.deleteUserImage()
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        
        self.view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        profileTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        //self.navigationItem.title = "Profile"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        profileTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        /*
        let settingsButton = UIButton(type: .custom)
        settingsButton.frame = CGRect(x: navView.frame.size.width - 46, y: 2, width: 30, height: 40)
        settingsButton.setImage(UIImage.init(named: "SettingsButton"), for: .normal)
        settingsButton.addTarget(self, action: #selector(self.settingsButtonTouched), for: .touchUpInside)
        navView.addSubview(settingsButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
         */
        
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.clipsToBounds = true
        self.loadUserImage()

        let firstName = kUserDefaults.string(forKey: kUserFirstNameKey)
        let lastName = kUserDefaults.string(forKey: kUserLastNameKey)
        let email = kUserDefaults.string(forKey: kUserEmailKey)
        
        if ((firstName != nil) && (lastName != nil))
        {
            userNameLabel.text = firstName! + " " + lastName!
        }
        else
        {
            userNameLabel.text = ""
        }
        
        if (email != nil)
        {
            userEmailLabel.text = kUserDefaults.string(forKey: kUserEmailKey)
        }
        else
        {
            userEmailLabel.text = ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)  
        
        // Pop the nav to the root if the user logged out
        if (settingsVC != nil)
        {
            let logout = settingsVC?.logoutTouched
            if (logout == true)
            {
                self.navigationController?.popToRootViewController(animated: false)
            }
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
