//
//  RoleSelectorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/11/21.
//

import UIKit

class RoleSelectorViewController: UIViewController
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var headCoachButton: UIButton!
    @IBOutlet weak var assistantCoachButton: UIButton!
    @IBOutlet weak var statisticianButton: UIButton!
    @IBOutlet weak var athleteButton: UIButton!
    @IBOutlet weak var parentButton: UIButton!
    @IBOutlet weak var athleticDirectorButton: UIButton!
    @IBOutlet weak var schoolAdministratorButton: UIButton!
    
    var selectedTeam : Team?
    var userRole = ""
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        {
            
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + kNavBarHeight)
        
        headCoachButton.layer.cornerRadius = 8
        assistantCoachButton.layer.cornerRadius = 8
        statisticianButton.layer.cornerRadius = 8
        athleteButton.layer.cornerRadius = 8
        parentButton.layer.cornerRadius = 8
        athleticDirectorButton.layer.cornerRadius = 8
        schoolAdministratorButton.layer.cornerRadius = 8
        
        headCoachButton.clipsToBounds = true
        assistantCoachButton.clipsToBounds = true
        statisticianButton.clipsToBounds = true
        athleteButton.clipsToBounds = true
        parentButton.clipsToBounds = true
        athleticDirectorButton.clipsToBounds = true
        schoolAdministratorButton.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
            
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
