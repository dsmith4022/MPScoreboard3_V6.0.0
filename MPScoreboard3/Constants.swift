//
//  Constants.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/21.
//

import Foundation
import UIKit

// MARK: - Enumerations
enum DeviceType
{
    case ipad
    case iphone
}

enum AspectRatio
{
    case low
    case medium
    case high
}


// MARK: - Shared Data
struct SharedData
{
    static var deviceType: Any = DeviceType.ipad
    static var deviceAspectRatio: Any = AspectRatio.low
    static var allSchools = Array<School>()
    static var topNotchHeight = 0
    static var bottomSafeAreaHeight = 0
    static var utcTimeOffset : TimeInterval = 0
}

// MARK: - Gender Sport List
let kSearchGenderSportsArray = ["Boys Baseball","Boys Basketball","Boys Cross Country","Boys Flag Football","Boys Football","Boys Golf","Boys Ice Hockey","Boys Lacrosse","Boys Soccer","Boys Swimming","Boys Tennis","Boys Track & Field","Boys Volleyball","Boys Water Polo","Boys Wrestling","Girls Basketball","Girls Cross Country","Girls Field Hockey","Girls Flag Football","Girls Golf","Girls Ice Hockey","Girls Lacrosse","Girls Soccer","Girls Softball","Girls Swimming","Girls Tennis","Girls Track & Field","Girls Volleyball","Girls Water Polo","Girls Wrestling"]

// MARK: - State Name List
let kStateShortNamesArray = ["AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT", "VA","WA","WV","WI","WY"]

// MARK: - General Constants
let kDeviceWidth = UIScreen.main.bounds.size.width
let kDeviceHeight = UIScreen.main.bounds.size.height
let kUserDefaults = UserDefaults.standard
let kStatusBarHeight = 20
let kNavBarHeight = 44
let kTabBarHeight = 49
let kNavBarFontSize = CGFloat(19)
let kAppIdentifierQueryParam = "brandplatformid=maxpreps_app_ios&apptype=scores&appplatform=ios"

let kEmptyGuid = "00000000-0000-0000-0000-000000000000"
let kTestDriveUserId = "01234567-89AB-CDEF-FEDC-BA9876543210"

let kDaveEmail = "dsmith4021@comcast.net"
let kDavePassword = "loriann"
//let kDaveUserId = "c3b23e5b-13ce-4d98-949c-ca41eaa31ab5"
//let kDaveFirstName = "Dave"
//let kDaveLastName = "Smith"
//let kDaveZip = "95670"
let kDave120Email = "dave120@maxpreps.com"
let kDave120Password = "123456"
let kDave122Email = "dave122@maxpreps.com"
let kDave122Password = "123456"
//let kDave120UserId = "1bf120c2-2dd3-4228-9f0c-208faa9f8e80"
let kAppleUserEmail = "apple@maxpreps.com"

// MARK: - Server Mode Keys
let kServerModeKey = "ServerMode"
let kServerModeProduction = "Production"
let kServerModeStaging = "Staging"
let kServerModeDev = "Dev"
let kServerModeBranch = "Branch"
let kBranchValue = "BranchValue"

// Other Prefs
let kDebugDialogsKey = "DebugDialogs"
let kNotificationMasterEnableKey = "NotificationMasterEnable"
let kVideoAutoplayModeKey = "VideoAutoplayMode"

// MARK: - User Info
let kUserEmailKey = "Email"                            // String
let kUserPasswordKey = "Password"                      // String
let kUserIdKey = "UserId"                              // String
let kUserFirstNameKey = "FirstName"                    // String
let kUserLastNameKey = "LastName"                      // String
let kUserZipKey = "Zip"                                // String
let kUserStateKey = "State"                            // String
let kUserRoleKey = "Role"                              // String
let kUserBirthdateKey = "Birthdate"                    // String
let kUserGenderKey = "Gender"                          // String
let kLatitudeKey = "Latitude"                          // String
let kLongitudeKey = "Longitude"                        // String
let kCurrentLocationKey = "CurrentLocation"            // Dictionary

// Admin Roles
let kUserAdminRolesDictionaryKey = "UserAdminRolesDictionary"    // Dictionary (saved to prefs)
let kRoleNameKey = "RoleName"
let kRoleSchoolIdKey = "SchoolId"
let kRollAllSeasonIdKey = "AccessId2"
let kRoleSchoolNameKey = "SchoolName"
let kRoleSportKey = "Sport"
let kRoleGenderKey = "Gender"
let kRoleTeamLevelKey = "TeamLevel"

