//
//  SearchViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/25/21.
//

import UIKit

class SearchViewController: UIViewController, ThreeSegmentControlViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{    
    private var teamSelectorVC: TeamSelectorViewController?
    private var localSchools = Array<School>()
    private var filteredSchools = Array<School>()
    private var allAthletesArray = Array<Dictionary<String,Any>>()
    private var filteredAthletesArray = Array<Dictionary<String,Any>>()
    private var favoriteAthletesIdentifierArray = [] as Array
        
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldBackground: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    private var genderSportButton: UIButton!
    private var filterButton: UIButton!
    private var bottomTabBarPad = CGFloat(0)
    
    private var threeSegmentControl : ThreeSegmentControlView?
    private var webVC: WebViewController!
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
    
    // MARK: - Filter Athletes
    
    private func filterAthletes()
    {
        filteredAthletesArray.removeAll()
        
        // All States case
        if (filterButton.titleLabel?.text == String(format: kDefaultFilterButtonTitle, kDefaultFilterState))
        {
            filteredAthletesArray = allAthletesArray
            searchTableView.reloadData()
        }
        else
        {
            //
            for athlete in allAthletesArray
            {
                let state = athlete["schoolState"] as! String
                let stateWithFormattedName = String(format: kDefaultFilterButtonTitle, state)
                
                if (filterButton.titleLabel?.text == stateWithFormattedName)
                {
                    filteredAthletesArray.append(athlete)
                }
            }
            
            searchTableView.reloadData()
        }
        
    }
    
    // MARK: - Search for Athlete
    
