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
    }
    
    var type: BrickType
    
    init(type: BrickType) {
        self.type = type
        
        let texture: SKTexture
        
        switch type {
        case .Green:
            texture = SKTexture(imageNamed: "BrickGreen")
        case .Blue:
            texture = SKTexture(imageNamed: "BrickBlue")
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
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
