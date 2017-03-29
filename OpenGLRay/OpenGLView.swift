//
//  OpenGLView.swift
//  OpenGLRay
//
//  Created by Hitendra Mac on 24/03/17.
//  Copyright © 2017 Hitendra Mac. All rights reserved.
//

import UIKit
import OpenGLES
import QuartzCore

struct OpenGLViewVertexConstants {
    static var initialOffset : Int {
        return 0
    }
    static var initialPositionOffset: Int{
        return Int( OpenGLViewVertexConstants.initialOffset * MemoryLayout<Float>.size )
    }
    static var initialColorOffset: Int{
        return Int( OpenGLViewVertexConstants.countPosition * MemoryLayout<Float>.size )
    }
    
    static var countPosition: Int {
        return 3
    }
    static var countColor: Int{
        return 4
    }
}

class OpenGLView: UIView {

    struct Vertex {
        var position: (GLfloat,GLfloat,GLfloat)
        var color: (GLfloat,GLfloat,GLfloat,GLfloat)
    }
    
    
    
    lazy var vertices : [Vertex] = {
        
        
        let vertex1 : Vertex = Vertex(position: (1,-1,1), color: (1,0,0,1))
        let vertex2 : Vertex = Vertex(position: (1,1,1), color: (0,1,0,1))
        let vertex3 : Vertex = Vertex(position: (-1,1,1), color: (0,0,1,1))
        let vertex4 : Vertex = Vertex(position: (-1,-1,1), color: (0,0,0,1))
        
        return [vertex1,vertex2,vertex3,vertex4]
    }()
    
    typealias Index = GLubyte
    lazy var indices : [Index] = {
        return [0,1,2,
                2,3,0]
    }()
    
    
    //
    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    var colorRenderBuffer : GLuint = 0;
    
    var positionSlot: GLuint = 1
    var colorSlot: GLuint = 2
    
    var vertexBuffer : GLuint = 0
    var indexBuffer: GLuint = 0;
    var framerBuffer : GLuint = 0
    
    //MARK:- INIT
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.setupLayer()
        self.setupContext()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.compileShaders()
        self.setupVBOs()
        self.render()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //layerClass
    override class var layerClass: AnyClass {
        get {
            return CAEAGLLayer.self
        }
    }
    
    //MARK:- Setup
    //setupLayer
    func setupLayer(){
        self.eaglLayer = self.layer as! CAEAGLLayer;
        self.eaglLayer.isOpaque = true;
    }
    
    //setupContext
    func setupContext(){
        let api : EAGLRenderingAPI = EAGLRenderingAPI.openGLES2;
        self.context = EAGLContext(api: api)
        
        EAGLContext.setCurrent(self.context);
    }
  
    //setupRenderBuffer
    func setupRenderBuffer(){
        glGenRenderbuffers(1, &self.colorRenderBuffer)
        
        //GL_RENDERBUFFER is a alias of self.colorRenderBuffer
        //Call glBindRenderbuffer to tell OpenGL “whenever I refer to GL_RENDERBUFFER, I really mean _colorRenderBuffer.”
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
        
        
        self.context.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.eaglLayer)
    }
    
    //setupFrameBuffer
    func setupFrameBuffer(){
        glGenFramebuffers(1, &framerBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framerBuffer)//GL_FRAMEBUFFER is a alias of framerBuffer
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
        
    }

    
    func compileShaders(){
        let (pSlot, cSlot) = ShaderHelper.compileShaders()
        self.positionSlot = pSlot;
        self.colorSlot = cSlot;
    }
    
    func setupVBOs(){
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(vertices.size), vertices, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(1, &indexBuffer);
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBuffer)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), GLsizeiptr(indices.size), indices, GLenum(GL_STATIC_DRAW))
    }

    //render
    func render(){
        glClearColor(0, 100.0/255.0, 50.0/255.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        
        glViewport(0, 0, GLint(frame.size.width), GLint(frame.size.height))
        
        glVertexAttribPointer( positionSlot, 3, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(vertices[0])), nil )
        glVertexAttribPointer( colorSlot, 4, GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(vertices[0])), UnsafePointer<Int>(bitPattern: MemoryLayout<GLfloat>.size * 3))
        
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.size)/sizeof(indices[0]), GLenum(GL_UNSIGNED_BYTE), nil)
        
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    
}
