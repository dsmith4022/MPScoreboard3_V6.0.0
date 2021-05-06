//
//  TallFavoriteTeamTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/11/21.
//

import UIKit

protocol TallFavoriteTeamTableViewCellDelegate: AnyObject
{
    func collectionViewDidSelectItem(urlString: String)
    func topContestTouched(urlString: String)
    func bottomContestTouched(urlString: String)
}

class TallFavoriteTeamTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource
{
    weak var delegate: TallFavoriteTeamTableViewCellDelegate?
    
    var articleArray = [] as Array<Dictionary<String,String>>
    var topContestData = [:] as Dictionary<String,Any>
    var bottomContestData = [:] as Dictionary<String,Any>
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var teamMascotImageView: UIImageView!
    @IBOutlet weak var teamFirstLetterLabel: UILabel!
    
    @IBOutlet weak var recordContainerView: UIView!
    @IBOutlet weak var recordLabel: UILabel!
    
    @IBOutlet weak var contestContainerView: UIView!
    @IBOutlet weak var contestTopInnerContainerView: UIView!
    @IBOutlet weak var topContestMascotImageView: UIImageView!
    @IBOutlet weak var topContestFirstLetterLabel: UILabel!
    @IBOutlet weak var topContestHomeAwayLabel: UILabel!
    @IBOutlet weak var topContestOpponentLabel: UILabel!
    @IBOutlet weak var topContestDateLabel: UILabel!
    @IBOutlet weak var topContestResultOrTimeLabel: UILabel!
    
    @IBOutlet weak var contestBottomInnerContainerView: UIView!
    @IBOutlet weak var bottomContestMascotImageView: UIImageView!
    @IBOutlet weak var bottomContestFirstLetterLabel: UILabel!
    @IBOutlet weak var bottomContestHomeAwayLabel: UILabel!
    @IBOutlet weak var bottomContestOpponentLabel: UILabel!
    @IBOutlet weak var bottomContestDateLabel: UILabel!
    @IBOutlet weak var bottomContestResultOrTimeLabel: UILabel!
    
    @IBOutlet weak var articleContainerView: UIView!
    @IBOutlet weak var articleCollectionView: UICollectionView!
    
    
    // MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return articleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCollectionViewCell", for: indexPath) as! ArticleCollectionViewCell
        
        let article = articleArray[indexPath.row]
        let articleUrl = article["thumbnailUrl"]
        let articleTitle = article["title"]
        
        // Load the title
        cell.articleTitleLabel.text = articleTitle
        
        // Load the image
        let url = URL(string: articleUrl!)
        
