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
        return Int( OpenGLViewVertexConstants.initialOffset * MemoryLayout<GLfloat>.size )
    }
    static var initialColorOffset: Int{
        return Int( self.initialPositionOffset + (OpenGLViewVertexConstants.countPosition * MemoryLayout<GLfloat>.size) )
    }
    static var initialTexCoordOffset: Int{
        return Int( self.initialColorOffset + (OpenGLViewVertexConstants.countColor * MemoryLayout<GLfloat>.size) )
    }
    
    
    static var countPosition: Int {
        return 3
    }
    static var countColor: Int{
        return 4
    }
    static var countTexCoord: Int{
        return 2
    }
}


class OpenGLView: UIView {

    struct Vertex {
        var position: (GLfloat,GLfloat,GLfloat)
        var color: (GLfloat,GLfloat,GLfloat,GLfloat)
        var texCoord: (GLfloat, GLfloat)
    }
    
    
    
    lazy var vertices : [Vertex] = {
        
        let z1: GLfloat = 0.0
        let z2: GLfloat = -2.0;
        
        return[
            
            //front 0 1 2 3
//            Vertex(position: (1,-1,z1), color: (1,0,0,1), texCoord: (1,0)),
//            Vertex(position: (1,1,z1), color: (1,0,0,1), texCoord: (1,1)),
//            Vertex(position: (-1,1,z1), color: (0,1,0,1), texCoord: (0,1)),
//            Vertex(position: (-1,-1,z1), color: (0,1,0,1), texCoord: (0,0)),
            
            Vertex(position: (1,-1,z1), color: (0,0,0,1), texCoord: (1,0)),
            Vertex(position: (1,1,z1), color: (0,0,0,1), texCoord: (1,1)),
            Vertex(position: (-1,1,z1), color: (0,0,0,1), texCoord: (0,1)),
            Vertex(position: (-1,-1,z1), color: (0,0,0,1), texCoord: (0,0)),
            
            //back 4 5 6 7
            Vertex(position: (1,-1,z2), color: (1,0,0,1), texCoord: (1,0)),
            Vertex(position: (1,1,z2), color: (0,1,0,1), texCoord: (1,1)),
            Vertex(position: (-1,1,z2), color: (0,0,1,1), texCoord: (0,1)),
            Vertex(position: (-1,-1,z2), color: (0,0,0,1), texCoord: (0,0)),
            
            //left 8 9 10 11
//            Vertex(position: (-1,1,z1), color: (0,1,0,1), texCoord: (1,1)),
//            Vertex(position: (-1,-1,z1), color: (0,1,0,1), texCoord: (1,0)),
//            Vertex(position: (-1,-1,z2), color: (0,0,0,1), texCoord: (0,0)),
//            Vertex(position: (-1,1,z2), color: (0,0,1,1), texCoord: (0,1)),
            Vertex(position: (-1,1,z1), color: (1,1,0,1), texCoord: (1,1)),
            Vertex(position: (-1,-1,z1), color: (1,1,0,1), texCoord: (1,0)),
            Vertex(position: (-1,-1,z2), color: (1,1,0,1), texCoord: (0,0)),
            Vertex(position: (-1,1,z2), color: (1,1,0,1), texCoord: (0,1)),
            
            //right 12 13 14 15
            Vertex(position: (1,-1,z1), color: (1,0,0,1), texCoord: (0,0)),
            Vertex(position: (1,1,z1), color: (1,0,0,1), texCoord: (0,1)),
            Vertex(position: (1,1,z2), color: (0,1,0,1), texCoord: (1,1)),
            Vertex(position: (1,-1,z2), color: (1,0,0,1), texCoord: (1,0)),
            
            //top 16 17 18 19
            Vertex(position: (1,1,z1), color: (1,0,0,1), texCoord: (1,0)),
            Vertex(position: (-1,1,z1), color: (0,1,0,1), texCoord: (0,0)),
            Vertex(position: (-1,1,z2), color: (0,0,1,1), texCoord: (0,1)),
            Vertex(position: (1,1,z2), color: (0,1,0,1), texCoord: (1,1)),
            
            //bottom 20 21 22 23
            Vertex(position: (1,-1,z1), color: (1,0,0,1), texCoord: (1,1)),
            Vertex(position: (-1,-1,z1), color: (0,1,0,1), texCoord: (0,1)),
            Vertex(position: (-1,-1,z2), color: (0,0,0,1), texCoord: (0,0)),
            Vertex(position: (1,-1,z2), color: (1,0,0,1), texCoord: (1,0))
        ]
            
        
    }()
    
    typealias Index = GLubyte
    lazy var indices : [Index] = {
        return [
            // Front
            0, 1, 2,
            2, 3, 0,
            
            // Back
            4, 6, 5,
            4, 7, 6,
            
            // Left
            8,9,10,
            8,10,11,
            
            // Right
            12,13,14,
            12,14,15,
            
            // Top
            16,17,18,
            16,19,18,
            
            // Bottom
            20,21,22,
            20,22,23,
            ]
    }()
    
    
    //
    var eaglLayer: CAEAGLLayer!
    var context: EAGLContext!
    var colorRenderBuffer : GLuint = 0;
    
