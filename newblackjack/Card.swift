//
//  Card.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/12/05.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import SpriteKit

enum CardPlace {
	case deck, p1, com
}

class Trump:Card{
	var pointLabel:SKLabelNode
	
	override init?(cardNum: Int) {
		guard cardNum <= 52 && cardNum > 0 else {
			print("cardNum不正のためトランプの初期化に失敗:\(cardNum)")
			return nil
		}
		
		self.pointLabel = {() -> SKLabelNode in
			let label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			label.fontSize = GameScene.cheight*16/138
			label.position = CGPoint(x:0,y:10000)
			label.zPosition = 2
			label.fontColor = SKColor.white
			return label
		}()
		
		super.init(cardNum: cardNum)
		
		self.pointLabel.text = String(self.initialPoint)
		
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func update(){
		
		//ラベルの位置を連動
		let x = self.image.position.x+GameScene.cwidth/2-GameScene.cheight*16/138
		let y = self.image.position.y+GameScene.cheight/2-GameScene.cheight*28/138
		self.pointLabel.position = CGPoint(x:x, y:y)
	}
}

class SpecialCard:Card{
	var attackLabel:SKLabelNode
	var hpLabel:SKLabelNode
	var attack:Int
	var hp:Int
	
	override init?(cardNum: Int) {
		guard cardNum > 52 else {
			print("cardNum不正のため特殊カードの初期化に失敗:\(cardNum)")
			return nil
		}
		
		switch cardNum {
		case 53://サタ
			self.attack = 6
			self.hp = 6
		case 54://オリ
			self.attack = 4
			self.hp = 4
		case 55://バハ
			self.attack = 13
			self.hp = 13
		case 56://ゼウス
			self.attack = 5
			self.hp = 10
		case 57://アリス
			self.attack = 3
			self.hp = 4
		case 58://ルシフェル
			self.attack = 6
			self.hp = 7
		case 59://bb
			self.attack = 5
			self.hp = 6
		case 60://ダリス
			self.attack = 5
			self.hp = 5
		default:
			print("attack,hpのセットエラー:\(cardNum)")
			return nil
		}
		
		let at = self.attack	//クロージャ内ではsuper.init()前にself.~を使えない
		let h = self.hp
		
		self.attackLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.text = String(at)
			Label.fontSize = GameScene.cheight*11/138
			Label.zPosition = 2
			//		self.addChild(Label) //表示される瞬間に行う
			return Label
			
		}()
		
		self.hpLabel = {() -> SKLabelNode in
			let Label = SKLabelNode(fontNamed: "HiraginoSans-W6")
			
			Label.text = String(h)
			Label.fontSize = GameScene.cheight*11/138
			Label.zPosition = 2
			//		self.addChild(Label) //表示される瞬間に行う
			return Label
			
		}()
		
		super.init(cardNum: cardNum)
	}
	
	
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func update(){
		//ラベルの位置を連動
		let x1 = self.image.position.x-GameScene.cwidth/2+GameScene.cheight*11/138
		let x2 = self.image.position.x+GameScene.cwidth/2-GameScene.cheight*11/138
		
		self.attackLabel.position = CGPoint(x:x1, y:self.image.position.y-GameScene.cheight/2+GameScene.cheight*8/138)
		self.hpLabel.position = CGPoint(x:x2, y:self.image.position.y-GameScene.cheight/2+GameScene.cheight*8/138)
	}
	
