//
//  Helpers.swift
//  RayTracer
//
//  Created by Javier Soto on 12/11/22.
//

import Foundation

public func equals<T: Equatable>(_ lhs: T, _ rhs: Any) -> Bool {
    guard let casted = rhs as? T else { return false }
    return lhs == casted
}
