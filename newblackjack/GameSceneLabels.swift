//
//  Labbels.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/08/24.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit

extension GameScene{//labelに関する拡張
	
	func setLabels(){
		
		if Game.mode == .scom{
			pBPLabel = {() -> SKLabelNode in  //設定先を誤るミスを防ぐため、クロージャーで設定
				let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
				Label.fontSize = GameScene.cheight*30/138
				Label.horizontalAlignmentMode = .left
				Label.position = CGPoint(x:self.frame.width/2, y:GameScene.cheight+GameScene.cheight*5/138)
				Label.text = "×"+String(Game.pBP)
				self.addChild(Label)
				return Label
			}()
			
			cBPLabel = {() -> SKLabelNode in
				let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
				Label.fontSize = GameScene.cheight*30/138
				Label.horizontalAlignmentMode = .left
				Label.position = CGPoint(x:self.frame.width/2, y:self.frame.height-(GameScene.cheight+GameScene.cheight*30/138))
				Label.text = "×" + String(Game.cBP)
				self.addChild(Label)
				return Label
			}()
		}
		
		//両者の得点表示のラベル
		ppLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = GameScene.cheight*30/138
			Label.horizontalAlignmentMode = .left	//左寄せ
			if Game.mode == .netp2 {
				Label.position = CGPoint(x:0, y:(self.frame.height)-GameScene.cheight-GameScene.cheight*30/138)
			}else{
				Label.position = CGPoint(x:0, y:GameScene.cheight+GameScene.cheight*5/138)
			}

			self.addChild(Label)
			return Label
		}()

		cpLabel = {() -> SKLabelNode in//ディーラーの得点
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = GameScene.cheight*30/138
			Label.horizontalAlignmentMode = .left
			if Game.mode == .netp2{
				Label.position = CGPoint(x:0, y:GameScene.cheight+GameScene.cheight*5/138)
			}else{
				Label.position = CGPoint(x:0, y:(self.frame.height)-GameScene.cheight-GameScene.cheight*30/138)
			}
			
			Label.isHidden=true
			self.addChild(Label)
			return Label
		}()

		//両者のbj表示用のラベル
		pbjLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize=GameScene.cheight*30/138
			Label.horizontalAlignmentMode = .left
			if Game.mode == .netp2 {
				Label.position = CGPoint(x:GameScene.cheight*30/138*2, y:(self.frame.height)-GameScene.cheight-GameScene.cheight*30/138)
			}else{
				Label.position = CGPoint(x:GameScene.cheight*30/138*2, y:GameScene.cheight+GameScene.cheight*5/138)
			}
			Label.isHidden=true
			Label.text="Blackjack!"
			Label.fontColor=SKColor.magenta
			self.addChild(Label)
			return Label
		}()

		cbjLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = GameScene.cheight*30/138
			Label.horizontalAlignmentMode = .left
			if Game.mode == .netp2 {
				Label.position = CGPoint(x:GameScene.cheight*30/138*2, y:GameScene.cheight+GameScene.cheight*5/138)
			}else{
				Label.position = CGPoint(x:GameScene.cheight*30/138*2, y:(self.frame.height)-GameScene.cheight-GameScene.cheight*30/138)
			}
			Label.isHidden=true
			Label.text="Blackjack!"
			Label.fontColor=SKColor.magenta
			self.addChild(Label)
			return Label
		}()

		//各トランプの得点のラベルを作成&設定（アリス・Aエラー回避のためこの位置）
