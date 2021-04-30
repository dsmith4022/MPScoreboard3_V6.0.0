//
//  Extensions.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/4/21.
//

import UIKit

// MARK: - Fonts

extension UIFont
{
    /*
        regular = 400
        semibold = 600
        bold = 700
        extrabold = 800
        heavy = 900
    */
    
    class func mpRegularFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-regular", size: size)!
    }
    class func mpSemiBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-semibold", size: size)!
    }
    class func mpBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-bold", size: size)!
    }
    class func mpExtraBoldFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-extrabold", size: size)!
    }
    class func mpHeavyFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-heavy", size: size)!
    }
    class func mpItalicFontWith( size:CGFloat ) -> UIFont{
        return  UIFont(name: "siro-italic", size: size)!
    }
}

// MARK: - Colors

extension UIColor
{
    class func mpOffWhiteNavColor() -> UIColor {
        //return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        return UIColor(named: "MPOffWhiteColor")!
    }
    
    class func mpHeaderBackgroundColor() -> UIColor {
        //return UIColor(red: 230.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1)
        return UIColor(named: "MPHeaderBackgroundColor")!
    } // EDEEF2
    
    class func mpGrayButtonBorderColor() -> UIColor {
        //return UIColor(red: 230.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1)
        return UIColor(named: "MPGrayButtonBorderColor")!
    } // D9DBDE
    
    class func mpSeparatorLineColor() -> UIColor {
        //return UIColor(red: 214.0/255.0, green: 216.0/255.0, blue: 219.0/255.0, alpha: 1)
        return UIColor(named: "MPSeparatorLineColor")!
    }

    class func mpRedColor() -> UIColor {
        //return UIColor(red: 225.0/255.0, green: 5.0/255.0, blue: 0.0/255.0, alpha: 1)
        return UIColor(named: "MPRedColor")!
    } // E10500
    
    class func mpGreenColor() -> UIColor {
        //return UIColor(red: 5.0/255.0, green: 163.0/255.0, blue: 66.0/255.0, alpha: 1)
        return UIColor(named: "MPGreenColor")!
    } // 05A342
    
    class func mpBlueColor() -> UIColor {
        //return UIColor(red: 0.0/255.0, green: 74.0/255.0, blue: 206.0/255.0, alpha: 1)
        return UIColor(named: "MPBlueColor")!
    } // 004ACE CBS blue
    
    class func mpLightGrayColor() -> UIColor {
        //return UIColor(red: 166.0/255.0, green: 169.0/255.0, blue: 173.0/255.0, alpha: 1)
        return UIColor(named: "MPLightGrayColor")!
    } // A6A9AD Lighest Text
    
    class func mpGrayColor() -> UIColor {
        //return UIColor(red: 117.0/255.0, green: 118.0/255.0, blue: 120.0/255.0, alpha: 1)
        return UIColor(named: "MPGrayColor")!
    } // 757678 Tertiary Text
 
    class func mpDarkGrayColor() -> UIColor {
        //return UIColor(red: 101.0/255.0, green: 102.0/255.0, blue: 103.0/255.0, alpha: 1)
        return UIColor(named: "MPDarkGrayColor")!
    } // 656667 Secondary Text
    
    class func mpBlackColor() -> UIColor {
        //return UIColor(red: 32.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1)
        return UIColor(named: "MPBlackColor")!
    } // 202121 Primary Text
    
    class func mpWhiteColor() -> UIColor {
        //return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        return UIColor(named: "MPWhiteColor")!
    } // ffffff White
    
    class func mpWhiteAlpha70Color() -> UIColor {
        return UIColor(named: "MPWhiteAlpha70Color")!
    } // ffffff White with 70% alpha
    
    class func mpWhiteAlpha80Color() -> UIColor {
        return UIColor(named: "MPWhiteAlpha80Color")!
    } // ffffff White with 80% alpha
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
            
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        {
            return UIColor(red: min(red + percentage/100, 1.0),
                               green: min(green + percentage/100, 1.0),
                               blue: min(blue + percentage/100, 1.0),
                               alpha: alpha)
        }
        else
        {
            return nil
        }
    }
    
    /*
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        // Bad data, String should be 6 or 8 characters
        if (hexString.count) < 6
        {
            self.init(red:0.5, green:0.5, blue:0.5, alpha:1.0)
            return
        }

        // strip 0X or 0x if it appears
        if (hexString.hasPrefix("0X") || hexString.hasPrefix("0x"))
        {
            hexString = ((hexString as NSString?)?.substring(from: 2))!
        }

        if hexString.count != 6
        {
            self.init(red:0.5, green:0.5, blue:0.5, alpha:1.0)
            return
        }

        // If the team color is white, dim it
        if hexString.lowercased() == "ffffff"
        {
            self.init(red:0.8, green:0.8, blue:0.8, alpha:1.0)
            return
        }

        // If the team color is black, lighten it
        if hexString.lowercased() == "000000"
        {
            self.init(red:0.2, green:0.2, blue:0.2, alpha:1.0)
            return
        }
        
        let scanner = Scanner(string: hexString)
        //if (hexString.hasPrefix("#"))
        //{
            //scanner.scanLocation = 1
        //}
        var color: UInt64 = 0
        //scanner.scanHexInt32(&color)
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
 */
}

// MARK: - Images

