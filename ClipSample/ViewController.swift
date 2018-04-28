//
//  ViewController.swift
//  ClipSample
//
//  Created by Kuze Masanori on 2015/12/05.
//  Copyright © 2015年 Kuze Masanori. All rights reserved.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ViewController: UIViewController {

    //切り取り線を表示する
    var clipLayer : CAShapeLayer!
 
    //切り取り線
    var path : CGMutablePath!
    //実画像への切り取り線
    var convertPath : CGMutablePath!
    
    //切り取った画像の左上と右下の座標
    var minX : CGFloat!
    var maxX : CGFloat!
    var minY : CGFloat!
    var maxY : CGFloat!
    
    //画像を表示するView
    var imageView : UIImageView!
    //切り取った画像を表示するView
    var clipImageView : UIImageView!
    
    //切り取った画像が存在するか
    var isClipView : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image : UIImage = UIImage(named: "2015-12-11.jpeg")!
        
        imageView = UIImageView(frame: self.view.frame)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = image
        self.view.addSubview(imageView)
    
        
        clipLayer = CAShapeLayer()
        clipLayer.frame = self.view.frame
        clipLayer.backgroundColor = UIColor.clear.cgColor
        clipLayer.name = "clipLayer"
        clipLayer.strokeColor = UIColor.blue.cgColor
        clipLayer.fillColor = UIColor.clear.cgColor
        clipLayer.lineWidth = 3.0
        clipLayer.lineDashPattern = [2,3]
        
        self.view.layer.addSublayer(clipLayer)
        
        isClipView = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            
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
                
                path = CGMutablePath()
                convertPath = CGMutablePath()
                
                path.move(to: CGPoint(x: location.x, y: location.y))
                
                let convertLocation = convertPointFromView(location)
                convertPath.move(to: CGPoint(x: convertLocation.x, y: convertLocation.y))

                minX = location.x
                maxX = location.x
                minY = location.y
                maxY = location.y
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            
            if(isClipView){
                
                clipImageView.frame.origin.x = location.x
                clipImageView.frame.origin.y = location.y
                
            } else {
                
                path.addLine(to: CGPoint(x: location.x, y: location.y))
                
                let convertLocation = convertPointFromView(location)
                convertPath.addLine(to: CGPoint(x: convertLocation.x, y: convertLocation.y))
                
                //NSLog("%f, %f", convertLocation.x.native, convertLocation.y.native)
                
                clipLayer.path = path
                
                if(location.x < minX){ minX = location.x }
                if(location.x > maxX){ maxX = location.x }
                if(location.y < minY){ minY = location.y }
                if(location.y > maxY){ maxY = location.y }
                
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
            
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            
            if(isClipView){
                
                clipImageView.frame.origin.x = location.x
                clipImageView.frame.origin.y = location.y
                
                clipImageView.layer.borderWidth = 0
                
                isClipView = false
                
            } else {
                
                path.move(to: CGPoint(x: location.x, y: location.y))
                
                let convertLocation = convertPointFromView(location)
                convertPath.addLine(to: CGPoint(x: convertLocation.x, y: convertLocation.y))
                
                if(location.x < minX){ minX = location.x }
                if(location.x > maxX){ maxX = location.x }
                if(location.y < minY){ minY = location.y }
                if(location.y > maxY){ maxY = location.y }
                
                clipLayer.path = path
                
                let maskImage = createMaskImage()
                let m : CGImage = maskImage.cgImage!
                let mask = CGImage(maskWidth: m.width,
                    height: m.height,
                    bitsPerComponent: m.bitsPerComponent,
                    bitsPerPixel: m.bitsPerPixel,
                    bytesPerRow: m.bytesPerRow,
                    provider: m.dataProvider!,
                    decode: nil,
                    shouldInterpolate: false)
                
                //CGImageにしたら向きが変わることがあるのでimageを作り直す
                let motoImage : UIImage = reDrawImage(imageView.image!)
                let masked : CGImage = motoImage.cgImage!.masking(mask!)!
                let maskedImage : UIImage = UIImage(cgImage: masked, scale: 1.0, orientation: UIImageOrientation.up)
                
                //切り取った画像を囲める画像を作成
                let s = UIScreen.main.scale
                let scale : CGRect = CGRect(x: (minX-5)*s, y: (minY-38)*s, width: (maxX-minX+10)*s, height: (maxY-minY+5)*s)
                let convertScale = convertRectFromView(scale)
                
                let clipedImageRef : CGImage = maskedImage.cgImage!.cropping(to: convertScale)!
                let clipedImage : UIImage = UIImage(cgImage: clipedImageRef)
                
                
                //切り取った画像を画面上に追加
                //clipImageView = UIImageView(frame: self.view.frame)
                let clipScale = CGRect(x: minX-5, y: (minY), width: (maxX-minX+10), height: (maxY-minY+5))
                clipImageView = UIImageView(frame:clipScale)
                clipImageView.isUserInteractionEnabled = true
                clipImageView.contentMode = UIViewContentMode.scaleAspectFit
                clipImageView.clipsToBounds = true
                clipImageView.image = clipedImage
                clipImageView.layer.borderWidth = 2.0
                clipImageView.layer.borderColor = UIColor.black.cgColor
                clipImageView.layer.cornerRadius = 10.0
                self.view.addSubview(clipImageView)
                
                
                isClipView = true
                
                clipLayer.path = nil
                
                //切り取られた箇所を灰色にする
                imageView.image = clipedMotoImage(imageView.image!)
                
            }
        }
    }
    

    
    //パスの形を元にマスク画像を作成
    func createMaskImage() -> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(imageView.image!.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: imageView.image!.size.width, height: imageView.image!.size.height))
        context?.addPath(convertPath)
        context?.setFillColor(UIColor.black.cgColor)
        context?.drawPath(using: CGPathDrawingMode.fill)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()

        return image!
    }
    
    //写真の向きがおかしくなるので、作り直す
    func reDrawImage(_ img: UIImage) -> UIImage{
        
        let motoImage = img
        
        UIGraphicsBeginImageContextWithOptions((motoImage.size), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        motoImage.draw(in: CGRect(x: 0, y: 0, width: (motoImage.size.width), height: (motoImage.size.height)))
        
        let reImage = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        
        return reImage!
    }
    

    //切り抜かれた箇所を灰色にする
    func clipedMotoImage(_ img: UIImage) -> UIImage{
        
        let motoImage = img
        
        UIGraphicsBeginImageContextWithOptions((motoImage.size), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        motoImage.draw(in: CGRect(x: 0, y: 0, width: (motoImage.size.width), height: (motoImage.size.height)))
        context?.addPath(convertPath)
        context?.setFillColor(UIColor.gray.cgColor)
        context?.drawPath(using: CGPathDrawingMode.fill)
        
        
        let reImage = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        
        return reImage!
    }
    
    //画面の座標を画像の座標に変換する
    func convertPointFromView(_ viewPoint : CGPoint) ->CGPoint{
        
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
    
    
    func convertRectFromView(_ viewRect : CGRect) ->CGRect{
        
        let viewTopLeft = viewRect.origin
        let viewBottomRight = CGPoint(x: viewRect.maxX, y: viewRect.maxY)
        
        let imageTopLeft = convertPointFromView(viewTopLeft)
        let imageBottomRight = convertPointFromView(viewBottomRight)
        
        var imageRect : CGRect = CGRect()
        imageRect.origin = imageTopLeft
        imageRect.size = CGSize(width: abs(imageBottomRight.x - imageTopLeft.x),
                            height: abs(imageBottomRight.y - imageTopLeft.y))
        return imageRect
        
    }
}

