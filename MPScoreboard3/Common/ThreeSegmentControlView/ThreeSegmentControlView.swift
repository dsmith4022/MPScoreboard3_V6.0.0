//
//  ThreeSegmentControlView.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/12/21.
//

import UIKit

protocol ThreeSegmentControlViewDelegate: AnyObject
{
    func segmentChanged()
}

class ThreeSegmentControlView: UIView
{
    var selectedSegment = 0
    weak var delegate: ThreeSegmentControlViewDelegate?
    
    var segmentWidth = 0.0
    var themeLight = false
    
    var labelOne : UILabel?
    var labelTwo : UILabel?
    var labelThree : UILabel?
    var buttonOne : UIButton?
    var buttonTwo : UIButton?
    var buttonThree : UIButton?
    var indicatorView : UIView?
    
    let kSegmentOnColor = UIColor.mpWhiteColor()
    let kSegmentOffColor = UIColor.mpWhiteAlpha70Color()
    let kSegmentOnColorLightTheme = UIColor.mpBlackColor()
    let kSegmentOffColorLightTheme = UIColor.mpLightGrayColor()

    // MARK: Init Methods
    
    required init(frame: CGRect, buttonOneTitle : String, buttonTwoTitle : String, buttonThreeTitle : String, lightTheme : Bool)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        self.selectedSegment = 0;
        themeLight = lightTheme;
        
        if (buttonThreeTitle.count > 0)
        {
            segmentWidth = Double(frame.size.width / 3.0)
        }
        else
        {
            segmentWidth = Double(frame.size.width / 2.0)
        }
        
        indicatorView = UIView(frame: CGRect(x: 16, y: frame.size.height - 4, width: CGFloat(segmentWidth - 32), height: 4))
        indicatorView!.clipsToBounds = true
        indicatorView!.layer.cornerRadius = 4
        indicatorView!.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        if (lightTheme)
        {
            indicatorView?.backgroundColor = UIColor.mpRedColor()
        }
        else
        {
            indicatorView?.backgroundColor = UIColor.mpWhiteColor()
        }
        self.addSubview(indicatorView!)
        
        labelOne = UILabel(frame: CGRect(x: 0, y: 11, width: segmentWidth, height: 16))
        labelOne?.textAlignment = .center
        labelOne?.text = buttonOneTitle;
        labelOne?.font = UIFont.mpBoldFontWith(size: 15)
        
        if (lightTheme)
        {
            labelOne?.textColor = kSegmentOnColorLightTheme
        }
        else
        {
            labelOne?.textColor = kSegmentOnColor;
        }
        self.addSubview(labelOne!)
        
        labelTwo = UILabel(frame: CGRect(x: segmentWidth, y: 11, width: segmentWidth, height: 16))
        labelTwo?.textAlignment = .center
        labelTwo?.text = buttonTwoTitle;
        labelTwo?.font = UIFont.mpRegularFontWith(size: 15)
        
        if (lightTheme)
        {
            labelTwo?.textColor = kSegmentOffColorLightTheme
        }
        else
        {
            labelTwo?.textColor = kSegmentOffColor;
        }
        self.addSubview(labelTwo!)
        
        if (buttonThreeTitle.count > 0)
        {
            labelThree = UILabel(frame: CGRect(x: 2 * segmentWidth, y: 11, width: segmentWidth, height: 16))
            labelThree?.textAlignment = .center
            labelThree?.text = buttonThreeTitle;
            labelThree?.font = UIFont.mpRegularFontWith(size: 15)
            
            if (lightTheme)
            {
                labelThree?.textColor = kSegmentOffColorLightTheme
            }
            else
            {
                labelThree?.textColor = kSegmentOffColor;
            }
            self.addSubview(labelThree!)
        }
        
