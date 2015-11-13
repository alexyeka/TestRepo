//
//  MediaEditView.swift
//  Nenzo
//
//  Created by sloot on 6/6/15.
//
//

let COLOR_EXPAND_SPEED:NSTimeInterval = 0.25
let DRAW_WIDTH:CGFloat = 6.0
let TEXT_ZOOM_MAX_POINT:CGFloat = 100.0

import AssetsLibrary
import UIKit
import AVFoundation

class MediaEditView: UIView {

    @IBOutlet var myImageView: UIImageView!
    
    weak var cameraViewDelegate:CameraViewDelegate!
    
    weak var cameraView:CameraView!
    
    @IBOutlet var myScrollView: UIScrollView!
    
    @IBOutlet var myPreviewView: UIView!
    
    @IBOutlet var pencilButton: UIButton!
    
    @IBOutlet var textButton: UIButton!
    
    @IBOutlet var whiteColorPickerView: UIColorPickerView!
    
    @IBOutlet var blueColorPickerView: UIColorPickerView!
    
    @IBOutlet var greenColorPickerView: UIColorPickerView!
    
    @IBOutlet var yellowColorPickerView: UIColorPickerView!
    
    @IBOutlet var orangeColorPickerView: UIColorPickerView!
    
    @IBOutlet var redColorPickerView: UIColorPickerView!
    
    @IBOutlet var blackColorPickerView: UIColorPickerView!
    
    @IBOutlet var leftWhiteColorPickerView: UIColorPickerView!
    
    @IBOutlet var leftBlueColorPickerView: UIColorPickerView!
    
    @IBOutlet var leftGreenColorPickerView: UIColorPickerView!
    
    @IBOutlet var leftYellowColorPickerView: UIColorPickerView!
    
    @IBOutlet var leftOrangeColorPickerView: UIColorPickerView!
    
    @IBOutlet var leftRedColorPickerView: UIColorPickerView!
    
    @IBOutlet var leftBlackColorPickerView: UIColorPickerView!
    
    @IBOutlet var circleBackgroundView: UIImageView!
    
    @IBOutlet var videoView: UIView!
    
    var colorPickers:[UIColorPickerView] = []
    
    var leftColorPickers:[UIColorPickerView] = []
    
    var colorExpanded:Bool = false
    
    var colorExpanding:Bool = false
    
    var leftColorExpanded:Bool = false
    
    var leftColorExpanding:Bool = false
    
    var isVideo:Bool = false
    
    var videoURL:NSURL!
    
    var shouldAddNewText:Bool = false
    
    var myType:CameraViewType = CameraViewType.Multiple
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setup(image:UIImage, newFrame:CGRect){
        myImageView.image = image
        videoView.hidden = true
        myImageView.hidden = false
        isVideo = false
        generalSetup()
    }
    
    func setupVideo(url:NSURL, newFrame:CGRect){
        videoURL = url
        previewVideo(url)
        videoView.hidden = false
        myImageView.hidden = true
        isVideo = true
        generalSetup()
    }
    
    func generalSetup(){
        myScrollView.minimumZoomScale = 1
        myScrollView.zoomScale = 1
        myScrollView.maximumZoomScale = 10.0
        //registerPinchGesture()
        
        alpha = 1.0
        
        colorPickers.append(whiteColorPickerView)
        colorPickers.append(blueColorPickerView)
        colorPickers.append(greenColorPickerView)
        colorPickers.append(yellowColorPickerView)
        colorPickers.append(orangeColorPickerView)
        colorPickers.append(redColorPickerView)
        colorPickers.append(blackColorPickerView)
        
        leftColorPickers.append(leftWhiteColorPickerView)
        leftColorPickers.append(leftBlueColorPickerView)
        leftColorPickers.append(leftGreenColorPickerView)
        leftColorPickers.append(leftYellowColorPickerView)
        leftColorPickers.append(leftOrangeColorPickerView)
        leftColorPickers.append(leftRedColorPickerView)
        leftColorPickers.append(leftBlackColorPickerView)
        
        let startFrame = whiteColorPickerView.frame
        for colorPicker in colorPickers {
            colorPicker.setup(whiteColorPickerView.frame)
        }
        
        let leftStartFrame = leftWhiteColorPickerView.frame
        for colorPicker in leftColorPickers {
            colorPicker.setup(leftWhiteColorPickerView.frame)
        }
    }
    
