//
//  Extension.swift
//  Nenzo
//
//  Created by sloot on 6/10/15.
//
//

import Foundation
import Accelerate
class UIDateTextField : UITextField {
    var date:NSDate?
    func addDatePicker() -> UIDatePicker{
        return addDatePicker(UIDatePickerMode.Date)
    }
    
    func addDatePicker(mode:UIDatePickerMode) -> UIDatePicker{
        var dp = UIDatePicker()
        dp.datePickerMode = mode
        inputView = dp
        return dp
    }
    
    func setTextFromDatePicker(datePicker:UIDatePicker?){
        if let dp = datePicker {
            let formatter:NSDateFormatter = NSDateFormatter()
            switch dp.datePickerMode {
            case UIDatePickerMode.Date:
                formatter.dateFormat = "MM/dd/yyyy"
            case UIDatePickerMode.DateAndTime:
                formatter.dateFormat = "EEE MMM d h:mm a"
            default:
                formatter.dateFormat = "MM/dd/yyyy"
            }
            text = formatter.stringFromDate(dp.date)
            let myTimeZone:NSInteger = NSTimeZone.systemTimeZone().secondsFromGMT
            let absTime:NSTimeInterval =  dp.date.timeIntervalSince1970 - NSTimeInterval(myTimeZone)
            date = dp.date
        }
    }
    
    func getTime() -> String {
        if let dt = date {
            let formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "hh:mm a"
            text = formatter.stringFromDate(dt)
            return text
        } else {
            return ""
        }
    }
    
    func getMonth() -> String {
        if let dt = date {
            let formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "MMM"
            text = formatter.stringFromDate(dt)
            return text
        } else {
            return ""
        }
    }
    
    func getDay() -> String {
        if let dt = date {
            let formatter:NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "dd"
            text = formatter.stringFromDate(dt)
            return text
        } else {
            return ""
        }
    }
}

extension UITextField {
    
    func addToolView(delegateView:UIView) -> PickerToolView {
        let toolView:PickerToolView = "PickerToolView".loadNib() as! PickerToolView
        toolView.delegate = delegateView as? PickerToolViewDelegate
        toolView.frame = CGRectMake(0, 0, delegateView.frame.width, 35.0)
        inputAccessoryView = toolView
        return toolView
    }

}

extension UITextView {
    func addToolView(delegateView:UIView) -> PickerToolView {
        let toolView:PickerToolView = "PickerToolView".loadNib() as! PickerToolView
        toolView.delegate = delegateView as? PickerToolViewDelegate
        toolView.frame = CGRectMake(0, 0, delegateView.frame.width, 35.0)
        inputAccessoryView = toolView
        return toolView
    }
    
    func setBody(newText:String){
        editable = true
        text = newText
        editable = false
    }
}

extension UIButton {
    override public var highlighted: Bool {
        get {
            return super.highlighted
        }
        set {
            if let button = self as? UIHighlightButton {
                if newValue {
                    backgroundColor = button.selectedColor
                }
                else {
                    backgroundColor = UIColor.whiteColor()
                }
                super.highlighted = newValue
            } else {
                if newValue {
                    alpha = 0.7
                }
                else {
                    alpha = 1.0
                }
                super.highlighted = newValue
            }
        }
    }
}

class NUIButton:UIButton {
    var chosen:Bool = false
}

class UIHighlightButton:UIButton {
    var selectedColor:UIColor = UIColor(red: 217.0/255.0, green: 217.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    
    func addBorder(){
        clipsToBounds = true
        var newLayer:CALayer = CALayer(layer: layer)
        newLayer.frame = CGRectMake(-0.5, -0.5, frame.width + 0.5, frame.height + 0.5)
        newLayer.borderWidth = 0.5
        newLayer.borderColor = UIColor(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1.0).CGColor
        newLayer.backgroundColor = UIColor.clearColor().CGColor
        layer.addSublayer(newLayer)
    }
}

extension UITextField {
    func stylePlaceHolder(str:String?){
        if let ph = str {
            let placeHolder = NSAttributedString(string: ph, attributes: [NSForegroundColorAttributeName:UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)])
            attributedPlaceholder = placeHolder
        } else {
            println("No placeholder")
        }
    }
    
    func stylePlaceHolder(){
        stylePlaceHolder(placeholder)
    }
    
    func stylePlaceHolder(str:String?, color:UIColor){
        if let ph = str {
            let placeHolder = NSAttributedString(string: ph, attributes: [NSForegroundColorAttributeName:color])
            attributedPlaceholder = placeHolder
        } else {
            println("No placeholder")
        }
    }
}

extension UIView {
    func cropCircular(){
        layer.cornerRadius = frame.width/2.0
        clipsToBounds = true
    }
}

var myNumSet:NSCharacterSet = NSCharacterSet(charactersInString: "0123456789").invertedSet

extension NSString {
    func extractPhoneNumber() -> NSString {
        var m:NSArray = componentsSeparatedByCharactersInSet(myNumSet)
        return m.componentsJoinedByString("")
    }
}

extension String {
    func loadNib() -> AnyObject? {
        let nib:UINib = UINib(nibName: self, bundle: nil)
        return nib.instantiateWithOwner(nil, options: nil).last
    }
}

extension NSDate {
    func getMonth() -> String {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.stringFromDate(self)
    }
    
    func getDay() -> String {
        let formatter:NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "dd"
        return formatter.stringFromDate(self)
    }
}

public extension UIImage {
    public func applyDarkEffect() -> UIImage? {
        return self
            //applyBlurWithRadius(10, tintColor: UIColor(white: 1.0, alpha: 0.0), saturationDeltaFactor: 1.0)
    }
    
