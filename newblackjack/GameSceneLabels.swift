//
//  Labbels.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/08/24.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit

extension GameScene{//labelに関する拡張
	
	func setLabels(frame_height:CGFloat,frame_width:CGFloat){
		
		let cheight = frame_height/3	//カードの縦の長さは画面サイズによって変わる。7+で138?
		
		if Cards.mode == .scom{
			pBPLabel = {() -> SKLabelNode in  //設定先を誤るミスを防ぐため、クロージャーで設定
				let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
				Label.fontSize = cheight*30/138
				Label.horizontalAlignmentMode = .left
				Label.position = CGPoint(x:frame_width/2, y:cheight+cheight*5/138)
				Label.text = "×"+String(Cards.pBP)
				self.addChild(Label)
				return Label
			}()
			
			cBPLabel = {() -> SKLabelNode in
				let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
				Label.fontSize = cheight*30/138
				Label.horizontalAlignmentMode = .left
				Label.position=CGPoint(x:frame_width/2, y:frame_height-(cheight+cheight*30/138))
				Label.text="×"+String(Cards.cBP)
				self.addChild(Label)
				return Label
			}()
		}
		
		//両者の得点表示のラベル
		ppLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = cheight*30/138
			Label.horizontalAlignmentMode = .left	//左寄せ
			if Cards.mode == .netp2 {
				Label.position = CGPoint(x:0, y:(frame_height)-cheight-cheight*30/138)
			}else{
				Label.position = CGPoint(x:0, y:cheight+cheight*5/138)
			}

			self.addChild(Label)
			return Label
		}()

		cpLabel = {() -> SKLabelNode in//ディーラーの得点
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.fontSize = cheight*30/138
			Label.horizontalAlignmentMode = .left
			if Cards.mode == .netp2{
				Label.position = CGPoint(x:0, y:cheight+cheight*5/138)
			}else{
				Label.position = CGPoint(x:0, y:(frame_height)-cheight-cheight*30/138)
			}
			
			Label.isHidden=true
			self.addChild(Label)
			return Label
		}()

		//両者のbj表示用のラベル
		pbjLabel = {() -> SKLabelNode in
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
			self.addChild(Label)
			return Label
		}()

		cbjLabel = {() -> SKLabelNode in
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
			self.addChild(Label)
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
			self.addChild(i)
		}
		
		//ターンを表示
		centerLabel = {() -> SKLabelNode in
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
			self.addChild(Label)
			return Label
		}()
		
		//対戦者表示のラベル
		p1Label = {() -> SKLabelNode in
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
			self.addChild(Label)
			return Label
		}()
		
		comLabel = {() -> SKLabelNode in
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
			self.addChild(Label)
			return Label
		}()
		
		//攻撃力と体力のラベルの設定
		
