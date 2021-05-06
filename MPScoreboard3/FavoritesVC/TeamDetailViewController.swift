//
//  TeamDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/19/21.
//

import UIKit

class TeamDetailViewController: UIViewController, UIScrollViewDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var itemScrollView: UIScrollView!
    @IBOutlet weak var yearSelectorButton: UIButton!
    @IBOutlet weak var saveFavoriteButton: UIButton!
    
    var selectedTeam : Team?
    var showSaveFavoriteButton = false
    var userRole = ""
    
    private var activeTeamsArray = [] as Array<Dictionary<String,Any>>
    private var currentTeam =  [:] as Dictionary<String,Any>
    private var yearArray = [] as Array<String>
    private var selectedYearIndex = 0
    private var filteredItems = [] as Array<String>
    private var selectedItemIndex = 0
    private var currentTeamColor = UIColor.mpRedColor()
    
    private var browserView: FavoritesBrowserView!
    private var browserHeight = 0
    
    private var contributeButton: UIButton!
    
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    private var allItems = ["Roster","Schedule","Stats","Rankings","Standings","Videos","Photos","Articles","Shop"]
    
    // MARK: - Get School Info
    
    private func getNewSchoolInfo(_ teams : Array<Any>)
    {
        // Build an array of schoolIds
        var schoolIds = [] as Array<String>
        
        for team in teams
        {
            let item = team  as! Dictionary<String, Any>
            let schoolId  = item[kNewSchoolIdKey] as! String
            
            schoolIds.append(schoolId)
        }

        NewFeeds.getSchoolInfoForSchoolIds(schoolIds) { error in
            if error == nil
            {
                print("Download school info success")
            }
            else
            {
                print("Download school info error")
            }
        }
    }
    
    // MARK: - Save User Favorite
    
    private func saveUserFavoriteTeam(_ favorite: Dictionary<String,Any>)
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        NewFeeds.saveUserFavoriteTeam(favorite){ (error) in
 
            if error == nil
            {
                // Get the user favorites so the prefs get updated
                NewFeeds.getUserFavoriteTeams(completionHandler: { error in
                    
                    // Hide the busy indicator
                    DispatchQueue.main.async
                    {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    
                    if (error == nil)
                    {
                        //self.navigationController?.popViewController(animated: true)
                        print("Download user favorites success")
                    }
                    else
                    {
                        print("Download user favorites error")
                    }
                })
                
                //self.navigationController?.popViewController(animated: true)
            }
            else
            {
                print("Save user favorites error")
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Error", message: "There was a server error when saving this team.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        yearSelectorButton.setTitle(title, for: .normal)
        
        // Search for the team that matches the selected year
        selectedYearIndex = yearArray.firstIndex(of: title!)!

        currentTeam = activeTeamsArray[selectedYearIndex]
        
        // Get the available items
        self.getAvailbleItems()
        
        // Load the browser
        selectedItemIndex = 0
        self.addNewBrowser()
    }
    
    // MARK: - Add New Browser Method
    
    private func addNewBrowser()
    {
        // Hide the busy indicator
        DispatchQueue.main.async
        {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        // Remove the existing browser if it exists
        if (browserView != nil)
        {
            browserView.removeFromSuperview()
        }

        // We need to create a new browser
        browserView = FavoritesBrowserView(frame: CGRect(x: 0, y: Int(navView.frame.size.height) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: browserHeight))
        //self.view.addSubview(browserView)
        self.view.insertSubview(browserView, belowSubview: contributeButton)
        
        let item = filteredItems[selectedItemIndex]
        let ssid = currentTeam["sportSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
        
        // Get the correct URL using the selectedItemIndex and the filteredItemsArray
        var urlString = ""
        var subDomain = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            let branchValue = kUserDefaults.string(forKey: kBranchValue)
            subDomain = String(format: "branch-%@.fe", branchValue!.lowercased())
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            subDomain = "dev"
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            subDomain = "staging"
        }
        else
        {
            subDomain = "www"
        }
        
        //let kScheduleHostProduction = "https://branch-e.fe.maxpreps.com/team/schedule?schoolid=%@&ssid=%@"

        switch item
        {
        case "Home":
            // Choose different URLs depending on the year
            if (selectedYearIndex == 0)
            {
                // Choose the team home url if the current year
                urlString = String(format: kTeamHomeHostGeneric, subDomain, schoolId, ssid)
            }
            else
            {
                // Choose the team schedule url if prior years
                urlString = String(format: kScheduleHostGeneric, subDomain, schoolId, ssid)
            }
        
        case "Roster":
            urlString = String(format: kRosterHostGeneric, subDomain, schoolId, ssid)
            
        case "Schedule":
            urlString = String(format: kScheduleHostGeneric, subDomain, schoolId, ssid)
            
        case "Stats":
            urlString = String(format: kStatsHostGeneric, subDomain, schoolId, ssid)
            
        case "Articles":
            urlString = String(format: kArticlesHostGeneric, subDomain, schoolId, ssid)
            
        case "Standings":
            urlString = String(format: kStandingsHostGeneric, subDomain, schoolId, ssid)
            
        case "Rankings":
            urlString = String(format: kRankingsHostGeneric, subDomain, schoolId, ssid)
            
        case "Photos":
            urlString = String(format: kPhotosHostGeneric, subDomain, schoolId, ssid)
            
        case "Videos":
            urlString = String(format: kVideosHostGeneric, subDomain, schoolId, ssid)
            
        case "Shop":
            urlString = String(format: kSportsWearHostGeneric, subDomain, schoolId, ssid)
            
        default:
            return
        }
        
        // Add the app's custom query parameter
        urlString = urlString + "&" + kAppIdentifierQueryParam
        
        // Add the Omniture tracking query parameter
        urlString = ADBMobile.visitorAppend(to: URL(string: urlString))!.absoluteString
        
        browserView.loadUrl(urlString)
     }
    
    // MARK: - Get Available Items
    
    private func getAvailbleItems()
    {
        let ssid = currentTeam["sportSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
        
        filteredItems.removeAll()
        
        filteredItems.append("Home")
        
        NewFeeds.getAvailableItemsForTeam(ssid, schoolId: schoolId) { (result, error) in
            
            if error == nil
            {
                /*
                 sportSeasonId
                 teamId
                 hasProPhotos
                 hasTeamRoster
                 maxprepsTeamPreviewModifiedOn
                 hasImportedTeamPreview
                 hasLeagueStandings
                 hasRankings
                 hasMaxprepsTeamPreview
                 hasContests
                 hasStats
                 maxprepsTeamPreviewCreatedOn
                 isPrepsSportsEnabled
                 hasVideos
                 hasArticles
                 updatedOn
                 */
                
                // Iterate through the allItems array and only save the available ones in the filteredItems array
                for item in self.allItems
                {
                    switch item
                    {
                    case "Roster":
                        let value = result?["hasTeamRoster"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Schedule":
                        let value = result?["hasContests"] as! Bool
                        if (value == true)
                        {
                            // Only include the schedule if in the current yesr
                            if (self.selectedYearIndex == 0)
                            {
                                self.filteredItems.append(item)
                            }
                        }
                    case "Stats":
                        let value = result?["hasStats"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Articles":
                        let value = result?["hasArticles"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Standings":
                        let value = result?["hasLeagueStandings"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Rankings":
                        let value = result?["hasRankings"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Photos":
                        let value = result?["hasProPhotos"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Videos":
                        let value = result?["hasVideos"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Shop":
                        let value = result?["isPrepsSportsEnabled"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    default:
                        continue
                    }
                }
            }
            else
            {
                print("Get available items failed")
            }
            
            self.loadItemSelector()
        }
    }
    
    // MARK: - Build Active Tears Array
    
    private func buildActiveYearsArray()
    {
        yearArray.removeAll()
        
        for item in activeTeamsArray
        {
            let year = item["year"] as! String
            yearArray.append(year)
        }
        
        if (activeTeamsArray.count > 0)
        {
            currentTeam = activeTeamsArray[selectedYearIndex]
            
            // Get the available items
            self.getAvailbleItems()
            
            // Load the browser
            selectedItemIndex = 0
            self.addNewBrowser() 
            
            let year = currentTeam["year"] as! String
            
            yearSelectorButton.setTitle(year, for: .normal)
            
            if (self.showSaveFavoriteButton == false)
            {
                yearSelectorButton.isHidden = false
            }
            else
            {
                yearSelectorButton.isHidden = true
            }
        }
        else
        {
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            yearSelectorButton.isHidden = true
            
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Error", message: "There was an error accessing this teams information.", lastItemCancelType: false) { (tag) in
                
            }
        }
    }
    
    // MARK: - Get SSID's for Team
    
    private func getSSIDsForTeam(schoolId: String, allSeasonId: String)
    {
        // Show the busy indicator
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        activeTeamsArray.removeAll()
        
        NewFeeds.getSSIDsForTeam(allSeasonId, schoolId: schoolId) { (result, error) in
            
            if error == nil
            {
                self.activeTeamsArray = result!
                
                self.buildActiveYearsArray()
                print("Get SSID's success")
            }
            else
            {
                print("Get SSID's error")
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        }
    }
    
    // MARK: - Load Item Selector
    
    private func loadItemSelector()
    {
        selectedItemIndex = 0
        
        // Remove existing buttons
        let itemScrollViewSubviews = itemScrollView.subviews
        for subview in itemScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        let mainSubviews = self.view.subviews
        for subview in mainSubviews
        {
            if (subview.tag == 200) || (subview.tag == 201)
            {
                subview.removeFromSuperview()
            }
        }
        
        var overallWidth = 0
        let pad = 10
        var leftPad = 0
        let rightPad = 10
        var index = 0
        
        for item in filteredItems
        {
            let itemWidth = Int(item.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13))) + (2 * pad)
            let tag = filteredItems.firstIndex(of: item)! + 100
            
            // Add the left pad to the first cell
            if (index == 0)
            {
                leftPad = 10
            }
            else
            {
                leftPad = 0
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 0, width: itemWidth, height: Int(itemScrollView.frame.size.height))
            button.backgroundColor = .clear
            button.setTitle(item, for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(self.itemTouched), for: .touchUpInside)
            
            // Add a line at the bottom of each button
            let textWidth = itemWidth - (2 * pad)
            let line = UIView(frame: CGRect(x: (button.frame.size.width - CGFloat(textWidth)) / 2.0, y: button.frame.size.height - 4, width: CGFloat(textWidth), height: 4))
            line.backgroundColor = currentTeamColor

            // Round the top corners
            line.clipsToBounds = true
            line.layer.cornerRadius = 4
            line.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            button.addSubview(line)
            
            if (index == 0)
            {
                button.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
                button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
            }
            else
            {
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                // Hide the inactive horiz line
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
            
            itemScrollView.addSubview(button)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        itemScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(itemScrollView.frame.size.height))
        
        // Add the left and right shadows
        leftShadow = UIImageView(frame: CGRect(x: -6, y: Int(itemScrollView.frame.origin.y), width: 22, height: Int(itemScrollView.frame.size.height)))
        leftShadow.image = UIImage(named: "LeftShadow")
        leftShadow.tag = 200
        self.view.addSubview(leftShadow)
        leftShadow.isHidden = true
        
        rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 16, y: Int(itemScrollView.frame.origin.y), width: 22, height: Int(itemScrollView.frame.size.height)))
        rightShadow.image = UIImage(named: "RightShadow")
        rightShadow.tag = 201
        self.view.addSubview(rightShadow)
        
        // Add a new Browser
        self.addNewBrowser()
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func yearSelectorButtonTouched(_ sender: UIButton)
    {
        let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpLightGrayColor() //currentTeamColor
        picker.titlesForComponents = [yearArray]
        picker.show()
    }
    
    @IBAction func saveFavoriteButtonTouched(_ sender: UIButton)
    {
        /*
        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Save Team", message: "Coming Soon...", lastItemCancelType: false) { (tag) in
            
        }
        */
        
        var favorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        
        if (favorites!.count >= kMaxFavoriteTeamsCount)
        {
            let messageTitle = String(kMaxFavoriteTeamsCount) + " Team Limit"
            let messageText = "The maximum number of favorites allowed is " + String(kMaxFavoriteTeamsCount) + ".  You must remove a team in order to add another."
            
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: messageTitle, message: messageText, lastItemCancelType: false) { (tag) in
                
            }
            return
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Ok"], title: "Save Team", message: "Do you want to save this team to your favorites?", lastItemCancelType: false) { (tag) in
            if (tag == 1)
            {
                let gender = self.selectedTeam?.gender
                let sport = self.selectedTeam?.sport
                let teamLevel = self.selectedTeam?.teamLevel
                let season = self.selectedTeam?.season
                let schoolId = self.selectedTeam?.schoolId
                let schoolName = self.selectedTeam?.schoolName
                let schoolFullName = self.selectedTeam?.schoolFullName
                let schoolState = self.selectedTeam?.schoolState
                let schoolCity = self.selectedTeam?.schoolCity
                let allSeasonId = self.selectedTeam?.allSeasonId
                let teamColor = self.selectedTeam?.teamColor
                let mascotUrl = self.selectedTeam?.mascotUrl
                
                // Update the selectedTeam
                let newFavorite = [kNewGenderKey:gender!, kNewSportKey:sport!, kNewLevelKey:teamLevel!, kNewSeasonKey:season!, kNewSchoolIdKey:schoolId!, kNewSchoolNameKey:schoolName!, kNewSchoolFormattedNameKey:schoolFullName!, kNewSchoolStateKey:schoolState!, kNewSchoolCityKey:schoolCity!, kNewSchoolInfoColor1Key:teamColor!, kNewSchoolMascotUrlKey:mascotUrl!, kNewUserfavoriteTeamIdKey:0, kNewAllSeasonIdKey:allSeasonId!, kNewNotificationSettingsKey:[]] as [String : Any]
                
                // Update prefs
                favorites!.append(newFavorite)
                
                kUserDefaults.set(favorites, forKey: kNewUserFavoriteTeamsArrayKey)
                
                // Update the SchoolInfo dictionary in prefs so the school list stays current
                self.getNewSchoolInfo(favorites!)
                
                // Update the DB
                self.saveUserFavoriteTeam(newFavorite)
            }
        }
    }
    
    @objc private func itemTouched(_ sender: UIButton)
    {
        // Change the font of the all of the buttons to regular, hide the underline view
        for subview in itemScrollView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
        }
        
        // Set the selected item's font to bold
        selectedItemIndex = sender.tag - 100
        sender.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
        sender.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        
        // Show the underline on the button
        let horizLine = sender.subviews[0]
        horizLine.isHidden = false
        
        // Add a new browser
        self.addNewBrowser()

    }
    
    @objc private func contributeButtonTouched()
    {
        let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        let schoolId = self.selectedTeam?.schoolId
        let allSeasonId = self.selectedTeam?.allSeasonId
        let roleKey = schoolId! + "_" + allSeasonId!
        
        var message = "Standard user content is added from this button."
        var title = "Standard User"
        
        if (adminRoles![roleKey] != nil)
        {
            let adminRole = adminRoles![roleKey] as! Dictionary<String,String>
            let roleName = adminRole[kRoleNameKey]
            
            if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
            {
                message = "Admin user content is added from this button."
                title = "Admin User"
            }
            else if (roleName == "Team Community")
            {
                message = "Team member content is added from this button."
                title = "Team Member"
            }
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: title, message: message, lastItemCancelType: false) { tag in
            
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == itemScrollView)
        {
            let xScroll = scrollView.contentOffset.x
            
            if (xScroll > 0)
            {
                leftShadow.isHidden = false
            }
            else
            {
                leftShadow.isHidden = true
            }
            
            if (xScroll >= scrollView.contentSize.width - scrollView.frame.size.width)
            {
                rightShadow.isHidden = true
            }
            else
            {
                rightShadow.isHidden = false
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Explicitly set the header view size. The items within the view are pinned to the bottom
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 58)
        itemScrollView.frame = CGRect(x: 0, y: navView.frame.size.height, width: kDeviceWidth, height: itemScrollView.frame.size.height)
        itemScrollView.backgroundColor = UIColor.mpWhiteColor()
        
        /*
         Team Object
         var teamId: Double
         var allSeasonId: String
         var gender: String
         var sport: String
         var teamColor: String
         var mascotUrl: String
         var schoolName: String
         var teamLevel: String
         var schoolId: String
         var schoolState: String
         var schoolCity: String
         var schoolFullName: String
         var season: String
         var notifications: Array<Any>
         */
        
        /*
        let schoolId = self.selectedTeam[kNewSchoolIdKey] as! String
        let name = self.selectedTeam[kNewSchoolNameKey] as! String        
        let gender = self.selectedTeam[kNewGenderKey] as! String
        let sport = self.selectedTeam[kNewSportKey] as! String
        let level = self.selectedTeam[kNewLevelKey] as!String
        */
        
        let name = self.selectedTeam?.schoolName
        let gender = self.selectedTeam?.gender
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let hexColorString = self.selectedTeam?.teamColor
        
        titleLabel.text = name
        subtitleLabel.text = MiscHelper.genderSportLevelFrom(gender: gender!, sport: sport!, level: level!)
        
        currentTeamColor = ColorHelper.color(fromHexString: hexColorString)!
        navView.backgroundColor = currentTeamColor
        
        // Calculate the browser height
        let navViewHeight = Int(navView.frame.size.height)
        let itemScrollViewHeight = Int(itemScrollView.frame.size.height)
        
        var bottomTabBarPad = 0
        
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }
        
        browserHeight = Int(kDeviceHeight) - navViewHeight - itemScrollViewHeight - SharedData.bottomSafeAreaHeight - bottomTabBarPad
        
        
        // Add the + button to the lower right corner if logged in
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId != kTestDriveUserId)
        {
            contributeButton = UIButton(type: .custom)
            contributeButton.frame = CGRect(x: Int(kDeviceWidth) - 76, y: navViewHeight + itemScrollViewHeight + browserHeight - 76, width: 60, height: 60)
            contributeButton.layer.cornerRadius = contributeButton.frame.size.width / 2
            contributeButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.33).cgColor
            contributeButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
            contributeButton.layer.shadowOpacity = 1.0
            contributeButton.layer.shadowRadius = 4.0
            contributeButton.clipsToBounds = false
            contributeButton.backgroundColor = currentTeamColor
            contributeButton.setTitle("+", for: .normal)
            contributeButton.setTitleColor(.white, for: .normal)
            contributeButton.titleLabel?.font = UIFont.mpRegularFontWith(size: 42) //.systemFont(ofSize: 42)
            contributeButton.titleEdgeInsets = UIEdgeInsets(top: -3, left: 0, bottom: 3, right: 0)
            contributeButton.contentHorizontalAlignment = .center
            contributeButton.addTarget(self, action: #selector(contributeButtonTouched), for: .touchUpInside)
            self.view.addSubview(contributeButton)
        }
        
        if (self.showSaveFavoriteButton == true)
        {
            yearSelectorButton.isHidden = true
            saveFavoriteButton.isHidden = false
        }
        else
        {
            yearSelectorButton.isHidden = false
            saveFavoriteButton.isHidden = true
        }
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        // Get the SSID's for the active team
        //let schoolId = self.selectedTeam[kNewSchoolIdKey] as! String
        //let allSeasonId = self.selectedTeam[kNewAllSeasonIdKey] as! String
        
        let schoolId = self.selectedTeam?.schoolId
        let allSeasonId = self.selectedTeam?.allSeasonId
        
        self.getSSIDsForTeam(schoolId: schoolId!, allSeasonId: allSeasonId!)
        
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
