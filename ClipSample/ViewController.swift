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
    var maskLayer : CAShapeLayer!
    var backLayer : CAShapeLayer!
    var path : CGMutablePathRef!
    var minX : CGFloat!
    var maxX : CGFloat!
    var minY : CGFloat!
    var maxY : CGFloat!
    
    var imageView : UIImageView!
    
    var tapView : Bool = false
    var touchView2 : Bool = false
    
    var imageView2 : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image : UIImage = UIImage(named: "2015-12-11.jpeg")!
        
        imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = image
        //imageView = UIImageView(image: image)
        //imageView.contentMode = UIViewContentMode.ScaleAspectFit
        //imageView.image = image
        self.view.addSubview(imageView)
    
        
        clipLayer = CAShapeLayer()
        clipLayer.frame = self.view.frame
        clipLayer.backgroundColor = UIColor.clearColor().CGColor
        clipLayer.name = "clipLayer"
        clipLayer.strokeColor = UIColor.blueColor().CGColor
        clipLayer.fillColor = UIColor.clearColor().CGColor
        clipLayer.lineWidth = 5.0
        clipLayer.lineDashPattern = [2,3]
        
        self.view.layer.addSublayer(clipLayer)
        
        tapView = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if let touch = touches.first {
            let location = touch.locationInView(self.view)
            
            if(tapView){
                if((location.x >= imageView2.frame.origin.x || location.x < imageView2.frame.origin.x) ||
                (location.y >= imageView2.frame.origin.y || location.y < imageView2.frame.origin.y)){
                    touchView2 = true
                    tapView = false
                }
            } else {
            
            backLayer = nil

            backLayer = CAShapeLayer()
            backLayer.frame = self.view.frame
            backLayer.backgroundColor = UIColor.clearColor().CGColor
            self.view.layer.addSublayer(backLayer)
            
            minX = 0
            maxX = 0
            minY = 0
            maxY = 0
            
            path = CGPathCreateMutable()
            
            CGPathMoveToPoint(path, nil, location.x, location.y)
//            path.addLineToPoint(location)
            
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
            
            if(touchView2){
                
                imageView2.frame.origin.x = location.x
                imageView2.frame.origin.y = location.y
                
            } else {
                
                CGPathAddLineToPoint(path, nil, location.x, location.y)
                //            path.addLineToPoint(location)
                
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
            
            //path = CGPathCreateMutable()
            
            if(touchView2){
                
                imageView2.frame.origin.x = location.x
                imageView2.frame.origin.y = location.y
                
                touchView2 = false
            } else {
                
                CGPathMoveToPoint(path, nil, location.x, location.y)
                
                if(location.x < minX){ minX = location.x }
                if(location.x > maxX){ maxX = location.x }
                if(location.y < minY){ minY = location.y }
                if(location.y > maxY){ maxY = location.y }
                
                
                clipLayer.path = path
                
                
                let s = UIScreen.mainScreen().scale
                maskLayer = CAShapeLayer()
                let scale : CGRect = CGRectMake((minX-5)*s, (minY-5)*s, (maxX-(minX-7))*s, (maxY-(minY-7))*s)
                let clipScale = CGRectMake((minX-5), (minY-5), (maxX-(minX-7)), (maxY-(minY-7)))
                maskLayer.frame = clipScale
                
                
                var scale2 : CGAffineTransform = CGAffineTransformIdentity
                scale2  = CGAffineTransformMakeScale(1, 1)
                var scale3 : CGAffineTransform = CGAffineTransformTranslate(scale2, -minX, -minY)
                
                
                let copyPath = CGPathCreateCopyByTransformingPath(path, &scale3)
                
                maskLayer.path = copyPath
                maskLayer.fillColor = UIColor.blackColor().CGColor
                
                let mask3 = capturedImage3()
                let m : CGImageRef = mask3.CGImage!
                let mask = CGImageMaskCreate(CGImageGetWidth(m),
                    CGImageGetHeight(m),
                    CGImageGetBitsPerComponent(m),
                    CGImageGetBitsPerPixel(m),
                    CGImageGetBytesPerRow(m),
                    CGImageGetDataProvider(m),
                    nil,
                    false)
                
                let motoImage : UIImage = reDrawImage("2015-12-11.jpeg")
                let masked : CGImageRef = CGImageCreateWithMask(motoImage.CGImage, mask)!
                let maskedImage : UIImage = UIImage(CGImage: masked, scale: 0.5, orientation: UIImageOrientation.Up)
                
                let clipedImageRef : CGImageRef = CGImageCreateWithImageInRect(maskedImage.CGImage, scale)!
                let clipedImage : UIImage = UIImage(CGImage: clipedImageRef)
                
                //imageView2 = UIImageView(frame: imageView.frame)
                imageView2 = UIImageView(frame:clipScale)
                imageView2.userInteractionEnabled = true
                imageView2.contentMode = UIViewContentMode.ScaleAspectFill
                imageView2.clipsToBounds = true
                imageView2.image = clipedImage
                imageView2.layer.borderWidth = 4.0
                imageView2.layer.borderColor = UIColor.blackColor().CGColor
                imageView2.layer.cornerRadius = 10.0
                self.view.addSubview(imageView2)
                
                
                tapView = true

            }
        }
    }
    
    //作ったけど今回の要件に合わず！！（とりあえず残しておく)
    func capturedImage() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        self.view.layer.presentationLayer()?.renderInContext(context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func capturedImage2() -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        self.view.layer.presentationLayer()?.renderInContext(context!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    
    
    func capturedImage3() -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        //imageView.image?.drawInRect(CGRectMake(0, 0, imageView.frame.width, imageView.frame.height))
        
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, self.view.frame)
        CGContextAddPath(context, path)
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextDrawPath(context, CGPathDrawingMode.Fill)
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        
        return image
    }
    
    
    func reDrawImage(str: String) -> UIImage{
        
        let motoImage = UIImage(named: str)
        
        UIGraphicsBeginImageContextWithOptions((motoImage?.size)!, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        motoImage?.drawInRect(CGRectMake(0, 0, (motoImage?.size.width)!, (motoImage?.size.height)!))
        
        let reImage = UIGraphicsGetImageFromCurrentImageContext()
        CGContextRestoreGState(context)
        UIGraphicsEndImageContext()
        
        return reImage
    }
    
    func maskImage(image: UIImage, maskImage: UIImage) -> UIImage {
        // 2
        let maskRef: CGImageRef = maskImage.CGImage!
        let mask: CGImageRef = CGImageMaskCreate(
            CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef),
            nil,
            false)!;
        
        // 3
        let maskedImageRef: CGImageRef = CGImageCreateWithMask(image.CGImage, mask)!;
        let maskedImage: UIImage = UIImage(CGImage: maskedImageRef);
        
        // 4
        //    CGImageRelease(maskedImageRef);
        //    CGImageRelease(mask);
        
        return maskedImage;
    }
}

