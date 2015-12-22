//
//  ViewController.swift
//  ClipSample
//
//  Created by Kuze Masanori on 2015/12/05.
//  Copyright © 2015年 Kuze Masanori. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var clipLayer : CAShapeLayer!
 
    var path : CGMutablePathRef!
    var convertPath : CGMutablePathRef!
    
    var minX : CGFloat!
    var maxX : CGFloat!
    var minY : CGFloat!
    var maxY : CGFloat!
    
    var imageView : UIImageView!
    var clipImageView : UIImageView!
    
    var isClipView : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image : UIImage = UIImage(named: "2015-12-11.jpeg")!
        
        imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = image
        self.view.addSubview(imageView)
    
        
        clipLayer = CAShapeLayer()
        clipLayer.frame = self.view.frame
        clipLayer.backgroundColor = UIColor.clearColor().CGColor
        clipLayer.name = "clipLayer"
        clipLayer.strokeColor = UIColor.blueColor().CGColor
        clipLayer.fillColor = UIColor.clearColor().CGColor
        clipLayer.lineWidth = 3.0
        clipLayer.lineDashPattern = [2,3]
        
        self.view.layer.addSublayer(clipLayer)
        
        isClipView = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first {
            let location = touch.locationInView(self.view)
            
            if(isClipView){
                if((location.x >= clipImageView.frame.origin.x || location.x < clipImageView.frame.origin.x) ||
                    (location.y >= clipImageView.frame.origin.y || location.y < clipImageView.frame.origin.y)){
                        clipImageView.frame.origin.x = location.x
                        clipImageView.frame.origin.y = location.y
                }
            } else {
                
                minX = 0
                maxX = 0
                minY = 0
                maxY = 0
                
                path = CGPathCreateMutable()
                convertPath = CGPathCreateMutable()
                
                CGPathMoveToPoint(path, nil, location.x, location.y)
                
                let convertLocation = convertPointFromView(location)
                CGPathMoveToPoint(convertPath, nil, convertLocation.x, convertLocation.y)
                
                minX = location.x
                maxX = location.x
                minY = location.y
                maxY = location.y
            }
        }
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        
        if let touch = touches.first {
            let location = touch.locationInView(self.view)
            
            if(isClipView){
                
                clipImageView.frame.origin.x = location.x
                clipImageView.frame.origin.y = location.y
                
            } else {
                
                CGPathAddLineToPoint(path, nil, location.x, location.y)
                
                let convertLocation = convertPointFromView(location)
                CGPathAddLineToPoint(convertPath, nil, convertLocation.x, convertLocation.y)
                //NSLog("%f, %f", convertLocation.x.native, convertLocation.y.native)
                
                clipLayer.path = path
                
                if(location.x < minX){ minX = location.x }
                if(location.x > maxX){ maxX = location.x }
                if(location.y < minY){ minY = location.y }
                if(location.y > maxY){ maxY = location.y }
                
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
            
        if let touch = touches.first {
            let location = touch.locationInView(self.view)
            
            if(isClipView){
                
                clipImageView.frame.origin.x = location.x
                clipImageView.frame.origin.y = location.y
                
                clipImageView.layer.borderWidth = 0
                
                isClipView = false
                
            } else {
                
                CGPathMoveToPoint(path, nil, location.x, location.y)
                
                let convertLocation = convertPointFromView(location)
                CGPathAddLineToPoint(convertPath, nil, convertLocation.x, convertLocation.y)
                
                if(location.x < minX){ minX = location.x }
                if(location.x > maxX){ maxX = location.x }
                if(location.y < minY){ minY = location.y }
                if(location.y > maxY){ maxY = location.y }
                
                clipLayer.path = path
                
                let s = UIScreen.mainScreen().scale
                
                let scale : CGRect = CGRectMake((minX-5)*s, (minY-38)*s, (maxX-minX+10)*s, (maxY-minY+5)*s)
                let clipScale = CGRectMake(minX-5, (minY), (maxX-minX+10), (maxY-minY+5))
                
                let maskImage = createMaskImage()
                let m : CGImageRef = maskImage.CGImage!
                let mask = CGImageMaskCreate(CGImageGetWidth(m),
                    CGImageGetHeight(m),
                    CGImageGetBitsPerComponent(m),
                    CGImageGetBitsPerPixel(m),
                    CGImageGetBytesPerRow(m),
                    CGImageGetDataProvider(m),
                    nil,
                    false)
                
                //let motoImage : UIImage = reDrawImage("2015-12-11.jpeg")
                let motoImage : UIImage = reDrawImage(imageView.image!)
                let masked : CGImageRef = CGImageCreateWithMask(motoImage.CGImage, mask)!
                let maskedImage : UIImage = UIImage(CGImage: masked, scale: 1.0, orientation: UIImageOrientation.Up)
                
                let convertScale = convertRectFromView(scale)
                
                let clipedImageRef : CGImageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, convertScale)!
                let clipedImage : UIImage = UIImage(CGImage: clipedImageRef)
                
                
                //clipImageView = UIImageView(frame: self.view.frame)
                clipImageView = UIImageView(frame:clipScale)
                clipImageView.userInteractionEnabled = true
                clipImageView.contentMode = UIViewContentMode.ScaleAspectFit
                clipImageView.clipsToBounds = true
                clipImageView.image = clipedImage
                clipImageView.layer.borderWidth = 2.0
                clipImageView.layer.borderColor = UIColor.blackColor().CGColor
                clipImageView.layer.cornerRadius = 10.0
                self.view.addSubview(clipImageView)
                
                
                isClipView = true
                
                clipLayer.path = nil
                
                imageView.image = clipedMotoImage(imageView.image!)
                
            }
        }
    }
    
    //作ったけど今回の要件に合わず！！（とりあえず残しておく)
