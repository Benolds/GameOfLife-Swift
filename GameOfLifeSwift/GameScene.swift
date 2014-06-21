//
//  GameScene.swift
//  GameOfLifeSwift
//
//  Created by Benjamin Reynolds on 6/4/14.
//  Copyright (c) 2014 Benjamin Reynolds. All rights reserved.
//


// This is the complete source code for the MakeGamesWithUse - Game of Life tutorial - using Swift and SpriteKit: https://www.makegameswith.us/gamernews/399/create-the-game-of-life-using-swift-and-spritekit

import SpriteKit

class GameScene: SKScene {
    
    // properties defining the grid
    let _gridHeight = 300 //grid dimensions (in pixels)
    let _gridWidth = 400
    let _numRows = 8 //number of tiles per column
    let _numCols = 10 // ...per row
    let _gridLowerLeftCorner = CGPoint(x: 158, y: 10) //grid offset from lower-left corner of screen
    let _margin = 4

    // properties defining the stats labels and buttons
    let _populationLabel = SKLabelNode(text: "Population")
    let _generationLabel = SKLabelNode(text: "Generation")
    var _populationValueLabel = SKLabelNode(text: "0")
    var _generationValueLabel = SKLabelNode(text: "0")
    var _playButton = SKSpriteNode(imageNamed: "play.png")
    var _pauseButton = SKSpriteNode(imageNamed: "pause.png")
    
    // 2d list of tiles
    var _tiles:Tile[][] = []

    // properties affecting the update loop
    var _isPlaying = false
    var _prevTime:CFTimeInterval = 0
    var _timeCounter:CFTimeInterval = 0
    
    // properties and setters for population and generatino stats
    var _population:Int = 0 {
        didSet {
            _populationValueLabel.text = "\(_population)" // update appropriate label when value changes
        }
    }
    var _generation:Int = 0 {
        didSet {
            _generationValueLabel.text = "\(_generation)"
        }
    }
    
    // set up the user interface upon loading the scene
    override func didMoveToView(view: SKView) {
        
        // add a background for the entire screen
        let background = SKSpriteNode(imageNamed: "background.png")
        background.anchorPoint = CGPoint.zeroPoint
        background.size = self.size
        background.zPosition = -2
        self.addChild(background)
        
        // add a background to appear behind the grid
        let gridBackground = SKSpriteNode(imageNamed: "grid.png")
        gridBackground.size = CGSize(width: _gridWidth, height: _gridHeight)
        gridBackground.zPosition = -1
        gridBackground.anchorPoint = CGPoint.zeroPoint
        gridBackground.position = _gridLowerLeftCorner
        self.addChild(gridBackground)
        
        // add a balloon background for the stats
        let balloon = SKSpriteNode(imageNamed: "balloon.png")
        balloon.position = CGPoint(x: 79, y: 170)
        balloon.setScale(0.5)
        self.addChild(balloon)
        
        // add a microscope image as a decoration
        let microscope = SKSpriteNode(imageNamed: "microscope.png")
        microscope.position = CGPoint(x: 79, y: 70)
        microscope.setScale(0.4)
        self.addChild(microscope)

        // population label
        _populationLabel.position = CGPoint(x: 79, y: 190)
        _populationLabel.fontName = "Courier"
        _populationLabel.fontSize = 12
        _populationLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_populationLabel)
        