// MARK: - User Favorite Teams, Athletes, and School Info Keys

let kSelectedFavoriteIndexKey = "SelectedFavoriteIndex"          // Int
let kSelectedFavoriteSectionKey = "SelectedFavoriteSection"      // Int (0=Teams, 1=Athletes)
let kMaxFavoriteTeamsCount = 16
let kMaxFavoriteAthletesCount = 16

// User Favorite Team Keys
let kNewUserFavoriteTeamsArrayKey = "NewUserFavoriteTeamsArray"  // Array
let kNewSchoolMascotKey = "schoolMascot"                         // String
let kNewSportKey = "sport"                                       // String
let kNewSchoolIdKey = "schoolId"                                 // String
let kNewUserfavoriteTeamIdKey = "userFavoriteTeamId"             // Int
let kNewSchoolCityKey = "schoolCity"                             // String
let kNewAllSeasonIdKey = "allSeasonId"                           // String
let kNewLevelKey = "level"                                       // String
let kNewSeasonKey = "season"                                     // String
let kNewSchoolMascotUrlKey = "schoolMascotUrl"                   // String
let kNewSchoolNameKey = "schoolName"                             // String
let kNewSchoolFormattedNameKey = "schoolFormattedName"           // String
let kNewGenderKey = "gender"                                     // String
let kNewSchoolStateKey = "schoolState"                           // String
let kNewNotificationSettingsKey = "notificationSettings"         // Array
let kNewNotificationSortOrderKey = "sortOrder"                   // Int
let kNewNotificationNameKey = "name"                             // String
let kNewNotificationShortNameKey = "shortName"                   // String
let kNewNotificationIsEnabledForAppKey = "isEnabledForApp"       // Bool
//let kNewNotificationIsEnabledForEmailKey = "isEnabledForEmail"   // Bool
//let kNewNotificationIsEnabledForSmsKey = "isEnabledForSms"       // Bool
//let kNewNotificationIsEnabledForWebKey = "isEnabledForWeb"       // Bool
let kNewNotificationUserFavoriteTeamNotificationSettingIdKey = "userFavoriteTeamNotificationSettingId"  // String
let kNewNotificationUserFavoriteTeamIdKey = "userFavoriteTeamId" // String

// User Favorite Athletes Keys
let kUserFavoriteAthletesArrayKey = "UserFavoriteAthletesArray"         // Array
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


// School Info Dictionary Keys
let kNewSchoolInfoDictionaryKey = "NewSchoolInfoDictionary"     // Dictionary
let kNewSchoolInfoNameKey = "name"                              // String
let kNewSchoolInfoFullNameKey = "formattedName"                 // String
let kNewSchoolInfoSchoolIdKey = "schoolId"                      // String
let kNewSchoolInfoMascotUrlKey = "mascotUrl"                    // String
let kNewSchoolInfoColor1Key = "color1"                          // String

// MARK: - Auto Favorites Keys

// Auto Favorites Engine Keys
let kSearchCenterLatitudeKey = "SearchCenterLatitude"        // String
let kSearchCenterLongitudeKey = "SearchCenterLongitude"      // String
let kSearchRadiusKey = "SearchRadius"                        // String

// MARK: - Default School Constants

// Default School
let kDefaultSchoolName = "Abbeville"
let kDefaultSchoolFullName = "Abbeville (AL)"
let kDefaultSchoolId = "78EE5E47-5386-4384-8A8B-0628CF8B9E8B"
let kDefaultSchoolState = "AL"
let kDefaultSchoolLocation = [kLatitudeKey: "31.5755", kLongitudeKey: "-85.279"] // 31.5755,-85.279
let kDefaultZipCode = "36310"

// MARK: - Third Party SDK Keys

// Amazon Production
let kAmazonAdAppKey = "f7d3ca9b746e4ec38e05ef4650cfe6c2"
//let kAmazonTestMode = false
let kAmazonTestMode = true
let kAmazonBannerAdSlotUUID = "337595cf-dad8-4123-ad3c-b8e581982afd"
let kAmazonInlineAdSlotUUID = "ac1729f3-9ea6-4cba-a391-e325c95b2fd0"

// Google Ads
let kNewsBannerAdIdKey = "NewsBannerAdId"
let kScoresBannerAdIdKey = "ScoresBannerAdId"
let kTeamsBannerAdIdKey = "TeamsBannerAdId"
let kWebBannerAdIdKey = "WebBannerAdId"

