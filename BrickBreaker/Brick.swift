//
//  Brick.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/16/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class Brick: SKSpriteNode {
    
     enum BrickType {
        case Blue
        case Green
        case Grey
    }
    
    var type: BrickType
    var indestructible: Bool
    
    init(type: BrickType) {
        self.type = type
        self.indestructible = (type == .Grey)
        
        let texture: SKTexture
        
        switch type {
        case .Green:
            texture = SKTexture(imageNamed: "BrickGreen")
        case .Blue:
            texture = SKTexture(imageNamed: "BrickBlue")
        case .Grey:
            texture = SKTexture(imageNamed: "BrickGrey")
        }
        
        super.init(texture: texture, color: nil, size: texture.size())
        
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.dynamic = false
        self.physicsBody?.categoryBitMask = GameScene.PhysicsCategory.Brick
    }
    
    func hit() {
        switch type {
        case .Green:
            self.runAction(SKAction.removeFromParent())
        case .Blue:
            self.texture = SKTexture(imageNamed: "BrickGreen")
            self.type = .Green
        case .Grey:
            // indestructible bricks
            break
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