//		for _ in 1...52{
//			tPointLabel.append(SKLabelNode(fontNamed: "HiraginoSans-W6"))
//		}
//		for i in tPointLabel{
//			i.fontSize=GameScene.cheight*16/138
//			i.position=CGPoint(x:0,y:10000)
//			i.zPosition=2
//			i.fontColor=SKColor.white
////			self.addChild(i)
//		}
		
		//ターンを表示
		centerLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			if Game.mode == .pvp{
				Label.text = "P1のターン"
			}else if Game.mode == .netp1{
				Label.text = "あなたのターン"
			}else if Game.mode == .netp2 {
				Label.text = "相手のターン"
			}else{
				Label.text = "playerのターン"
			}
			Label.fontSize = GameScene.cheight*45/138
			Label.position = CGPoint(x:self.frame.width/2, y:self.frame.height/2 - GameScene.cheight*20/138)
			self.addChild(Label)
			return Label
		}()
		
		//対戦者表示のラベル
		p1Label = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			Label.fontSize = GameScene.cheight*20/138
			Label.horizontalAlignmentMode = .left
			Label.text="P1"
			Label.fontColor=SKColor.blue
			
			if Game.mode == .com || Game.mode == .pvp || Game.mode == .netp1 || Game.mode == .scom{
				Label.position = CGPoint(x:0, y:GameScene.cheight+GameScene.cheight*35/138)
			}else{  //netp2
				Label.position = CGPoint(x:0, y:(self.frame.height)-GameScene.cheight-GameScene.cheight*55/138)
			}
			self.addChild(Label)
			return Label
		}()
		
		comLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = GameScene.cheight*20/138
			Label.horizontalAlignmentMode = .left	//左寄せ
			if Game.mode == .com || Game.mode == .scom{
				Label.position = CGPoint(x:0, y:(self.frame.height)-GameScene.cheight-GameScene.cheight*50/138)
				Label.text = "com"
				Label.fontColor=SKColor.yellow
			}else if Game.mode == .pvp || Game.mode == .netp1{
				Label.position = CGPoint(x:0, y:(self.frame.height)-GameScene.cheight-GameScene.cheight*50/138)
				Label.text="P2"
				Label.fontColor=SKColor.red
			}else{
				Label.position = CGPoint(x:0, y:GameScene.cheight+GameScene.cheight*35/138)
				Label.text="P2"
				Label.fontColor=SKColor.red
			}
			self.addChild(Label)
			return Label
		}()
		
		//攻撃力と体力のラベルの設定
//
//		specialLabels[.satanA] = setSpecialCardLabel(text: "6", GameScene.cheight: GameScene.cheight)
//		specialLabels[.olivieA] = setSpecialCardLabel(text: "4", GameScene.cheight: GameScene.cheight)
//		specialLabels[.bahamutA] = setSpecialCardLabel(text: "13", GameScene.cheight: cheight)
//		specialLabels[.zeusA] = setSpecialCardLabel(text: "5", cheight: cheight)
//		specialLabels[.aliceA] = setSpecialCardLabel(text: "3", cheight: cheight)
//		specialLabels[.satanHP] = setSpecialCardLabel(text: "6", cheight: cheight)
//		specialLabels[.olivieHP] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.bahamutHP] = setSpecialCardLabel(text: "13", cheight: cheight)
//		specialLabels[.zeusHP] = setSpecialCardLabel(text: "10", cheight: cheight)
//		specialLabels[.aliceHP] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.olivieA2] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.bahamutA2] = setSpecialCardLabel(text: "13", cheight: cheight)
//		specialLabels[.aliceA2] = setSpecialCardLabel(text: "3", cheight: cheight)
//		specialLabels[.olivieHP2] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.bahamutHP2] = setSpecialCardLabel(text: "13", cheight: cheight)
//		specialLabels[.aliceHP2] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.olivieA3] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.bahamutA3] = setSpecialCardLabel(text: "13", cheight: cheight)
//		specialLabels[.aliceA3] = setSpecialCardLabel(text: "3", cheight: cheight)
//		specialLabels[.olivieHP3] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.bahamutHP3] = setSpecialCardLabel(text: "13", cheight: cheight)
//		specialLabels[.aliceHP3] = setSpecialCardLabel(text: "4", cheight: cheight)
//		specialLabels[.luciferA] = setSpecialCardLabel(text: "6", cheight: cheight)
//		specialLabels[.luciferA2] = setSpecialCardLabel(text: "6", cheight: cheight)
//		specialLabels[.luciferA3] = setSpecialCardLabel(text: "6", cheight: cheight)
//		specialLabels[.luciferHP] = setSpecialCardLabel(text: "7", cheight: cheight)
//		specialLabels[.luciferHP2] = setSpecialCardLabel(text: "7", cheight: cheight)
//		specialLabels[.luciferHP3] = setSpecialCardLabel(text: "7", cheight: cheight)

	}
	
