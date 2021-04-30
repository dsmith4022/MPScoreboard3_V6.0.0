//
//  OldFavoriteViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit

class OldFavoriteViewController: UIViewController, UIScrollViewDelegate, IQActionSheetPickerViewDelegate, FavoritesListViewDelegate, FavoritesBrowserViewDelegate
{    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navContainerView: UIView!
    @IBOutlet weak var logoBackgroundView: UIView!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var teamFirstLetterLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var noFavoritesLabel: UILabel!
    @IBOutlet weak var switchTeamsButton: UIButton!
    @IBOutlet weak var itemScrollView: UIScrollView!
    @IBOutlet weak var yearSelectorButton: UIButton!
    @IBOutlet weak var memberSelectorButton: UIButton!
    @IBOutlet weak var auxLogoBackgroundView: UIView!
    @IBOutlet weak var auxMascotImageView: UIImageView!
    @IBOutlet weak var auxTeamFirstLetterLabel: UILabel!
    
    private let gradient = CAGradientLayer()
    private var activeTeamsArray = [] as Array<Dictionary<String,Any>>
    private var currentTeam =  [:] as Dictionary<String,Any>
    private var yearArray = [] as Array<String>
    private var selectedYearIndex = 0
    private var filteredItems = [] as Array<String>
    private var currentTeamColor = UIColor.mpRedColor()
    
    private var searchVC: SearchViewController!
    private var webVC: WebViewController!
    private var favoritesListView: FavoritesListView!
    
    private var browserView: FavoritesBrowserView!
    private var browserHeight = 0

    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    private var profileButton : UIButton?
    
    private var allItems = ["Roster","Schedule","Stats","Rankings","Standings","Videos","Photos","Articles","Shop"]
    
    // MARK: - Get Available Items
    
    private func getAvailbleItems()
    {
        let ssid = currentTeam["sportSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
        
        filteredItems.removeAll()
        
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
    
    // MARK: - Add Browser Method
    
    private func addBrowser()
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

        let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
        let navContainerViewHeight = Int(navContainerView.frame.size.height)
        let itemScrollViewHeight = Int(itemScrollView.frame.size.height)
        
        browserHeight = Int(kDeviceHeight) - fakeStatusBarHeight - navContainerViewHeight - itemScrollViewHeight - SharedData.bottomSafeAreaHeight - kTabBarHeight
        
        // We need to create a new browser
        browserView = FavoritesBrowserView(frame: CGRect(x: 0, y: fakeStatusBarHeight + navContainerViewHeight + itemScrollViewHeight, width: Int(kDeviceWidth), height: browserHeight))
        browserView.delegate = self
        self.view.addSubview(browserView)
        
        let ssid = currentTeam["sportSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
        
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
        
        // Choose different URLs depending on the year
        if (selectedYearIndex == 0)
        {
            // Choose the team home url if the current year
            var urlString = String(format: kTeamHomeHostGeneric, subDomain, schoolId, ssid)
            urlString = urlString + "&" + kAppIdentifierQueryParam
            
            browserView.loadUrl(urlString)
        }
        else
        {
            // Choose the team schedule url if prior years
            var urlString = String(format: kScheduleHostGeneric, subDomain, schoolId, ssid)
            urlString = urlString + "&" + kAppIdentifierQueryParam
            
            browserView.loadUrl(urlString)
            
            /*
            NewFeeds.getTeamRecord(ssid, schoolId: schoolId) { (result, error) in
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                if error == nil
                {
                    print("Get school record success")
                }
                else
                {
                    print("Get school record failed")
                }
            }
            */
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
            
            // Load the browser and get the available items
            self.addBrowser()
            self.getAvailbleItems()
            
            let year = currentTeam["year"] as! String
            
            yearSelectorButton.setTitle(year, for: .normal)
            yearSelectorButton.isHidden = false
            
        }
        else
        {
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            
            yearSelectorButton.isHidden = true
            
            MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "Error", message: "There was an error accessing for this teams information.", lastItemCancelType: false) { (tag) in
                
            }
        }
    }
    
    // MARK: - Get SSID's for Team
    
    private func getSSIDsForTeam(_ activeTeam: Dictionary<String, Any>)
    {
        // Show the busy indicator
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let schoolId = activeTeam[kNewSchoolIdKey] as! String
        let allSeasonId = activeTeam[kNewAllSeasonIdKey] as! String
        
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
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        yearSelectorButton.setTitle(title, for: .normal)
        
        // Search for the team that matches the selected year
        selectedYearIndex = yearArray.firstIndex(of: title!)!

        currentTeam = activeTeamsArray[selectedYearIndex]
        
        // Load the browser and get the available items
        self.addBrowser()
        self.getAvailbleItems()  
    }
    
    // MARK: - Load User Image
    
    func loadUserImage()
    {
        // Get the user image
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            let image = UIImage.init(named: "SettingsButton")
            profileButton?.setImage(image, for: .normal)
            return
        }
        
        LegacyFeeds.getUserImage(userId: userId!) { (data, error) in
            
            if (error == nil)
            {
                let image = UIImage.init(data: data!)
                
                if (image != nil)
                {
                    self.profileButton?.setImage(image, for: .normal)
                }
                else
                {
                    let image = UIImage.init(named: "EmptyProfileButton")
                    self.profileButton?.setImage(image, for: .normal)
                }
            }
            else
            {
                let image = UIImage.init(named: "EmptyProfileButton")
                self.profileButton?.setImage(image, for: .normal)
            }
        }
    }
    
