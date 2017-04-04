//
//  ShaderHelper.swift
//  OpenGLRay
//
//  Created by Hitendra Mac on 24/03/17.
//  Copyright © 2017 Hitendra Mac. All rights reserved.
//

import Foundation
import OpenGLES
import QuartzCore


func sizeof <T> (_ : T.Type) -> GLsizei
{
    return GLsizei(MemoryLayout<T>.size)
}

func sizeof <T> (_ : T) -> GLsizei
{
    return GLsizei(MemoryLayout<T>.size)
}

extension Array {
    var size: Int {
        return self.count * MemoryLayout.size(ofValue: self[0])
    }
}

class ShaderHelper {
    class func compileShader(with name: String, type: GLenum) -> GLuint {
        let shaderPath = Bundle.main.path(forResource: name, ofType: "glsl")
        let shaderString = try! String.init(contentsOfFile: shaderPath!, encoding: String.Encoding.utf8)
        
        let shaderHandle : GLuint = glCreateShader(type)
        
        var shaderStringUTF8 = (shaderString as NSString).utf8String
        var shaderLength: GLint = GLint(shaderString.characters.count);
        glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderLength)
        
        glCompileShader(shaderHandle);
        
        var compileSuccess : GLint = 0;
        
        glGetShaderiv(shaderHandle, GLenum(GL_COMPILE_STATUS), &compileSuccess)
        if compileSuccess == GL_FALSE {
            var message : [GLchar] = Array.init(repeating: 0, count: 256)
            var length: GLint = 0
            glGetShaderInfoLog(shaderHandle, sizeof(message) , &length, &message[0])
            print("glGetShaderInfoLog := \(NSString(utf8String: message))")
            exit(0)
        }
        return shaderHandle;
    }
    
    class func compileShaders() -> (GLuint, GLuint, GLuint, GLuint, GLuint, GLuint){
        let vertexShader: GLuint = self .compileShader(with: "SimpleVertex", type: GLenum(GL_VERTEX_SHADER));
        let fragmentShader: GLuint = self .compileShader(with: "SimpleFragment", type: GLenum(GL_FRAGMENT_SHADER));
        
        let programHandle: GLuint = glCreateProgram()
        glAttachShader(programHandle, vertexShader)
        glAttachShader(programHandle, fragmentShader)
        glLinkProgram(programHandle)
        
        var linkSuccess: GLint = 0
        glGetProgramiv(programHandle, GLenum(GL_LINK_STATUS), &linkSuccess)
        if linkSuccess == GL_FALSE {
            var message : [GLchar] = Array.init(repeating: 0, count: 256)
            var length: GLint = 0
            glGetProgramInfoLog(programHandle, sizeof(message), &length, &message[0])
            print("glGetProgramInfoLog := \(NSString(utf8String: message))")
            exit(0)
        }
        
        glUseProgram(programHandle)
        let positionSlot : GLuint = GLuint( glGetAttribLocation(programHandle, "Position") )
        let colorSlot : GLuint = GLuint( glGetAttribLocation(programHandle, "SourceColor") )
        let projectionUniform = GLuint( glGetUniformLocation(programHandle, "Projection") );
        let modelViewUniform = GLuint( glGetUniformLocation(programHandle, "Modelview") );
        let texCoordSlot = GLuint( glGetAttribLocation(programHandle, "TexCoordIn") )
        let textureUniform = GLuint( glGetUniformLocation(programHandle, "Texture") )
        
        glEnableVertexAttribArray(positionSlot)
        glEnableVertexAttribArray(colorSlot)
        glEnableVertexAttribArray(texCoordSlot)
        
        return (positionSlot, colorSlot, projectionUniform, modelViewUniform, texCoordSlot, textureUniform)
    }
}
    
