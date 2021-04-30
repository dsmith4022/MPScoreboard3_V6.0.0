//
//  ScoresViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit

class ScoresViewController: UIViewController
{
    private var webVC: WebViewController?
    
    // MARK: - Button Methods
    
    @IBAction func webButtonTouched(_ sender: UIButton)
    {
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = ""
        webVC?.urlString = "https://www.maxpreps.com"
        webVC?.titleColor = UIColor.mpWhiteColor()
        webVC?.navColor = .systemTeal
        webVC?.allowRotation = false
        webVC?.showShareButton = true
        webVC?.showNavControls = true
        webVC?.showScrollIndicators = false
        webVC?.showLoadingOverlay = true
        webVC?.showBannerAd = false

        self.navigationController?.pushViewController(webVC!, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    @IBAction func webButtonWithAdsTouched(_ sender: UIButton)
    {
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = ""
        webVC?.urlString = "https://www.maxpreps.com"
        webVC?.titleColor = UIColor.mpWhiteColor()
        webVC?.navColor = .systemTeal
        webVC?.allowRotation = false
        webVC?.showShareButton = true
        webVC?.showNavControls = true
        webVC?.showScrollIndicators = false
        webVC?.showLoadingOverlay = true
        webVC?.showBannerAd = true

        self.navigationController?.pushViewController(webVC!, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        self.navigationItem.title = "Scores"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpBoldFontWith(size: kNavBarFontSize)]
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
    }

    override var shouldAutorotate: Bool
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