    // MARK: - Show Settings VC
    
    private func showSettingsVC()
    {
        let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        let settingsNav = TopNavigationController()
        settingsNav.viewControllers = [settingsVC] as Array
        settingsNav.modalPresentationStyle = .fullScreen
        self.present(settingsNav, animated: true)
        {
            
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func profileButtonTouched()
    {
        // Show the SettingsVC is a test drive user
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kTestDriveUserId)
        {
            self.showSettingsVC()
        }
        else
        {
            self.hidesBottomBarWhenPushed = true
                        
            let profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
            self.navigationController?.pushViewController(profileVC, animated: true)
            
            self.hidesBottomBarWhenPushed = false
        }
    }
    
    // MARK: - Load Item Selector
    
    private func loadItemSelector()
    {
        // Remove existing buttons
        let itemScrollViewSubviews = itemScrollView.subviews
        for subview in itemScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        let mainSubviews = self.view.subviews
        for subview in mainSubviews
        {
            if (subview.tag == 200) || (subview.tag == 201) || (subview.tag == 202)
            {
                subview.removeFromSuperview()
            }
        }
        
        // Add a thin gray line at the bottom of the scrollView
        let horizLine = UIView(frame: CGRect(x: 0, y: itemScrollView.frame.size.height - 1, width: itemScrollView.frame.size.width, height: 1))
        horizLine.tag = 202
        horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
        itemScrollView.addSubview(horizLine)
        
        var overallWidth = 0
        let pad = 10
        var leftPad = 0
        let rightPad = 10
        var index = 0
        
        for item in filteredItems
        {
            let itemWidth = Int(item.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 14))) + (2 * pad)
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
            button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
            button.setTitle(item, for: .normal)
            button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(self.itemTouched), for: .touchUpInside)
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
    }
    
    // MARK: - Load Favorite Team Header
    
    private func loadFavoriteTeamHeader(_ activeTeam: Dictionary<String, Any>)
    {
        itemScrollView.isHidden = false
        logoBackgroundView.alpha = 1
        
        let name = activeTeam[kNewSchoolNameKey] as! String
        let gender = activeTeam[kNewGenderKey] as! String
        let sport = activeTeam[kNewSportKey] as! String
        let teamLevel = activeTeam[kNewLevelKey] as! String
        //let season = activeTeam[kNewSeasonKey] as! String
        let initial = String(name.prefix(1))
        
        schoolNameLabel?.text = name
        schoolNameLabel?.backgroundColor = .clear
        
        let teamName = MiscHelper.genderSportShortLevelFrom(gender: gender, sport: sport, level: teamLevel).uppercased()
        teamNameLabel?.text = teamName
        
        // Shift the sport Icon to the left of the teamNameLabel
        let currentTeamNameFont = teamNameLabel.font
        let teamNameWidth = Int(teamName.widthOfString(usingFont: currentTeamNameFont!)) + 10
        
        sportIconImageView.frame = CGRect(x: ((Int(navContainerView.frame.size.width) - teamNameWidth) / 2) - 17, y: Int(sportIconImageView.frame.origin.y), width: Int(sportIconImageView.frame.size.width), height: Int(sportIconImageView.frame.size.height))
        sportIconImageView.image = MiscHelper.getImageForSport(sport)
        
        // Calculate the width of the school name to set it's frame
        let currentSchoolNameFont = schoolNameLabel.font
        let textWidth = Int(name.widthOfString(usingFont: currentSchoolNameFont!)) + 10

        var schoolNameLabelWidth = 0
        
        if (textWidth < Int(navContainerView.frame.size.width) - 80)
        {
            schoolNameLabelWidth = textWidth
        }
        else
        {
            schoolNameLabelWidth = Int(navContainerView.frame.size.width) - 80
        }
        
        schoolNameLabel.frame = CGRect(x: (Int(navContainerView.frame.size.width) - schoolNameLabelWidth) / 2, y: Int(schoolNameLabel.frame.origin.y), width: schoolNameLabelWidth , height: Int(schoolNameLabel.frame.size.height))
        
        // Move the changeTeam button to the right of the schoolNameLabel
        switchTeamsButton?.frame = CGRect(x: schoolNameLabel.frame.origin.x + schoolNameLabel.frame.size.width, y: switchTeamsButton.frame.origin.y, width: switchTeamsButton.frame.size.width, height: switchTeamsButton.frame.size.height)
        

        // Remove the gradient layer
        gradient.removeFromSuperlayer()
        
        // Tint the fakeStatusBar and navView
        let schoolId = activeTeam[kNewSchoolIdKey] as! String
        let schoolInfos = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
        
        // Make sure that the school info exists
        if schoolInfos![schoolId] != nil
        {
            let schoolInfo = schoolInfos![schoolId] as! Dictionary<String, String>
            let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]
            currentTeamColor = ColorHelper.color(fromHexString: hexColorString)!
            let stopColor = currentTeamColor.darker(by: 20.0)
            
            fakeStatusBar?.backgroundColor = currentTeamColor
            
            gradient.frame = navView!.bounds //bounds
            gradient.colors = [currentTeamColor.cgColor, stopColor!.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            navView?.layer.insertSublayer(gradient, at: 0)
            
            let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
            let url = URL(string: mascotUrl!)
            
            if (mascotUrl!.count > 0)
            {
                let scaledWidth = self.mascotImageView.frame.size.height
                let auxScaledWidth = self.auxMascotImageView.frame.size.height
                
                // Get the data and make an image
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    let image = UIImage(data: data)
                    let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth, height: scaledWidth))
                    let auxScaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: auxScaledWidth, height: auxScaledWidth))
                    
                    DispatchQueue.main.async()
                    {
                        self.mascotImageView.isHidden = false
                        self.teamFirstLetterLabel.isHidden = true
                        self.auxMascotImageView.isHidden = false
                        self.auxTeamFirstLetterLabel.isHidden = true
                        
                        // Clip the image to a round circle if the corners are not white or clear
                        let cornerColor = image!.getColorIfCornersMatch()
                        
                        if (cornerColor != nil)
                        {
                            //print ("Corner Color match")
                            
                            var red: CGFloat = 0
                            var green: CGFloat = 0
                            var blue: CGFloat = 0
                            var alpha: CGFloat = 0
                            
                            // Use the scaled image if the color is white or the alpha is zero
                            cornerColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                            
                            if (((red == 1) && (green == 1) && (blue == 1)) || (alpha == 0))
                            {
                                self.mascotImageView.image = scaledImage
                                self.auxMascotImageView.image = auxScaledImage
                            }
                            else
                            {
                                let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: self.mascotImageView.frame.size.width / 2.0)
                                self.mascotImageView.image = roundedImage
                                
                                let roundedImage2 = UIImage.maskRoundedImage(image: auxScaledImage!, radius: self.auxMascotImageView.frame.size.width / 2.0)
                                self.auxMascotImageView.image = roundedImage2
                            }
                        }
                        else
                        {
                            print("Corner Color Mismatch")
                            self.mascotImageView.image = scaledImage
                            self.auxMascotImageView.image = auxScaledImage
                        }
                    }
                }
            }
            else
            {
                // Set the first letter color
                self.teamFirstLetterLabel.textColor = currentTeamColor
                self.mascotImageView.isHidden = true
                self.teamFirstLetterLabel.isHidden = false
                self.teamFirstLetterLabel.text = initial
                
                self.auxTeamFirstLetterLabel.textColor = currentTeamColor
                self.auxMascotImageView.isHidden = true
                self.auxTeamFirstLetterLabel.isHidden = false
                self.auxTeamFirstLetterLabel.text = initial
            }
            
        }
        else
        {
            fakeStatusBar!.backgroundColor = UIColor.mpRedColor()
            let stopColor = UIColor.mpRedColor().darker(by: 20.0)!
            
            gradient.frame = navView!.bounds //bounds
            gradient.colors = [UIColor.red.cgColor, stopColor.cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 0, y: 1)
            navView?.layer.insertSublayer(gradient, at: 0)
            
            // Set the first letter color
            self.teamFirstLetterLabel.textColor = UIColor.mpRedColor()
            self.mascotImageView.isHidden = true
            self.teamFirstLetterLabel.isHidden = false
            self.teamFirstLetterLabel.text = initial
            
            self.auxTeamFirstLetterLabel.textColor = UIColor.mpRedColor()
            self.auxMascotImageView.isHidden = true
            self.auxTeamFirstLetterLabel.isHidden = false
            self.auxTeamFirstLetterLabel.text = initial
        }
        
    }
    
    // MARK: - Load Favorite Athlete Header
    
    private func loadFavoriteAthleteHeader(_ activeAthlete: Dictionary<String, Any>)
    {
        itemScrollView.isHidden = true
        sportIconImageView.image = nil
        logoBackgroundView.alpha = 1
        
        auxLogoBackgroundView.alpha = 0
        
        if (browserView != nil)
        {
            browserView.removeFromSuperview()
        }
        
        let firstName = activeAthlete[kAthleteCareerProfileFirstNameKey] as! String
        let lastName = activeAthlete[kAthleteCareerProfileLastNameKey] as! String
        let fullName = firstName + " " + lastName
        let schoolName = activeAthlete[kAthleteCareerProfileSchoolNameKey] as! String
        let initial = String(schoolName.prefix(1))
        let schoolColor = activeAthlete[kAthleteCareerProfileSchoolColor1Key] as! String
        let mascotUrl = activeAthlete[kAthleteCareerProfileSchoolMascotUrlKey] as! String
        
        // The schoolNameLabel is loaded with the athlete's full name
        schoolNameLabel?.text = fullName
        schoolNameLabel?.backgroundColor = .clear
        
        teamNameLabel?.text = schoolName
        
        // Calculate the width of the school name to set it's frame
        let currentFont = schoolNameLabel.font
        let textWidth = Int(fullName.widthOfString(usingFont: currentFont!)) + 10

        var schoolNameLabelWidth = 0
        
        if (textWidth < Int(navContainerView.frame.size.width) - 80)
        {
            schoolNameLabelWidth = textWidth
        }
        else
        {
            schoolNameLabelWidth = Int(navContainerView.frame.size.width) - 80
        }
        
        schoolNameLabel.frame = CGRect(x: (Int(navContainerView.frame.size.width) - schoolNameLabelWidth) / 2, y: Int(schoolNameLabel.frame.origin.y), width: schoolNameLabelWidth , height: Int(schoolNameLabel.frame.size.height))
        
        // Move the changeTeam button to the right of the schoolNameLabel
        switchTeamsButton?.frame = CGRect(x: schoolNameLabel.frame.origin.x + schoolNameLabel.frame.size.width, y: switchTeamsButton.frame.origin.y, width: switchTeamsButton.frame.size.width, height: switchTeamsButton.frame.size.height)
        

        // Remove the gradient layer
        gradient.removeFromSuperlayer()
        
        // Tint the fakeStatusBar and navView
        currentTeamColor = ColorHelper.color(fromHexString: schoolColor)!
        let stopColor = currentTeamColor.darker(by: 20.0)
        
        fakeStatusBar?.backgroundColor = currentTeamColor
        
        gradient.frame = navView!.bounds //bounds
        gradient.colors = [currentTeamColor.cgColor, stopColor!.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        navView?.layer.insertSublayer(gradient, at: 0)
        
        let url = URL(string: mascotUrl)
        
        if (mascotUrl.count > 0)
        {
            let scaledWidth = self.mascotImageView.frame.size.height
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                
                let image = UIImage(data: data)
                let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth, height: scaledWidth))
                
                DispatchQueue.main.async()
                {
                    self.mascotImageView.isHidden = false
                    self.teamFirstLetterLabel.isHidden = true
                    
                    // Clip the image to a round circle if the corners are not white or clear
                    let cornerColor = image!.getColorIfCornersMatch()
                    
                    if (cornerColor != nil)
                    {
                        //print ("Corner Color match")
                        
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        var alpha: CGFloat = 0
                        
                        // Use the scaled image if the color is white or the alpha is zero
                        cornerColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                        
                        if (((red == 1) && (green == 1) && (blue == 1)) || (alpha == 0))
                        {
                            self.mascotImageView.image = scaledImage
                        }
                        else
                        {
                            let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: self.mascotImageView.frame.size.width / 2.0)
                            self.mascotImageView.image = roundedImage
                        }
                    }
                    else
                    {
                        print("Corner Color Mismatch")
                        self.mascotImageView.image = scaledImage
                    }
                }
            }
        }
        else
        {
            // Set the first letter color
            self.teamFirstLetterLabel.textColor = currentTeamColor
            self.mascotImageView.isHidden = true
            self.teamFirstLetterLabel.isHidden = false
            self.teamFirstLetterLabel.text = initial
        }

    }
    
    // MARK: - Favorites List View Delegate
    
    func closeFavoritesListViewAfterChange()
    {
        favoritesListView.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
        
        // Refresh the screen
        let section = kUserDefaults.value(forKey: kSelectedFavoriteSectionKey) as! Int
        
        if (section == 0)
        {
            let favorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
            selectedYearIndex = 0
            
            if (favorites != nil) && (favorites!.count > 0)
            {
                noFavoritesLabel.isHidden = true
                memberSelectorButton.isHidden = false
                
                // Temporary code
                memberSelectorButton.setTitle("JOIN TEAM", for: .normal)
                
                if (favorites!.count > 1)
                {
                    switchTeamsButton.isHidden = false
                }
                else
                {
                    switchTeamsButton.isHidden = true
                }
                
                var index = kUserDefaults.value(forKey: kSelectedFavoriteIndexKey) as! Int
                
                // Fix the index in case it exceeds the count
                if (index >= favorites!.count)
                {
                    index = 0
                    kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
                }
                
                let favoriteTeam = favorites?[index] as! Dictionary<String, Any>
                self.loadFavoriteTeamHeader(favoriteTeam)
                
                // Get the SSID's for the active team
                self.getSSIDsForTeam(favoriteTeam)
            }
            else
            {
                // Display the no favorite label
                noFavoritesLabel.isHidden = false
                switchTeamsButton.isHidden = true
                schoolNameLabel.text = ""
                teamNameLabel.text = ""
                logoBackgroundView.isHidden = true
                fakeStatusBar!.backgroundColor = UIColor.mpRedColor()
                navView!.backgroundColor = UIColor.mpRedColor()
                yearSelectorButton.isHidden = true
                memberSelectorButton.isHidden = true
            }
        }
        else
        {
            // Favorite Athlete
            let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
            selectedYearIndex = 0
            
            if (favoriteAthletes != nil) && (favoriteAthletes!.count > 0)
            {
                noFavoritesLabel.isHidden = true
                memberSelectorButton.isHidden = true
                yearSelectorButton.isHidden = true
                
                // Temporary code
                memberSelectorButton.setTitle("JOIN TEAM", for: .normal)
                
                if (favoriteAthletes!.count > 1)
                {
                    switchTeamsButton.isHidden = false
                }
                else
                {
                    switchTeamsButton.isHidden = true
                }
                
                var index = kUserDefaults.value(forKey: kSelectedFavoriteIndexKey) as! Int
                
                // Fix the index in case it exceeds the count
                if (index >= favoriteAthletes!.count)
                {
                    index = 0
                    kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
                }
                
                let favoriteAthlete = favoriteAthletes?[index] as! Dictionary<String, Any>
                self.loadFavoriteAthleteHeader(favoriteAthlete)
                
                
            }
            else
            {
                // Display the no favorite label
                noFavoritesLabel.isHidden = false
                switchTeamsButton.isHidden = true
                schoolNameLabel.text = ""
                teamNameLabel.text = ""
                logoBackgroundView.isHidden = true
                fakeStatusBar!.backgroundColor = UIColor.mpRedColor()
                navView!.backgroundColor = UIColor.mpRedColor()
                yearSelectorButton.isHidden = true
                memberSelectorButton.isHidden = true
            }
        }
    }
    
    func closeFavoritesListView()
    {
        favoritesListView.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Button Methods
    
    @IBAction func searchButtonTouched(_ sender: UIButton)
    {
        let favoriteTeamsArray = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        let favoriteAthletesArray = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        
        if (favoriteTeamsArray != nil) && (favoriteAthletesArray != nil)
        {
            if ((favoriteTeamsArray!.count < kMaxFavoriteTeamsCount) && (favoriteAthletesArray!.count < kMaxFavoriteAthletesCount))
            {
                self.hidesBottomBarWhenPushed = true
                searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
                self.navigationController?.pushViewController(searchVC!, animated: true)
                self.hidesBottomBarWhenPushed = false
            }
            else
            {
                let messageTitle = String(kMaxFavoriteTeamsCount) + " Team Limit"
                let messageText = "The maximum number of favorites allowed is " + String(kMaxFavoriteTeamsCount) + ".  You must remove a team in order to add another."
                
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: messageTitle, message: messageText, lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    @IBAction func switchTeamsButtonTouched(_ sender: UIButton)
    {
        /*
        favoritesListVC = FavoritesListViewController(nibName: "FavoritesListViewController", bundle: nil)
        let favoritesListNav = TopNavigationController()
        favoritesListNav.viewControllers = [favoritesListVC]
        favoritesListNav.modalPresentationStyle = .fullScreen
        self.present(favoritesListNav, animated: true)
        {
            
        }
         */
        self.tabBarController?.tabBar.isHidden = true
        
        favoritesListView = FavoritesListView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
        favoritesListView.delegate = self
        self.view.addSubview(favoritesListView)
    }
    
    @IBAction func yearSelectorButtonTouched(_ sender: UIButton)
    {
        let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = currentTeamColor
        picker.titlesForComponents = [yearArray]
        picker.show()
    }
    
    @IBAction func memberButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MaxPreps App", message: "This will open the team onboarding flow.", lastItemCancelType: false) { (tag) in
            
        }
    }
        
    @objc private func itemTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = filteredItems[index]
        let ssid = currentTeam["sportSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
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
        
        /*
         let kRosterHostGeneric
         let kScheduleHostGeneric
         let kRankingsHostGeneric
         let kStatsHostGeneric
         let kStandingsHostGeneric
         let kPhotosHostGeneric
         let kVideosHostGeneric
         let kArticlesHostGeneric
         let kSportsWearHostGeneric
         */
        
        switch item
        {
        case "Roster":
            urlString = String(format: kRosterHostGeneric, subDomain, schoolId, ssid)
            
        case "Schedule":
            urlString = String(format: kScheduleHostGeneric, subDomain, schoolId, ssid)
            
        case "Stats":
            urlString = String(format: kStatsHostGeneric, subDomain, schoolId, ssid)
            
        case "Articles":
            urlString = String(format: kArticlesHostGeneric,subDomain, schoolId, ssid)
            
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
        
        // Show the web browser
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = ""
        webVC?.urlString = urlString
        webVC?.titleColor = UIColor.mpWhiteColor()
        webVC?.navColor = currentTeamColor
        webVC?.allowRotation = false
        webVC?.showShareButton = true
        webVC?.showNavControls = true
        webVC?.showScrollIndicators = false
        webVC?.showLoadingOverlay = true
        webVC?.showBannerAd = true

        self.navigationController?.pushViewController(webVC!, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - FavoritesBrowserDelegate
    
    func favoritesBrowserScrollViewDidScroll(_ value : Int)
    {
        let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
        let navContainerViewHeight = Int(navContainerView.frame.size.height)
        let navViewHeight = Int(navView.frame.size.height)
        let itemScrollViewHeight = Int(itemScrollView.frame.size.height)
        let browserHeight = Int(kDeviceHeight) - fakeStatusBarHeight - navContainerViewHeight - itemScrollViewHeight -  SharedData.bottomSafeAreaHeight - kTabBarHeight
        
        // The colored navBar is 60 pixels high
        if (value <= 0)
        {
            browserView.updateFrame(CGRect(x: 0, y: fakeStatusBarHeight + navContainerViewHeight + itemScrollViewHeight, width: Int(kDeviceWidth), height: browserHeight))
            itemScrollView?.frame = CGRect(x: 0, y: fakeStatusBarHeight + navContainerViewHeight, width: Int(kDeviceWidth), height: itemScrollViewHeight)
            logoBackgroundView.alpha = 1
            auxLogoBackgroundView.alpha = 0
        }
        else if (value > 0) && (value < navContainerViewHeight - navViewHeight)
        {
            browserView.updateFrame(CGRect(x: 0, y: fakeStatusBarHeight + navContainerViewHeight + itemScrollViewHeight - value, width: Int(kDeviceWidth), height: browserHeight + value))
            itemScrollView?.frame = CGRect(x: 0, y: fakeStatusBarHeight + navContainerViewHeight - value, width: Int(kDeviceWidth), height: itemScrollViewHeight)
            
            // Fade at twice the scroll rate
            let fade = 1.0 - (CGFloat(2 * value) / CGFloat(fakeStatusBarHeight + navViewHeight + itemScrollViewHeight))
            logoBackgroundView.alpha = fade
            auxLogoBackgroundView.alpha = 1 - fade
        }
        else
        {
            browserView.updateFrame(CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + itemScrollViewHeight, width: Int(kDeviceWidth), height: browserHeight + navContainerViewHeight - navViewHeight))
            itemScrollView?.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight, width: Int(kDeviceWidth), height: itemScrollViewHeight)
            logoBackgroundView.alpha = 0
            auxLogoBackgroundView.alpha = 1
        }
        
        // Move the left and right shadows too
        if (leftShadow != nil)
        {
            leftShadow.frame = CGRect(x: -6, y: Int(itemScrollView.frame.origin.y), width: 22, height: Int(itemScrollView.frame.size.height))
        }
        
        if (rightShadow != nil)
        {
            rightShadow.frame = CGRect(x: Int(kDeviceWidth) - 16, y: Int(itemScrollView.frame.origin.y), width: 22, height: Int(itemScrollView.frame.size.height))
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
        
        self.view.backgroundColor = UIColor.mpWhiteColor()
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navContainerView.frame.size.height)
        itemScrollView.frame = CGRect(x: 0, y: navContainerView.frame.origin.y + navContainerView.frame.size.height, width: kDeviceWidth, height: itemScrollView.frame.size.height)
        itemScrollView.backgroundColor = UIColor.mpWhiteColor()
        
        // Moved to getTeamRecords
        /*
        // We need to explicitly calculate the browser's height without ads for use elesewhere
        let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
        let navContainerViewHeight = Int(navContainerView.frame.size.height)
        let itemScrollViewHeight = Int(itemScrollView.frame.size.height)
        
        browserHeight = Int(kDeviceHeight) - fakeStatusBarHeight - navContainerViewHeight - itemScrollViewHeight - SharedData.bottomSafeAreaHeight - kTabBarHeight
        
        browserView = FavoritesBrowserView(frame: CGRect(x: 0, y: fakeStatusBarHeight + navContainerViewHeight + itemScrollViewHeight, width: Int(kDeviceWidth), height: browserHeight))
        browserView.delegate = self
        self.view.addSubview(browserView)
        */
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Make the logo backgrounds round
        logoBackgroundView.layer.cornerRadius = logoBackgroundView.frame.size.width / 2.0
        logoBackgroundView.clipsToBounds = true
        
        auxLogoBackgroundView.layer.cornerRadius = auxLogoBackgroundView.frame.size.width / 2.0
        auxLogoBackgroundView.clipsToBounds = true
        
        auxLogoBackgroundView.alpha = 0
        
        schoolNameLabel.text = ""
        teamNameLabel.text = ""
        mascotImageView.image = nil;
        teamFirstLetterLabel.text = ""
        auxMascotImageView.image = nil;
        auxTeamFirstLetterLabel.text = ""
        yearSelectorButton.isHidden = true
        memberSelectorButton.isHidden = true
        
        // Add the profile button. The image will be updated later
        profileButton = UIButton(type: .custom)
        profileButton?.frame = CGRect(x: 20, y: 10, width: 34, height: 34)
        profileButton?.layer.cornerRadius = (profileButton?.frame.size.width)! / 2.0
        profileButton?.clipsToBounds = true
        //profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        profileButton?.addTarget(self, action: #selector(self.profileButtonTouched), for: .touchUpInside)
        navView?.addSubview(profileButton!)
        
        // Set the image to the settings icon if a Test Drive user right away
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            profileButton?.setImage(UIImage.init(named: "SettingsButton"), for: .normal)
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
        
        // Load the user image
        self.loadUserImage()
        
        // Skip the rest of the code if retruning from a web view
        if (webVC != nil)
        {
            webVC = nil
            return
        }
        
        // Load the initial screen.
        let section = kUserDefaults.value(forKey: kSelectedFavoriteSectionKey) as! Int
        
        if (section == 0)
        {
            // Favorite Team
            let favoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
            selectedYearIndex = 0
            
            if (favoriteTeams != nil) && (favoriteTeams!.count > 0)
            {
                noFavoritesLabel.isHidden = true
                memberSelectorButton.isHidden = false
                yearSelectorButton.isHidden = false
                
                // Temporary code
                memberSelectorButton.setTitle("JOIN TEAM", for: .normal)
                
                if (favoriteTeams!.count > 1)
                {
                    switchTeamsButton.isHidden = false
                }
                else
                {
                    switchTeamsButton.isHidden = true
                }
                
                var index = kUserDefaults.value(forKey: kSelectedFavoriteIndexKey) as! Int
                
                // Fix the index in case it exceeds the count
                if (index >= favoriteTeams!.count)
                {
                    index = 0
                    kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
                }
                
                let favoriteTeam = favoriteTeams?[index] as! Dictionary<String, Any>
                self.loadFavoriteTeamHeader(favoriteTeam)
                
                // Get the SSID's for the active team
                self.getSSIDsForTeam(favoriteTeam)
            }
            else
            {
                // Display the no favorite label
                noFavoritesLabel.isHidden = false
                switchTeamsButton.isHidden = true
                schoolNameLabel.text = ""
                teamNameLabel.text = ""
                logoBackgroundView.isHidden = true
                fakeStatusBar!.backgroundColor = UIColor.mpRedColor()
                navView!.backgroundColor = UIColor.mpRedColor()
                yearSelectorButton.isHidden = true
                memberSelectorButton.isHidden = true
            }
        }
        else
        {
            // Favorite Athlete
            let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
            selectedYearIndex = 0
            
            if (favoriteAthletes != nil) && (favoriteAthletes!.count > 0)
            {
                noFavoritesLabel.isHidden = true
                memberSelectorButton.isHidden = true
                yearSelectorButton.isHidden = true
                
                // Temporary code
                memberSelectorButton.setTitle("JOIN TEAM", for: .normal)
                
                if (favoriteAthletes!.count > 1)
                {
                    switchTeamsButton.isHidden = false
                }
                else
                {
                    switchTeamsButton.isHidden = true
                }
                
                var index = kUserDefaults.value(forKey: kSelectedFavoriteIndexKey) as! Int
                
                // Fix the index in case it exceeds the count
                if (index >= favoriteAthletes!.count)
                {
                    index = 0
                    kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
                }
                
                let favoriteAthlete = favoriteAthletes?[index] as! Dictionary<String, Any>
                self.loadFavoriteAthleteHeader(favoriteAthlete)
            }
            else
            {
                // Display the no favorite label
                noFavoritesLabel.isHidden = false
                switchTeamsButton.isHidden = true
                schoolNameLabel.text = ""
                teamNameLabel.text = ""
                logoBackgroundView.isHidden = true
                fakeStatusBar!.backgroundColor = UIColor.mpRedColor()
                navView!.backgroundColor = UIColor.mpRedColor()
                yearSelectorButton.isHidden = true
                memberSelectorButton.isHidden = true
            }
        }
        
        /*
        // Refresh the Screen if coming back from the searchVC or the favoriteListVC
        if let value = searchVC?.favoriteSaved
        {
            if (value == true)
            {
                
            }
        }
        */
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
