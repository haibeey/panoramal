//
//  Panoramal.swift
//
//
//  Created by Akerele Abraham on 27/01/2025.
//

import SwiftUI
import MetalKit
import UIKit
import Foundation

public struct PanoramaI: View {
    
    @ObservedObject private var config: Config
    
    @State private var onPointerDownPsi: Float = 0
    @State private var onPointerDownTheta: Float = 0
    
    @State private var onPointerDownPointerX: Float = 0
    @State private var onPointerDownPointerY: Float = 0
    
    @State private var lastTouch: Bool = false
    
    @State private var zoom: CGFloat = 1.0
    @State private var lastZoom: CGFloat = 1.0
    
    var urlPath: String?
    var url: URL?
    var name: String?
    var ext: String?
    var folder_path: String?
    
    public init(urlPath: String? = nil,
                url: URL? = nil,
                name: String? = nil,
                ext: String? = nil,
                folder_path: String? = nil,
                the_config : Config? = nil) {
        
        var configInstance  = the_config
        if (the_config == nil){
            configInstance = Config(containerHeight: Float(UIScreen.main.bounds.height),
                                    containerWidth: Float(UIScreen.main.bounds.width))
        }
        
        self._config = ObservedObject(wrappedValue: configInstance!)
        
        self.urlPath = urlPath
        self.url = url
        self.name = name
        self.ext = ext
        self.folder_path = folder_path
        
    }
    
    
    public var body: some View {
        
        
        Group {
            if config.isPlaceHolderTexture {
                Text("Invalid panorama file.")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            } else {
                Group {
                    if let urlPath = self.urlPath {
                        PanoramaView(urlPath: urlPath, config: self.config)
                    } else if let url = self.url {
                        PanoramaView(url: url, config: self.config)
                    } else if let name = self.name, let ext = self.ext {
                        PanoramaView(name: name, ext: ext, config: self.config)
                    } else if let name = self.name, let folder_path = self.folder_path {
                        PanoramaView(file_name: name, folder_path: folder_path, config: self.config)
                    } else {
                        Text("Invalid panorama file.")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }.gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            
                            if(!lastTouch){
                                lastTouch = true
                                onPointerDownPointerX = Float(value.location.x)
                                onPointerDownPointerY = Float(value.location.y)
                                
                                onPointerDownPsi = self.config.psi
                                onPointerDownTheta = self.config.theta
                                return
                            }
                            
                            let x : Float = Float(value.location.x)
                            let y : Float = Float(value.location.y)
                            
                            let width = self.config.containerWidth
                            let height = self.config.containerHeight
                            
                            let  psi =
                            ((atan(onPointerDownPointerX / width * 2.0 - 1.0) - atan(x / width * 2.0 - 1.0)) * 180 / .pi * 100.0 / 90.0 ) + onPointerDownPsi
                            
                            
                            let vfov = 2 * atan(tan(30.0 / 360 * .pi) * height / width) * 180.0 / .pi
                            
                            let  theta =
                            ((atan(y / height * 2.0 - 1.0) - atan(onPointerDownPointerY / height * 2.0 - 1.0)) * 180.0 / .pi * vfov / 90) + onPointerDownTheta
                            
                            
                            // rotation is constant for now as we assume panning with your hands.
                            config.updateAngles(psi: psi, theta: theta, rotation: 0)
                            
                        }
                        .onEnded { value in
                            
                            onPointerDownPointerX = Float(value.location.x)
                            onPointerDownPointerY = Float(value.location.y)
                            
                            onPointerDownPsi = self.config.psi
                            onPointerDownTheta = self.config.theta
                            
                            lastTouch = false
                        }
                ).simultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastZoom
                            zoom *= delta
                            lastZoom = value
                            
                            let clampedZoom = min(max(zoom, 0.5), 3.0)
                            config.updateHorizontalFieldView(hfov: Float(clampedZoom) * config.horizontalFieldView)
                        }
                        .onEnded { _ in
                            lastZoom = 1.0
                        }
                )
            }
        }
    }
}
