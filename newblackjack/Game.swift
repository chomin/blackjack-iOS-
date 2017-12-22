//
//  getcards.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/06.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import UIKit

enum gameState {
	case end,waiting,start,ready,p1turn,p2turn,judge,br
}
enum gameMode {
	case com,pvp,netp1,netp2,scom,spvp,snetp1,snetp2
}

class Game{	//カードや得点の管理、勝敗判定などを行うクラス
	
	//クラスプロパティ（クラス自身が保持する値）
	static var pcards:[Card] = []	//手札(各カードは1から52の通し番号)
	static var ccards:[Card] = []
	static var deckCards:[Card] = []   //(山札,得点)
	static var state:gameState = .end	  //end,waiting（1人が待っている状態）,start(配り終えた情報を送信するまで),ready(配り終えた情報を相手が受信するまで),p1turn,p2turn,judge,endと推移
	static var mode:gameMode = .com	//com,pvp,netp1,netp2,scom(shadowjackモード),spvp,snetp1,snetp2
	static var pBP = 0
	static var cBP = 0
	static var pPoint = 0
	static var cPoint = 0
	static var cardSum = 0  //カードの合計枚数
	static var maxCardVariety = 0	//カードの種類
	static var firstDealed = false
	static var adjustPoints:(pp:Int, cp:Int) = (0, 0)
	
	@discardableResult	//結果を使わなくてもいいよ
	func setCards() -> (pcards:[Card], ccards:[Card], pp:String, cp:String){
		Game.cardSum = 0
		
		if Game.mode == .com || Game.mode == .pvp || Game.mode == .netp1 || Game.mode == .netp2{
			Game.maxCardVariety = 52
		}else{
			Game.maxCardVariety = 60
		}

		for i in 1...Game.maxCardVariety{
			
			if i==53 || i==56{//サタンとゼウスは禁止カード
				continue
			}
			
			
			
			if i<53{

				Game.deckCards.append(Trump(cardNum: i)!)
				Game.cardSum += 1

			}else{//特殊カード
				
				for _ in 1...4{
					Game.deckCards.append(SpecialCard(cardNum: i)!)
					Game.cardSum += 1
				}
			}
		}
		

		
		
		//Fisher–Yatesシャッフルアルゴルズム
		for i in 0...Game.cardSum-1{
			let j = Int(arc4random_uniform(UInt32(Game.cardSum-1)))%Game.cardSum  //上限をつけないとiPhone5では動かない。。。
			let t = Game.deckCards[i]
			Game.deckCards[i] = Game.deckCards[j]
			Game.deckCards[j] = t
		}

		
		
		//カードを配る
		self.pHit()
		self.pHit()
		self.cHit()
		self.cRecversedHit()
		
		let (pp,cp) = getpoints()
		
		
		return (Game.pcards, Game.ccards, pp!, cp!)
	}
	
	func getpoints() ->(pp:String?,cp:String?){
		
		let (ppoint,cpoint,_,_) = calculatepoints()
		//ppoint,cpointはそれぞれ(noA:Int,inA:Int)、pAとcAはAを持っているか(Bool)
		
		//得点をcp,ppにまとめた後、ラベルに表示（ラベルはオプショナルだから足し算できない）
		var cp,pp:String
		
		cp=String(cpoint.noA)
		if cpoint.noA>21{
			cp+=" Bust!!"
		}
		
		pp=String(ppoint.noA)
		if ppoint.noA>21{
			pp+=" Bust!!"
		}
		
		return (pp,cp)
		
	}//ラベル用のポイントを返す
	
	@discardableResult
	func pHit() -> (pcards:[Card],pp:String){//pcardsにcards[0]を配る
		
		Game.pcards.append(Game.deckCards[0])
		Game.deckCards.removeFirst()
		
		//描写予約及びファンファーレ、場のエフェクト
		if Game.pcards.last! is Trump{//トランプ
			
			GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(Game.pcards.count-1), y: GameScene.cheight/2, card: Game.pcards.last!)
			
		}else if let SC = Game.pcards.last! as? SpecialCard{//引いたのが特殊カード
			
			SC.fanfare(cardPlace: .p1, index: Game.pcards.count-1)
		}
		
		for j in Game.pcards{//場にある分の効果を確認
			guard j !== Game.pcards.last! else{//最後に引いたものは除く
				break
			}
			
			if let SC2 = j as? SpecialCard{
				SC2.drawEffect(drawPlayer: .p1)
			}
		}
		for j in Game.ccards{//場にある分の効果を確認
			if let SC2 = j as? SpecialCard{
				SC2.drawEffect(drawPlayer: .p1)
			}
		}
		