    public func applyBlurWithRadius(blurRadius: CGFloat, tintColor: UIColor?, saturationDeltaFactor: CGFloat, maskImage: UIImage? = nil) -> UIImage? {
        // Check pre-conditions.
        if (size.width < 1 || size.height < 1) {
            println("*** error: invalid size: \(size.width) x \(size.height). Both dimensions must be >= 1: \(self)")
            return nil
        }
        if self.CGImage == nil {
            println("*** error: image must be backed by a CGImage: \(self)")
            return nil
        }
        if maskImage != nil && maskImage!.CGImage == nil {
            println("*** error: maskImage must be backed by a CGImage: \(maskImage)")
            return nil
        }
        
        let __FLT_EPSILON__ = CGFloat(FLT_EPSILON)
        let screenScale = UIScreen.mainScreen().scale
        let imageRect = CGRect(origin: CGPointZero, size: size)
        var effectImage = self
        
        let hasBlur = blurRadius > __FLT_EPSILON__
        let hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > __FLT_EPSILON__
        
        if hasBlur || hasSaturationChange {
            func createEffectBuffer(context: CGContext) -> vImage_Buffer {
                let data = CGBitmapContextGetData(context)
                let width = vImagePixelCount(CGBitmapContextGetWidth(context))
                let height = vImagePixelCount(CGBitmapContextGetHeight(context))
                let rowBytes = CGBitmapContextGetBytesPerRow(context)
                
                return vImage_Buffer(data: data, height: height, width: width, rowBytes: rowBytes)
            }
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectInContext = UIGraphicsGetCurrentContext()
            
            CGContextScaleCTM(effectInContext, 1.0, -1.0)
            CGContextTranslateCTM(effectInContext, 0, -size.height)
            CGContextDrawImage(effectInContext, imageRect, self.CGImage)
            
            var effectInBuffer = createEffectBuffer(effectInContext)
            
            
            UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
            let effectOutContext = UIGraphicsGetCurrentContext()
            
            var effectOutBuffer = createEffectBuffer(effectOutContext)
            
            
            if hasBlur {
                // A description of how to compute the box kernel width from the Gaussian
                // radius (aka standard deviation) appears in the SVG spec:
                // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
                //
                // For larger values of 's' (s >= 2.0), an approximation can be used: Three
                // successive box-blurs build a piece-wise quadratic convolution kernel, which
                // approximates the Gaussian kernel to within roughly 3%.
                //
                // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
                //
                // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
                //
                
                let inputRadius = blurRadius * screenScale
                var radius = UInt32(floor(inputRadius * 3.0 * CGFloat(sqrt(2 * M_PI)) / 4 + 0.5))
                if radius % 2 != 1 {
                    radius += 1 // force radius to be odd so that the three box-blur methodology works.
                }
                
                let imageEdgeExtendFlags = vImage_Flags(kvImageEdgeExtend)
                
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, radius, radius, nil, imageEdgeExtendFlags)
            }
            
            var effectImageBuffersAreSwapped = false
            
            if hasSaturationChange {
                let s: CGFloat = saturationDeltaFactor
                let floatingPointSaturationMatrix: [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1
                ]
                
                let divisor: CGFloat = 256
                let matrixSize = floatingPointSaturationMatrix.count
                var saturationMatrix = [Int16](count: matrixSize, repeatedValue: 0)
                
                for var i: Int = 0; i < matrixSize; ++i {
                    saturationMatrix[i] = Int16(round(floatingPointSaturationMatrix[i] * divisor))
                }
                
                if hasBlur {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                    effectImageBuffersAreSwapped = true
                } else {
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                }
            }
            
            if !effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            UIGraphicsEndImageContext()
            
            if effectImageBuffersAreSwapped {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
            }
            
            UIGraphicsEndImageContext()
        }
        
        // Set up output context.
        UIGraphicsBeginImageContextWithOptions(size, false, screenScale)
        let outputContext = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(outputContext, 1.0, -1.0)
        CGContextTranslateCTM(outputContext, 0, -size.height)
        
        // Draw base image.
        CGContextDrawImage(outputContext, imageRect, self.CGImage)
        
        // Draw effect image.
        if hasBlur {
            CGContextSaveGState(outputContext)
            if let image = maskImage {
                CGContextClipToMask(outputContext, imageRect, image.CGImage);
            }
            CGContextDrawImage(outputContext, imageRect, effectImage.CGImage)
            CGContextRestoreGState(outputContext)
        }
        
        // Add in color tint.
        if let color = tintColor {
            CGContextSaveGState(outputContext)
            CGContextSetFillColorWithColor(outputContext, color.CGColor)
            CGContextFillRect(outputContext, imageRect)
            CGContextRestoreGState(outputContext)
        }
        
        // Output image is ready.
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage
    }
}

extension NSDate {
    func daysAgo() -> String {
        let calender:NSCalendar = NSCalendar.currentCalendar()
        calender.timeZone = NSTimeZone.systemTimeZone()
        let now = NSDate()
        var fromDate:NSDate? = nil
        var toDate:NSDate? = nil
        calender.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, startDate: &fromDate, interval: nil, forDate: self)
        calender.rangeOfUnit(NSCalendarUnit.CalendarUnitDay, startDate: &toDate, interval: nil, forDate: NSDate())
        
        let difference:NSDateComponents = calender.components(NSCalendarUnit.CalendarUnitDay, fromDate: fromDate!, toDate: toDate!, options: NSCalendarOptions.allZeros)
        var returnString:String = "Sent "
        let diff = difference.day
        if diff == 0 {
            returnString += "Today"
        } else if diff == 1 {
            returnString += "Yesterday"
        } else {
            returnString += "\(diff) days ago"
        }
        return returnString
    }
}