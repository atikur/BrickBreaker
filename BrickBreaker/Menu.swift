//
//  Menu.swift
//  BrickBreaker
//
//  Created by Atikur Rahman on 7/27/15.
//  Copyright (c) 2015 Atikur Rahman. All rights reserved.
//

import SpriteKit

class Menu: SKNode {
    
    var menuPanel: SKSpriteNode!
    var playButton: SKSpriteNode!
    
    var panelText: SKLabelNode!
    var buttonText: SKLabelNode!
    
    override init() {
        super.init()
                
        menuPanel = SKSpriteNode(imageNamed: "MenuPanel")
        menuPanel.position = CGPointZero
        addChild(menuPanel)
        
        panelText = SKLabelNode(fontNamed: "Futura")
        panelText.text = "LEVEL 1"
        panelText.fontSize = 15
        panelText.fontColor = SKColor.grayColor()
        panelText.verticalAlignmentMode = .Center
        menuPanel.addChild(panelText)
        
        playButton = SKSpriteNode(imageNamed: "Button")
        playButton.name = "Play Button"
        playButton.position = CGPointMake(0, -(menuPanel.size.height * 0.5 + playButton.size.height * 0.5 + 10))
        addChild(playButton)
        
        buttonText = SKLabelNode(fontNamed: "Futura")
        buttonText.name = "Play Button"
        buttonText.position = CGPointMake(0, 2)
        buttonText.text = "PLAY"
        buttonText.fontSize = 15
        buttonText.fontColor = SKColor.grayColor()
        buttonText.verticalAlignmentMode = .Center
        playButton.addChild(buttonText)
    }
    
    func hide() {
        let slideLeft = SKAction.moveByX(-260, y: 0, duration: 0.5)
        slideLeft.timingMode = .EaseIn
        let slideRight = SKAction.moveByX(260, y: 0, duration: 0.5)
        slideRight.timingMode = .EaseIn
        
        menuPanel.position = CGPointMake(0, menuPanel.position.y)
        playButton.position = CGPointMake(0, playButton.position.y)
        
        menuPanel.runAction(slideLeft)
        playButton.runAction(slideRight) {
            self.hidden = true
        }
    }
    
    func show() {
        let slideLeft = SKAction.moveByX(-260, y: 0, duration: 0.5)
        slideLeft.timingMode = .EaseOut
        let slideRight = SKAction.moveByX(260, y: 0, duration: 0.5)
        slideRight.timingMode = .EaseOut
        
        menuPanel.position = CGPointMake(260, menuPanel.position.y)
        playButton.position = CGPointMake(-260, playButton.position.y)
        
        menuPanel.runAction(slideLeft)
        playButton.runAction(slideRight)
        
        self.hidden = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