// MARK: - Feed Constants and URLs

// Feed Constants
let kSessionIdKey = "SessionId"
let kRequestKey = "Request"
let kMaxPrepsAppError = "MP App Error"
let kTokenBusterKey = "TokenBuster"

// Host for updating the individual school files for each state (appended with "state=<CA, WA, ALL, etc.>)
let kDownloadSchoolListHostProduction = "https://secure.maxpreps.com/feeds/apps/common/schools.ashx?state=ALL"

// Host for getting UTC time from the server
let kUtcTimeHostProduction = "https://prod.api.maxpreps.com/teamapp/utilities/utc/v1"

// URL used to populate a browser with a user's login cookies (appended with "?sessionId=<value>")
let kLoginUserWithIdHostProduction = "https://secure.maxpreps.com/feeds/apps_json/common/login_user.ashx"
let kLoginUserWithIdHostStaging = "https://secure-staging.maxpreps.com/feeds/apps_json/common/login_user.ashx"
let kLoginUserWithIdHostDev = "https://secure-dev.maxpreps.com/feeds/apps_json/common/login_user.ashx"

// Old URL for getting the user's info
let kSecureUserIdHostProduction = "https://secure.maxpreps.com/feeds/apps_json/common/validate_member.ashx"
let kSecureUserIdHostStaging = "https://secure-staging.maxpreps.com/feeds/apps_json/common/validate_member.ashx"
let kSecureUserIdHostDev = "https://secure-dev.maxpreps.com/feeds/apps_json/common/validate_member.ashx"

// URL for getting the user's info
let kUserInfoHostProduction = "https://production.api.maxpreps.com/users/%@/roles/public/v1"
let kUserInfoHostStaging = "https://stag.api.maxpreps.com/users/%@/public/v1"
let kUserInfoHostDev = "https://dev.api.maxpreps.com/users/%@/public/v1"

// URL for getting user favorite teams (GET)
let kNewGetUserFavoriteTeamsHostProduction = "https://production.api.maxpreps.com/gateways/app/user-favorites/v1?userid=%@"
let kNewGetUserFavoriteTeamsHostStaging = "https://stag.api.maxpreps.com/gateways/app/user-favorites/v1?userid=%@"
let kNewGetUserFavoriteTeamsHostDev = "https://dev.api.maxpreps.com/gateways/app/user-favorites/v1?userid=%@"

// URL for deleting a single user favorite team (DELETE)
let kNewDeleteUserFavoriteTeamHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-teams/%@/v1"
let kNewDeleteUserFavoriteTeamHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-teams/%@/v1"
let kNewDeleteUserFavoriteTeamHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-teams/%@/v1"

// URL for saving a single user favorite team (POST)
let kNewSaveUserFavoriteTeamHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-teams/v1?sendEmail=true"
let kNewSaveUserFavoriteTeamHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-teams/v1?sendEmail=true"
let kNewSaveUserFavoriteTeamHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-teams/v1?sendEmail=true"

// URL for updating a user favorite team notification setting (PATCH)
let kNewUpdateUserFavoriteTeamNotificationHostProduction =  "https://production.api.maxpreps.com/users/favorite-teams/notification-settings/%@/v1"
let kNewUpdateUserFavoriteTeamNotificationHostStaging = "https://stag.api.maxpreps.com/users/favorite-teams/notification-settings/%@/v1"
let kNewUpdateUserFavoriteTeamNotificationHostDev = "https://dev.api.maxpreps.com/users/favorite-teams/notification-settings/%@/v1"

// URL for getting user favorite athletes (GET)
let kGetUserFavoriteAthletesHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-careers/v1"
let kGetUserFavoriteAthletesHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-careers/v1"
let kGetUserFavoriteAthletesHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-careers/v1"

// URL for adding a user favorite athlete (POST)
let kAddUserFavoriteAthleteHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-careers/v1?sendEmail=true"
let kAddUserFavoriteAthleteHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-careers/v1?sendEmail=true"
let kAddUserFavoriteAthleteHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-careers/v1?sendEmail=true"

// URL for adding user favorite athletes (POST)
let kDeleteUserFavoriteAthleteHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-careers/%@/v1"
let kDeleteUserFavoriteAthleteHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-careers/%@/v1"
let kDeleteUserFavoriteAthleteHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-careers/%@/v1"

