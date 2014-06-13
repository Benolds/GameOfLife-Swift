//
//  Tile.swift
//  GameOfLifeSwift
//
//  Created by Benjamin Reynolds on 6/5/14.
//  Copyright (c) 2014 Benjamin Reynolds. All rights reserved.
//

import SpriteKit

class Tile: SKSpriteNode {
    var isAlive:Bool = false {
        didSet {
            if isAlive {
                self.hidden = false;
            } else {
                self.hidden = true;
            }
        }
    }
    var numLivingNeighbors = 0
}