extension UIImage
{
    func getColorIfCornersMatch() -> UIColor?
    {
        let provider = self.cgImage!.dataProvider
        let providerData = provider!.data
        let data = CFDataGetBytePtr(providerData)
        
        // Look at the pixels inset at each corner by 2
        let numberOfComponents = 4
        var x = 2
        var y = 2
        
        let pixelData1 = ((Int(size.width) * y) + x) * numberOfComponents
        let r1 = data![pixelData1]
        let g1 = data![pixelData1 + 1]
        let b1 = data![pixelData1 + 2]
        let a1 = data![pixelData1 + 3]
        let r1Val = CGFloat(r1) / 255.0
        let g1Val = CGFloat(g1) / 255.0
        let b1Val = CGFloat(b1) / 255.0
        let a1Val = CGFloat(a1) / 255.0
        
        x = Int(self.size.width - 3)
        y = 2
        let pixelData2 = ((Int(size.width) * y) + x) * numberOfComponents
        let r2 = data![pixelData2]
        let g2 = data![pixelData2 + 1]
        let b2 = data![pixelData2 + 2]
        let a2 = data![pixelData2 + 3]
        let r2Val = CGFloat(r2) / 255.0
        let g2Val = CGFloat(g2) / 255.0
        let b2Val = CGFloat(b2) / 255.0
        
        x = 2
        y = Int(self.size.height - 3)
        let pixelData3 = ((Int(size.width) * y) + x) * numberOfComponents
        let r3 = data![pixelData3]
        let g3 = data![pixelData3 + 1]
        let b3 = data![pixelData3 + 2]
        let a3 = data![pixelData3 + 3]
        let r3Val = CGFloat(r3) / 255.0
        let g3Val = CGFloat(g3) / 255.0
        let b3Val = CGFloat(b3) / 255.0
        
        x = Int(self.size.width - 3)
        y = Int(self.size.height - 3)
        let pixelData4 = ((Int(size.width) * y) + x) * numberOfComponents
        let r4 = data![pixelData4]
        let g4 = data![pixelData4 + 1]
        let b4 = data![pixelData4 + 2]
        let a4 = data![pixelData4 + 3]
        let r4Val = CGFloat(r4) / 255.0
        let g4Val = CGFloat(g4) / 255.0
        let b4Val = CGFloat(b4) / 255.0
        
        // Calculate the corner luminance
        let luma1 = (r1Val * CGFloat(0.2126)) + (g1Val * CGFloat(0.7152)) + (b1Val * CGFloat(0.0722))
        let luma2 = (r2Val * CGFloat(0.2126)) + (g2Val * CGFloat(0.7152)) + (b2Val * CGFloat(0.0722))
        let luma3 = (r3Val * CGFloat(0.2126)) + (g3Val * CGFloat(0.7152)) + (b3Val * CGFloat(0.0722))
        let luma4 = (r4Val * CGFloat(0.2126)) + (g4Val * CGFloat(0.7152)) + (b4Val * CGFloat(0.0722))
        
        let meanLuma = (luma1 + luma2 + luma3 + luma4) / 4.0
        let lumaDiff = meanLuma - luma1
        let absoluteValOfLumaDiff = abs(lumaDiff)
        
        // Check if the meanLuma is similar to the upper left corner's luma and the corner alphas match
        //if ((r1 == r2) && (r2 == r3) && (r3 == r4) && (g1 == g2) && (g2 == g3) && (g3 == g4) && (b1 == b2) && (b2 == b3) && (b3 == b4) && (a1 == a2) && (a2 == a3) && (a3 == a4))
        if ((absoluteValOfLumaDiff < 0.01) && (a1 == a2) && (a2 == a3) && (a3 == a4))
        {
            return UIColor(red: r1Val, green: g1Val, blue: b1Val, alpha: a1Val)
        }
        else
        {
            return nil
        }
    }
    
    class func drawImageOnLargerCanvas(image useImage: UIImage, canvasSize: CGSize, canvasColor: UIColor ) -> UIImage
    {
        let rect = CGRect(origin: .zero, size: canvasSize)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)

        // fill the entire image
        canvasColor.setFill()
        UIRectFill(rect)

        // calculate a Rect the size of the image to draw, centered in the canvas rect
        let centeredImageRect = CGRect(x: (canvasSize.width - useImage.size.width) / 2,
                                       y: (canvasSize.height - useImage.size.height) / 2,
                                       width: useImage.size.width,
                                       height: useImage.size.height)

        // get a drawing context
        let context = UIGraphicsGetCurrentContext();

        // "cut" a transparent rectangle in the middle of the "canvas" image
        context?.clear(centeredImageRect)

        // draw the image into that rect
        useImage.draw(in: centeredImageRect)

        // get the new "image in the center of a canvas image"
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!

    }
    
    class func maskRoundedImage(image: UIImage, radius: CGFloat) -> UIImage
    {
        let imageView: UIImageView = UIImageView(image: image)
        let layer = imageView.layer
        layer.masksToBounds = true
        layer.cornerRadius = radius
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return roundedImage!
    }
}
    
// MARK: - Dictionary
    
extension Dictionary
{
    func merge(dict: Dictionary<Key,Value>) -> Dictionary<Key,Value>
    {
        var mutableCopy = self
        for (key, value) in dict
        {
            // If both dictionaries have a value for same key, the value of the other dictionary is used.
            mutableCopy[key] = value
        }
        return mutableCopy
    }
}

// MARK: - String

extension String {

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}

// MARK: - UIView

extension UIView
{
    class func fromNib<T: UIView>() -> T
    {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

