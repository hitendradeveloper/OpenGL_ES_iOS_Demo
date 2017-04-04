//
//  ImageHelper.swift
//  OpenGLRay
//
//  Created by Hitendra Mac on 03/04/17.
//  Copyright © 2017 Hitendra Mac. All rights reserved.
//

import UIKit
import OpenGLES
import QuartzCore
import CoreGraphics
import CoreImage

class ImageHelper {
    class func loadTexture(named: String) -> GLuint {
        let imageRef = UIImage(named: named)?.cgImage
        
        guard let spriteImage = imageRef else {
            print("Failed to load image := \(named)")
            return 0
        }
        
        let (width,height) : (Int,Int) = (spriteImage.width,spriteImage.height)        
        let spriteData : UnsafeMutableRawPointer! = calloc(width*height*OpenGLViewVertexConstants.countColor, MemoryLayout<GLfloat>.size)
        
        let spriteContext = CGContext(data: spriteData,
                       width: width,
                       height: height,
                       bitsPerComponent: 8,
                       bytesPerRow: width * MemoryLayout<GLfloat>.size,
                       space: spriteImage.colorSpace!,
                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue);
        
        spriteContext?.draw(spriteImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var textureID : GLuint = 0
        glGenTextures(1, &textureID)
        glBindTexture(GLenum(GL_TEXTURE_2D), textureID)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_NEAREST)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(width), GLsizei(height), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), spriteData)
        
        free(spriteData)

        return textureID;
    }
}