//    func capturedImage() -> UIImage{
//        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//        CGContextSaveGState(context)
//        
//        self.view.layer.presentationLayer()?.renderInContext(context!)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        CGContextRestoreGState(context)
//        UIGraphicsEndImageContext()
//        
//        return image
//    }
//    
//    func capturedImage2() -> UIImage{
//        
//        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
//        let context = UIGraphicsGetCurrentContext()
//        CGContextSaveGState(context)
//        
//        self.view.layer.presentationLayer()?.renderInContext(context!)
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        CGContextRestoreGState(context)
//        UIGraphicsEndImageContext()
//        
//        return image
//    }
    
    //パスの形を元にマスク画像を作成
    func createMaskImage() -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(imageView.image!.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, imageView.image!.size.width, imageView.image!.size.height))
        CGContextAddPath(context, convertPath)
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.Fill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()

        return image
    }
    
    //写真の向きがおかしくなるので、作り直す
    func reDrawImage(img: UIImage) -> UIImage{
        
        let motoImage = img
        
        UIGraphicsBeginImageContextWithOptions((motoImage.size), false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        motoImage.drawInRect(CGRectMake(0, 0, (motoImage.size.width), (motoImage.size.height)))
        
        let reImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        return reImage
    }
    

    //切り抜かれた箇所を灰色にする
    func clipedMotoImage(img: UIImage) -> UIImage{
        
        let motoImage = img
        
        UIGraphicsBeginImageContextWithOptions((motoImage.size), false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        motoImage.drawInRect(CGRectMake(0, 0, (motoImage.size.width), (motoImage.size.height)))
        CGContextAddPath(context, convertPath)
        CGContextSetFillColorWithColor(context, UIColor.grayColor().CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.Fill)
        
        
        let reImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        return reImage
    }
    
    //画面の座標を画像の座標に変換する
    func convertPointFromView(viewPoint : CGPoint) ->CGPoint{
        
        var imagePoint : CGPoint = viewPoint
        
        let imageSize = imageView.image?.size
        let viewSize = self.view.frame.size
        
        
        let ratioX : CGFloat = viewSize.width / imageSize!.width
        let ratioY : CGFloat = viewSize.height / imageSize!.height
        
        let scale : CGFloat = min(ratioX, ratioY)
        
        imagePoint.x -= (viewSize.width  - imageSize!.width  * scale) / 2.0
        imagePoint.y -= (viewSize.height - imageSize!.height * scale) / 2.0
        
        imagePoint.x /= scale;
        imagePoint.y /= scale;
    
        return imagePoint
    }
    
    
    func convertRectFromView(viewRect : CGRect) ->CGRect{
        
        let viewTopLeft = viewRect.origin
        let viewBottomRight = CGPointMake(CGRectGetMaxX(viewRect), CGRectGetMaxY(viewRect))
        
        let imageTopLeft = convertPointFromView(viewTopLeft)
        let imageBottomRight = convertPointFromView(viewBottomRight)
        
        var imageRect : CGRect = CGRect()
        imageRect.origin = imageTopLeft
        imageRect.size = CGSizeMake(abs(imageBottomRight.x - imageTopLeft.x),
                            abs(imageBottomRight.y - imageTopLeft.y))
        return imageRect
        
    }
}

