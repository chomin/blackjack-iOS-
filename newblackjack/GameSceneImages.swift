//
//  Images.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/08/24.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import  SpriteKit

extension GameScene{//画像に関する拡張
	func setImages(){
		
		//EP表示画像の設定
		if Game.mode == .scom{
			pBPim = {() -> SKSpriteNode in	  //設定先を間違えるミスを防ぐため、クロージャで設定
				let node=SKSpriteNode(imageNamed:"進化")
				node.size=CGSize(width:GameScene.cheight*30/138,height:GameScene.cheight*30/138)
				node.position = CGPoint(x:self.frame.width/2-GameScene.cheight*20/138, y:GameScene.cheight+GameScene.cheight*15/138)
				self.addChild(node)
				return node
				
			}()
			
			cBPim = {() -> SKSpriteNode in
				let node=SKSpriteNode(imageNamed:"進化2")
				node.size=CGSize(width:GameScene.cheight*30/138,height:GameScene.cheight*30/138)
				node.position = CGPoint(x:self.frame.width/2-GameScene.cheight*20/138, y:self.frame.height-(GameScene.cheight+GameScene.cheight*20/138))
				self.addChild(node)
				return node
			}()
		}
		
	
		//cardのサイズを設定
		let j = GameScene.backCard.image
		if GameScene.cwidth != nil{
			j.size = CGSize(width:GameScene.cwidth,height:GameScene.cheight)
		}
		j.position = CGPoint(x:0, y:10000)    //枠外に
		j.zPosition = 1
		
	}
	
}