    var avPlayerLayer:AVPlayerLayer = AVPlayerLayer()
    
    func previewVideo(url:NSURL){
        var avPlayer:AVPlayer = AVPlayer(URL: url)
        avPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        avPlayerLayer.player = avPlayer
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: avPlayer.currentItem)
        
        var screenRect:CGRect = UIScreen.mainScreen().bounds
        
        avPlayerLayer.frame = CGRectMake(0, 0, screenRect.width, screenRect.height)
        
        videoView.layer.addSublayer(avPlayerLayer)
        avPlayer.play()
    }
    
    func playerItemDidReachEnd(notification:NSNotification){
        if let p = notification.object as? AVPlayerItem {
            p.seekToTime(kCMTimeZero)
        }
    }
    
    func drawCropCircle() -> UIView{
        let imgW:CGFloat = 320.0
        let imgH:CGFloat = 568.0
        
        let relativeRadius:CGFloat = 146.0
        let relativeX:CGFloat = 160.0
        let relativeY:CGFloat = 232.0
        
        let trueRadius = relativeRadius/imgW * frame.width
        
        let trueX = relativeX/imgW * frame.width
        let trueY = relativeY/imgH * frame.height
        
        let originX = trueX - trueRadius
        let originY = trueY - trueRadius
        
        var circle:UIView = UIView()
        circle.frame = CGRectMake(originX, originY, trueRadius*2, trueRadius*2)
        circle.clipsToBounds = true
        circle.backgroundColor = UIColor.clearColor()
        circle.layer.cornerRadius = trueRadius
        return circle
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        if !cameraView.hasCamera {
            cameraView.exit()
        }
        removeFromSuperview()
    }
    
    var shouldClose:Bool = true
    
    @IBAction func donePressed(sender: AnyObject) {
        if shouldClose {
            shouldClose = false
            switch myType.hashValue {
            case CameraViewType.Multiple.hashValue :
                let img = captureWholeImage()
                if isVideo {
                    processVideo(videoURL, img: img)
                } else {
                    cameraView.exit()
                    self.removeFromSuperview()
                    cameraViewDelegate.didSelectImage(img)
                }
            case CameraViewType.Profile.hashValue :
                let img = captureImage()
                let wholeImg = captureWholeImage()
                cameraViewDelegate.didSelectCircularImage(img, wholeImg: wholeImg)
                cameraView.exit()
                self.removeFromSuperview()
            default:
                break
            }
        }
    }
    
    func processVideo(url:NSURL, img:UIImage){
        showLoading()
        let videoAsset:AVURLAsset = AVURLAsset(URL: url, options: nil)
        let mixComposition:AVMutableComposition = AVMutableComposition()
        let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID:CMPersistentTrackID())
        let compositionAudioTrack:AVMutableCompositionTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID:CMPersistentTrackID())
        if let clipAudioTrack:AVAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeAudio).last as? AVAssetTrack {
            compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: clipAudioTrack, atTime: kCMTimeZero, error: nil)
        }
        if let clipVideoTrack:AVAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).last as? AVAssetTrack {
            compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: clipVideoTrack, atTime: kCMTimeZero, error: nil)
            compositionVideoTrack.preferredTransform = clipVideoTrack.preferredTransform
            
            var aLayer:CALayer = CALayer()
            aLayer.contents = img.CGImage
            aLayer.frame = CGRectMake(0, 0, clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width)
            aLayer.opacity = 0.65
            
            var parentLayer:CALayer = CALayer()
            var videoLayer:CALayer = CALayer()
            parentLayer.frame = CGRectMake(0, 0, clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width)
            videoLayer.frame = CGRectMake(0, 0, clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width)
            
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(aLayer)
            
            var videoComp:AVMutableVideoComposition = AVMutableVideoComposition()
            videoComp.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.width)
            videoComp.frameDuration = CMTimeMake(1, 30)
            videoComp.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, inLayer: parentLayer)
            
            var instruction:AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
            
            if let videoTrack:AVAssetTrack = mixComposition.tracksWithMediaType(AVMediaTypeVideo).first as? AVAssetTrack {
                var layerInstruction:AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                layerInstruction.setTransform(clipVideoTrack.preferredTransform, atTime: kCMTimeZero)
                instruction.layerInstructions = [layerInstruction]
                videoComp.instructions = [instruction]
                
                var export = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
                export.videoComposition = videoComp
                
                let outputPath:String = "\(NSTemporaryDirectory())output.mov"
                let outputURL:NSURL = NSURL(fileURLWithPath: outputPath)!
                let fileManager:NSFileManager = NSFileManager.defaultManager()
                if fileManager.fileExistsAtPath(outputPath) {
                    if !fileManager.removeItemAtPath(outputPath, error: nil) {
                    }
                }
                
                export.outputFileType = AVFileTypeQuickTimeMovie
                export.outputURL = outputURL
                export.shouldOptimizeForNetworkUse = true
                export.exportAsynchronouslyWithCompletionHandler(){
                    var asset:AVURLAsset = AVURLAsset(URL: outputURL, options: nil)
                    var imageGenerator = AVAssetImageGenerator(asset: asset)
                    let img2 = UIImage(CGImage: imageGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil, error: nil))!
                    dispatch_async(dispatch_get_main_queue()){
                        removeLoading()
                        self.cameraView.exit()
                        self.removeFromSuperview()
                        self.cameraViewDelegate.didSelectVideo(outputURL, img: img2)
                    }
                }
                
            }
        }
        
    }
    
    var saving = false
    @IBAction func savePressed(sender: AnyObject) {
        if !saving {
            saving = true
            if isVideo {
                var library:ALAssetsLibrary = ALAssetsLibrary()
                library.writeVideoAtPathToSavedPhotosAlbum(videoURL, completionBlock: { (url, err) -> Void in
                    self.saving = false
                })
            } else {
                let imageToSave = CIImage(image:captureWholeImage())
                
                if let softwareContext = CIContext(options:[kCIContextUseSoftwareRenderer: true]) {
                    let cgimg = softwareContext.createCGImage(imageToSave, fromRect:imageToSave.extent())
                    
                    let library = ALAssetsLibrary()
                    library.writeImageToSavedPhotosAlbum(cgimg,
                        metadata:imageToSave.properties(),
                        completionBlock: { (url, err) -> Void in
                            self.saving = false
                    })
                } else {
                    showError("Saving not supported on this device")
                    saving = false
                }
            }
        }
    }
    
    func captureWholeImage() -> UIImage {
        var previewRect:CGRect = myPreviewView.bounds
        UIGraphicsBeginImageContext(previewRect.size)
        var previewContext:CGContextRef = UIGraphicsGetCurrentContext()
        myPreviewView.layer.renderInContext(previewContext)
        var imgCopy:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imgCopy
    }
    
    func captureImage() -> UIImage {
        var cropCircle = drawCropCircle()
    
        var copyImageView:UIImageView = UIImageView(image: captureWholeImage())
//        copyImageView.frame = frame
//        copyImageView.backgroundColor = UIColor.redColor()
//        addSubview(copyImageView)
        copyImageView.frame = CGRectMake(-cropCircle.frame.origin.x, -cropCircle.frame.origin.y, frame.width, frame.height)
        cropCircle.addSubview(copyImageView)
        
        var rect:CGRect = cropCircle.bounds
        UIGraphicsBeginImageContext(rect.size)
        var context:CGContextRef = UIGraphicsGetCurrentContext()
        cropCircle.layer.renderInContext(context)
        var img:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    var myDrawView:ACEDrawingView?
    var myTextView:UIView?
    var selectedTextField:NUITextField?
    var isDrawMode:Bool = true
    var colorBallAtPencil:Bool = true
}

