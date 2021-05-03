//
//  TallFavoriteTeamTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/11/21.
//

import UIKit

class TallFavoriteTeamTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var teamMascotImageView: UIImageView!
    @IBOutlet weak var teamFirstLetterLabel: UILabel!
    
    func addShapeLayers(color: UIColor)
    {
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 57, y: 0))
        rearPath.addLine(to: CGPoint(x: 10, y: containerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: containerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let lightColor = color.lighter(by: 50.0)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor!.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        self.containerView.layer.insertSublayer(rearShapeLayer, below: self.mascotContainerView.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 42, y: 0))
        frontPath.addLine(to: CGPoint(x: 10, y: containerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: containerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        self.containerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.contentView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        // Round the edges
        self.containerView.layer.cornerRadius = 8
        self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.containerView.clipsToBounds = true
        
        self.mascotContainerView.layer.cornerRadius = self.mascotContainerView.frame.size.width / 2.0
        self.mascotContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
