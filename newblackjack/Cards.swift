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

class Cards{	//カードや得点の管理、勝敗判定などを行うクラス
	
	//クラスプロパティ（クラス自身が保持する値）	
	static var pcards:[(card:Int,point:Int)]=[]	//手札(各カードは1から52の通し番号)(空の配列であることに注意！)
	static var ccards:[(card:Int,point:Int)]=[]
	static var cards:[(card:Int,point:Int)]=[]   //(山札,得点)
	static var state:gameState = .end	  //end,waiting（1人が待っている状態）,start(配り終えた情報を送信するまで),ready(配り終えた情報を相手が受信するまで),p1turn,p2turn,judge,endと推移
	static var mode:gameMode = .com	//com,pvp,netp1,netp2,scom(shadowjackモード),spvp,snetp1,snetp2
	static var pBP=0
	static var cBP=0
	static var cardSum=0  //カードの合計枚数
	
	@discardableResult	//結果を使わなくてもいいよ
	func setcard() -> (pcards:[(Int,Int)],ccards:[(Int,Int)],pp:String,cp:String){
		
		if Cards.mode == .com || Cards.mode == .pvp || Cards.mode == .netp1 || Cards.mode == .netp2{
			Cards.cardSum=52
		}else{
			Cards.cardSum=66
		}
		
		var removeCount=0
		
		for i in 1...Cards.cardSum{
			
			if i==53 || i==56{//サタンとゼウスは禁止カード
				removeCount += 1
				continue
			}
			
			if i<53{
				if (i-1)%13 > 8{	//10,J,Q,Kのとき
					Cards.cards.append((i,10))
				}else{
					Cards.cards.append((i,i%13))
				}
			}else{//特殊カード
				if i==53 || i==55 || i==56 || i==60 || i==61{
					Cards.cards.append((i,10))
				}else if i==57 || i==62 || i==63{
					Cards.cards.append((i,4))
				}else if i==54 || i==58 || i==59{
					Cards.cards.append((i,9))
				}else if i==64 || i==65 || i==66 {
					Cards.cards.append((i,8))
				}
			}
		}
		
		Cards.cardSum -= removeCount
		
		
		//Fisher–Yatesシャッフルアルゴルズム
		for i in 0...Cards.cardSum-1{
			let j=Int(arc4random_uniform(UInt32(Cards.cardSum-1)))%Cards.cardSum  //上限をつけないとiPhone5では動かない。。。
			let t=Cards.cards[i]
			Cards.cards[i]=Cards.cards[j]
			Cards.cards[j]=t
		}

		
		
		//カードを配る
		Cards.pcards.append(Cards.cards[0])
		Cards.cards.removeFirst()
		Cards.pcards.append(Cards.cards[0])
		Cards.cards.removeFirst()
		Cards.ccards.append(Cards.cards[0])
		Cards.cards.removeFirst()
		Cards.ccards.append(Cards.cards[0])
		Cards.cards.removeFirst()
		
		let (pp,cp) = getpoints()
		
		
		return (Cards.pcards,Cards.ccards,pp!,cp!)
	}
	
	func getpoints() ->(pp:String?,cp:String?){
		
		let (ppoint,cpoint,_,_)=calculatepoints()
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
	
	func hit() -> (pcards:[(Int,Int)],pp:String){//pcardsにcards[0]を配る
		
		Cards.pcards.append(Cards.cards[0])
		Cards.cards.removeFirst()
		let (pp,_)=getpoints()
		return (Cards.pcards,pp!)
	}
	
	func stand() -> (ccards:[(Int,Int)],cp:String){
		Cards.ccards.append(Cards.cards[0])
		Cards.cards.removeFirst()
		let (_,cp)=getpoints()
		return (Cards.ccards,cp!)
		
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
		
		for i in Cards.pcards{
			
				ppoint.inA+=i.point
				ppoint.noA+=i.point
			
//			初期値不変の場合の計算
//			if i.card<53{//トランプ
//				if (i.card-1)%13 > 8{	//10,J,Q,Kのとき
//					ppoint.inA+=10
//					ppoint.noA+=10
//				}else{
//					ppoint.inA+=i.card%13
//					ppoint.noA+=i.card%13
//				}
//			}else{//特殊カード
//				if i.card==53 || i.card==55 || i.card==56{
//					ppoint.inA+=10
//					ppoint.noA+=10
//				}else if i.card==57{
//					ppoint.inA+=4
//					ppoint.noA+=4
//				}else if i.card==54{
//					ppoint.inA+=9
//					ppoint.noA+=9
//				}
//			
//			}
		}
		
		for i in Cards.ccards{

				cpoint.inA+=i.point
				cpoint.noA+=i.point
			
		}
		
		//Aを持っているかの判定
		var pA=false,cA=false
		for i in Cards.pcards{
			if i.card%13 == 1 && i.card<53{
				pA=true
			}
		}
		for i in Cards.ccards{
			if i.card%13 == 1 && i.card<53{
				cA=true
			}
		}
		
		return (ppoint,cpoint,pA,cA)
	
	}
	
	
}
