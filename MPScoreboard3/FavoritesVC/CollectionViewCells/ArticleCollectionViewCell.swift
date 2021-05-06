//
//  ArticleCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/4/21.
//

import UIKit

class ArticleCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        articleImageView.layer.cornerRadius = 8
        articleImageView.clipsToBounds = true
    }

}
