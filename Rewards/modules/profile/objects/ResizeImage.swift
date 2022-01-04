//
//  ResizeImage.swift
//  Rewards
//
//  Created by Anthonio Ez on 07/06/2018.
//  Copyright © 2018 Nairalance. All rights reserved.
//

import UIKit

class ResizeImage: NSObject
{
    static let outputWidth = CGFloat(640);
    static let outputHeight = CGFloat(640);

    static func start(_ image: UIImage, response: ((String?, UIImage?, Data?)-> Void))
    {
        begin();
        
        if(image.size.width < outputWidth || image.size.height < outputHeight)
        {
            done();
            response("Profile pictures must be at least \(outputWidth) x \(outputHeight) pixels", nil, nil);
            return;
        }

        let outputImage = resizeImage(image: image, targetSize: CGSize(width: outputWidth, height: outputHeight));        
        if(outputImage == nil)
        {
            done();
            response("Unable to resize image", nil, nil);
            return;
        }
        
        let data = UIImagePNGRepresentation(outputImage!);
        if(data == nil)
        {
            done()
            response("Unable to convert image", nil, nil);
            return;
        }

        done();
        response(nil, outputImage, data)
    }
    
    static func begin()
    {
        DispatchQueue.main.async(execute: {
            UI.showProgress("Please wait...")
        })
    }
    
    static func done()
    {
        DispatchQueue.main.async(execute: {
            UI.hideProgress()
        })
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage?
    {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /*
    static func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIViewContentMode = .scaleAspectFit) -> UIImage
    {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
 */
}