extension MediaEditView:UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        if isVideo {
            return videoView
        } else {
            return myImageView
        }
    }
}

extension MediaEditView {

    @IBAction func selectColor(sender: UIButton) {
        if let colorPicker = sender.superview as? UIColorPickerView {
            if isDrawMode {
                pencilButton.tintColor = colorPicker.dotColor()
                if let drawView = myDrawView {
                    drawView.lineColor = colorPicker.dotColor()
                }
            } else {
                textButton.setTitleColor(colorPicker.dotColor(), forState: .Normal)
                if shouldAddNewText {
                    shouldAddNewText = false
                    addNewText()
                } else {
                    if let tf = selectedTextField {
                        tf.textColor = colorPicker.dotColor()
                    }
                }
            }
        }
    }
    
    func toggleColorBalls(){
        if !colorExpanding {
            colorExpanding = true
            if colorExpanded {
                colorExpanded = false
                UIView.animateWithDuration(COLOR_EXPAND_SPEED, animations: { () -> Void in
                    for colorPicker in self.colorPickers {
                        colorPicker.unexpand()
                    }
                    }, completion: { (done) -> Void in
                        self.colorExpanding = false
                })
                
            } else {
                colorExpanded = true
                UIView.animateWithDuration(COLOR_EXPAND_SPEED, animations: { () -> Void in
                    for colorPicker in self.colorPickers {
                        colorPicker.expand()
                    }
                    }, completion: { (done) -> Void in
                        self.colorExpanding = false
                })
            }
        }
    }
    