//	func setSpecialCardLabel(text:String,cheight:CGFloat) -> SKLabelNode {
//		let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
//
//		Label.text=text
//		Label.fontSize=cheight*11/138
//		Label.zPosition=2
////		self.addChild(Label) //表示される瞬間に行う
//		return Label
//	}
	
//	func setTPointLabelsText(){
//		for i in Game.cards{//初期値を設定
//			if i.card<53{//トランプ限定
//				tPointLabel[i.card-1].text=String(i.point)
//			}
//		}
//		for i in Game.pcards{
//			if i.card<53{
//				tPointLabel[i.card-1].text=String(i.point)
//			}
//		}
//		for i in Game.ccards{
//			if i.card<53{
//				tPointLabel[i.card-1].text=String(i.point)
//			}
//		}
//	}
	
//	func getSpecialLabels(cardNum:Int) -> ([SKLabelNode]){
//		guard cardNum > 52  && cardNum < 67 else {
//			print("getSpecialLabels error: cardNumに該当する特殊カードは存在しません")
//			return []
//		}
//
//		switch cardNum {
//		case 53:
//			return [specialLabels[.satanA]!, specialLabels[.satanHP]!]
//		case 54:
//			return [specialLabels[.olivieA]!, specialLabels[.olivieHP]!]
//		case 55:
//			return [specialLabels[.bahamutA]!, specialLabels[.bahamutHP]!]
//		case 56:
//			return [specialLabels[.zeusA]!, specialLabels[.zeusHP]!]
//		case 57:
//			return [specialLabels[.aliceA]!, specialLabels[.aliceHP]!]
//		case 58:
//			return [specialLabels[.olivieA2]!, specialLabels[.olivieHP2]!]
//		case 59:
//			return [specialLabels[.olivieA3]!, specialLabels[.olivieHP3]!]
//		case 60:
//			return [specialLabels[.bahamutA2]!, specialLabels[.bahamutHP2]!]
//		case 61:
//			return [specialLabels[.bahamutA3]!, specialLabels[.bahamutHP3]!]
//		case 62:
//			return [specialLabels[.aliceA2]!, specialLabels[.aliceHP2]!]
//		case 63:
//			return [specialLabels[.aliceA3]!, specialLabels[.aliceHP3]!]
//		case 64:
//			return [specialLabels[.luciferA]!, specialLabels[.luciferHP]!]
//		case 65:
//			return [specialLabels[.luciferA2]!, specialLabels[.luciferHP2]!]
//		case 66:
//			return [specialLabels[.luciferA3]!, specialLabels[.luciferHP3]!]
//		default:
//			print("getSpecialLabels error: cardNumに該当する特殊カードは存在しません")
//			return []
//		}
//	}
	