	func fanfare(cardPlace: CardPlace, index: Int){//登場音の予約と効果の発動
		
		guard cardPlace != .deck else {
			print("カードが配られていません")
			return
		}
		
		
		self.cardPlace = cardPlace
		
		switch cardNum {
		case 53:
			print("アポカリプスデッキに変更（未実装）")
			if cardPlace == .p1{
				GameScene.makePaintResevation(sound: .satanIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: self)
			}else {
				GameScene.makePaintResevation(sound: .satanIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.frameHeight - GameScene.cheight/2, card: self)
			}
			
		case 54://オリヴィエ
			if self.cardPlace == .p1{
				Game.pBP = 3
				GameScene.makeOlivieResevation(x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: self, BPLabel: (pBP: "3", cBP: nil))
			}else if self.cardPlace == .com{
				Game.cBP = 3
				GameScene.makeOlivieResevation(x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y:GameScene.frameHeight-GameScene.cheight/2, card: self, BPLabel: (pBP: nil, cBP: "3"))
			}else{
				print("cardPlaceが更新されていません:\(cardPlace)")
			}
			
		case 55://バハ
			if cardPlace == .p1{
				GameScene.makePaintResevation(sound: .bahamutIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: self)
			}else {
				GameScene.makePaintResevation(sound: .bahamutIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.frameHeight - GameScene.cheight/2, card: self)
			}
			if Game.firstDealed{
				//破壊と移動
				var hideCards:[Card] = [GameScene.backCard]
				var repaintCards:[(x:CGFloat, y:CGFloat, card:Card)] = []
				var repaintPCardNum = 0
				var repaintCCardNum = 0
				var pcardsRemoveIndexes:[Int] = []
				var ccardsRemoveIndexes:[Int] = []
				
				//ルシフェル調整点数を初期化
				Game.adjustPoints = (0, 0)
				
				if self.cardPlace == .p1{//ラスワの発動はバハムートを引いた側から
					for (index, value) in Game.pcards.enumerated(){
						if value !== self as Card && value.canBeBroken {
							
							hideCards.append(value)
							//						Game.pcards.remove(at: index)	//個数が変わる！
							pcardsRemoveIndexes.append(index)
						}else{//残ったものの位置を更新
							repaintCards.append((GameScene.cwidth/2 + CGFloat(repaintPCardNum)*GameScene.cwidth, GameScene.cheight/2, value))
							repaintPCardNum += 1
						}
					}
					for(index, value) in Game.ccards.enumerated(){
						if value !== self as Card && value.canBeBroken {
							
							hideCards.append(value)
							//						Game.ccards.remove(at: index)
							ccardsRemoveIndexes.append(index)
						}else{
							repaintCards.append((GameScene.cwidth/2 + CGFloat(repaintCCardNum)*GameScene.cwidth, GameScene.frameHeight - GameScene.cheight/2, value))
							repaintCCardNum += 1
						}
					}
				}else if self.cardPlace == .com{
					for(index, value) in Game.ccards.enumerated(){
						if value !== self as Card && value.canBeBroken {
							
							hideCards.append(value)
							//						Game.ccards.remove(at: index)
							ccardsRemoveIndexes.append(index)
						}else{
							repaintCards.append((GameScene.cwidth/2 + CGFloat(repaintCCardNum)*GameScene.cwidth, GameScene.frameHeight - GameScene.cheight/2, value))
							repaintCCardNum += 1
						}
					}
					for (index, value) in Game.pcards.enumerated(){
						if value !== self as Card && value.canBeBroken {
							
							hideCards.append(value)
							//						Game.pcards.remove(at: index)	//個数が変わる！
							pcardsRemoveIndexes.append(index)
						}else{//残ったものの位置を更新
							repaintCards.append((GameScene.cwidth/2 + CGFloat(repaintPCardNum)*GameScene.cwidth, GameScene.cheight/2, value))
							repaintPCardNum += 1
						}
					}
				}
				
				//対象カードを破壊
				for (index,value) in pcardsRemoveIndexes.enumerated(){
					Game.pcards.remove(at: value - index)
				}
				for (index,value) in ccardsRemoveIndexes.enumerated(){
					Game.ccards.remove(at: value - index)
				}
				
				GameScene.resevation.append((sound: .br, paint:[], repaint:repaintCards, hide: hideCards, pointLabels: Game().getpoints(), tPointLabels: [], BPLabels: (pBP: nil, cBP: nil)))
				
				//全破壊の後、ラストワード発動
				for i in hideCards{
					if let SC = i as? SpecialCard{
						SC.lastWord()
					}
				}
			
			}
			
		case 56://ゼウス
			if cardPlace == .p1{
				GameScene.makePaintResevation(sound: .zeusIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: self)
			}else {
				GameScene.makePaintResevation(sound: .zeusIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.frameHeight - GameScene.cheight/2, card: self)
			}
		
		case 57://アリス
			if cardPlace == .p1{
				var changeTPLabels:[(card: Card, value: String, color: UIColor?)] = []
				for i in Game.pcards{
					if let a = i as? Trump{
						a.point += 1
						changeTPLabels.append((card: a, value: String(a.point), color: UIColor.orange))
					}
				}
				
				GameScene.makeAliceResevation(x: GameScene.cwidth/2 + CGFloat(index)*GameScene.cwidth, y: GameScene.cheight/2, card: self, tPointLabel: changeTPLabels)
			}else{
				var changeTPLabels:[(card: Card, value: String, color: UIColor?)] = []
				for i in Game.ccards{
					if let a = i as? Trump{
						a.point += 1
						changeTPLabels.append((card: a, value: String(a.point), color: UIColor.orange))
					}
				}
				
				GameScene.makeAliceResevation(x: GameScene.cwidth/2 + CGFloat(index)*GameScene.cwidth, y: GameScene.frameHeight - GameScene.cheight/2, card: self, tPointLabel: changeTPLabels)
			}
			
		case 58://ルシフェル
			if cardPlace == .p1{
				GameScene.makePaintResevation(sound: .luciferIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: self)
			}else {
				GameScene.makePaintResevation(sound: .luciferIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.frameHeight - GameScene.cheight/2, card: self)
			}
			
		case 59://bb
			if cardPlace == .p1{
				GameScene.makePaintResevation(sound: .bbIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: self)
			}else {
				GameScene.makePaintResevation(sound: .bbIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.frameHeight - GameScene.cheight/2, card: self)
			}
			
			self.attack += 2
			self.hp += 2
			self.attackLabel.text = String(self.attack)
			self.attackLabel.fontColor = .green
			self.hpLabel.text = String(self.hp)
			self.hpLabel.fontColor = .green
			
			self.canBeBroken = false
			
		case 60://ダリス
			if cardPlace == .p1{
				GameScene.makePaintResevation(sound: .daliceIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.cheight/2, card: self)
			}else {
				GameScene.makePaintResevation(sound: .daliceIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(index), y: GameScene.frameHeight - GameScene.cheight/2, card: self)
			}
			
		default:
			print("該当する特殊カードがありませんat fanfare:\(cardNum)")
			
		}
	}
	
