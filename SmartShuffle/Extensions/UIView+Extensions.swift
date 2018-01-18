//
//  UIView+Extensions.swift
//  SmartShuffle
//
//  Created by Matthew Howes Singleton on 1/18/18.
//  Copyright © 2018 Matthew Howes Singleton. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  
  func createRoundedCorners() {
    layer.cornerRadius = 7
    clipsToBounds = true
  }
  
}