    func toggleLeftColorBalls(){
        if !leftColorExpanding {
            leftColorExpanding = true
            if leftColorExpanded {
                leftColorExpanded = false
                UIView.animateWithDuration(COLOR_EXPAND_SPEED, animations: { () -> Void in
                    for colorPicker in self.leftColorPickers {
                        colorPicker.unexpand()
                    }
                    }, completion: { (done) -> Void in
                        self.leftColorExpanding = false
                })
                
            } else {
                leftColorExpanded = true
                UIView.animateWithDuration(COLOR_EXPAND_SPEED, animations: { () -> Void in
                    for colorPicker in self.leftColorPickers {
                        colorPicker.expand()
                    }
                    }, completion: { (done) -> Void in
                        self.leftColorExpanding = false
                })
            }
        }
    }

    @IBAction func togglePencilButton(sender: UIButton) {
        if myDrawView == nil {
            myDrawView = ACEDrawingView()
            myDrawView!.frame = frame
            myDrawView!.lineColor = pencilButton.tintColor
            myDrawView!.lineWidth = DRAW_WIDTH
        }
        myPreviewView.addSubview(myDrawView!)
        transferSelectedTextField()
        if isDrawMode || !colorExpanded {
            toggleColorBalls()
        }
        if leftColorExpanded {
            toggleLeftColorBalls()
        }
        isDrawMode = true
    }
    
    @IBAction func addTextPressed(sender: UIButton) {
        isDrawMode = false
        if !leftColorExpanded {
            shouldAddNewText = true
            toggleLeftColorBalls()
        } else {
            shouldAddNewText = false
            toggleLeftColorBalls()
        }
    }
    