// URL for getting school info for a group of schools (mascot, color, etc)
let kNewGetInfoForSchoolsHostProduction = "https://production.api.maxpreps.com/schools/lean-schools/bulk/v1"
let kNewGetInfoForSchoolsHostStaging = "https://stag.api.maxpreps.com/schools/lean-schools/bulk/v1"
let kNewGetInfoForSchoolsHostDev = "https://dev.api.maxpreps.com/schools/lean-schools/bulk/v1"

// URL for getting info (teams) for a particular school
let kNewGetTeamsForSchoolHostProduction = "https://production.api.maxpreps.com/gateways/app/school-info/v1?schoolId=%@"
let kNewGetTeamsForSchoolHostStaging = "https://stag.api.maxpreps.com/gateways/app/school-info/v1?schoolId=%@"
let kNewGetTeamsForSchoolHostDev = "https://dev.api.maxpreps.com/gateways/app/school-info/v1?schoolId=%@"

// URL for using Bitly URL compression
let kBitlyUrlConverterHostProduction = "https://production.api.maxpreps.com/utilities/bitly/shorten/v1?url=%@"
let kBitlyUrlConverterHostStaging = "https://stag.api.maxpreps.com/utilities/bitly/shorten/v1?url=%@"
let kBitlyUrlConverterHostDev = "https://dev.api.maxpreps.com/utilities/bitly/shorten/v1?url=%@"

// URL for getting the ssid's for a team using the allSeasonId
let kGetSSIDsForTeamHostProduction = "https://production.api.maxpreps.com/teams/%@/allsportseasons/%@/sportseasons/v1"
let kGetSSIDsForTeamHostStaging = "https://stag.api.maxpreps.com/teams/%@/allsportseasons/%@/sportseasons/v1"
let kGetSSIDsForTeamHostDev = "https://dev.api.maxpreps.com/teams/%@/allsportseasons/%@/sportseasons/v1"

// URL for getting the team record
let kGetTeamRecordHostProduction = "https://production.api.maxpreps.com/gateways/react/team-standings/v1?teamid=%@&sportseasonid=%@&maxcount=3"
let kGetTeamRecordHostStaging = "https://stag.api.maxpreps.com/gateways/react/team-standings/v1?teamid=%@&sportseasonid=%@&maxcount=3"
let kGetTeamRecordHostDev = "https://dev.api.maxpreps.com/gateways/react/team-standings/v1?teamid=%@&sportseasonid=%@&maxcount=3"

// URL for getting a team's item availability
let kGetTeamAvailabilityHostProduction = "https://production.api.maxpreps.com/teams/%@/sportseasons/%@/data-availability/v1"
let kGetTeamAvailabilityHostStaging = "https://stag.api.maxpreps.com/teams/%@/sportseasons/%@/data-availability/v1"
let kGetTeamAvailabilityHostDev = "https://dev.api.maxpreps.com/teams/%@/sportseasons/%@/data-availability/v1"

// URLs for searching for an athlete
let kAthleteSearchHostProduction = "https://dev.api.maxpreps.com/gateways/app/roster-athlete-search/v1?term=%@&gender=%@&sport=%@" // optional "&maxresults=%@&state=%@&year=%@"
let kAthleteSearchHostStaging = "https://stag.api.maxpreps.com/gateways/app/roster-athlete-search/v1?term=%@&gender=%@&sport=%@" // optional "&maxresults=%@&state=%@&year=%@"
let kAthleteSearchHostDev = "https://dev.api.maxpreps.com/gateways/app/roster-athlete-search/v1?term=%@&gender=%@&sport=%@" // optional "&maxresults=%@&state=%@&year=%@"


// User Profile URLs
let kMemberProfileHostProduction = "https://secure.maxpreps.com/m/member/default.aspx"
let kMemberProfileHostStaging = "https://secure-staging.maxpreps.com/m/member/default.aspx"
let kMemberProfileHostDev = "https://secure-dev.maxpreps.com/m/member/default.aspx"

let kSubscriptionsUrlProduction = "https://secure.maxpreps.com/m/member/subscriptions.aspx"
let kSubscriptionsUrlStaging = "https://secure-staging.maxpreps.com/m/member/subscriptions.aspx"
let kSubscriptionsUrlDev = "https://secure-dev.maxpreps.com/m/member/subscriptions.aspx"

// Used for tech support, privacy policy
let kTechSupportUrl = "https://support.maxpreps.com"
let kCBSTermsOfUseUrl = "https://cbsinteractive.com/legal/cbsi/terms-of-use/"
let kCBSPrivacyPolicyUrl = "https://www.cbsinteractive.com/legal/cbsi/privacy-policy"
let kCAPrivacyPolicyUrl = "https://ca.privacy.cbs"
let kCADoNotSellUrl = "https://ca.privacy.cbs/donotsell"