	func lastWord(){
		switch cardNum {
		case 60://ダリス
			//（相手を含めて）残っているカードをすべて消滅させる(自身は破壊されてるのでないはず)
			var hideCards:[Card] = []
			var pcardsRemoveIndexes:[Int] = []
			var ccardsRemoveIndexes:[Int] = []
			
			for (index, value) in Game.pcards.enumerated(){
				hideCards.append(value)
				pcardsRemoveIndexes.append(index)
			}
			for (index, value) in Game.ccards.enumerated(){
				hideCards.append(value)
				ccardsRemoveIndexes.append(index)
			}
			
			GameScene.makeDaliceLastResevation(hide: hideCards)
			
			for (index,value) in pcardsRemoveIndexes.enumerated(){
				Game.pcards.remove(at: value - index)
			}
			for (index,value) in ccardsRemoveIndexes.enumerated(){
				Game.ccards.remove(at: value - index)
			}
			
			//ダリスを新たに召喚（これ自体を追加すると2重append。文章的にも新たに召喚するのが正しい）(makeDaliceLastResevationに記述)
			//新しいダリスを生成
			let newDalice = SpecialCard(cardNum: 60)!
			if self.cardPlace == .p1{
				Game.pcards.append(newDalice)
				newDalice.cardPlace = .p1
				GameScene.makePaintResevation(sound: .daliceIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(Game.pcards.count-1), y: GameScene.cheight/2, card: newDalice)//count関係の順番に注意
				
			}else{
				Game.ccards.append(newDalice)
				newDalice.cardPlace = .com
				GameScene.makePaintResevation(sound: .daliceIn, x: GameScene.cwidth/2 + GameScene.cwidth*CGFloat(Game.ccards.count-1), y: GameScene.frameHeight - GameScene.cheight/2, card: newDalice)//count関係の順番に注意
				
			}
			
			
		default:
			print("ラストワードが設定されていません")
		}
	}
	
	func drawEffect(drawPlayer: CardPlace){//ドローし、ドローしたカードのファンファーレ効果後に呼び出す（場にある分の効果）
		switch cardNum {
		case 57://アリス
			if self.cardPlace == .p1 && drawPlayer == .p1{
				if let a = Game.pcards.last as? Trump{
					a.point += 1
					GameScene.resevation.append((sound: .debuffField, paint: [], repaint: [], hide: [], pointLabels: Game().getpoints(), tPointLabels: [(card: a, value: String(a.point), color: .orange)], BPLabels: (pBP: nil, cBP: nil)))
				}
			}else if self.cardPlace == .com && drawPlayer == .com{
				if let a = Game.ccards.last as? Trump{
					a.point += 1
					GameScene.resevation.append((sound: .debuffField, paint: [], repaint: [], hide: [], pointLabels: Game().getpoints(), tPointLabels: [(card: a, value: String(a.point), color: .orange)], BPLabels: (pBP: nil, cBP: nil)))
				}
			}
			
			
		default: break
//			print("ドロー時に発動する効果はありません")
		}
	}
	
