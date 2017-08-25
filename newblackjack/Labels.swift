//
//  Labbels.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/08/24.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit

class Labels{
	
	func setLabels(frame_height:CGFloat,frame_width:CGFloat) -> (pBPLabel:SKLabelNode,cBPLabel:SKLabelNode,ppLabel:SKLabelNode,cpLabel:SKLabelNode,pbjLabel:SKLabelNode,cbjLabel:SKLabelNode,tPointLabel:[SKLabelNode],centerLabel:SKLabelNode,p1Label:SKLabelNode,comLabel:SKLabelNode,specialLabels:[String:SKLabelNode]){
		
		let cheight = frame_height/3	//カードの縦の長さは画面サイズによって変わる。7+で138?
		
		var pBPLabel = SKLabelNode()
		var cBPLabel = SKLabelNode()
		var tPointLabel:[SKLabelNode]=[]
		
		
		if Cards.mode == .scom{
			pBPLabel = {() -> SKLabelNode in  //設定先を誤るミスを防ぐため、クロージャーで設定
				let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
				Label.fontSize = cheight*30/138
				Label.horizontalAlignmentMode = .left
				Label.position = CGPoint(x:frame_width/2, y:cheight+cheight*5/138)
				Label.text = "×"+String(Cards.pBP)
				return Label
			}()
			
			cBPLabel = {() -> SKLabelNode in
				let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
				Label.fontSize = cheight*30/138
				Label.horizontalAlignmentMode = .left
				Label.position=CGPoint(x:frame_width/2, y:frame_height-(cheight+cheight*30/138))
				Label.text="×"+String(Cards.cBP)
				return Label
			}()
		}
		
		//両者の得点表示のラベル
		let ppLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = cheight*30/138
			Label.horizontalAlignmentMode = .left	//左寄せ
			if Cards.mode == .netp2 {
				Label.position = CGPoint(x:0, y:(frame_height)-cheight-cheight*30/138)
				Label.isHidden=true
			}else{
				Label.position = CGPoint(x:0, y:cheight+cheight*5/138)
			}

			
			return Label
		}()

		let cpLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = cheight*30/138
			Label.horizontalAlignmentMode = .left
			if Cards.mode == .netp2{
				Label.position = CGPoint(x:0, y:cheight+cheight*5/138)
			}else{
				Label.position = CGPoint(x:0, y:(frame_height)-cheight-cheight*30/138)
				Label.isHidden=true
			}
			
			return Label
		}()

		//両者のbj表示用のラベル
		let pbjLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize=cheight*30/138
			Label.horizontalAlignmentMode = .left
			if Cards.mode == .netp2 {
				Label.position = CGPoint(x:cheight*30/138*2, y:(frame_height)-cheight-cheight*30/138)
			}else{
				Label.position = CGPoint(x:cheight*30/138*2, y:cheight+cheight*5/138)
			}
			Label.isHidden=true
			Label.text="Blackjack!"
			Label.fontColor=SKColor.magenta
			
			return Label
		}()

		let cbjLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = cheight*30/138
			Label.horizontalAlignmentMode = .left
			if Cards.mode == .netp2 {
				Label.position = CGPoint(x:cheight*30/138*2, y:cheight+cheight*5/138)
			}else{
				Label.position = CGPoint(x:cheight*30/138*2, y:(frame_height)-cheight-cheight*30/138)
			}
			Label.isHidden=true
			Label.text="Blackjack!"
			Label.fontColor=SKColor.magenta
			
			return Label
		}()

		//各トランプの得点のラベルを作成&設定（アリス・Aエラー回避のためこの位置）
		for _ in 1...52{
			tPointLabel.append(SKLabelNode(fontNamed: "HiraginoSans-W6"))
		}
		for i in tPointLabel{
			i.fontSize=cheight*16/138
			i.position=CGPoint(x:-1000,y:0)
			i.zPosition=2
			i.fontColor=SKColor.white
		}
		
		//ターンを表示
		let centerLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			if Cards.mode == .pvp{
				Label.text = "P1のターン"
			}else if Cards.mode == .netp1{
				Label.text = "あなたのターン"
			}else if Cards.mode == .netp2 {
				Label.text = "相手のターン"
			}else{
				Label.text = "playerのターン"
			}
			Label.fontSize = cheight*45/138
			Label.position = CGPoint(x:frame_width/2, y:frame_height/2 - cheight*20/138)

			return Label
		}()
		
		//対戦者表示のラベル
		let p1Label = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			Label.fontSize = cheight*20/138
			Label.horizontalAlignmentMode = .left
			Label.text="P1"
			Label.fontColor=SKColor.blue
			
			if Cards.mode == .com || Cards.mode == .pvp || Cards.mode == .netp1 || Cards.mode == .scom{
				Label.position = CGPoint(x:0, y:cheight+cheight*35/138)
			}else{  //netp2
				Label.position = CGPoint(x:0, y:(frame_height)-cheight-cheight*55/138)
			}
			
			return Label
		}()
		
		let comLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = cheight*20/138
			Label.horizontalAlignmentMode = .left	//左寄せ
			if Cards.mode == .com || Cards.mode == .scom{
				Label.position = CGPoint(x:0, y:(frame_height)-cheight-cheight*50/138)
				Label.text = "com"
				Label.fontColor=SKColor.yellow
			}else if Cards.mode == .pvp || Cards.mode == .netp1{
				Label.position = CGPoint(x:0, y:(frame_height)-cheight-cheight*50/138)
				Label.text="P2"
				Label.fontColor=SKColor.red
			}else{
				Label.position = CGPoint(x:0, y:cheight+cheight*35/138)
				Label.text="P2"
				Label.fontColor=SKColor.red
			}
			
			return Label
		}()
		
		//攻撃力と体力のラベルの設定
		var specialLabels:[String:SKLabelNode]=[:]
		
		specialLabels["satanA"] = setSpecialCardLabel(text: "6", cheight: cheight)
		specialLabels["olivieA"] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels["bahamutA"] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels["zeusA"] = setSpecialCardLabel(text: "5", cheight: cheight)
		specialLabels["aliceA"] = setSpecialCardLabel(text: "3", cheight: cheight)
		specialLabels["satanHP"] = setSpecialCardLabel(text: "6", cheight: cheight)
		specialLabels["olivieHP"] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels["bahamutHP"] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels["zeusHP"] = setSpecialCardLabel(text: "10", cheight: cheight)
		specialLabels["aliceHP"] = setSpecialCardLabel(text: "4", cheight: cheight)

		
		return (pBPLabel,cBPLabel,ppLabel,cpLabel,pbjLabel,cbjLabel,tPointLabel,centerLabel,p1Label,comLabel,specialLabels)
	}
	
	func setSpecialCardLabel(text:String,cheight:CGFloat) -> SKLabelNode {
		let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
		
		Label.text=text
		Label.fontSize=cheight*11/138
		Label.zPosition=2
		
		return Label
	}
	
}