		specialLabels[.satanA] = setSpecialCardLabel(text: "6", cheight: cheight)
		specialLabels[.olivieA] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.bahamutA] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels[.zeusA] = setSpecialCardLabel(text: "5", cheight: cheight)
		specialLabels[.aliceA] = setSpecialCardLabel(text: "3", cheight: cheight)
		specialLabels[.satanHP] = setSpecialCardLabel(text: "6", cheight: cheight)
		specialLabels[.olivieHP] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.bahamutHP] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels[.zeusHP] = setSpecialCardLabel(text: "10", cheight: cheight)
		specialLabels[.aliceHP] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.olivieA2] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.bahamutA2] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels[.aliceA2] = setSpecialCardLabel(text: "3", cheight: cheight)
		specialLabels[.olivieHP2] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.bahamutHP2] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels[.aliceHP2] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.olivieA3] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.bahamutA3] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels[.aliceA3] = setSpecialCardLabel(text: "3", cheight: cheight)
		specialLabels[.olivieHP3] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.bahamutHP3] = setSpecialCardLabel(text: "13", cheight: cheight)
		specialLabels[.aliceHP3] = setSpecialCardLabel(text: "4", cheight: cheight)
		specialLabels[.luciferA] = setSpecialCardLabel(text: "6", cheight: cheight)
		specialLabels[.luciferA2] = setSpecialCardLabel(text: "6", cheight: cheight)
		specialLabels[.luciferA3] = setSpecialCardLabel(text: "6", cheight: cheight)
		specialLabels[.luciferHP] = setSpecialCardLabel(text: "7", cheight: cheight)
		specialLabels[.luciferHP2] = setSpecialCardLabel(text: "7", cheight: cheight)
		specialLabels[.luciferHP3] = setSpecialCardLabel(text: "7", cheight: cheight)

	}
	
	func setSpecialCardLabel(text:String,cheight:CGFloat) -> SKLabelNode {
		let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
		
		Label.text=text
		Label.fontSize=cheight*11/138
		Label.zPosition=2
		self.addChild(Label)
		return Label
	}
	
	func setTPointLabelsText(){
		for i in Cards.cards{//初期値を設定
			if i.card<53{//トランプ限定
				tPointLabel[i.card-1].text=String(i.point)
			}
		}
		for i in Cards.pcards{
			if i.card<53{
				tPointLabel[i.card-1].text=String(i.point)
			}
		}
		for i in Cards.ccards{
			if i.card<53{
				tPointLabel[i.card-1].text=String(i.point)
			}
		}
	}
	
	func updateSpecialLabelsPosition(cheight:CGFloat){
		let cwidth = cheight*2/3
		
		if specialLabels.count>0{
			
			specialLabels[.satanA]!.position=CGPoint(x:card[53].position.x-cwidth/2+cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
			specialLabels[.satanHP]!.position=CGPoint(x:card[53].position.x+cwidth/2-cheight*11/138,y:card[53].position.y-cheight/2+cheight*8/138)
			specialLabels[.olivieA]!.position=CGPoint(x:card[54].position.x-cwidth/2+cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
			specialLabels[.olivieHP]!.position=CGPoint(x:card[54].position.x+cwidth/2-cheight*11/138,y:card[54].position.y-cheight/2+cheight*8/138)
			specialLabels[.bahamutA]!.position=CGPoint(x:card[55].position.x-cwidth/2+cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
			specialLabels[.bahamutHP]!.position=CGPoint(x:card[55].position.x+cwidth/2-cheight*11/138,y:card[55].position.y-cheight/2+cheight*8/138)
			specialLabels[.zeusA]!.position=CGPoint(x:card[56].position.x-cwidth/2+cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
			specialLabels[.zeusHP]!.position=CGPoint(x:card[56].position.x+cwidth/2-cheight*11/138,y:card[56].position.y-cheight/2+cheight*8/138)
			specialLabels[.aliceA]!.position=CGPoint(x:card[57].position.x-cwidth/2+cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
			specialLabels[.aliceHP]!.position=CGPoint(x:card[57].position.x+cwidth/2-cheight*11/138,y:card[57].position.y-cheight/2+cheight*8/138)
			specialLabels[.olivieA2]!.position=CGPoint(x:card[58].position.x-cwidth/2+cheight*11/138,y:card[58].position.y-cheight/2+cheight*8/138)
			specialLabels[.olivieHP2]!.position=CGPoint(x:card[58].position.x+cwidth/2-cheight*11/138,y:card[58].position.y-cheight/2+cheight*8/138)
			specialLabels[.bahamutA2]!.position=CGPoint(x:card[60].position.x-cwidth/2+cheight*11/138,y:card[60].position.y-cheight/2+cheight*8/138)
			specialLabels[.bahamutHP2]!.position=CGPoint(x:card[60].position.x+cwidth/2-cheight*11/138,y:card[60].position.y-cheight/2+cheight*8/138)
			specialLabels[.aliceA2]!.position=CGPoint(x:card[62].position.x-cwidth/2+cheight*11/138,y:card[62].position.y-cheight/2+cheight*8/138)
			specialLabels[.aliceHP2]!.position=CGPoint(x:card[62].position.x+cwidth/2-cheight*11/138,y:card[62].position.y-cheight/2+cheight*8/138)
			specialLabels[.olivieA3]!.position=CGPoint(x:card[59].position.x-cwidth/2+cheight*11/138,y:card[59].position.y-cheight/2+cheight*8/138)
			specialLabels[.olivieHP3]!.position=CGPoint(x:card[59].position.x+cwidth/2-cheight*11/138,y:card[59].position.y-cheight/2+cheight*8/138)
			specialLabels[.bahamutA3]!.position=CGPoint(x:card[61].position.x-cwidth/2+cheight*11/138,y:card[61].position.y-cheight/2+cheight*8/138)
			specialLabels[.bahamutHP3]!.position=CGPoint(x:card[61].position.x+cwidth/2-cheight*11/138,y:card[61].position.y-cheight/2+cheight*8/138)
			specialLabels[.aliceA3]!.position=CGPoint(x:card[63].position.x-cwidth/2+cheight*11/138,y:card[63].position.y-cheight/2+cheight*8/138)
			specialLabels[.aliceHP3]!.position=CGPoint(x:card[63].position.x+cwidth/2-cheight*11/138,y:card[63].position.y-cheight/2+cheight*8/138)
			
			
		}
	}
	
	
	
}
