//
//  GameScene.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/14/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var paddle: SKSpriteNode!
    var touchLocation: CGPoint!
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            let xMovement = touch.locationInNode(self).x - touchLocation.x
            
            paddle.position = CGPointMake(paddle.position.x + xMovement, paddle.position.y)
            
            let paddleMinX = -paddle.size.width * 0.25
            let paddleMaxX = self.size.width + paddle.size.width * 0.25
            
            if paddle.position.x < paddleMinX {
                paddle.position = CGPointMake(paddleMinX, paddle.position.y)
            }
            
            if paddle.position.x > paddleMaxX {
                paddle.position = CGPointMake(paddleMaxX, paddle.position.y)
            }
            
            touchLocation = touch.locationInNode(self)
        }
    }
    
    // MARK: - Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        
        paddle = SKSpriteNode(imageNamed: "Paddle")
        paddle.position = CGPointMake(self.size.width/2, 90)
        addChild(paddle)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}