//
//  SearchViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/25/21.
//

import UIKit

class SearchViewController: UIViewController, ThreeSegmentControlViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, AthleteSearchViewDelegate
{    
    private var teamSelectorVC: TeamSelectorViewController?
    private var localSchools = Array<School>()
    private var filteredSchools = Array<School>()
        
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldBackground: UIView!
    @IBOutlet weak var searchTableView: UITableView!

    private var bottomTabBarPad = CGFloat(0)
    
    private var threeSegmentControl : ThreeSegmentControlView?
    private var athleteSearchView: AthleteSearchView!
    
    let kEmptyGenderSportButtonTitle = "Select Sport (required)"
    let kDefaultFilterButtonTitle = "Filter: %@"
    let kDefaultFilterState = "All States"
    
    // MARK: - Sort and Filter Schools
    
    private func sortLocalSchools()
    {
        localSchools = SharedData.allSchools.sorted(by: { $0.searchDistance < $1.searchDistance })
        
        //sortedSchools = (SharedData.allSchools as NSArray).sortedArray(using: [NSSortDescriptor(key: kSearchDistanceKey, ascending: true)]) as! [[String:AnyObject]]
        
        if (localSchools.count >= 20)
        {
            let end = localSchools.count - 1
            let range = 20...end
            localSchools.removeSubrange(range)
                
            searchTableView.reloadData()
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "The school database is corrupted.", lastItemCancelType: false) { (tag) in }
        }
        //print("Done")
    }

    
    private func updateTableUsingSearchFilter()
    {
        if (searchTextField.text!.count > 0)
        {
            // Filter by name
            filteredSchools.removeAll()
            
            var unsortedFilteredSchools = Array<School>()
            
            for school in SharedData.allSchools
            {
                let name = school.name.lowercased()
                
                if (name.count >= searchTextField.text!.count)
                {
                    if (name.starts(with: searchTextField.text!.lowercased()))
                    {
                        unsortedFilteredSchools.append(school)
                    }
                }
            }
            
            // Sort
            filteredSchools = unsortedFilteredSchools.sorted(by: { $0.searchDistance < $1.searchDistance })
            
            searchTableView.reloadData()
            
            print("Filtered School Count: " + String(filteredSchools.count))
        }
        else
        {
            self.sortLocalSchools()
        }
    }
    
    // MARK: - Build Years Array
    /*
    private func buildYearsArray()
    {
        let dateFormatter = DateFormatter()
        
        // Get the current year
        dateFormatter.dateFormat = "yy"
        let currentYearString = dateFormatter.string(from: Date())
        let currentYear = Int(currentYearString)!
        
        // Get the current month
        dateFormatter.dateFormat = "M"
        let currentMonth = dateFormatter.string(from: Date())
        
        print("Month: " + currentMonth + ", Year: " + currentYearString)
        
        var currentFirstYear = 0

        switch currentMonth
        {
        case "1":
            currentFirstYear = currentYear - 1
        case "2":
            currentFirstYear = currentYear - 1
        case "3":
            currentFirstYear = currentYear - 1
        case "4":
            currentFirstYear = currentYear - 1
        case "5":
            currentFirstYear = currentYear - 1
        case "6":
            currentFirstYear = currentYear - 1
        case "7":
            currentFirstYear = currentYear - 1
        case "8":
            currentFirstYear = currentYear
        case "9":
            currentFirstYear = currentYear
        case "10":
            currentFirstYear = currentYear
        case "11":
            currentFirstYear = currentYear
        case "12":
            currentFirstYear = currentYear
        default:
            currentFirstYear = 0
        }
        
        // Build an array of years starting in 04
        let initialYear = 3
        var firstYear = 0
        var secondYear = 0
        
        //for index in stride(from: initialYear, to: currentFirstYear, by: 1) //initialYear..<currentFirstYear
        for index in stride(from: currentFirstYear, to: initialYear, by: -1)
        {
            firstYear = index
            secondYear = index + 1
            var firstYearString = ""
            var secondYearString = ""
            
            if (firstYear < 10)
            {
                firstYearString = String(format: "0%d", firstYear)
            }
            else
            {
                firstYearString = String(firstYear)
            }
            
            if (secondYear < 10)
            {
                secondYearString = String(format: "0%d", secondYear)
            }
            else
            {
                secondYearString = String(secondYear)
            }
            
            let compositeYearString = String(format: "%@-%@", firstYearString, secondYearString)
            
            yearsArray.append(compositeYearString)
        }
        
        /*
        // Debug
        for year in yearsArray
        {
            print(year)
        }
        */
    }
    */
    
    // MARK: - TextField Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (threeSegmentControl?.selectedSegment == 0)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
            {
                self.updateTableUsingSearchFilter()
            }
        }

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        if (threeSegmentControl?.selectedSegment == 0)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
            {
                self.updateTableUsingSearchFilter()
            }
        }
        
        return true
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (searchTextField.text!.count > 0)
        {
            return filteredSchools.count
        }
        else
        {
            return localSchools.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width - 40, height: 32))
        label.font = UIFont.mpRegularFontWith(size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.mpLightGrayColor()
        
        if (searchTextField.text!.count == 0)
        {
            label.text = "NEARBY"
        }
        else
        {
            label.text = String(format: "RESULTS (%ld)", filteredSchools.count)   //"LOCAL"
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 32))
        view.backgroundColor = UIColor.mpWhiteColor()
        view.addSubview(label)
        
        //let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        //horizLine.backgroundColor = UIColor.mpSeparatorLineColor()
        //view.addSubview(horizLine)
        
        return view

    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        // Remove the star image
        for view in cell!.contentView.subviews
        {
            if (view.tag >= 100)
            {
                view.removeFromSuperview()
            }
        }
        
        cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
        cell?.selectionStyle = .none
        cell?.textLabel?.text = ""
        cell?.detailTextLabel?.text = ""
        cell?.detailTextLabel?.numberOfLines = 2
        cell?.textLabel?.textColor = UIColor.mpBlackColor()
        cell?.detailTextLabel?.textColor = UIColor.mpLightGrayColor()
        cell?.detailTextLabel?.font = UIFont.mpRegularFontWith(size: 14)
        
        cell?.selectionStyle = .default
        cell?.textLabel?.font = UIFont.mpBoldFontWith(size: 16)
        
        if (searchTextField.text!.count > 0)
        {
            let school:School = filteredSchools[indexPath.row]
            cell?.textLabel?.text = school.name
            
            if (school.city.count > 0)
            {
                cell?.detailTextLabel?.text = String(format: "%@, %@", school.city, school.state)
            }
            else
            {
                cell?.detailTextLabel?.text = school.state
            }
        }
        else
        {
            let school:School = localSchools[indexPath.row]
            cell?.textLabel?.text = school.name
            
            if (school.city.count > 0)
            {
                cell?.detailTextLabel?.text = String(format: "%@, %@", school.city, school.state)
            }
            else
            {
                cell?.detailTextLabel?.text = school.state
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectedSchool : School?
        
        if (searchTextField.text!.count > 0)
        {
            selectedSchool = filteredSchools[indexPath.row]
        }
        else
        {
            selectedSchool = localSchools[indexPath.row]
        }
        
        // Show the TeamSelectorVC
        //self.hidesBottomBarWhenPushed = true
        
        teamSelectorVC = TeamSelectorViewController(nibName: "TeamSelectorViewController", bundle: nil)
        teamSelectorVC?.selectedSchool = selectedSchool
        self.navigationController?.pushViewController(teamSelectorVC!, animated: true)
        
        //self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - AthleteSearchView Delegate
    
    func athleteSearchDidSelectAthlete(selectedAthlete: Athlete, showSaveFavoriteButton: Bool, showRemoveFavoriteButton: Bool)
    {
        let athleteDetailVC = AthleteDetailViewController(nibName: "AthleteDetailViewController", bundle: nil)
        athleteDetailVC.selectedAthlete = selectedAthlete
        athleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        athleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        
        self.navigationController?.pushViewController(athleteDetailVC, animated: true)
    }
    
    // MARK: - ThreeSegmentControl Delegate
    
    func segmentChanged()
    {
        searchTextField.resignFirstResponder()
        searchTextField.text = ""
        
        if (threeSegmentControl?.selectedSegment == 0)
        {
            athleteSearchView.isHidden = true
        }
        else
        {
            athleteSearchView.isHidden = false
        }
        
        searchTableView.reloadData()
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardCancelButtonTouched(_ sender: UIButton)
    {
        searchTextField.resignFirstResponder()
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let yScroll = Int(scrollView.contentOffset.y)
        
        if (yScroll < 0)
        {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard will show")
            
            // Need to subtract the tab bar height from the keyboard height
            searchTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + searchTextFieldBackground.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height - fakeStatusBar.frame.size.height - searchTextFieldBackground.frame.size.height - keyboardSize.height)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        searchTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + searchTextFieldBackground.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height - fakeStatusBar.frame.size.height - searchTextFieldBackground.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - bottomTabBarPad)
    }
    
    // MARK: - View Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // This VC uses it's own Navigation bar
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = CGFloat(kTabBarHeight)
        }
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        searchTextFieldBackground.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: CGFloat(kDeviceWidth), height: searchTextFieldBackground.frame.size.height)
        searchTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + searchTextFieldBackground.frame.size.height, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.size.height - searchTextFieldBackground.frame.size.height - fakeStatusBar.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - bottomTabBarPad)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Add the ThreeSegmentControlView to the navView
        threeSegmentControl = ThreeSegmentControlView(frame: CGRect(x: 0, y: navView.frame.size.height - 40, width: navView.frame.size.width, height: 40), buttonOneTitle: "Teams", buttonTwoTitle: "Athletes", buttonThreeTitle: "", lightTheme: true)
        threeSegmentControl?.delegate = self
        navView.addSubview(threeSegmentControl!)
        
        // Add the athleteSearchView on top of the searchTableView and searchTextFieldBackground
        athleteSearchView = AthleteSearchView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.size.height - fakeStatusBar.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - bottomTabBarPad))
        athleteSearchView.delegate = self
        athleteSearchView.backgroundColor = UIColor.mpWhiteColor()
        self.view.addSubview(athleteSearchView)
        athleteSearchView.isHidden = true
        
        searchTextField.placeholder = "Search for a school"
        searchTextField.font = UIFont.mpRegularFontWith(size: 15)
        
        self.sortLocalSchools()
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
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