// Teams tab URLs
/*
let kTeamHomeHostProduction = "https://www.maxpreps.com/team/index?schoolid=%@&ssid=%@"
let kRosterHostProduction = "https://www.maxpreps.com/team/roster?schoolid=%@&ssid=%@"
let kScheduleHostProduction = "https://www.maxpreps.com/team/schedule?schoolid=%@&ssid=%@"
//let kScheduleHostProduction = "https://branch-e.fe.maxpreps.com/team/schedule?schoolid=%@&ssid=%@"
let kRankingsHostProduction = "https://www.maxpreps.com/team/rankings?schoolid=%@&ssid=%@"
let kStatsHostProduction = "https://www.maxpreps.com/m/team/stats.aspx?schoolid=%@&ssid=%@" //Changed from secure
let kStandingsHostProduction = "https://www.maxpreps.com/team/standings?schoolid=%@&ssid=%@"
let kPhotosHostProduction = "https://www.maxpreps.com/team/photography?schoolid=%@&ssid=%@"
let kVideosHostProduction = "https://www.maxpreps.com/m/team/videos.aspx?schoolid=%@&ssid=%@" //Changed from secure
let kArticlesHostProduction = "https://www.maxpreps.com/m/team/articles.aspx?schoolid=%@&ssid=%@" //Changed from secure
let kSportsWearHostProduction = "https://www.maxpreps.com/m/team/store.aspx?schoolid=%@&ssid=%@"
let kCareerProfileHostProduction = "https://www.maxpreps.com/m/career/default.aspx?careerid=%@"
*/

// Teams tab URLs
let kTeamHomeHostGeneric = "https://%@.maxpreps.com/team/index?schoolid=%@&ssid=%@"
let kRosterHostGeneric = "https://%@.maxpreps.com/team/roster?schoolid=%@&ssid=%@"
let kScheduleHostGeneric = "https://%@.maxpreps.com/team/schedule?schoolid=%@&ssid=%@"
let kRankingsHostGeneric = "https://%@.maxpreps.com/team/rankings?schoolid=%@&ssid=%@"
let kStatsHostGeneric = "https://%@.maxpreps.com/m/team/stats.aspx?schoolid=%@&ssid=%@" //
let kStandingsHostGeneric = "https://%@.maxpreps.com/team/standings?schoolid=%@&ssid=%@"
let kPhotosHostGeneric = "https://%@.maxpreps.com/team/photography?schoolid=%@&ssid=%@"
let kVideosHostGeneric = "https://%@.maxpreps.com/m/team/videos.aspx?schoolid=%@&ssid=%@" //
let kArticlesHostGeneric = "https://%@.maxpreps.com/m/team/articles.aspx?schoolid=%@&ssid=%@" //
let kSportsWearHostGeneric = "https://%@.maxpreps.com/m/team/store.aspx?schoolid=%@&ssid=%@"
let kCareerProfileHostGeneric = "https://%@.maxpreps.com/m/career/default.aspx?careerid=%@"


// Old User Image Feed URLs
let kGetUserImageUrlProduction = "https://secure.maxpreps.com/utility/member/handlers/get_qwixcore_profile_image.ashx"
let kGetUserImageUrlStaging = "https://secure-staging.maxpreps.com/utility/member/handlers/get_qwixcore_profile_image.ashx"
let kGetUserImageUrlDev = "https://secure-dev.maxpreps.com/utility/member/handlers/get_qwixcore_profile_image.ashx"

let kSaveUserImageUrlProduction = "https://secure.maxpreps.com/utility/member/handlers/save_qwixcore_profile_image.ashx"
let kSaveUserImageUrlStaging = "https://secure-staging.maxpreps.com/utility/member/handlers/save_qwixcore_profile_image.ashx"
let kSaveUserImageUrlDev = "https://secure-dev.maxpreps.com/utility/member/handlers/save_qwixcore_profile_image.ashx"

let kDeleteUserImageUrlProduction = "https://secure.maxpreps.com/utility/member/handlers/delete_qwixcore_profile_image.ashx"
let kDeleteUserImageUrlStaging = "https://secure-staging.maxpreps.com/utility/member/handlers/delete_qwixcore_profile_image.ashx"
let kDeleteUserImageUrlDev = "https://secure-dev.maxpreps.com/utility/member/handlers/delete_qwixcore_profile_image.ashx"


