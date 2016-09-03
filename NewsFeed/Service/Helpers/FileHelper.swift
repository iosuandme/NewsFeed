//
//  FileHelper.swift
//  NewsFeed
//
//  Created by WorkHarder on 8/15/16.
//  Copyright © 2016 Kidney. All rights reserved.
//

import CocoaSecurity
import FCFileManager

class FileHelper: NSObject {
    static func generateJPEGFile(withImage image: UIImage) -> BmobFile {
        let bigData = compressImageData(image, compressRatio: 0.8, maxCompressRatio: 0.5)
        
        let fileName = CocoaSecurity.md5WithData(bigData).hex + ".jpg"
        let filePath = FCFileManager.pathForTemporaryDirectoryWithPath(fileName)
        
        var file: BmobFile!
        if FCFileManager.existsItemAtPath(filePath) || FCFileManager.writeFileAtPath(filePath, content: bigData) {
            file = BmobFile(filePath: filePath)
            file.url = filePath
        } else {
            assertionFailure("save error")
        }
        
        return file
    }
    
    static func generateJPEGFilesInlcudeThumbnail(withImage image: UIImage) -> [[String : AnyObject]] {
        let bigData = compressImageData(image, compressRatio: 0.8, maxCompressRatio: 0.5)
        let thuData = compressImageData(image, compressRatio: 0.8, maxCompressRatio: 0.5, maxUploadResolution: 300*300, maxUploadSize: 50*1024)
        
        let hdFile = ["filename" : CocoaSecurity.md5WithData(bigData).hex + ".jpg",
                      "data" : bigData]
        let thumbnail = ["filename" : CocoaSecurity.md5WithData(thuData).hex + ".jpg",
                         "data" : thuData]
        
        return [thumbnail, hdFile]
    }
    
    private static func compressImageData(image: UIImage, compressRatio ratio:CGFloat) -> NSData {
        return compressImageData(image, compressRatio: ratio, maxCompressRatio: 0.1)
    }
    
    private static func compressImageData(image: UIImage, compressRatio ratio:CGFloat, maxCompressRatio maxRatio:CGFloat, maxUploadResolution: CGFloat = 375 * 665.0 * 3 * 3, maxUploadSize: CGFloat = 1000*1024) -> NSData {
        
        var factor: CGFloat;
        let currentResolution = image.size.height * image.size.width;
        
        var scaledImage = image
        if (currentResolution > maxUploadResolution) {
            factor = sqrt(currentResolution / maxUploadResolution) * 2;
            scaledImage = self.scaleDown(image, withSize: CGSizeMake(image.size.width / factor, image.size.height / factor))
        }
        
        //Compression settings
        var compression = ratio;
        let maxCompression = maxRatio;
        
        //We loop into the image data to compress accordingly to the compression ratio
        var imageData = UIImageJPEGRepresentation(scaledImage, compression);
        while (CGFloat(imageData!.length) > maxUploadSize && compression > maxCompression) {
            compression -= 0.10;
            imageData = UIImageJPEGRepresentation(image, compression);
        }
        
        return imageData!
    }
    
    private static func scaleDown(image: UIImage, withSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    // MARK: path
    
    static func getImagePath(name: String, ofType type: String = ".png") -> NSURL {
        
        let postfix = "@" + String(Int(UIScreen.mainScreen().scale)) + "x"
        let path = NSBundle.mainBundle().pathForResource(name + postfix, ofType: type)
        
        assert(path != nil, "image \(postfix)\(type) is not found")
        
        return NSURL(fileURLWithPath: path!)
    }
}
