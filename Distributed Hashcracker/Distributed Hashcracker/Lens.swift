//
//  Lens.swift
//  Distributed Hashcracker
//
//  Created by Pascal Schönthier on 09.03.16.
//  Copyright © 2016 Pascal Schönthier. All rights reserved.
//

import Foundation


struct Lens<Whole, Part> {
    let get : Whole -> Part
    let set: (Part, Whole) -> Whole
}
