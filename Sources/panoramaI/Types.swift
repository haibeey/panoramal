//
//  Types.swift
//  
//
//  Created by Akerele Abraham on 27/01/2025.
//

import Foundation
import simd

struct Inputs {
    var aspectRatio: Float
    var psi:  Float
    var theta:  Float
    var f:  SIMD2<Float>
    var rotation:  Float
    var panOffset: SIMD2<Float>
}

struct Vertex {
    var position: SIMD3<Float>
    var texCoord: SIMD2<Float>
}

