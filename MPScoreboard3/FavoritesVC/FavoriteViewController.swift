//
//  FavoriteViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/19/21.
//

import UIKit

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, FavoritesListViewDelegate, TallFavoriteTeamTableViewCellDelegate

{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var editFavoritesButton: UIButton!
    @IBOutlet weak var largeTitleLabel: UILabel!
    @IBOutlet weak var noFavoriteContainerView: UIView!
    @IBOutlet weak var noFavoritesImageView: UIImageView!
    @IBOutlet weak var noFavoriteInnerContainerView: UIView!
    @IBOutlet weak var noFavoriteGetStartedButton: UIButton!
    
    private var profileButton : UIButton?
    private var athleteContainerScrollView : UIScrollView?
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    private var favoriteTeamsArray = [] as Array
    private var favoriteAthletesArray = [] as Array
    private var detailedFavoritesArray = [] as Array
    private var bottomTabBarPad = 0
    
    private var searchVC: SearchViewController!
    private var webVC: WebViewController!
    private var settingsVC: SettingsViewController!
    private var teamDetailVC: TeamDetailViewController!
    private var profileVC: ProfileViewController!
    private var favoritesListView: FavoritesListView!
    
    // MARK: - Get Team Detail Card Data
    
    private func getTeamDetailCardData()
    {
        // Extract the schoolId and allSeasonId from the favorites
        detailedFavoritesArray.removeAll()
        
        var postData = [] as Array<Dictionary<String,String>>
        
        for favorite in favoriteTeamsArray
        {
            let item = favorite  as! Dictionary<String, Any>
            let schoolId = item[kNewSchoolIdKey] as! String
            let allSeasonId = item[kNewAllSeasonIdKey] as! String
            let postDictionary = ["teamId": schoolId, "allSeasonId": allSeasonId]
            postData.append(postDictionary)
        }
        
        NewFeeds.getDetailCardDataForTeams(postData) { [self] resultData, error in
            
            if (error == nil)
            {
                print("Team Detail Success")
                
                // Refactor the feed if it doesn't match the favorites
                if (resultData!.count == favoriteTeamsArray.count)
                {
                    detailedFavoritesArray = resultData!
                    //print("Done")
                }
                else
                {
                    for favorite in favoriteTeamsArray
                    {
                        let item = favorite  as! Dictionary<String, Any>
                        let schoolId = item[kNewSchoolIdKey] as! String
                        let allSeasonId = item[kNewAllSeasonIdKey] as! String
                        
                        var noMatch = false
                        for resultObj in resultData!
                        {
                            let obj = resultObj as Dictionary<String,Any>
                            let resultSchoolId = obj["teamId"] as! String
                            let resultAllSeasonId = obj["allSeasonId"] as! String
                            
                            if (resultSchoolId == schoolId) && (resultAllSeasonId == allSeasonId)
                            {
                                // Match is found so add the resultObj to the detailedFavoritesArray
                                detailedFavoritesArray.append(resultObj)
                                noMatch = false
                                break
                            }
                            else
                            {
                                noMatch = true
                            }
                        }
                        
                        if (noMatch == true)
                        {
                            // Add a dummy object
                            let dummyObj = ["record":[:], "schedules":[], "latestItems":[]] as [String : Any]
                            detailedFavoritesArray.append(dummyObj)
                        }
                    }
                }
                
                /*
                 {
                     "status": 200,
                     "message": "Success",
                     "cacheResult": "Unknown",
                     "data": [
                         {
                             "teamId": "d9622df1-9a90-49e7-b219-d6c380c566fe",
                             "allSeasonId": "22e2b335-334e-4d4d-9f67-a0f716bb1ccd",
                             "cardItems": [
                                 {
                                     "record": {
                                         "overallStanding": {
                                             "winningPercentage": 0.000,
                                             "overallWinLossTies": "0-0",
                                             "homeWinLossTies": "0-0",
                                             "awayWinLossTies": "0-0",
                                             "neutralWinLossTies": "0-0",
                                             "points": 0,
                                             "pointsAgainst": 0,
                                             "streak": 0,
                                             "streakResult": "0"
                                         },
                                         "leagueStanding": {
                                             "leagueName": "Foothill Valley",
                                             "canonicalUrl": "https://z.maxpreps.com/league/vIKP_ANcBEeRvG9E5Ztn4Q/standings-foothill-valley.htm",
                                             "conferenceWinningPercentage": 0.000,
                                             "conferenceWinLossTies": "0-0",
                                             "conferenceStandingPlacement": "1st"
                                         }
                                     }
                                 },
                                 {
                                     "schedules": [
                                         {
                                             "hasResult": false,
                                             "resultString": "",
                                             "dateString": "3/19",
                                             "timeString": "7:00 PM",
                                             "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                             "opponentName": "Rio Linda",
                                             "opponentNameAcronym": "RLHS",
                                             "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                "opponentColor1": "000080",
                                             "homeAwayType": "Home",
                                             "contestIsLive": false,
                                             "canonicalUrl": "https://dev.maxpreps.com/games/3-19-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=OIRYlXxgWEaHfK7OipEITQ"
                                         },
                                         {
                                             "hasResult": false,
                                             "resultString": "",
                                             "dateString": "3/25",
                                             "timeString": "12:00 PM",
                                             "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                             "opponentName": "Rio Linda",
                                             "opponentNameAcronym": "RLHS",
                                             "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                "opponentColor1": "000080",
                                             "homeAwayType": "Neutral",
                                             "contestIsLive": false,
                                             "canonicalUrl": "https://dev.maxpreps.com/games/3-25-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=ZLpSnJTDFUSEscaGO3BsYQ"
                                         }
                                     ]
                                 },
                                 {
                                     "latestItems": [
                                         {
                                             "type": "Article",
                                             "title": "State officials, CIF, coaches meet",
                                             "text": "Dr. Mark Ghaly enters discussion; California coaches group calls meeting 'cooperative,  positive, and open,' but student-athletes are running out of time. ",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/c/b/8/cb8ee48f-fe58-44dc-baec-f00d7ccf7692/3a4ed84d-c366-eb11-80ce-a444a33a3a97_original.jpg?version=637481180400000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/j-SOy1j-3ES67PANfM92kg/california-high-school-sports--state-officials,-cif,-coaches-find-common-ground,-talks-to-resume-next-week.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "New hope for California sports",
                                             "text": "Teams slotted in purple tier now allowed to compete; four Sac-Joaquin Section cross country teams ran in Monday meet.",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/5/0/7/507b80b1-d75a-4909-b52c-474eef259269/e618f53f-745f-eb11-80ce-a444a33a3a97_original.jpg?version=637471932600000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/sYB7UFrXCUm1LEdO7yWSaQ/new-hope-for-california-high-school-sports-after-stay-home-orders-lifted.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "SJS releases new play for Season 1 in 2021",
                                             "text": "State's second-largest section will forego traditional postseason to allow schools chance to participate in more games. ",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/d/2/9/d298908e-0c1c-46aa-861c-96e4fa76ffad/07b358d0-8941-eb11-80ce-a444a33a3a97_original.jpg?version=637439061000000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/jpCY0hwMqkaGHJbk-nb_rQ/sac-joaquin-section-releases-new-plan-for-season-1-in-2021.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "Video: When will California sports return?",
                                             "text": "Health and Human Services agency provides an update as state grapples with COVID-19 guidelines, tiers.",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/9/a/a9a554a4-6e1b-4835-828a-4b989d7a79a9/2cf9a134-d723-eb11-80ce-a444a33a3a97_original.jpg?version=637409524200000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/pFSlqRtuNUiCikuYnXp5qQ/video--when-will-california-high-school-and-youth-sports-return.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "Map: Where NFL QBs went to high school",
                                             "text": "Patrick Mahomes, Kyler Murray join 18 other quarterbacks who played high school football in Texas.",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/e/0/ae0a7fa5-86bc-4082-91e3-4cf67d094940/29d89c6e-d17d-ea11-80ce-a444a33a3a97_original.jpg?version=637223926200000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/pX8KrryGgkCR40z2fQlJQA/map--where-every-nfl-quarterback-drafted-in-the-past-10-years-played-high-school-football.htm"
                                         }
                                     ]
                                 }
                             ]
                         }
                     ],
                     "warnings": [],
                     "errors": []
                 }
                 */
            }
            else
            {
                print("Team Detail Fail")
            }
            
            self.favoritesTableView.reloadData()
        }
    }
    
    
    
    // MARK: - Favorites List View Delegate
    
    func closeFavoritesListViewAfterChange()
    {
        favoritesListView.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
        
        // Refresh the screen
        if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favoriteTeamsArray = favTeams
        }
        
        if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            favoriteAthletesArray = favAthletes
        }
        
        // Show the empty favorites overlay
        if (favoriteTeamsArray.count == 0)
        {
            noFavoriteContainerView.isHidden = false
            editFavoritesButton.isHidden = true
        }
        else
        {
            noFavoriteContainerView.isHidden = true
            editFavoritesButton.isHidden = false
            
            favoritesTableView.reloadData()
            
            // Disable scrolling if the content height is less than the tableView's frame
            let contentHeight = (favoriteAthletesArray.count * 50) + (favoriteTeamsArray.count * 58)
            
            if (contentHeight < Int(favoritesTableView.frame.size.height))
            {
                favoritesTableView.isScrollEnabled = false
            }
            else
            {
                favoritesTableView.isScrollEnabled = true
            }
        }
        
        // Get card details if the favorite tema count is 1, 2, or 3
        if (favoriteTeamsArray.count > 0) && (favoriteTeamsArray.count <= 3)
        {
            self.getTeamDetailCardData()
        }
        
    }
    
    func closeFavoritesListView()
    {
        favoritesListView.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Show Web VC
    
    private func showWebViewController(urlString: String, title: String)
    {
        // Add the app's custom query parameter
        var fixedUrlString = ""
        
        if (urlString.contains("?"))
        {
            fixedUrlString = urlString + "&" + kAppIdentifierQueryParam
        }
        else
        {
            fixedUrlString = urlString + "?" + kAppIdentifierQueryParam
        }
        
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = title
        webVC?.urlString = fixedUrlString
        webVC?.titleColor = UIColor.mpBlackColor()
        webVC?.navColor = UIColor.mpWhiteColor()//schoolColor
        webVC?.allowRotation = false
        webVC?.showShareButton = true
        webVC?.showNavControls = true
        webVC?.showScrollIndicators = false
        webVC?.showLoadingOverlay = true
        webVC?.showBannerAd = false

        self.navigationController?.pushViewController(webVC!, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - Show Settings VC
    
    private func showSettingsVC()
    {
        settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        let settingsNav = TopNavigationController()
        settingsNav.viewControllers = [settingsVC] as Array
        settingsNav.modalPresentationStyle = .fullScreen
        self.present(settingsNav, animated: true)
        {
            
        }
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
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoriteTeamsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (favoriteTeamsArray.count > 3)
        {
            return 60.0
        }
        else
        {
            // Need to make sure that this array has data because the table could be loaded before the feed finishes
            if (detailedFavoritesArray.count > indexPath.row)
            {
                let cardObject = detailedFavoritesArray[indexPath.row] as! Dictionary<String,Any>

                let schedules = cardObject["schedules"] as! Array<Dictionary<String,Any>>
                let latestItems = cardObject["latestItems"] as! Array<Dictionary<String,Any>>
                
                // Set the display mode
                if ((schedules.count > 0) && (latestItems.count > 0))
                {
                    return 356.0
                }
                else if ((schedules.count > 0) && (latestItems.count == 0))
                {
                    return 356.0 - 152.0 // No Articles
                }
                else if ((schedules.count == 0) && (latestItems.count > 0))
                {
                    return 356.0 - 92.0 // No Contests
                }
                else
                {
                    return 356.0 - 152.0 - 92.0 // Just the record field is displayed
                }
            }
            else
            {
                return 0 // Everything is hidden
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (favoriteAthletesArray.count > 0)
        {
            return 50.0
        }
        else
        {
            return 0.1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        athleteContainerScrollView?.removeFromSuperview()
        
        if (favoriteAthletesArray.count == 0)
        {
            return nil
        }
        else
        {
            athleteContainerScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: Int(tableView.frame.size.width), height: 50))
            athleteContainerScrollView!.backgroundColor = UIColor.mpWhiteColor()
            athleteContainerScrollView!.bounces = false
            athleteContainerScrollView!.delegate = self
            athleteContainerScrollView!.showsHorizontalScrollIndicator = false
            
            // Fill the scrollView with buttons
            var count = 0
            var overallWidth = 0
            let textPad = 10
            let buttonSpace = 12
            var leftPad = 0
            let rightPad = 16
            
            for athlete in favoriteAthletesArray as! Array<Dictionary<String,Any>>
            {
                let firstName = athlete[kAthleteCareerProfileFirstNameKey] as! String
                let lastName = athlete[kAthleteCareerProfileLastNameKey] as! String
                let fullName = firstName + " " + lastName
                //let schoolName = athlete[kAthleteCareerProfileSchoolNameKey] as! String
                //let initial = String(schoolName.prefix(1))
                //let schoolColor = athlete[kAthleteCareerProfileSchoolColor1Key] as! String
                //let mascotUrl = athlete[kAthleteCareerProfileSchoolMascotUrlKey] as! String
                
                let itemWidth = Int(fullName.widthOfString(usingFont: UIFont.mpRegularFontWith(size: 15))) + (2 * textPad)
                let tag = 100 + count
                
                // Add the left pad to the first cell
                if (count == 0)
                {
                    leftPad = 16
                }
                else
                {
                    leftPad = 0
                }
                
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: overallWidth + leftPad, y: 9, width: itemWidth, height: 32)
                button.tag = tag
                button.backgroundColor = UIColor.mpWhiteColor()
                button.layer.cornerRadius = button.frame.size.height / 2.0
                button.layer.borderWidth = 1
                button.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
                button.clipsToBounds = true
                button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
                button.setTitle(fullName, for: .normal)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                button.addTarget(self, action: #selector(self.athleteButtonTouched), for: .touchUpInside)
                
                athleteContainerScrollView!.addSubview(button)
                
                count += 1
                overallWidth += (itemWidth + leftPad + buttonSpace)
            }
            
            athleteContainerScrollView!.contentSize = CGSize(width: overallWidth + rightPad - buttonSpace, height: Int(athleteContainerScrollView!.frame.size.height))
            
            // Add the left and right shadows
            leftShadow = UIImageView(frame: CGRect(x: -6, y: Int(0), width: 22, height: Int(athleteContainerScrollView!.frame.size.height)))
            leftShadow.image = UIImage(named: "LeftShadow")
            leftShadow.tag = 200
            athleteContainerScrollView!.addSubview(leftShadow)
            leftShadow.isHidden = true
            
            rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 16, y: 0, width: 22, height: Int(athleteContainerScrollView!.frame.size.height)))
            rightShadow.image = UIImage(named: "RightShadow")
            rightShadow.tag = 201
            athleteContainerScrollView!.addSubview(rightShadow)
            
            // Hide the rightShadow if the scrollView contentSize.x is smaller than the width
            if (athleteContainerScrollView!.contentSize.width <= kDeviceWidth)
            {
                rightShadow.isHidden = true
            }
            
            return athleteContainerScrollView
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let favorite = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
        
        let name = favorite[kNewSchoolNameKey] as! String
        let initial = String(name.prefix(1))
        
        let gender = favorite[kNewGenderKey] as! String
        let sport = favorite[kNewSportKey] as! String
        let level = favorite[kNewLevelKey] as!String
        let schoolId = favorite[kNewSchoolIdKey] as!String
        let allSeasonId = favorite[kNewAllSeasonIdKey] as! String
        
        let levelGenderSport = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        
        // Different cells depending on the favorites count
        if (favoriteTeamsArray.count > 3)
        {
            // Short Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "ShortFavoriteTeamTableViewCell") as? ShortFavoriteTeamTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("ShortFavoriteTeamTableViewCell", owner: self, options: nil)
                cell = nib![0] as? ShortFavoriteTeamTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.teamFirstLetterLabel.isHidden = false
            cell?.adminContainerView.isHidden = true
            cell?.memberContainerView.isHidden = true
            cell?.joinButton.isHidden = true

            cell?.subtitleLabel.text =  levelGenderSport
            cell?.titleLabel.text = name
            cell?.teamFirstLetterLabel.text = initial
            
            // Look at the roles dictionary for a match if a logged in user
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            
            if (userId != kTestDriveUserId)
            {
                let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
                let roleKey = schoolId + "_" + allSeasonId
                
                if (adminRoles![roleKey] != nil)
                {
                    let adminRole = adminRoles![roleKey] as! Dictionary<String,String>
                    let roleName = adminRole[kRoleNameKey]
                    
                    if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
                    {
                        cell?.adminContainerView.isHidden = false
                    }
                    else if (roleName == "Team Community")
                    {
                        cell?.memberContainerView.isHidden = false
                    }
                }
            }
            
            // Look for a mascot
            if let schoolsInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
            {
                if let schoolInfo = schoolsInfo[schoolId] as? Dictionary<String, String>
                {
                    // Set the cell's fill color
                    let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                    let color = ColorHelper.color(fromHexString: hexColorString)
                    //cell?.addShapeLayers(color: color!)
                    
                    let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
                    let url = URL(string: mascotUrl!)

                    if (mascotUrl!.count > 0)
                    {
                        // Get the data and make an image
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }
                            //print("Download Finished")
                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                
                                if (image != nil)
                                {
                                    let scaledWidth = cell?.teamMascotImageView.frame.size.height
                                    let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth!, height: scaledWidth!))
                                    
                                    cell?.teamFirstLetterLabel.isHidden = true
                                    
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
                                            cell?.teamMascotImageView.image = scaledImage
                                        }
                                        else
                                        {
                                            let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: scaledWidth! / 2.0)
                                            cell?.teamMascotImageView.image = roundedImage
                                        }
                                    }
                                    else
                                    {
                                        print("Corner Color Mismatch")
                                        cell?.teamMascotImageView.image = scaledImage
                                    }
                                }
                                else
                                {
                                    // Set the first letter color
                                    cell?.teamFirstLetterLabel.textColor = color
                                }
                            }
                        }
                    }
                    else
                    {
                        // Set the first letter color
                        cell?.teamFirstLetterLabel.textColor = color
                    }
                }
            }
            
            return cell!
    
        }
        else
        {
            // Tall Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "TallFavoriteTeamTableViewCell") as? TallFavoriteTeamTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TallFavoriteTeamTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TallFavoriteTeamTableViewCell
            }
            
            cell?.delegate = self
            cell?.selectionStyle = .none
            
            // Need to make sure that this array has data because the table could be loaded before the feed finishes
            if (detailedFavoritesArray.count > indexPath.row)
            {
                let cardObject = detailedFavoritesArray[indexPath.row] as! Dictionary<String,Any>
                let record = cardObject["record"] as! Dictionary<String,Any>
                let schedules = cardObject["schedules"] as! Array<Dictionary<String,Any>>
                let latestItems = cardObject["latestItems"] as! Array<Dictionary<String,String>>
                
                // Set the display mode
                if ((schedules.count > 0) && (latestItems.count > 0))
                {
                    cell?.setDisplayMode(mode: FavoriteDetailCellMode.allCells)
                    cell?.loadTeamRecordData(record)
                    cell?.loadArticleData(latestItems)
                    
                    if (schedules.count == 1)
                    {
                        let contest = schedules.first
                        cell?.loadTopContestData(contest!)
                    }
                    else
                    {
                        let contest1 = schedules.first
                        cell?.loadTopContestData(contest1!)
                        
                        let contest2 = schedules.last
                        cell?.loadTopContestData(contest2!)
                    }
                }
                else if ((schedules.count > 0) && (latestItems.count == 0))
                {
                    cell?.setDisplayMode(mode: FavoriteDetailCellMode.noArticles)
                    cell?.loadTeamRecordData(record)
                    
                    if (schedules.count == 1)
                    {
                        let contest = schedules.first
                        cell?.loadTopContestData(contest!)
                    }
                    else
                    {
                        let contest1 = schedules.first
                        cell?.loadTopContestData(contest1!)
                        
                        let contest2 = schedules.last
                        cell?.loadTopContestData(contest2!)
                    }
                }
                else if ((schedules.count == 0) && (latestItems.count > 0))
                {
                    cell?.setDisplayMode(mode: FavoriteDetailCellMode.noContests)
                    cell?.loadTeamRecordData(record)
                    cell?.loadArticleData(latestItems)
                }
                else
                {
                    cell?.setDisplayMode(mode: FavoriteDetailCellMode.noContestsOrArticles)
                    cell?.loadTeamRecordData(record)
                }
            }
            
            cell?.teamFirstLetterLabel.isHidden = false

            cell?.subtitleLabel.text =  levelGenderSport
            cell?.titleLabel.text = name
            cell?.teamFirstLetterLabel.text = initial
            cell?.sportIconImageView.image = MiscHelper.getImageForSport(sport)
            
            // Look for a mascot
            if let schoolsInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
            {
                if let schoolInfo = schoolsInfo[schoolId] as? Dictionary<String, String>
                {
                    // Set the cell's fill color
                    let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                    let color = ColorHelper.color(fromHexString: hexColorString)
                    cell?.addShapeLayers(color: color!)
                    
                    let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
                    let url = URL(string: mascotUrl!)

                    if (mascotUrl!.count > 0)
                    {
                        // Get the data and make an image
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }
                            //print("Download Finished")
                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                
                                if (image != nil)
                                {
                                    let scaledWidth = cell?.teamMascotImageView.frame.size.height
                                    let scaledImage = ImageHelper.image(with: image, scaledTo: CGSize(width: scaledWidth!, height: scaledWidth!))
                                    
                                    cell?.teamFirstLetterLabel.isHidden = true
                                    
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
                                            cell?.teamMascotImageView.image = scaledImage
                                        }
                                        else
                                        {
                                            let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: scaledWidth! / 2.0)
                                            cell?.teamMascotImageView.image = roundedImage
                                        }
                                    }
                                    else
                                    {
                                        print("Corner Color Mismatch")
                                        cell?.teamMascotImageView.image = scaledImage
                                    }
                                }
                                else
                                {
                                    // Set the first letter color
                                    cell?.teamFirstLetterLabel.textColor = color
                                }
                            }
                        }
                    }
                    else
                    {
                        // Set the first letter color
                        cell?.teamFirstLetterLabel.textColor = color
                    }
                }
            }
            
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        
        let selectedTeam = favoriteTeamsArray[indexPath.row] as! Dictionary<String,Any>
        
        // Refactor the selected team into a Team object that is used by the TeamDetailVC
        let schoolId = selectedTeam[kNewSchoolIdKey] as! String
        let name = selectedTeam[kNewSchoolNameKey] as! String
        let fullName = selectedTeam[kNewSchoolFormattedNameKey] as! String
        let city = selectedTeam[kNewSchoolCityKey] as! String
        let state = selectedTeam[kNewSchoolStateKey] as! String
        let gender = selectedTeam[kNewGenderKey] as! String
        let sport = selectedTeam[kNewSportKey] as! String
        let level = selectedTeam[kNewLevelKey] as!String
        let season = selectedTeam[kNewSeasonKey] as!String
        let allSeasonId = selectedTeam[kNewAllSeasonIdKey] as! String
        var mascotUrlString = ""
        var hexColorString = ""
        
        // Make sure that the school info exists
        let schoolInfos = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)

        if schoolInfos![schoolId] != nil
        {
            let schoolInfo = schoolInfos![schoolId] as! Dictionary<String, String>
            hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
            mascotUrlString = schoolInfo[kNewSchoolInfoMascotUrlKey]!
        }
        
        let selectedTeamObj = Team(teamId: 0, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: hexColorString, mascotUrl: mascotUrlString, schoolName: name, teamLevel: level, schoolId: schoolId, schoolState: state, schoolCity: city, schoolFullName: fullName, season: season, notifications: [])
        
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
        
        // Look at the roles dictionary for a match to forward the role to the VC
        let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        let roleKey = schoolId + "_" + allSeasonId
        var userRole = "Follower"
        
        if (adminRoles![roleKey] != nil)
        {
            let adminRole = adminRoles![roleKey] as! Dictionary<String,String>
            let roleName = adminRole[kRoleNameKey]
            
            if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
            {
                userRole = "Admin"
            }
            else if (roleName == "Team Community")
            {
                userRole = "Member"
            }
        }
        
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = selectedTeamObj
        teamDetailVC.showSaveFavoriteButton = false
        teamDetailVC.userRole = userRole
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
        
        /*
        // Set the new selectedIndex in prefs
        kUserDefaults.setValue(NSNumber(integerLiteral: indexPath.row), forKey: kSelectedFavoriteIndexKey)
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.dismiss(animated: true)
            {
                
            }
        }
         */
    }
    
    // MARK: - TallTableViewCell Delegate Methods
    
    func collectionViewDidSelectItem(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "")
    }
    
    func topContestTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Contest")
    }
    
    func bottomContestTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Contest")
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
                        
            profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
            self.navigationController?.pushViewController(profileVC, animated: true)
            
            self.hidesBottomBarWhenPushed = false
        }
    }
    
    @IBAction func searchButtonTouched(_ sender: UIButton)
    {
        searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(searchVC!, animated: true)
        
        /*
        let favoriteTeamsArray = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        let favoriteAthletesArray = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        
        if (favoriteTeamsArray != nil) && (favoriteAthletesArray != nil)
        {
            if ((favoriteTeamsArray!.count < kMaxFavoriteTeamsCount) && (favoriteAthletesArray!.count < kMaxFavoriteAthletesCount))
            {
                //self.hidesBottomBarWhenPushed = true
                searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
                self.navigationController?.pushViewController(searchVC!, animated: true)
                //self.hidesBottomBarWhenPushed = false
            }
            else
            {
                let messageTitle = String(kMaxFavoriteTeamsCount) + " Team Limit"
                let messageText = "The maximum number of favorites allowed is " + String(kMaxFavoriteTeamsCount) + ".  You must remove a team in order to add another."
                
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: messageTitle, message: messageText, lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
 */
    }
    
    @objc private func athleteButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        
        // Favorite Athlete
        let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        
        if (favoriteAthletes != nil) && (favoriteAthletes!.count > 0)
        {
            let favoriteAthlete = favoriteAthletes?[index] as! Dictionary<String, Any>
            
            /*
             let kAthleteCareerProfileFirstNameKey = "careerProfileFirstName"        // String
             let kAthleteCareerProfileLastNameKey = "careerProfileLastName"          // String
             let kAthleteCareerProfileSchoolNameKey = "schoolName"                   // String
             let kAthleteCareerProfileSchoolIdKey = "schoolId"                       // String
             let kAthleteCareerProfileSchoolColor1Key = "schoolColor1"               // String
             let kAthleteCareerProfileSchoolMascotUrlKey = "schoolMascotUrl"         // String
             let kAthleteCareerProfileSchoolCityKey = "schoolCity"                   // String
             let kAthleteCareerProfileSchoolStateKey = "schoolState"                 // String
             let kAthleteCareerProfileIdKey = "careerProfileId"                      // String
             let kAthleteCareerProfilePhotoUrlKey = "photoUrl"                       // String
             */
            
            let firstName = favoriteAthlete[kAthleteCareerProfileFirstNameKey] as! String
            let lastName = favoriteAthlete[kAthleteCareerProfileLastNameKey] as! String
            let schoolName = favoriteAthlete[kAthleteCareerProfileSchoolNameKey] as! String
            let schoolId = favoriteAthlete[kAthleteCareerProfileSchoolIdKey] as! String
            let schoolColor1 = favoriteAthlete[kAthleteCareerProfileSchoolColor1Key] as! String
            let schoolMascotUrl = favoriteAthlete[kAthleteCareerProfileSchoolMascotUrlKey] as! String
            let schoolCity = favoriteAthlete[kAthleteCareerProfileSchoolCityKey] as! String
            let schoolState = favoriteAthlete[kAthleteCareerProfileSchoolStateKey] as! String
            let careerProfileId = favoriteAthlete[kAthleteCareerProfileIdKey] as! String
            let photoUrl = ""
            
            
            let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor1, schoolMascotUrl: schoolMascotUrl, careerId: careerProfileId, photoUrl: photoUrl)
            
            let athleteDetailVC = AthleteDetailViewController(nibName: "AthleteDetailViewController", bundle: nil)
            athleteDetailVC.selectedAthlete = selectedAthlete
            athleteDetailVC.showSaveFavoriteButton = false
            
            self.navigationController?.pushViewController(athleteDetailVC, animated: true)
            
            /*
            let schoolColorString = favoriteAthlete[kAthleteCareerProfileSchoolColor1Key] as! String
            let schoolColor = ColorHelper.color(fromHexString: schoolColorString)!
            
            let careerProfileId = favoriteAthlete[kAthleteCareerProfileIdKey] as! String
            
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
            
            var urlString = String(format: kCareerProfileHostGeneric, subDomain, careerProfileId)
            
            // Add the app's custom query parameter
            urlString = urlString + "&" + kAppIdentifierQueryParam
            
            // Show the web browser
            //self.hidesBottomBarWhenPushed = true
            
            webVC = WebViewController(nibName: "WebViewController", bundle: nil)
            webVC?.titleString = ""
            webVC?.urlString = urlString
            webVC?.titleColor = UIColor.mpWhiteColor()
            webVC?.navColor = schoolColor
            webVC?.allowRotation = false
            webVC?.showShareButton = true
            webVC?.showNavControls = true
            webVC?.showScrollIndicators = false
            webVC?.showLoadingOverlay = true
            webVC?.showBannerAd = false

            self.navigationController?.pushViewController(webVC!, animated: true)
            //self.hidesBottomBarWhenPushed = false
            */
        }
    }
    
    @IBAction func favoritesButtonTouched(_ sender: UIButton)
    {
        
        /*
        let favoritesListVC = FavoritesListViewController(nibName: "FavoritesListViewController", bundle: nil)
        //let favoritesListNav = TopNavigationController()
        //favoritesListNav.viewControllers = [favoritesListVC]
        favoritesListVC.modalPresentationStyle = .formSheet
        favoritesListVC.preferredContentSize = CGSize(width: CGFloat(kDeviceWidth), height: 400.0)
        self.present(favoritesListVC, animated: true, completion: {
            
        })
        */
        
        self.tabBarController?.tabBar.isHidden = true
        
        favoritesListView = FavoritesListView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
        favoritesListView.delegate = self
        self.view.addSubview(favoritesListView)

    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == athleteContainerScrollView)
        {
            let xScroll = Int(scrollView.contentOffset.x)
            
            leftShadow.transform = CGAffineTransform(translationX: CGFloat(xScroll), y: 0)
            rightShadow.transform = CGAffineTransform(translationX: CGFloat(xScroll), y: 0)
            
            if (xScroll <= 0)
            {
                leftShadow.isHidden = true
                rightShadow.isHidden = false
            }
            else if ((xScroll > 0) && (xScroll < (Int(athleteContainerScrollView!.contentSize.width) - Int(kDeviceWidth))))
            {
                leftShadow.isHidden = false
                rightShadow.isHidden = false
            }
            else
            {
                leftShadow.isHidden = false
                rightShadow.isHidden = true
            }
        }
        else
        {
            // TableView is scrolling
            let yScroll = Int(scrollView.contentOffset.y)
            let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
            let navViewHeight =  Int(navView.frame.size.height)
            let titleContainerViewHeight = Int(titleContainerView.frame.size.height)
            let headerHeight = fakeStatusBarHeight + navViewHeight + titleContainerViewHeight
            
            if (yScroll <= 0)
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)

                favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
                
                largeTitleLabel.alpha = 1
                navTitleLabel.alpha = 0
            }
            else if ((yScroll > 0) && (yScroll < titleContainerViewHeight))
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - CGFloat(yScroll), width: kDeviceWidth, height: titleContainerView.frame.size.height)
                            
                favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight - yScroll, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + yScroll)
                
                // Fade at twice the scroll rate
                let fade = 1.0 - (CGFloat(2 * yScroll) / CGFloat(titleContainerViewHeight))
                largeTitleLabel.alpha = fade
                navTitleLabel.alpha = 1 - fade
            }
            else
            {
                titleContainerView.frame = CGRect(x: 0, y: headerHeight - titleContainerViewHeight, width: Int(kDeviceWidth), height: titleContainerViewHeight)
                            
                favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + titleContainerViewHeight)
                
                largeTitleLabel.alpha = 0
                navTitleLabel.alpha = 1
            }
        }
        
        

    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view.backgroundColor = UIColor.mpWhiteColor()
        
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }

        // Explicitly set the header view sizes
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)
        
        let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
        let navViewHeight =  Int(navView.frame.size.height)
        let titleContainerViewHeight = Int(titleContainerView.frame.size.height)
        
        let headerHeight = fakeStatusBarHeight + navViewHeight + titleContainerViewHeight
        
        favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
        
        // Resize the noFavoritesContainer, imageView, and move the innerContainer
        noFavoriteContainerView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
        
        let initialImageWidth = noFavoritesImageView.frame.size.width
        let initialImageHeight = noFavoritesImageView.frame.size.height
        let scale = CGFloat(kDeviceWidth / 414)
        let aspectRatio = initialImageWidth / initialImageHeight
        let newImageWidth = initialImageWidth * scale
        let newImageHeight = newImageWidth / aspectRatio
        
        var imageViewStartY =  noFavoritesImageView.frame.origin.y
        
        // Reduce the stating Y of the image for the iPhone SE
        if (kDeviceHeight < 667)
        {
            imageViewStartY = 5
        }
        
        noFavoritesImageView.frame = CGRect(x: noFavoritesImageView.frame.origin.x, y: imageViewStartY, width: newImageWidth, height: newImageHeight)
        
        noFavoriteInnerContainerView.frame = CGRect(x: 0, y: noFavoritesImageView.frame.origin.y + noFavoritesImageView.frame.size.height, width: CGFloat(kDeviceWidth), height: noFavoriteInnerContainerView.frame.size.height)
        
        noFavoriteGetStartedButton.layer.cornerRadius = 8
        noFavoriteGetStartedButton.layer.borderWidth = 1
        noFavoriteGetStartedButton.layer.borderColor = UIColor.mpBlueColor().cgColor
        noFavoriteGetStartedButton.clipsToBounds = true
        
        noFavoriteContainerView.isHidden = true
        
        // Add the profile button. The image will be updated later
        profileButton = UIButton(type: .custom)
        profileButton?.frame = CGRect(x: 20, y: 4, width: 34, height: 34)
        profileButton?.layer.cornerRadius = (profileButton?.frame.size.width)! / 2.0
        profileButton?.clipsToBounds = true
        //profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        profileButton?.addTarget(self, action: #selector(self.profileButtonTouched), for: .touchUpInside)
        navView?.addSubview(profileButton!)
        
        navTitleLabel.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        
        // Skip loading the user image and the table if coming back from these VC's since nothing can change
        if (webVC != nil) || (teamDetailVC != nil)
        {
            return
        }
        
        // Set the image to the settings icon if a Test Drive user right away
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            profileButton?.setImage(UIImage.init(named: "SettingsButton"), for: .normal)
        }
        else
        {
            // Load the user image
            self.loadUserImage()
        }
        
        // Load the favorites
        favoriteTeamsArray.removeAll()
        favoriteAthletesArray.removeAll()
        
        if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favoriteTeamsArray = favTeams
        }
        
        if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            favoriteAthletesArray = favAthletes
        }
        
        favoritesTableView.reloadData()
        
        // Hide the table if the teams count is zero
        if (favoriteTeamsArray.count == 0)
        {
            noFavoriteContainerView.isHidden = false
            editFavoritesButton.isHidden = true
        }
        else
        {
            noFavoriteContainerView.isHidden = true
            editFavoritesButton.isHidden = false
            
            var contentHeight = 0
            
            // Disable scrolling if the content height is less than the tableView's frame
            if (favoriteTeamsArray.count > 0) && (favoriteTeamsArray.count <= 3)
            {
                contentHeight = (favoriteAthletesArray.count * 50) + (favoriteTeamsArray.count * 356)
            }
            else
            {
                contentHeight = (favoriteAthletesArray.count * 50) + (favoriteTeamsArray.count * 58)
            }
            
            if (contentHeight < Int(favoritesTableView.frame.size.height))
            {
                favoritesTableView.isScrollEnabled = false
            }
            else
            {
                favoritesTableView.isScrollEnabled = true
            }
        }
        
        // Get card details if the favorite tema count is 1, 2, or 3
        if (favoriteTeamsArray.count > 0) && (favoriteTeamsArray.count <= 3)
        {
            self.getTeamDetailCardData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.darkContent
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
