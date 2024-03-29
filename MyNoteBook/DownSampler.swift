//
//  DownSampler.swift
//  MyNoteBook
//
//  Created by Jorge Sanchez on 09/02/2021.
//

import UIKit

enum DownSampler {
    static func downsample(imageAt imageURL: URL,
                           to pointSize: CGSize? = CGSize(width: 40, height: 40),
                           scale: CGFloat? = 3) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions) else{
            return nil
        }
        var downsampleOptions: CFDictionary
        if let pointSize = pointSize,
           let scale = scale {
            let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
            downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                 kCGImageSourceShouldCacheImmediately: true,
                                 kCGImageSourceCreateThumbnailWithTransform: true,
                                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary
        }else {
            downsampleOptions = [kCGImageSourceCreateThumbnailFromImageAlways: kCFBooleanTrue,
                                 kCGImageSourceShouldCacheImmediately: kCFBooleanTrue,
                                 kCGImageSourceCreateThumbnailWithTransform: kCFBooleanTrue] as CFDictionary
        }
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
    
}

