//
//  GameScene.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/14/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PhysicsCategory {
        static let Ball: UInt32     = 0
        static let Paddle: UInt32   = 0b1
        static let Brick: UInt32    = 0b10
    }
    
    let ballSpeed: CGFloat = 200
    
    var paddle: SKSpriteNode!
    var touchLocation: CGPoint!
    
    var brickLayer: SKNode!
    var ballReleased: Bool!
    var positionBall: Bool!
    var currentLevel: Int!
    
    var hearts: [SKSpriteNode]!
    
    var lives: Int! {
        didSet {
            for (index, heart) in enumerate(hearts) {
                if index < lives {
                    heart.texture = SKTexture(imageNamed: "HeartFull")
                } else {
                    heart.texture = SKTexture(imageNamed: "HeartEmpty")
                }
            }
        }
    }
    
    // MARK: -
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        for touch in (touches as! Set<UITouch>) {
            if !ballReleased {
                positionBall = true
            }
            touchLocation = touch.locationInNode(self)
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if positionBall == true {
            paddle.removeAllChildren()
            
            createBallWithLocation(CGPointMake(paddle.position.x, paddle.position.y + paddle.size.height * 0.5), velocity: CGVectorMake(0, ballSpeed))
            ballReleased = true
            positionBall = false
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
    
    override func update(currentTime: NSTimeInterval) {
        if isLevelComplete() {
            currentLevel = currentLevel + 1
            
            if currentLevel > 2 {
                currentLevel = 0
            }
            
            loadLevel(currentLevel)
            newBall()
        }
    }
    
    // MARK: - SKPhysicsContactDelegate Methods
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        } else {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        
        // contact between ball and paddle
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Paddle {
                if firstBody.node?.position.y > secondBody.node?.position.y {
                // get contact point in paddle coordinates
                let pointInPaddle = secondBody.node?.convertPoint(contact.contactPoint, fromNode: self)
                // get contact position as percentage of paddle's width
                let contactPosition = (secondBody.node!.frame.size.width * 0.5 + pointInPaddle!.x) / secondBody.node!.frame.size.width
                // cap percentage between 0 to 1 and flip it
                let multiplier = 1.0 - fmax(fmin(contactPosition, 1.0), 0.0)
                // calculate angle based on ball position in paddle
                let angle = (CGFloat(M_PI_2) * multiplier) + CGFloat(M_PI_4)
                // convert angle to vector
                let direction = CGVectorMake(cos(angle), sin(angle))
                
                firstBody.velocity = CGVectorMake(direction.dx * ballSpeed, direction.dy * ballSpeed)
            }
        }
        
        // contact between ball and brick
        if firstBody.categoryBitMask == PhysicsCategory.Ball && secondBody.categoryBitMask == PhysicsCategory.Brick {
            if let brick = (secondBody.node as? Brick) {
                brick.hit()
            }
        }
    }
    
    // MARK: -
    
    func createBallWithLocation(position: CGPoint, velocity: CGVector) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.name = "ball"
        ball.position = position
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width * 0.5)
        ball.physicsBody?.friction = 0.0
        ball.physicsBody?.linearDamping = 0.0
        ball.physicsBody?.angularDamping = 0.0
        ball.physicsBody?.restitution = 1.0
        ball.physicsBody?.velocity = velocity
        ball.physicsBody?.categoryBitMask = PhysicsCategory.Ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.Paddle | PhysicsCategory.Brick
        
        addChild(ball)
        return ball
    }
    
    func loadLevel(level: Int) {
        brickLayer.removeAllChildren()
        
        var collection: [[Brick.BrickType!]] = []
        
        switch level {
        case 0:
            collection = [
                [.Green, .Green, ],

            ]
        case 1:
            collection = [
                [.Green, .Green, .Blue, .Blue, .Green, .Green],

            ]
        case 2:
            collection = [
                [.Green, nil, .Green, .Green, nil, .Green],

            ]
        default:
            break
        }
        
        for (rowIndex, row) in enumerate(collection) {
            for (colIndex, brickType) in enumerate(row) {
                if brickType != nil {
                    let brick = Brick(type: brickType)
                    brick.position = CGPointMake(
                        2 + brick.size.width * 0.5 + (brick.size.width + 3) * CGFloat(colIndex),
                        -(2 + brick.size.height * 0.5 + (brick.size.height + 3) * CGFloat(rowIndex)))
                    brickLayer.addChild(brick)
                }
            }
        }
    }
    
    func isLevelComplete() -> Bool {
        for node in brickLayer.children {
            if let brick = node as? Brick {
                if !brick.indestructible {
                    return false
                }
            }
        }
        
        return true
    }
    
    func newBall() {
        self.enumerateChildNodesWithName("ball") {
            node, _ in
            node.removeFromParent()
        }
        
        let ball = SKSpriteNode(imageNamed: "BallBlue")
        ball.position = CGPointMake(0, paddle.size.height)
        paddle.addChild(ball)
        
        paddle.position = CGPointMake(self.size.width/2, paddle.position.y)
        
        ballReleased = false
    }
    
    // MARK: - Initializers
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        self.physicsWorld.contactDelegate = self
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        // setup brick layer
        brickLayer = SKNode()
        brickLayer.position = CGPointMake(0, self.size.height)
        addChild(brickLayer)
        
        hearts = [
            SKSpriteNode(imageNamed: "HeartFull"),
            SKSpriteNode(imageNamed: "HeartFull")
        ]
        
        for (index, heart) in enumerate(hearts) {
            heart.position = CGPointMake(self.size.width - (16 + 29 * CGFloat(index)), self.size.height - 14)
            addChild(heart)
        }
        
        paddle = SKSpriteNode(imageNamed: "Paddle")
        paddle.position = CGPointMake(self.size.width/2, 90)
        paddle.physicsBody = SKPhysicsBody(rectangleOfSize: paddle.size)
        paddle.physicsBody?.dynamic = false
        paddle.physicsBody?.categoryBitMask = PhysicsCategory.Paddle
        addChild(paddle)
        
        currentLevel = 0
        lives = 2
        positionBall = false
        
        loadLevel(currentLevel)
        newBall()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}