    func addNewText(){
        if myTextView == nil {
            myTextView = UIView()
            myTextView!.frame = frame
            var pinch:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: "didPinch:")
            myTextView!.addGestureRecognizer(pinch)
            var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "textViewTapped")
            myTextView!.addGestureRecognizer(tap)
            var pan:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didPan:")
            myTextView!.addGestureRecognizer(pan)
        }
        myPreviewView.addSubview(myTextView!)
        if colorExpanded {
            toggleColorBalls()
        }
        if leftColorExpanded {
            toggleLeftColorBalls()
        }
        var newText:NUITextField = NUITextField()
        newText.font = textButton.titleLabel!.font// UIFont(name: "CaviarDreams-Bold", size: newText.font.pointSize)
        let newTextWidth:CGFloat = 40.0
        let newTextHeight:CGFloat = 30.0
        selectedTextField = newText
        newText.textColor = textButton.titleLabel!.textColor
        newText.frame = CGRectMake((myTextView!.frame.width - newTextWidth)/2.0, (myTextView!.frame.height - newTextHeight)/2.0, newTextWidth, newTextHeight)
        newText.textAlignment = NSTextAlignment.Center
        newText.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        newText.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        newText.contentMode = UIViewContentMode.Center
        newText.setBaseWritingDirection(UITextWritingDirection.Natural, forRange: newText.textRangeFromPosition(newText.beginningOfDocument, toPosition: newText.endOfDocument))
        newText.delegate = self
        newText.returnKeyType = UIReturnKeyType.Done
        newText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        myTextView!.addSubview(newText)
        newText.becomeFirstResponder()
    }
    
    func textViewTapped() {
        finishTypeMode()
    }
    
    func finishTypeMode(){
        if let tf = selectedTextField {
            tf.resignFirstResponder()
            tf.finishedTyping = true
        }
    }
    
    func transferSelectedTextField(){
        if let tf = selectedTextField {
            tf.removeFromSuperview()
            tf.userInteractionEnabled = false
            myDrawView!.addSubview(tf)
            selectedTextField = nil
        }
    }
    
    func didPinch(recognizer : UIPinchGestureRecognizer) {
        if let tf = selectedTextField {
            let oldFont:UIFont = tf.font
            if recognizer.scale < 1.0 || oldFont.pointSize < TEXT_ZOOM_MAX_POINT {
                let newFont:UIFont = UIFont(name: oldFont.fontName, size: oldFont.pointSize * recognizer.scale)!
                tf.font = newFont
                tf.resize()
            }
        }
        recognizer.scale = 1
    }
    
    func didPan(recognizer : UIPanGestureRecognizer) {
        if let tf = selectedTextField {
            if recognizer.state == UIGestureRecognizerState.Ended {
                let newCenter:CGPoint = CGPointMake(tf.center.x + tf.transform.tx, tf.center.y + tf.transform.ty)
                tf.center = newCenter
                
                var theTransform:CGAffineTransform = tf.transform
                theTransform.tx = 0
                theTransform.ty = 0
                tf.transform = theTransform
            } else {
                let translation:CGPoint = recognizer.translationInView(myTextView!)
                var theTransform:CGAffineTransform = tf.transform
                theTransform.tx = translation.x
                theTransform.ty = translation.y
                tf.transform = theTransform
            }
        }
    }
}

let BUFFER:CGFloat = 50.0

extension UITextField {
    func resize(){
        let oldFrame:CGRect = frame
        sizeToFit()
        let newFrame:CGRect = frame
        let updatedFrame:CGRect = CGRectMake(newFrame.origin.x - (newFrame.width + BUFFER - oldFrame.width)/2, newFrame.origin.y - (newFrame.height + BUFFER - oldFrame.height)/2, newFrame.width + BUFFER, newFrame.height + BUFFER)
        self.frame = updatedFrame
    }
}

extension MediaEditView:UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        finishTypeMode()
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if let tf = selectedTextField where textField == tf {
            if tf.finishedTyping {
                toggleLeftColorBalls()
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        textField.resize()
    }
}

class NUITextField:UITextField {
    var finishedTyping:Bool = false
}