//	func updateSpecialLabelsPosition(){
//
//		if specialLabels.count>0{
//
//			specialLabels[.satanA]!.position=CGPoint(x:card[53].position.x-cwidth/2+cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
//			specialLabels[.satanHP]!.position=CGPoint(x:card[53].position.x+cwidth/2-cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
//			specialLabels[.olivieA]!.position=CGPoint(x:card[54].position.x-cwidth/2+cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
//			specialLabels[.olivieHP]!.position=CGPoint(x:card[54].position.x+cwidth/2-cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
//			specialLabels[.bahamutA]!.position=CGPoint(x:card[55].position.x-cwidth/2+cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
//			specialLabels[.bahamutHP]!.position=CGPoint(x:card[55].position.x+cwidth/2-cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
//			specialLabels[.zeusA]!.position=CGPoint(x:card[56].position.x-cwidth/2+cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
//			specialLabels[.zeusHP]!.position=CGPoint(x:card[56].position.x+cwidth/2-cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
//			specialLabels[.aliceA]!.position=CGPoint(x:card[57].position.x-cwidth/2+cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
//			specialLabels[.aliceHP]!.position=CGPoint(x:card[57].position.x+cwidth/2-cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
//			specialLabels[.olivieA2]!.position=CGPoint(x:card[58].position.x-cwidth/2+cheight*11/138,y:card[58].position.y-cheight/2+cheight*8/138)
//			specialLabels[.olivieHP2]!.position=CGPoint(x:card[58].position.x+cwidth/2-cheight*11/138,y:card[58].position.y-cheight/2+cheight*8/138)
//			specialLabels[.bahamutA2]!.position=CGPoint(x:card[60].position.x-cwidth/2+cheight*11/138,y:card[60].position.y-cheight/2+cheight*8/138)
//			specialLabels[.bahamutHP2]!.position=CGPoint(x:card[60].position.x+cwidth/2-cheight*11/138,y:card[60].position.y-cheight/2+cheight*8/138)
//			specialLabels[.aliceA2]!.position=CGPoint(x:card[62].position.x-cwidth/2+cheight*11/138,y:card[62].position.y-cheight/2+cheight*8/138)
//			specialLabels[.aliceHP2]!.position=CGPoint(x:card[62].position.x+cwidth/2-cheight*11/138,y:card[62].position.y-cheight/2+cheight*8/138)
//			specialLabels[.olivieA3]!.position=CGPoint(x:card[59].position.x-cwidth/2+cheight*11/138,y:card[59].position.y-cheight/2+cheight*8/138)
//			specialLabels[.olivieHP3]!.position=CGPoint(x:card[59].position.x+cwidth/2-cheight*11/138,y:card[59].position.y-cheight/2+cheight*8/138)
//			specialLabels[.bahamutA3]!.position=CGPoint(x:card[61].position.x-cwidth/2+cheight*11/138,y:card[61].position.y-cheight/2+cheight*8/138)
//			specialLabels[.bahamutHP3]!.position=CGPoint(x:card[61].position.x+cwidth/2-cheight*11/138,y:card[61].position.y-cheight/2+cheight*8/138)
//			specialLabels[.aliceA3]!.position=CGPoint(x:card[63].position.x-cwidth/2+cheight*11/138,y:card[63].position.y-cheight/2+cheight*8/138)
//			specialLabels[.aliceHP3]!.position=CGPoint(x:card[63].position.x+cwidth/2-cheight*11/138,y:card[63].position.y-cheight/2+cheight*8/138)
//			specialLabels[.luciferA]!.position=CGPoint(x:card[64].position.x-cwidth/2+cheight*11/138,y:card[64].position.y-cheight/2+cheight*8/138)
//			specialLabels[.luciferHP]!.position=CGPoint(x:card[64].position.x+cwidth/2-cheight*11/138,y:card[64].position.y-cheight/2+cheight*8/138)
//			specialLabels[.luciferA2]!.position=CGPoint(x:card[65].position.x-cwidth/2+cheight*11/138,y:card[65].position.y-cheight/2+cheight*8/138)
//			specialLabels[.luciferHP2]!.position=CGPoint(x:card[65].position.x+cwidth/2-cheight*11/138,y:card[65].position.y-cheight/2+cheight*8/138)
//			specialLabels[.luciferA3]!.position=CGPoint(x:card[66].position.x-cwidth/2+cheight*11/138,y:card[66].position.y-cheight/2+cheight*8/138)
//			specialLabels[.luciferHP3]!.position=CGPoint(x:card[66].position.x+cwidth/2-cheight*11/138,y:card[66].position.y-cheight/2+cheight*8/138)
//
//
//		}
//	}
	
//	func specialLabelsAddChildren(cardNum:Int ,player:Player) {
//		guard cardNum > 52 else {
//			return
//		}
//		
//		let labels = getSpecialLabels(cardNum: cardNum)
//		for i in labels{
//			if player == .p1{
//				self.pScrollNode.contentNode.addChild(i)
//			}else{
//				self.cScrollNode.contentNode.addChild(i)
//			}
//		}
//		
//	}
	
	
}