        buttonOne = UIButton(type: .custom)
        buttonOne?.frame = CGRect(x: 0, y: 0, width: CGFloat(segmentWidth), height: frame.size.height - 4)
        buttonOne?.backgroundColor = .clear
        buttonOne?.addTarget(self, action: #selector(self.buttonOneTouched), for: .touchUpInside)
        self.addSubview(buttonOne!)
        
        buttonTwo = UIButton(type: .custom)
        buttonTwo?.frame = CGRect(x: CGFloat(segmentWidth), y: 0, width: CGFloat(segmentWidth), height: frame.size.height - 4)
        buttonTwo?.backgroundColor = .clear
        buttonTwo?.addTarget(self, action: #selector(self.buttonTwoTouched), for: .touchUpInside)
        self.addSubview(buttonTwo!)
        
        if (buttonThreeTitle.count > 0)
        {
            buttonThree = UIButton(type: .custom)
            buttonThree?.frame = CGRect(x: CGFloat(2 * segmentWidth), y: 0, width: CGFloat(segmentWidth), height: frame.size.height - 4)
            buttonThree?.backgroundColor = .clear
            buttonThree?.addTarget(self, action: #selector(self.buttonThreeTouched), for: .touchUpInside)
            self.addSubview(buttonThree!)
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Button Methods
    
    @objc private func buttonOneTouched()
    {
        if (self.selectedSegment == 0)
        {
            return;
        }
        
        self.selectedSegment = 0;
        
        labelOne?.font = UIFont.mpBoldFontWith(size: 15)
        labelTwo?.font = UIFont.mpRegularFontWith(size: 15)
        labelThree?.font = UIFont.mpRegularFontWith(size: 15)
        
        if (themeLight)
        {
            labelOne?.textColor = kSegmentOnColorLightTheme
            labelTwo?.textColor = kSegmentOffColorLightTheme
            labelThree?.textColor = kSegmentOffColorLightTheme
        }
        else
        {
            labelOne?.textColor = kSegmentOnColor
            labelTwo?.textColor = kSegmentOffColor
            labelThree?.textColor = kSegmentOffColor
        }
        
        self.animateIndicator(offset:0.0)
        
        self.delegate?.segmentChanged()
    }
    
    @objc private func buttonTwoTouched()
    {
        if (self.selectedSegment == 1)
        {
            return;
        }
        
        self.selectedSegment = 1;
        
        labelOne?.font = UIFont.mpRegularFontWith(size: 15)
        labelTwo?.font = UIFont.mpBoldFontWith(size: 15)
        labelThree?.font = UIFont.mpRegularFontWith(size: 15)
        
        if (themeLight)
        {
            labelOne?.textColor = kSegmentOffColorLightTheme
            labelTwo?.textColor = kSegmentOnColorLightTheme
            labelThree?.textColor = kSegmentOffColorLightTheme
        }
        else
        {
            labelOne?.textColor = kSegmentOffColor
            labelTwo?.textColor = kSegmentOnColor
            labelThree?.textColor = kSegmentOffColor
        }
        
        self.animateIndicator(offset:segmentWidth)
        
        self.delegate?.segmentChanged()
    }
    
    @objc private func buttonThreeTouched()
    {
        if (self.selectedSegment == 2)
        {
            return;
        }
        
        self.selectedSegment = 2;
        
        labelOne?.font = UIFont.mpRegularFontWith(size: 15)
        labelTwo?.font = UIFont.mpRegularFontWith(size: 15)
        labelThree?.font = UIFont.mpBoldFontWith(size: 15)
        
        if (themeLight)
        {
            labelOne?.textColor = kSegmentOffColorLightTheme
            labelTwo?.textColor = kSegmentOffColorLightTheme
            labelThree?.textColor = kSegmentOnColorLightTheme
        }
        else
        {
            labelOne?.textColor = kSegmentOffColor
            labelTwo?.textColor = kSegmentOffColor
            labelThree?.textColor = kSegmentOnColor
        }
        
        self.animateIndicator(offset:(2 * segmentWidth))
        
        self.delegate?.segmentChanged()
    }
    
    // MARK: - Animation Method
    
    private func animateIndicator(offset : Double)
    {
        UIView.animate(withDuration: 0.2)
        { [self] in
            self.indicatorView?.transform = CGAffineTransform.init(translationX: CGFloat(offset), y: 0)
        }
    }
    
    // MARK: - Set Segment Method
    
    func setSegment(index : Int)
    {
        switch index
        {
        case 0:
            self.selectedSegment = 0
            if (themeLight)
            {
                labelOne?.textColor = kSegmentOnColorLightTheme
                labelTwo?.textColor = kSegmentOffColorLightTheme
                labelThree?.textColor = kSegmentOffColorLightTheme
            }
            else
            {
                labelOne?.textColor = kSegmentOnColor;
                labelTwo?.textColor = kSegmentOffColor;
                labelThree?.textColor = kSegmentOffColor;
            }
            self.indicatorView?.transform = CGAffineTransform.init(translationX: 0, y: 0)
            
        case 1:
            self.selectedSegment = 1
            if (themeLight)
            {
                labelOne?.textColor = kSegmentOffColorLightTheme
                labelTwo?.textColor = kSegmentOnColorLightTheme
                labelThree?.textColor = kSegmentOffColorLightTheme
            }
            else
            {
                labelOne?.textColor = kSegmentOffColor;
                labelTwo?.textColor = kSegmentOnColor;
                labelThree?.textColor = kSegmentOffColor;
            }
            self.indicatorView?.transform = CGAffineTransform.init(translationX: CGFloat(segmentWidth), y: 0)
            
        case 2:
            self.selectedSegment = 2
            if (themeLight)
            {
                labelOne?.textColor = kSegmentOffColorLightTheme
                labelTwo?.textColor = kSegmentOffColorLightTheme
                labelThree?.textColor = kSegmentOnColorLightTheme
            }
            else
            {
                labelOne?.textColor = kSegmentOffColor;
                labelTwo?.textColor = kSegmentOffColor;
                labelThree?.textColor = kSegmentOnColor;
            }
            self.indicatorView?.transform = CGAffineTransform.init(translationX: CGFloat(2 * segmentWidth), y: 0)
            
        default:
            break
        }
    }
}
