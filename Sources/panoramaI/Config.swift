//
//  Config.swift
//  
//
//  Created by Akerele Abraham on 27/01/2025.
//

import Foundation
import simd


public class Config : ObservableObject{
    @Published var panOffset: SIMD2<Float>
    @Published var psi: Float = 0
    @Published var theta: Float = 0
    @Published var rotation: Float = 0
    @Published var containerHeight : Float
    @Published var containerWidth : Float
    @Published var horizontalFieldView : Float = 65.0;
    @Published var dragSensitivity : Float = 1.0
    @Published var isPlaceHolderTexture  = false
    
    let minTheta : Float = -90.0
    let maxTheta : Float = 90.0
    
    
    public init(containerHeight :Float,
                containerWidth : Float,
                hfov : Float = 65.0,
                dragSensitivity : Float = 1.05,
                psi : Float = 0.0,
                rotation : Float = 0.0,
                theta : Float = 0.0,
                panOffset : SIMD2<Float> = SIMD2<Float>(1,1),
                isPlaceHolderTexture : Bool = false
    ) {
        self.containerWidth = containerWidth
        self.containerHeight = containerHeight
        self.panOffset = panOffset
        self.horizontalFieldView = hfov
        self.psi = psi
        self.theta = theta
        self.rotation = rotation
        self.dragSensitivity = dragSensitivity
        self.isPlaceHolderTexture = isPlaceHolderTexture
    }
    
    func updatePanOffset(x: Float,y: Float){
        DispatchQueue.main.async {
            self.panOffset = SIMD2<Float>(x,y)
        }
    }
    
    func updateAngles(psi: Float,theta: Float,rotation: Float){
        DispatchQueue.main.async {
            self.psi = psi
            self.theta = max(self.minTheta, min(self.maxTheta, theta))
            self.rotation = rotation
        }
    }
    
    public func  updateHorizontalFieldView(hfov : Float){
        DispatchQueue.main.async {
            if(hfov < 30){
                self.horizontalFieldView = 30
            }else if(hfov > 90){
                self.horizontalFieldView = 80
            }else{
                self.horizontalFieldView = hfov
            }
            
        }
    }
    
    func updateIsPlaceHolderTexture(ipht: Bool){
        DispatchQueue.main.async {
            self.isPlaceHolderTexture = ipht
        }
    }
}