        MiscHelper.getData(from: url!) { data, response, error in
            guard let data = data, error == nil else { return }
            
            //print("Download Finished")
            DispatchQueue.main.async()
            {
                let image = UIImage(data: data)
                
                if (image != nil)
                {
                    cell.articleImageView.image = image
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let article = articleArray[indexPath.row]
        let articleUrl = article["canonicalUrl"]
        self.delegate?.collectionViewDidSelectItem(urlString: articleUrl!)
    }
    
    // MARK: - Button Methods
    
    @IBAction func topContestButtonTouched()
    {
        let urlString = topContestData["canonicalUrl"] as! String
        self.delegate?.topContestTouched(urlString: urlString)
    }
    
    @IBAction func bottomContestButtonTouched()
    {
        let urlString = bottomContestData["canonicalUrl"] as! String
        self.delegate?.bottomContestTouched(urlString: urlString)
    }
    
    // MARK: - Load Team Record Data
    
    func loadTeamRecordData(_ data: Dictionary<String, Any>)
    {
        recordContainerView.isHidden = false
        
        // Check if there is any data since it could be an empty dictionary
        if (data["overallStanding"] == nil)
        {
            recordLabel.text = "No record found"
        }
        else
        {
            let overallStandingDict = data["overallStanding"] as! Dictionary<String,Any>
            let leagueStandingDict = data["leagueStanding"] as! Dictionary<String,Any>
            let winLossTies = overallStandingDict["overallWinLossTies"] as! String
            let leagueName = leagueStandingDict["leagueName"] as! String
            let conferenceStanding = leagueStandingDict["conferenceStandingPlacement"] as! String
            
            var text = ""
            if (leagueName.count > 0)
            {
                if (conferenceStanding.count > 0)
                {
                    text = String(format: "%@, %@ in %@", winLossTies, conferenceStanding, leagueName)
                }
                else
                {
                    text = String(format: "%@, %@", winLossTies, leagueName)
                }
            }
            else
            {
                text = String(format: "Record: %@", winLossTies)
            }
            
            recordLabel.text = text
        }
    }
    
    // MARK: - Load Contest Data
    
    func loadTopContestData(_ data: Dictionary<String,Any>)
    {
        contestContainerView.isHidden = false
        contestTopInnerContainerView.isHidden = false
        
        topContestData = data
        
        let opponentUrl = data["opponentMascotUrl"] as! String
        let opponentColorString = data["opponentColor1"] as! String
        let opponentColor = ColorHelper.color(fromHexString: opponentColorString)
        let opponentName = data["opponentNameAcronym"] as! String
        let initial = String(opponentName.prefix(1))
        let dateString = data["dateString"] as! String

        topContestFirstLetterLabel.text = initial
        topContestOpponentLabel.text = opponentName
        topContestDateLabel.text = dateString
        
        let homeAwayType = data["homeAwayType"] as! String
        if (homeAwayType == "Away")
        {
            topContestHomeAwayLabel.text = "@"
        }
        else
        {
            topContestHomeAwayLabel.text = "vs."
        }
        
        let hasResult = data["hasResult"] as! Bool
        if (hasResult == true)
        {
            let resultString = data["resultString"] as! String
            let attrString =  NSMutableAttributedString(string:resultString)
            let range = NSRange(location: 0, length: 1)
            let firstLetter = resultString.prefix(1)
            
            // Gray for ties
            var color = UIColor.mpGrayColor()
            if (firstLetter == "W")
            {
                color = UIColor.mpGreenColor()
            }
            else if (firstLetter == "L")
            {
                color = UIColor.mpRedColor()
            }
            attrString.addAttribute(NSAttributedString.Key.foregroundColor,value:color, range:range)
            topContestResultOrTimeLabel.attributedText = attrString
        }
        else
        {
            let timeString = data["timeString"] as! String
            topContestResultOrTimeLabel.text = timeString
        }
        
        let url = URL(string: opponentUrl)

        if (opponentUrl.count > 0)
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
                        self.topContestFirstLetterLabel.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.topContestMascotImageView)!)
                    }
                    else
                    {
                        // Set the first letter color
                        self.topContestFirstLetterLabel.textColor = opponentColor
                    }
                }
            }
        }
        else
        {
            // Set the first letter color
            self.topContestFirstLetterLabel.textColor = opponentColor
        }
    }
    
    func loadBottomContestData(_ data: Dictionary<String,Any>)
    {
        contestContainerView.isHidden = false
        contestBottomInnerContainerView.isHidden = false
        
        bottomContestData = data
        
        let opponentUrl = data["opponentMascotUrl"] as! String
        let opponentColorString = data["opponentColor1"] as! String
        let opponentColor = ColorHelper.color(fromHexString: opponentColorString)
        let opponentName = data["opponentNameAcronym"] as! String
        let initial = String(opponentName.prefix(1))
        let dateString = data["dateString"] as! String

        bottomContestFirstLetterLabel.text = initial
        bottomContestOpponentLabel.text = opponentName
        bottomContestDateLabel.text = dateString
        
        let homeAwayType = data["homeAwayType"] as! String
        if (homeAwayType == "Away")
        {
            bottomContestHomeAwayLabel.text = "@"
        }
        else
        {
            bottomContestHomeAwayLabel.text = "vs."
        }
        
        let hasResult = data["hasResult"] as! Bool
        if (hasResult == true)
        {
            let resultString = data["resultString"] as! String
            let attrString =  NSMutableAttributedString(string:resultString)
            let range = NSRange(location: 0, length: 1)
            let firstLetter = resultString.prefix(1)
            
            // Gray for ties
            var color = UIColor.mpGrayColor()
            if (firstLetter == "W")
            {
                color = UIColor.mpGreenColor()
            }
            else if (firstLetter == "L")
            {
                color = UIColor.mpRedColor()
            }
            attrString.addAttribute(NSAttributedString.Key.foregroundColor,value:color, range:range)
            bottomContestResultOrTimeLabel.attributedText = attrString
        }
        else
        {
            let timeString = data["timeString"] as! String
            bottomContestResultOrTimeLabel.text = timeString
        }
        
        let url = URL(string: opponentUrl)

        if (opponentUrl.count > 0)
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
                        self.bottomContestFirstLetterLabel.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.bottomContestMascotImageView)!)
                    }
                    else
                    {
                        // Set the first letter color
                        self.bottomContestFirstLetterLabel.textColor = opponentColor
                    }
                }
            }
        }
        else
        {
            // Set the first letter color
            self.bottomContestFirstLetterLabel.textColor = opponentColor
        }
    }
    
    // MARK: - Load Article Data
    
    func loadArticleData(_ data: Array<Dictionary<String,String>>)
    {
        articleContainerView.isHidden = false
        
        articleArray = data
        
        articleCollectionView.reloadData()
    }
    
    // MARK: - Set Display Mode
    
    func setDisplayMode(mode: FavoriteDetailCellMode)
    {
        switch mode
        {
        case FavoriteDetailCellMode.allCells:
            
            // Reset the frmaes to their default location
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height)
            
            articleContainerView.frame = CGRect(x: 0, y: topContainerView.frame.size.height + recordContainerView.frame.size.height + contestContainerView.frame.size.height, width: articleContainerView.frame.size.width, height: articleContainerView.frame.size.height)
            
        case FavoriteDetailCellMode.allCellsOneContest:
            
            // Reset the frmaes to their default location
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height - contestBottomInnerContainerView.frame.size.height)
            
            articleContainerView.frame = CGRect(x: 0, y: topContainerView.frame.size.height + recordContainerView.frame.size.height + contestContainerView.frame.size.height - contestBottomInnerContainerView.frame.size.height, width: articleContainerView.frame.size.width, height: articleContainerView.frame.size.height)
            
        case FavoriteDetailCellMode.noArticlesAllContests:
            
            articleContainerView.isHidden = true
            
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height)
            
        case FavoriteDetailCellMode.noArticlesOneContest:
            
            articleContainerView.isHidden = true
            
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height - contestBottomInnerContainerView.frame.size.height)

        case FavoriteDetailCellMode.noContests:
            
            contestContainerView.isHidden = true
            
            articleContainerView.frame = CGRect(x: 0, y: topContainerView.frame.size.height + recordContainerView.frame.size.height, width: articleContainerView.frame.size.width, height: articleContainerView.frame.size.height)
            
        case FavoriteDetailCellMode.noContestsOrArticles:
            
            contestContainerView.isHidden = true
            articleContainerView.isHidden = true
        }
    }
    
    // MARK: - Draw Shape Layers
    
    func addShapeLayers(color: UIColor)
    {
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 57, y: 0))
        rearPath.addLine(to: CGPoint(x: 10, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let lightColor = color.lighter(by: 50.0)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor!.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        self.topContainerView.layer.insertSublayer(rearShapeLayer, below: self.mascotContainerView.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 42, y: 0))
        frontPath.addLine(to: CGPoint(x: 10, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        self.topContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    // MARK: - Init Methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.contentView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        // Round the edges
        self.topContainerView.layer.cornerRadius = 8
        self.topContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.topContainerView.clipsToBounds = true
        
        self.mascotContainerView.layer.cornerRadius = self.mascotContainerView.frame.size.width / 2.0
        self.mascotContainerView.clipsToBounds = true
        
        // Register the Gallery Cell
        articleCollectionView.register(UINib.init(nibName: "ArticleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ArticleCollectionViewCell")
        
        // Hide the various inner containers. They will be unhidden in the load data functions
        recordContainerView.isHidden = true
        contestContainerView.isHidden = true
        contestTopInnerContainerView.isHidden = true
        contestBottomInnerContainerView.isHidden = true
        articleContainerView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