	func bustEffect(bustPlayer: CardPlace)  {//bustした時に呼び出す（場にある分の効果）
		
		guard bustPlayer != .deck else {
			print("bustEffectを発動するカードが配られていません")
			return
		}
		
		switch cardNum {
		case 58://ルシフェル
			if self.cardPlace == bustPlayer{
				if self.cardPlace == .p1{
					Game.adjustPoints.pp -= 4
				}else if self.cardPlace == .com{
					Game.adjustPoints.cp -= 4
				}else{
					print("ルシフェルが配られていません@bustEffect")
				}
				
				GameScene.makeLuciferCureResevation()
			}
			
		default:
			print("bust時に発動する効果はありません")
		}
	}
}

class Card{//
	let cardNum:Int
	var point:Int
	let initialPoint:Int
	let image:SKSpriteNode
	var cardPlace:CardPlace
	var canBeBroken:Bool
	var isReversed:Bool	//バハの確認に必要
	
	
	init?(cardNum:Int) {
		guard cardNum >= 0 else {
			print("cardNum不正のためCardの初期化に失敗:\(cardNum)")
			return nil
		}
		
		self.canBeBroken = true
		self.isReversed = false
		self.cardPlace = .deck
		self.cardNum = cardNum
		
		if cardNum == 0 {//裏面
			self.image = SKSpriteNode(imageNamed: "z02")
			self.point = 0
			self.initialPoint = 0
			
		}else	if cardNum < 53 && cardNum > 0{//トランプ
			
			switch cardNum{
			case 1...13:
				self.image = SKSpriteNode(imageNamed: "c\(cardNum)-1")
			case 14...26:
				self.image = SKSpriteNode(imageNamed: "d\(cardNum - 13)-1")
			case 27...39:
				self.image = SKSpriteNode(imageNamed: "h\(cardNum - 26)-1")
			case 40...52:
				self.image = SKSpriteNode(imageNamed: "s\(cardNum - 39)-1")
			default:
				print("トランプ画像のルーティングエラー:\(cardNum)")
				return nil
			}
			
			if (cardNum-1)%13 > 8{	//10,J,Q,Kのとき
				self.point = 10
				self.initialPoint = 10
			}else{
				self.point = cardNum % 13
				self.initialPoint = cardNum % 13
			}
		}else{//特殊カード
			
			switch cardNum{
			case 53:
				self.point = 10
				self.initialPoint = 10
				self.image = SKSpriteNode(imageNamed: "Satan")
			case 54:
				self.point = 9
				self.initialPoint = 9
				self.image = SKSpriteNode(imageNamed: "Olivie")
			case 55:
				self.point = 10
				self.initialPoint = 10
				self.image = SKSpriteNode(imageNamed: "Bahamut")
			case 56:
				self.point = 10
				self.initialPoint = 10
				self.image = SKSpriteNode(imageNamed: "Zeus")
			case 57:
				self.point = 4
				self.initialPoint = 4
				self.image = SKSpriteNode(imageNamed: "Alice")
			case 58:
				self.point = 8
				self.initialPoint = 8
				self.image = SKSpriteNode(imageNamed: "Lucifer")
			case 59:
				self.point = 6
				self.initialPoint = 6
				self.image = SKSpriteNode(imageNamed: "BB")
			case 60:
				self.point = 7
				self.initialPoint = 7
				self.image = SKSpriteNode(imageNamed: "Dalice")
			default:
				print("特殊カード画像のルーティングエラー:\(cardNum)")
				return nil
			}
			
			
		}
		
		let j = self.image
		if GameScene.cwidth != nil{
			j.size = CGSize(width:GameScene.cwidth,height:GameScene.cheight)
		}
		j.position = CGPoint(x:0, y:10000)    //枠外に
		j.zPosition = 1
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func update() {
		
	}
	
}
