//
//  Swap.swift
//  Check In
//
//  Created by Юрий Бондарчук on 17/12/2017.
//  Copyright © 2017 Samantha Parola. All rights reserved.
//


import Foundation

func ==(lhs: Swap, rhs: Swap) -> Bool {
    return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) ||
        (lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
}

struct Swap: CustomStringConvertible, Hashable {
    
    var hashValue: Int {
        return cookieA.hashValue ^ cookieB.hashValue
    }
    let cookieA: Cookie
    let cookieB: Cookie
    
    init(cookieA: Cookie, cookieB: Cookie) {
        self.cookieA = cookieA
        self.cookieB = cookieB
    }
    
    var description: String {
        return "swap \(cookieA) with \(cookieB)"
    }
}