		let (pp,_)=getpoints()
		return (Game.pcards, pp!)
	}
	
	@discardableResult
	func cHit() -> (ccards:[Card],cp:String){
		Game.ccards.append(Game.deckCards[0])
		Game.deckCards.removeFirst()
		
		if Game.ccards.last! is Trump{
			GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth*CGFloat(Game.ccards.count-1), y: GameScene.frameHeight-GameScene.cheight/2, card: Game.ccards.last!)
			
		}else if let SC =  Game.ccards.last! as? SpecialCard{
			
			SC.fanfare(cardPlace: .com, index: Game.ccards.count-1)
		}
		for j in Game.pcards{//場にある分の効果を確認
			if let SC2 = j as? SpecialCard{
				SC2.drawEffect(drawPlayer: .com)
			}
		}
		for j in Game.ccards{//場にある分の効果を確認
			guard j !== Game.ccards.last! else{//最後に引いたものは除く
				break
			}
			if let SC2 = j as? SpecialCard{
				SC2.drawEffect(drawPlayer: .com)
			}
		}
		
		
		let (_,cp)=getpoints()
		return (Game.ccards, cp!)
		
	}
	
	func cRecversedHit(){
		Game.ccards.append(Game.deckCards[0])
		Game.deckCards.removeFirst()
		GameScene.makePaintResevation(sound: .card, x: GameScene.cwidth/2+GameScene.cwidth, y: GameScene.frameHeight-GameScene.cheight/2, card: GameScene.backCard)
		Game.ccards.last!.isReversed = true
	}
	
	func judge(_ i:Int) -> Int{
		//iを0で受けるとBJの判定を行い、他で受けると行わない
		
		//		0:同数
		//		1:pが多い
		//		2:cが多い
		//		3:pが勝ち
		//		4:cが勝ち
		//		5:引き分け
		
		let (ppoint,cpoint,pA,cA)=calculatepoints()
		
		//BJの判定
		if i==0{
			if ppoint.noA==21 && pA==true && cpoint.noA==21 && cA==true{
				return 5
			}else if ppoint.noA==21 && pA==true{
				return 3
			}else if cpoint.noA==21 && cA==true{
				return 4
			}
		}
		
		//バスト判定
		if ppoint.noA > 21{
			return 4
		}
		
		if cpoint.noA > 21{
			return 3
		}
		
		//得点判定
		if ppoint.inA<22 && pA==true{
			if cpoint.inA<22 && cA==true{
				if ppoint.inA>cpoint.inA {
					return 1
				}else if ppoint.inA<cpoint.inA{
					return 2
				}else{
					return 0
				}
			}else{
				if ppoint.inA>cpoint.noA {
					return 1
				}else if ppoint.inA<cpoint.noA{
					return 2
				}else{
					return 0
				}
			}
		}else{
			if cpoint.inA<22 && cA==true{
				if ppoint.noA>cpoint.inA {
					return 1
				}else if ppoint.noA<cpoint.inA{
					return 2
				}else{
					return 0
				}
			}else{
				if ppoint.noA>cpoint.noA {
					return 1
				}else if ppoint.noA<cpoint.noA{
					return 2
				}else{
					return 0
				}
			}
		}
	}
	
	func calculatepoints() -> (pp:(noA:Int,inA:Int),cp:(noA:Int,inA:Int),pA:Bool,cA:Bool){
		
		//初期化
		var ppoint=(noA:0,inA:10)
		var cpoint=(noA:0,inA:10)//inAは、もし今のポイントに、更に１０点加えたら...の値
		
		for i in Game.pcards{
				ppoint.inA+=i.point
				ppoint.noA+=i.point
		}
		for i in Game.ccards{
				cpoint.inA+=i.point
				cpoint.noA+=i.point
		}
		
		ppoint.inA += Game.adjustPoints.pp
		ppoint.noA += Game.adjustPoints.pp
		cpoint.inA += Game.adjustPoints.cp
		cpoint.noA += Game.adjustPoints.cp
		
		if ppoint.inA < 0{
			ppoint.inA = 0
		}
		if ppoint.noA < 0{
			ppoint.noA = 0
		}
		if cpoint.inA < 0{
			cpoint.inA = 0
		}
		if cpoint.noA < 0{
			cpoint.noA = 0
		}
		
		//Aを持っているかの判定
		var pA = false, cA = false
		for i in Game.pcards{
			if i.cardNum % 13 == 1 && i.cardNum < 53{
				pA = true
			}
		}
		for i in Game.ccards{
			if i.cardNum % 13 == 1 && i.cardNum < 53{
				cA = true
			}
		}
		
		return (ppoint,cpoint,pA,cA)
	
	}
	
	
}
