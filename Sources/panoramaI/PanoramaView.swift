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
            width: 1,
            height: 1,
            mipmapped: false
        )
        textureDescriptor.usage = [.shaderRead, .shaderWrite]
        let placeholderTexture = device.makeTexture(descriptor: textureDescriptor)!
        
        let color: [UInt8] = [255, 255, 255, 255]
        placeholderTexture.replace(
            region: MTLRegionMake2D(0, 0, 1, 1),
            mipmapLevel: 0,
            withBytes: color,
            bytesPerRow: 4
        )
        
        return placeholderTexture
    }
    
    public init(name: String,ext : String, config: Config) {
        self.config = config
        let util  = Utils()
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
