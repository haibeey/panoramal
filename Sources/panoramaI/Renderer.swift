//
//  Renderer.swift
//
//
//  Created by Akerele Abraham on 27/01/2025.
//

import Foundation
import MetalKit
import UIKit
import SwiftUI



public class Renderer: NSObject, MTKViewDelegate {
    
    let  PI : Float = 3.14159265358979323846264
    
    var inputs : Inputs
    
    let parent: PanoramaView
    let texture: MTLTexture
    
    let allocator: MTKMeshBufferAllocator
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    let pipelineState: MTLRenderPipelineState
    let vertexBuffer: MTLBuffer
    let fragmentBuffer: MTLBuffer
    let indexBuffer: MTLBuffer
    
    let sampler: MTLSamplerState
    
    let vertices: [Vertex] = [
        Vertex(position: [-1, -1, 1], texCoord: [0, 1]),  // Bottom-left
        Vertex(position: [ 1, -1, 1], texCoord: [1, 1]),  // Bottom-right
        Vertex(position: [ 1,  1, 1], texCoord: [1, 0]),  // Top-right
        Vertex(position: [-1,  1, 1], texCoord: [0, 0])   // Top-left
    ]
    
    let indices: [UInt16] = [
        3, 2, 1,  // First triangle
        3, 1, 0   // Second triangle
    ]
    
    init(_ parent: PanoramaView,texture : MTLTexture) {
        let aspectRatio : Float = parent.config.containerWidth / parent.config.containerHeight
        let hfov : Float = parent.config.horizontalFieldView * ( .pi / 180 )
        let vfov = 2 * atan(tan(hfov * 0.5) / aspectRatio)
        let focal = 1 / tan(vfov * 0.5)
        inputs = Inputs(
            aspectRatio: aspectRatio,
            psi: 0,
            theta:  0 ,
            f: SIMD2<Float>(focal,focal),
            rotation: 0 ,
            panOffset: SIMD2<Float>(0.5,0.5)
        )
        
        self.parent = parent
        self.texture = texture
        
        if let device = MTLCreateSystemDefaultDevice() {
            self.device = device
        }
        
        let vertexDescriptor = MTLVertexDescriptor()
        var offset: Int = 0
        
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = offset
        vertexDescriptor.attributes[0].bufferIndex = 0
        offset += MemoryLayout<SIMD3<Float>>.stride
        
        
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = offset
        vertexDescriptor.attributes[1].bufferIndex = 0
        offset += MemoryLayout<SIMD2<Float>>.stride
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        self.allocator = MTKMeshBufferAllocator(device: device)
        self.commandQueue = device.makeCommandQueue()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        do{
            let library : MTLLibrary = try device.makeLibrary(source:Utils().readShader()!,options:nil)
            pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
            pipelineDescriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
            try pipelineState = device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }catch{
            fatalError("Failed to create render pipeline state: \(error.localizedDescription)")
        }
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        samplerDescriptor.magFilter = .linear
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.maxAnisotropy = 1
        
        sampler = device.makeSamplerState(descriptor: samplerDescriptor)!
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                         length: MemoryLayout<Vertex>.stride * vertices.count,
                                         options: .storageModeShared)!
        indexBuffer = device.makeBuffer(bytes: indices,
                                        length: MemoryLayout<UInt16>.stride * indices.count,
                                        options: .storageModeShared)!
        fragmentBuffer = device.makeBuffer(bytes: &inputs,
                                           length: MemoryLayout<Inputs>.stride,
                                           options: .storageModeShared)!
        super.init()
    }
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    public func draw(in view: MTKView) {
        autoreleasepool {
       
            let aspectRatio = parent.config.containerWidth / parent.config.containerHeight
            let hfov = parent.config.horizontalFieldView * (.pi / 180)
            let vfov = 2 * atan(tan(hfov * 0.5) / aspectRatio)
            let focal = 1 / tan(vfov * 0.5)
            inputs.f = SIMD2<Float>(focal, focal)
            inputs.theta = parent.config.theta * (.pi / 180)
            inputs.psi = parent.config.psi * (.pi / 180)

        
            memcpy(fragmentBuffer.contents(), &inputs, MemoryLayout<Inputs>.stride)

            guard let drawable = view.currentDrawable,
                  let rpd = view.currentRenderPassDescriptor else { return }

            let cmdBuf = commandQueue.makeCommandBuffer()!
            rpd.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
            let encoder = cmdBuf.makeRenderCommandEncoder(descriptor: rpd)!

            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setFragmentTexture(texture, index: 0)
            encoder.setFragmentSamplerState(sampler, index: 0)
            encoder.setFragmentBuffer(fragmentBuffer, offset: 0, index: 1)

            encoder.drawIndexedPrimitives(type: .triangle,
                                          indexCount: indices.count,
                                          indexType: .uint16,
                                          indexBuffer: indexBuffer,
                                          indexBufferOffset: 0)
            encoder.endEncoding()


            cmdBuf.present(drawable)
            cmdBuf.commit()
        }
    }

}

