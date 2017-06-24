//
//  getcards.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/06.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import UIKit


class Cards{	//カードや得点の管理、勝敗判定などを行うクラス
	
	
	
	//クラスプロパティ（クラス自身が保持する値）	
	static var pcards:[Int]=[]	//手札(各カードは1から52の通し番号)(空の配列であることに注意！)
	static var ccards:[Int]=[]
	static var cards=[Int](1...52)    //山札
	static var state:String="end"	  //end,waiting（1人が待っている状態）,start(配り終えた情報を送信するまで),ready(配り終えた情報を相手が受信するまで),p1turn,p2turn,judge,endと推移
	
	
	
	
	func setcard() -> (pcards:[Int],ccards:[Int],pp:String,cp:String){
		
		
		//Fisher–Yatesシャッフルアルゴルズム
		for i in 0...51{
			let j=Int(arc4random_uniform(51))%52  //上限をつけないとiPhone5では動かない。。。
			let t=Cards.cards[i]
			Cards.cards[i]=Cards.cards[j]
			Cards.cards[j]=t
		}
		
		//カードを配る
		Cards.pcards.append(Cards.cards[0])
		Cards.pcards.append(Cards.cards[1])
		Cards.ccards.append(Cards.cards[2])
		Cards.ccards.append(Cards.cards[3])
		
		//
		//		//念のため山札からカード消去 不要！（配列のindexを増やしている）
		//		for _ in 1...4{
		//
		//			Cards.cards.removeFirst()
		//		}
		
		
		let (pp,cp)=getpoints()
		
		
		return (Cards.pcards,Cards.ccards,pp,cp)
	}
	
	func getpoints() ->(pp:String,cp:String){
		
		let (ppoint,cpoint,pA,cA)=calculatepoints()
		//ppoint,cpointはそれぞれ(noA:Int,inA:Int)、pAとcAはAを持っているか(Bool)
		
		//得点をcp,ppにまとめた後、ラベルに表示（ラベルはオプショナルだから足し算できない）
		var cp,pp:String
		
		cp=String(cpoint.noA)
		if cA==true && cpoint.inA<22{
			cp += "/\(cpoint.inA)"
		}
		
		
		pp=String(ppoint.noA)
		if pA==true && ppoint.inA<22{
			pp += "/\(ppoint.inA)"
		}
		
		return (pp,cp)
		
	}
	
	
	func hit(_ hcount:Int) -> (pcards:[Int],pp:String){
		
		Cards.pcards.append(Cards.cards[4+hcount])
		//		Cards.cards.removeFirst()   不要！（配列のindexを増やしている）
		let (pp,_)=getpoints()
		return (Cards.pcards,pp)
	}
	
	func stand(_ hscount:Int) -> (ccards:[Int],cp:String){
		Cards.ccards.append(Cards.cards[4+hscount])
		let (_,cp)=getpoints()
		return (Cards.ccards,cp)
		
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
			if ppoint==(11,21) && pA==true && cpoint==(11,21) && cA==true{
				return 5
			}else if ppoint==(11,21) && pA==true{
				return 3
			}else if cpoint==(11,21) && cA==true{
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
		var cpoint=(noA:0,inA:10)
		
		for i in Cards.pcards{
			if (i-1)%13 > 8{	//10,J,Q,Kのとき
				ppoint.inA+=10
				ppoint.noA+=10
			}else{
				ppoint.inA+=i%13
				ppoint.noA+=i%13
			}
			
			
		}
		
		for i in Cards.ccards{
			if (i-1)%13 > 8{
				cpoint.inA+=10
				cpoint.noA+=10
			}else{
				cpoint.inA+=i%13
				cpoint.noA+=i%13
			}
		}
		
		//Aを持っているかの判定
		var pA=false,cA=false
		for i in Cards.pcards{
			if i%13 == 1{
				pA=true
			}
		}
		for i in Cards.ccards{
			if i%13 == 1{
				cA=true
			}
		}
		
		return (ppoint,cpoint,pA,cA)
		
	}
	
	
}

