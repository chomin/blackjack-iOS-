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
		if Cards.mode == .scom{
			pBPim = {() -> SKSpriteNode in	  //設定先を間違えるミスを防ぐため、クロージャで設定
				let node=SKSpriteNode(imageNamed:"進化")
				node.size=CGSize(width:cheight*30/138,height:cheight*30/138)
				node.position = CGPoint(x:self.frame.width/2-cheight*20/138, y:cheight+cheight*15/138)
				self.addChild(node)
				return node
				
			}()
			
			cBPim = {() -> SKSpriteNode in
				let node=SKSpriteNode(imageNamed:"進化2")
				node.size=CGSize(width:cheight*30/138,height:cheight*30/138)
				node.position = CGPoint(x:self.frame.width/2-cheight*20/138, y:self.frame.height-(cheight+cheight*20/138))
				self.addChild(node)
				return node
			}()
		}
		
		
		//card[0]に裏面を格納
		card.append(SKSpriteNode(imageNamed:"z02"))
		
		//クローバー、ダイヤ、ハート、スペードの順に画像を格納
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "c\(i)-1"))
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "d\(i)-1"))
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "h\(i)-1"))
		}
		for i in 1...13{
			card.append(SKSpriteNode(imageNamed: "s\(i)-1"))
		}
		
		//特殊カードを追加
		card.append(SKSpriteNode(imageNamed: "Satan"))//53
		card.append(SKSpriteNode(imageNamed: "Olivie"))//54
		card.append(SKSpriteNode(imageNamed: "Bahamut"))//55
		card.append(SKSpriteNode(imageNamed: "Zeus"))//56
		card.append(SKSpriteNode(imageNamed: "Alice"))//57
		card.append(SKSpriteNode(imageNamed: "Olivie"))//58
		card.append(SKSpriteNode(imageNamed: "Olivie"))//59
		card.append(SKSpriteNode(imageNamed: "Bahamut"))//60
		card.append(SKSpriteNode(imageNamed: "Bahamut"))//61
		card.append(SKSpriteNode(imageNamed: "Alice"))//62
		card.append(SKSpriteNode(imageNamed: "Alice"))//63
		card.append(SKSpriteNode(imageNamed: "Lucifer"))//64
		card.append(SKSpriteNode(imageNamed: "Lucifer"))//65
		card.append(SKSpriteNode(imageNamed: "Lucifer"))//66
		
		
		//cardのサイズを設定
		for i in card{
			i.size = CGSize(width:cwidth,height:cheight)
			i.position = CGPoint(x:0, y:10000)    //枠外に
			i.zPosition = 1
		}
	}
	
}