    var positionSlot: GLuint = 0
    var colorSlot: GLuint = 0
    
    var projectionUniform: GLuint = 0
    var modelViewUniform: GLuint = 0
    var currentRotation: GLfloat = 0
    
    var vertexBuffer : GLuint = 0
    var indexBuffer: GLuint = 0;
    var framerBuffer : GLuint = 0
    var depthRenderBuffer : GLuint = 0

    var floorTexture : GLuint = 0
    var fishTexture : GLuint = 0
    var texCoordSlot : GLuint = 0
    var textureUniform : GLuint = 0
    
    func setupDisplayLink() {
        let displayLink = CADisplayLink.init(target: self, selector: #selector(OpenGLView.render(displayLink:)))
        displayLink.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }

    
    //MARK:- INIT
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.setupLayer()
        self.setupContext()
        self.setupDepthBuffer()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.compileShaders()
        self.setupVBOs()
        self.setupDisplayLink()
        
        self.floorTexture = ImageHelper.loadTexture(named: "tile_floor.png");
        self.fishTexture = ImageHelper.loadTexture(named: "item_powerup_fish.png");
        
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
    
    //setup depth buffer
    func setupDepthBuffer(){
        glGenRenderbuffers(1, &self.depthRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.depthRenderBuffer)
        glRenderbufferStorage(GLenum(GL_RENDERBUFFER), GLenum(GL_DEPTH_COMPONENT16), GLsizei(self.bounds.size.width), GLsizei(self.bounds.size.height))
    }
    
    
    //setupFrameBuffer
    func setupFrameBuffer(){
        glGenFramebuffers(1, &self.framerBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.framerBuffer)//GL_FRAMEBUFFER is a alias of framerBuffer
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.colorRenderBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_DEPTH_ATTACHMENT), GLenum(GL_RENDERBUFFER), self.depthRenderBuffer);
    }
    
   
    func compileShaders(){
        let (positionSlot, colorSlot, projectionUniform, modelViewUniform, texCoordSlot, textureUniform) = ShaderHelper.compileShaders()
        self.positionSlot = positionSlot;
        self.colorSlot = colorSlot;
        self.projectionUniform = projectionUniform
        self.modelViewUniform = modelViewUniform;
        self.texCoordSlot = texCoordSlot;
        self.textureUniform = textureUniform;
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
    func render(displayLink : CADisplayLink){
        
        self.currentRotation += GLfloat(displayLink.duration * 90.10);
        
        //
        glClearColor(0, 100.0/255.0, 50.0/255.0, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT))
        glEnable(GLenum(GL_DEPTH_TEST))
        
        //
        let projection : CC3GLMatrix = CC3GLMatrix.matrix() as! CC3GLMatrix
        let height : Float = Float( 4 * (self.frame.size.height/self.frame.size.width) );
        projection.populate(fromFrustumLeft: -2, andRight: 2, andBottom: -height/2, andTop: height/2, andNear: 4, andFar: 10)
        glUniformMatrix4fv(GLint(self.projectionUniform), 1, GLboolean(GL_FALSE), projection.glMatrix)
        
        let modelView = CC3GLMatrix.matrix() as! CC3GLMatrix;
        modelView.populate(fromTranslation: CC3VectorMake(GLfloat(sin(CACurrentMediaTime())), 0, -7))
        modelView.rotate(by: CC3VectorMake(self.currentRotation+90, self.currentRotation, -self.currentRotation))
        glUniformMatrix4fv(GLint(self.modelViewUniform), 1, 0, modelView.glMatrix)
        

        glViewport(0, 0, GLint(frame.size.width), GLint(frame.size.height))
        
        glVertexAttribPointer( positionSlot, GLint(OpenGLViewVertexConstants.countPosition), GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(vertices[0])), nil )
        glVertexAttribPointer( colorSlot, GLint(OpenGLViewVertexConstants.countColor), GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(vertices[0])), UnsafePointer<Int>(bitPattern: MemoryLayout<GLfloat>.size * 3))
        
        glVertexAttribPointer(self.texCoordSlot, GLint(OpenGLViewVertexConstants.countTexCoord), GLenum(GL_FLOAT), GLboolean(UInt8(GL_FALSE)), GLsizei(sizeof(vertices[0])), UnsafePointer<Int>(bitPattern: OpenGLViewVertexConstants.initialTexCoordOffset))
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(GLenum(GL_TEXTURE_2D), self.floorTexture)
        glUniform1i(GLint(self.textureUniform), 0)
        
        
        //
        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(indices.size)/sizeof(indices[0]), GLenum(GL_UNSIGNED_BYTE), nil)
        
        self.context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    
}
