//
//  LegalViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/18/21.
//

import UIKit

class LegalViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    private var webVC: WebViewController?
    
    @IBOutlet weak var legalTableView: UITableView!
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 22
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.0
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
        
        switch (indexPath.row)
        {
            case 0:
                cell?.textLabel?.text = "CBS Terms of Use"
                
            case 1:
                cell?.textLabel?.text = "CBS Privacy Policy"
                
            case 2:
                cell?.textLabel?.text = "CA Privacy/Info We Collect"
                
            case 3:
                cell?.textLabel?.text = "Do Not Sell My Personal Information"
                
            default:
                break;
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var urlString = ""
        var titleString = ""
        
        if (indexPath.row == 0)
        {
            titleString = "" //"CBS Terms of Use"
            urlString = kCBSTermsOfUseUrl
        }
        else if (indexPath.row == 1)
        {
            titleString = "" //"CBS Privacy Policy"
            urlString = kCBSPrivacyPolicyUrl
        }
        else if (indexPath.row == 2)
        {
            titleString = "" //CA Privacy/Info We Collect"
            urlString = kCAPrivacyPolicyUrl
        }
        else
        {
            titleString = "" //Do Not Sell My Personal Information"
            urlString = kCADoNotSellUrl
        }
        
        // Show support web view
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = titleString
        webVC?.urlString = urlString
        webVC?.titleColor = UIColor.mpBlackColor()
        webVC?.navColor = UIColor.mpOffWhiteNavColor()
        webVC?.allowRotation = false
        webVC?.showShareButton = false
        webVC?.showNavControls = false
        webVC?.showScrollIndicators = true
        webVC?.showLoadingOverlay = false

        self.navigationController?.pushViewController(webVC!, animated: true)

    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.title = "Legal"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        legalTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
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
