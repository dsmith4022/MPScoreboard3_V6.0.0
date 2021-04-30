//
//  VideoSettingsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/18/21.
//

import UIKit

class VideoSettingsViewController: UIViewController
{
    private var autoplayMode = 0
    
    @IBOutlet weak var allAutoplayButton: UIButton!
    @IBOutlet weak var wifiAutoplayButton: UIButton!
    @IBOutlet weak var noAutoplayButton: UIButton!
    
    // MARK: - Update Buttons
    
    private func updateButtons()
    {
        switch autoplayMode
        {
        case 0:
            noAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOn"), for: .normal)
            wifiAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOff"), for: .normal)
            allAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOff"), for: .normal)
        case 1:
            noAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOff"), for: .normal)
            wifiAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOn"), for: .normal)
            allAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOff"), for: .normal)
        case 2:
            noAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOff"), for: .normal)
            wifiAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOff"), for: .normal)
            allAutoplayButton.setBackgroundImage(UIImage(named: "RadioButtonOn"), for: .normal)
        default:
            break
        }
    }
    
    // MARK: - Gesture Recognizer Method
    
    @objc private func handleTripleTap()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Show", "Hide"], title: "MaxPreps App", message: "Debug Dialogs", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                kUserDefaults.setValue(NSNumber(booleanLiteral: true), forKey: kDebugDialogsKey)
            }
            else
            {
                kUserDefaults.setValue(NSNumber(booleanLiteral: false), forKey: kDebugDialogsKey)
            }
        }
        
        // Reset any "one time display" keys here for testing
    }
    
    // MARK: - Button Methods
    
    @IBAction func noAutoplayTouched(_ sender: UIButton)
    {
        autoplayMode = 0
        kUserDefaults.setValue(NSNumber.init(value: 0), forKey: kVideoAutoplayModeKey)
        self.updateButtons()
    }
    
    @IBAction func wifiAutoplayTouched(_ sender: UIButton)
    {
        autoplayMode = 1
        kUserDefaults.setValue(NSNumber.init(value: 1), forKey: kVideoAutoplayModeKey)
        self.updateButtons()
    }
    
    @IBAction func allAutoplayTouched(_ sender: UIButton)
    {
        autoplayMode = 2
        kUserDefaults.setValue(NSNumber.init(value: 2), forKey: kVideoAutoplayModeKey)
        self.updateButtons()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.title = "Video Settings"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(handleTripleTap))
        tripleTap.numberOfTapsRequired = 3
        
        var bottomTabBarPad = 0
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }
        
        let viewHeight = Int(kDeviceHeight) - SharedData.topNotchHeight - kStatusBarHeight - kNavBarHeight - SharedData.bottomSafeAreaHeight - bottomTabBarPad
        
        let hiddenTouchRegion = UIView(frame: CGRect(x: (kDeviceWidth - 240) / 2.0, y: CGFloat(viewHeight - 130), width: 240.0, height: 130.0))
        hiddenTouchRegion.backgroundColor = .clear
        hiddenTouchRegion.isMultipleTouchEnabled = true
        hiddenTouchRegion.isUserInteractionEnabled = true
        hiddenTouchRegion.addGestureRecognizer(tripleTap)
        self.view.addSubview(hiddenTouchRegion)

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        autoplayMode = kUserDefaults.value(forKey: kVideoAutoplayModeKey) as! Int
        self.updateButtons()
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
