//
//  PanoramaView.swift
//  
//
//  Created by Akerele Abraham on 02/02/2025.
//


import SwiftUI
import MetalKit
import UIKit


struct PanoramaView: UIViewRepresentable {
    private var texture: MTLTexture
    @ObservedObject var config: Config
    
    
    private static func createPlaceholderTexture() -> MTLTexture {
        let device = MTLCreateSystemDefaultDevice()!
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Unorm,
            width: 2,
            height: 2,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        
        let placeholderTexture = device.makeTexture(descriptor: textureDescriptor)!
        

        let pixels: [UInt8] = [
            200, 200, 200, 255,
            50,  50,  50,  255,
            50,  50,  50,  255,
            200, 200, 200, 255
        ]
        
        placeholderTexture.replace(
            region: MTLRegionMake2D(0, 0, 2, 2),
            mipmapLevel: 0,
            withBytes: pixels,
            bytesPerRow: 2 * 4
        )
        
        return placeholderTexture
    }
    
    public init(name: String,ext : String, config: Config) {
        self.config = config
        do {
            let device = MTLCreateSystemDefaultDevice()!
            let url = Bundle.main.url(forResource: name, withExtension: ext)!
            let options : [MTKTextureLoader.Option: Any] = [.SRGB: false, .generateMipmaps: true]
            let textureLoader = MTKTextureLoader(device: device)
            texture = try textureLoader.newTexture(URL: url, options: options)
            

        } catch {
            texture = PanoramaView.createPlaceholderTexture()
            print("Failed to load texture: \(error.localizedDescription)")
        }
        
    }
    
    public init(urlPath: String, config: Config) {
        self.config = config
        do {
            let util  = Utils()
            let url = URL(string: urlPath)!
            let localFilePath = try util.downloadFileAndReturnLocalURL(from: url)
            
            let device = MTLCreateSystemDefaultDevice()!
            let textureLoader = MTKTextureLoader(device: device)
            
            let options : [MTKTextureLoader.Option: Any] = [.SRGB: false, .generateMipmaps: true]
            texture = try textureLoader.newTexture(URL: localFilePath, options: options)
            
            
        } catch {
            texture = PanoramaView.createPlaceholderTexture()
            print("Failed to load texture: \(error.localizedDescription)")
        }
    }
    
    public init(file_name: String, folder_path: String,config: Config) {
        self.config = config
        do {
            let util  = Utils()
            if let url = util.getImageURL(name: file_name, folder_path: folder_path){
                let device = MTLCreateSystemDefaultDevice()!
                let textureLoader = MTKTextureLoader(device: device)
                let options : [MTKTextureLoader.Option: Any] = [.SRGB: false, .generateMipmaps: true]
                texture = try textureLoader.newTexture(URL: url.absoluteURL, options: options)
            }else{
                texture = PanoramaView.createPlaceholderTexture()
            }
            
        } catch {
            texture = PanoramaView.createPlaceholderTexture()
            print("Failed to load texture: \(error.localizedDescription)")
        }
    }
    
    public func makeCoordinator() -> Renderer {
        return Renderer(self,texture: texture)
    }
    
    public func updateUIView(_ uiView: MTKView, context: UIViewRepresentableContext<PanoramaView>) {}
    
    
    public func makeUIView(context: UIViewRepresentableContext<PanoramaView>) -> MTKView {
        
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 30
        mtkView.enableSetNeedsDisplay = true
        
        if let metalDevice = MTLCreateSystemDefaultDevice() {
            mtkView.device = metalDevice
        }
        
        mtkView.framebufferOnly = false
        mtkView.drawableSize = mtkView.frame.size
        mtkView.isPaused = false
        mtkView.depthStencilPixelFormat = .depth32Float
        
        return mtkView
    }
}