        _populationValueLabel.position = CGPoint(x: 79, y: 175)
        _populationValueLabel.fontName = "Courier"
        _populationValueLabel.fontSize = 12
        _populationValueLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_populationValueLabel)
        
        //generation label
        _generationLabel.position = CGPoint(x: 79, y: 160)
        _generationLabel.fontName = "Courier"
        _generationLabel.fontSize = 12
        _generationLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_generationLabel)
        
        _generationValueLabel.position = CGPoint(x: 79, y: 145)
        _generationValueLabel.fontName = "Courier"
        _generationValueLabel.fontSize = 12
        _generationValueLabel.fontColor = UIColor(red: 0, green: 0.2, blue: 0, alpha: 1)
        self.addChild(_generationValueLabel)

        // play and pause buttons
        _playButton.position = CGPoint(x: 79, y: 290)
        _playButton.setScale(0.5)
        self.addChild(_playButton)
        
        _pauseButton.position = CGPoint(x: 79, y: 250)
        _pauseButton.setScale(0.5)
        self.addChild(_pauseButton)

        // initialize the 2d array of tiles
        let tileSize = calculateTileSize()
        for r in 0.._numRows {
            var tileRow:Tile[] = []
            for c in 0.._numCols {
                let tile = Tile(imageNamed: "bubble.png")
                tile.isAlive = false
                tile.size = CGSize(width: tileSize.width, height: tileSize.height)
                tile.anchorPoint = CGPoint.zeroPoint
                tile.position = getTilePosition(row: r, column: c)
                self.addChild(tile)
                tileRow.append(tile)
            }
            _tiles.append(tileRow)
        }

    }
    
    // given a row and column, returns the (x,y) position that the tile should be placed at
    func getTilePosition(row r:Int, column c:Int) -> CGPoint
    {
        let tileSize = calculateTileSize()
        let x = Int(_gridLowerLeftCorner.x) + _margin + (c * (Int(tileSize.width) + _margin))
        let y = Int(_gridLowerLeftCorner.y) + _margin + (r * (Int(tileSize.height) + _margin))
        return CGPoint(x: x, y: y)
    }
    
    //calculates the width and height tiles should be based on the grid size and number of rows and columns
    func calculateTileSize() -> CGSize
    {
        let tileWidth = _gridWidth / _numCols - _margin
        let tileHeight = _gridHeight / _numRows - _margin
        
        return CGSize(width: tileWidth, height: tileHeight)
    }
    
    // given and (x,y) position, returns a tile overlapping that position, if any, else returns nil
    func getTileAtPosition(xPos x: Int, yPos y: Int) -> Tile? {
        let r = Int( Float(y - (Int(_gridLowerLeftCorner.y) + _margin)) / Float(_gridHeight) * Float(_numRows))
        let c = Int( Float(x - (Int(_gridLowerLeftCorner.x) + _margin)) / Float(_gridWidth) * Float(_numCols))
        
        if isValidTile(row: r, column: c) {
            return _tiles[r][c]
        } else {
            return nil
        }
    }
    
    // returns true if the row and column provided are within the bounds of the grid
    func isValidTile(row r: Int, column c:Int) -> Bool {
        return r >= 0 && r < _numRows && c >= 0 && c < _numCols
    }
    
    // checks for taps on tiles and buttons
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        // tapping a tile toggles its isAlive state
        for touch: AnyObject in touches {
            var selectedTile = getTileAtPosition(xPos: Int(touch.locationInNode(self).x), yPos: Int(touch.locationInNode(self).y))
            if let tile = selectedTile {
                tile.isAlive = !tile.isAlive
                if tile.isAlive {
                    _population++
                } else {
                    _population--
                }
            }
            
            // tapping tha play button plays the game update loop
            if CGRectContainsPoint(_playButton.frame, touch.locationInNode(self)) {
                playButtonPressed()
            }
            
            // tapping the pause button stops the game update loop
            if CGRectContainsPoint(_pauseButton.frame, touch.locationInNode(self)) {
                pauseButtonPressed()
            }
        }
    }

    // evolves the game board state by one iteration
    func timeStep()
    {
        countLivingNeighbors()
        updateCreatures()
        _generation++
    }

    // sets the numLivingNeighbors property of each tile to a value between [0, 8] based on the number of adjacent alive tiles
    func countLivingNeighbors()
    {
        for r in 0.._numRows {
            for c in 0.._numCols
            {
                var numLivingNeighbors = 0
                
                for i in (r-1)...(r+1) {
                    for j in (c-1)...(c+1)
                    {
                        if ( !((r == i) && (c == j)) && isValidTile(row: i, column: j)) {
                            if _tiles[i][j].isAlive {
                                numLivingNeighbors++
                            }
                        }
                    }
                }
                _tiles[r][c].numLivingNeighbors = numLivingNeighbors
            }
        }
    }

    // sets the isAlive state of each tile dependin on their number of living neighbors
    func updateCreatures()
    {
        var numAlive = 0
        
        for r in 0.._numRows {
            for c in 0.._numCols
            {
                var tile = _tiles[r][c]
                
                if tile.numLivingNeighbors == 3 {
                    tile.isAlive = true
                } else if tile.numLivingNeighbors < 2 || tile.numLivingNeighbors > 3 {
                    tile.isAlive = false
                }
                
                if tile.isAlive {
                    numAlive++
                }
            }
        }
        
        _population = numAlive
    }
    
    // starts the game update loop upon button pressed
    func playButtonPressed()
    {
        _isPlaying = true
    }
    
    // stops the game update loop upon button pressed
    func pauseButtonPressed()
    {
        _isPlaying = false
    }

    // calls the timeStep method every 0.5 seconds
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if _prevTime == 0 {
            _prevTime = currentTime
        }
        
        
        if _isPlaying
        {
            _timeCounter += currentTime - _prevTime
            
            if _timeCounter > 0.5 {
                _timeCounter = 0
                timeStep()
            }
        }
        
        _prevTime = currentTime
        
    }
}