    private func searchForAthlete()
    {
        self.allAthletesArray = []
        self.searchTableView.reloadData()
        
        // Show the busy indicator
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let sportArray = genderSportButton.titleLabel?.text!.split(separator: " ", maxSplits: 1)
        
        if (sportArray!.count == 2)
        {
            let gender = String(sportArray!.first!)
            let sport = String(sportArray!.last!)
            
            NewFeeds.searchForAthlete(searchTextField.text!, gender, sport) { (athletes, error) in
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                if (error == nil)
                {
                    print("Search Done")
                    
                    if (athletes!.count == 0)
                    {
                        // Show an Alert
                        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Search Result", message: "No athletes were found in that sport.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                    else
                    {
                        self.allAthletesArray = athletes!
                        
                        // Filter the athletes
                        self.filterAthletes()
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Error", message: "The search returned a server error", lastItemCancelType: false) { (tag) in
                        
                    }
                }
            }
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
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        
        if (pickerView.tag == 100)
        {
            // Skip if the sport didn't change
            if (genderSportButton.titleLabel?.text == title)
            {
                return
            }
            
            genderSportButton.setTitle(title, for: .normal)
            
            allAthletesArray.removeAll()
            filteredAthletesArray.removeAll()
            searchTableView.reloadData()
        }
        else
        {
            let filterTitle = String(format: kDefaultFilterButtonTitle, title!)
            filterButton.setTitle(filterTitle, for: .normal)
            
            // Filter the athletes
            self.filterAthletes()
        }
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - TextField Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        if (threeSegmentControl?.selectedSegment == 1)
        {
            if (genderSportButton.titleLabel?.text == kEmptyGenderSportButtonTitle)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Missing Sport", message: "You must select a sport.", lastItemCancelType: false) { (tag) in
                    
                    self.searchTextField.resignFirstResponder()
                }
            }
            else
            {
                if (searchTextField.text!.count == 0)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Missing Info", message: "You must enter the name of the athlete.", lastItemCancelType: false) { (tag) in
                        
                    }
                }
                else
                {
                    self.searchForAthlete()
                }
            }
        }
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
        if (threeSegmentControl?.selectedSegment == 0)
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
        else
        {
            return filteredAthletesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (threeSegmentControl?.selectedSegment == 0)
        {
            return 56.0
        }
        else
        {
            return 72.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (threeSegmentControl?.selectedSegment == 0)
        {
            return 32.0
        }
        else
        {
            return 44.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (threeSegmentControl?.selectedSegment == 0)
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
        else
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
            view.backgroundColor = UIColor.mpWhiteColor()
            
            let horizLine = UIView(frame: CGRect(x: 0, y: 43, width: tableView.frame.size.width, height: 1))
            horizLine.backgroundColor = UIColor.mpOffWhiteNavColor()
            view.addSubview(horizLine)
            
            // Add the genderSportButton and filterButton that were created at init
            view.addSubview(genderSportButton)
            view.addSubview(filterButton)
            
            return view
        }
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
        
        if (threeSegmentControl?.selectedSegment == 0)
        {
            cell?.selectionStyle = .default
            cell?.textLabel?.font = UIFont.mpSemiBoldFontWith(size: 16)
            
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
        }
        else
        {
            cell?.selectionStyle = .default
            cell?.textLabel?.font = UIFont.mpBoldFontWith(size: 16)
            
            let athlete = filteredAthletesArray[indexPath.row]
            
            let firstName = athlete["firstName"] as! String
            let lastName = athlete["lastName"] as! String
            let schoolFullName = athlete["schoolFormattedName"] as! String
            let careerId = athlete["careerId"] as! String
            
            cell?.textLabel?.text = firstName + " " + lastName
            
            // Get the sportYears
            let sportYears = athlete["sportYears"] as! Array<Dictionary<String,Any>>
            let firstSport = sportYears.first!
            let years = firstSport["years"] as! Array<String>
            let joinedYears = years.joined(separator: ", ")
            
            cell?.detailTextLabel?.text = schoolFullName + "\n" + joinedYears
            
            // Add a star if the athlete is already a favorite
            let result = favoriteAthletesIdentifierArray.filter { $0 as! String == careerId }
            if (!result.isEmpty)
            {
                let star = UIImageView(frame: CGRect(x: tableView.frame.size.width - 36, y: 25, width: 20, height: 20))
                star.tag = 100 + indexPath.row
                star.image = UIImage(named: "ActiveFavorites")
                cell?.contentView.addSubview(star)
                cell?.selectionStyle = .none
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (threeSegmentControl?.selectedSegment == 0)
        {
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
        else
        {
            // Refactor the athlete dictionary sinto an Athlete object

            let athlete = filteredAthletesArray[indexPath.row]

            let firstName = athlete["firstName"] as! String
            let lastName = athlete["lastName"] as! String
            let schoolName = athlete["schoolName"] as! String
            let schoolId = athlete["schoolId"] as! String
            let schoolColor1 = athlete["schoolColor1"] as! String
            let schoolMascotUrl = athlete["schoolMascotUrl"] as! String
            let schoolCity = athlete["schoolCity"] as! String
            let schoolState = athlete["schoolState"] as! String
            let careerId = athlete["careerId"] as! String
            let photoUrl = ""
            
            let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor1, schoolMascotUrl: schoolMascotUrl, careerId: careerId, photoUrl: photoUrl)
            
            let athleteDetailVC = AthleteDetailViewController(nibName: "AthleteDetailViewController", bundle: nil)
            athleteDetailVC.selectedAthlete = selectedAthlete
            
            var showFavoriteButton = false
            
            // Check to see if the athlete is already a favorite
            let result = favoriteAthletesIdentifierArray.filter { $0 as! String == careerId }
            
            if (result.isEmpty == false)
            {
                showFavoriteButton = false
            }
            else
            {
                // Two paths depending on wheteher the user is logged in or not
                let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
                
                if (userId != kTestDriveUserId)
                {
                    showFavoriteButton = true
                }
                else
                {
                    showFavoriteButton = false
                }
            }
            
            athleteDetailVC.showSaveFavoriteButton = showFavoriteButton
            
            self.navigationController?.pushViewController(athleteDetailVC, animated: true)

        }
    }
    
    // MARK: - ThreeSegmentControl Delgate
    
    func segmentChanged()
    {
        searchTextField.resignFirstResponder()
        searchTextField.text = ""
        
        if (threeSegmentControl?.selectedSegment == 0)
        {
            athleteSearchView.isHidden = true
            
            //searchTextField.placeholder = "Search for a school"
            //searchTextField.returnKeyType = .done
            //searchTextField.inputAccessoryView?.isHidden = true
        }
        else
        {
            athleteSearchView.isHidden = false
            
            /*
            searchTextField.placeholder = "Search for an athlete"
            searchTextField.returnKeyType = .search
            searchTextField.inputAccessoryView?.isHidden = false
            
            genderSportButton.setTitle(kEmptyGenderSportButtonTitle, for: .normal)
            filterButton.setTitle(String(format: kDefaultFilterButtonTitle, kDefaultFilterState), for: .normal)
            
            allAthletesArray.removeAll()
            filteredAthletesArray.removeAll()
            */
        }
        
        searchTableView.reloadData()
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func genderSportButtonTouched(_ sender: UIButton)
    {
        let picker = IQActionSheetPickerView(title: "", delegate: self)
        picker.tag = 100
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpLightGrayColor()
        picker.titlesForComponents = [kSearchGenderSportsArray]
        picker.show()
    }
    
    @objc func filterButtonTouched(_ sender: UIButton)
    {
        var stateList = kStateShortNamesArray
        stateList.insert("All States", at: 0)
        
        let picker = IQActionSheetPickerView(title: "", delegate: self)
        picker.tag = 101
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpLightGrayColor()
        picker.titlesForComponents = [stateList]
        picker.show()
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
        athleteSearchView.backgroundColor = UIColor.mpWhiteColor()
        self.view.addSubview(athleteSearchView)
        athleteSearchView.isHidden = true
        
        genderSportButton = UIButton(type: .custom)
        genderSportButton.frame = CGRect(x: 20, y: 7, width: (kDeviceWidth - 40) * 0.60, height: 30)
        genderSportButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        genderSportButton.titleLabel?.font = UIFont.mpBoldFontWith(size: 14)
        genderSportButton.setTitle(kEmptyGenderSportButtonTitle, for: .normal)
        genderSportButton.contentHorizontalAlignment = .left
        genderSportButton.addTarget(self, action: #selector(genderSportButtonTouched), for: .touchUpInside)
        
        filterButton = UIButton(type: .custom)
        filterButton.frame = CGRect(x: kDeviceWidth - 20 - ((kDeviceWidth - 40) * 0.4), y: 7, width: (kDeviceWidth - 40) * 0.4, height: 30)
        filterButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        filterButton.titleLabel?.font = UIFont.mpBoldFontWith(size: 14)
        filterButton.setTitle(String(format: kDefaultFilterButtonTitle, kDefaultFilterState), for: .normal)
        filterButton.contentHorizontalAlignment = .right
        filterButton.addTarget(self, action: #selector(filterButtonTouched), for: .touchUpInside)
        
        /*
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpLightGrayColor()
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 5, y: 5, width: 80, height: 30)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 19)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        cancelButton.addTarget(self, action: #selector(keyboardCancelButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(cancelButton)
        
        searchTextField.inputAccessoryView = accessoryView
        searchTextField.inputAccessoryView?.isHidden = true
        */
        
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
        
        
        
        // Build the favorite team identifier array so a star can be put next to each favorite team
        // Fill the favorite team identifier array
        
        favoriteAthletesIdentifierArray.removeAll()
        
        // Get the favorite athletes
        if let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            for favoriteAthlete in favoriteAthletes
            {
                let item = favoriteAthlete  as! Dictionary<String, Any>
                let careerProfileId = item["careerProfileId"] as! String
                            
                favoriteAthletesIdentifierArray.append(careerProfileId)
            }
        }
        
        
            
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
