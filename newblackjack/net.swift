//
//  net.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/17.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import UIKit


class net:UIViewController,URLSessionDelegate{	//ネット関係の処理をする(URLSessionDelegateを継承するためにUIViewControllerを継承)
	
	static var fLastId = 0
	static var uuid=""    //別クラスで定義するため、まずここで初期値を設定する必要があり、定数にできない
	static var dealer = 0	  //\(dealer)番目に入った人がディーラー
	static var isLatest = false
	
	
	
	
	func receiveData(){		//受信する
		//送信とのクラッシュ対策
		Netp1Scene.hitButton.isEnabled=false
		Netp1Scene.standButton.isEnabled=false
		Netp1Scene.resetButton.isEnabled=false
		Netp1Scene.titleButton.isEnabled=false
		Netp2Scene.hitButton.isEnabled=false
		Netp2Scene.standButton.isEnabled=false
		Netp2Scene.resetButton.isEnabled=false
		Netp2Scene.titleButton.isEnabled=false
		
		// 通信用のConfigを生成.
		//		let config: URLSessionConfiguration =  URLSessionConfiguration.default
		
		// Sessionを生成.
		//		let session: URLSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
		
		// 通信先のURLを生成.
		let url:NSURL = NSURL(string: "https://chomin-api.herokuapp.com/bj4s/latest.json/")!
		
		// リクエストを生成.
		let request:NSURLRequest  = NSURLRequest(url: url as URL)
		
		
		var data: Data?
		do {
			let res: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
			data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: res)	//同期通信！
			
		} catch {
			print(error)
			receiveData()
		}
		
		// タスクの生成.
		//		let task: URLSessionDataTask = session.dataTask(with: url as URL, completionHandler: { (data, response, err) -> Void in	//これは非同期通信（処理をバックグラウンドで行い、完了前でも次に進む）
		if data == nil {//起こらない？
			print("nil")
		}else{
			
//			let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//			print(str!)
//			print("↑受信したデータ")
			
			do {
				// 受け取ったJSONデータをパースする.(辞書型に変換)
				let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Dictionary<String, Any>]
				
				/*
				このAPIにおいてそれぞれのJSONは
				id（番号）
				cards(String)
				pcards(String)
				ccards(String)
				state(String)
				uuid(String)
				created_at（時）
				updated_at
				url
				
				を返す。(6/12時点)
				*/
				
				if json.isEmpty==false{
					
					var cardS:String
					var pcardsS:String
					var ccardsS:String
					var state:String
					var cards:[Int]=[]
					var pcards:[Int]=[]
					var ccards:[Int]=[]
					let lastIndex=json.count-1
					let lastId=json[lastIndex]["id"] as! Int
					var fLastIdIndex = -1 //fLastIdのデータが入ってる位置
					
					for i in 0...lastIndex{//fLastIdのデータが入っている位置を調べる
						if json[i]["id"] as! Int == net.fLastId{
							fLastIdIndex=i
							break
						}
					}
					if fLastIdIndex == -1 && net.fLastId != 0{//見つからず、初期状態でないとき
						print("fLastIdのデータが見つかりませんでした")
						exit(1)
					}
					
					if net.fLastId >= lastId {
						net.isLatest=true
					}else{//更新すべきとき
						net.isLatest=false
						let adjust:Int  //反映されていないデータの個数
						if net.fLastId==0{
							adjust=1
						}else{
							adjust=lastIndex-fLastIdIndex
						}
						
						let alast=lastIndex-adjust+1	//adjusted last index(新しいものを1つずつ順に獲得する)
						
						net.fLastId=json[alast]["id"] as! Int
						
						if json.count >= 2 && adjust==1{
							if json[alast]["state"] as! String=="waiting" && json[alast-1]["state"] as! String=="waiting" && json[alast]["uuid"] as! String==net.uuid{	//ダブルwaitingになったら、あとから送ったほうがstartを投げる
								
								waitingScene.sendstart=true
							}
						}
						
						if let tmp0=json[alast]["cards"]{
							cardS=tmp0 as! String
							//それぞれの文字列を配列に戻す
							
							
							for i in 0...52{
								let hstart=cardS.characters.index(cardS.startIndex, offsetBy: 1+i)
								
								if let end=cardS.characters.index(of: ","){
									let tmp=Int(cardS[hstart..<end])
									cards.append(tmp!)
									cardS.removeSubrange(hstart...end) //半角スペースと置き換え？
								}else{//要エラー処理
									let end=cardS.characters.index(of: "]")
									let tmp=Int(cardS[hstart..<end!])
									if tmp==nil{
										break
									}
									cards.append(tmp!)
									break
								}
							}
							//cardとかを更新
							Cards.cards=cards
							
						}
						
						if let tmp0=json[alast]["pcards"]{
							pcardsS=tmp0 as! String
							for i in 0...52{
								let hstart=pcardsS.characters.index(pcardsS.startIndex, offsetBy: 1+i)
								
								if let end=pcardsS.characters.index(of: ","){
									let tmp=Int(pcardsS[hstart..<end])
									pcards.append(tmp!)
									pcardsS.removeSubrange(hstart...end) //半角スペースと置き換え？
								}else {
									let end=pcardsS.characters.index(of: "]")
									let tmp=Int(pcardsS[hstart..<end!])
									if tmp==nil{
										break
									}
									pcards.append(tmp!)
									break
								}
							}
							Cards.pcards=pcards
						}
						if let tmp0=json[alast]["ccards"]{
							ccardsS=tmp0 as! String
							for i in 0...52{
								let hstart=ccardsS.characters.index(ccardsS.startIndex, offsetBy: 1+i)
								
								if let end=ccardsS.characters.index(of: ","){
									let tmp=Int(ccardsS[hstart..<end])
									ccards.append(tmp!)
									ccardsS.removeSubrange(hstart...end) //半角スペースと置き換え？
								}else{
									let end=ccardsS.characters.index(of: "]")
									let tmp=Int(ccardsS[hstart..<end!])
									if tmp==nil{
										break
									}
									ccards.append(tmp!)
									break
								}
							}
							Cards.ccards=ccards
						}
						if let tmp0=json[alast]["state"]{
							
							state=tmp0 as! String
							Cards.state=state
							
						}
						if let tmp0=json[alast]["dealer"]{
							net.dealer=tmp0 as! Int
						}
						
						if adjust==1{
							net.isLatest=true
						}
						
					}//
				}else{  //もし空だったら(if json.isEmpty==false)
					net.isLatest=true
				}
				
			} catch {
				print("error")
				print(error)
				receiveData()
			}   //do
			
		} //if data!=nil
		
		Netp1Scene.hitButton.isEnabled=true
		Netp1Scene.standButton.isEnabled=true
		Netp1Scene.resetButton.isEnabled=true
		Netp1Scene.titleButton.isEnabled=true
		Netp2Scene.hitButton.isEnabled=true
		Netp2Scene.standButton.isEnabled=true
		Netp2Scene.resetButton.isEnabled=true
		Netp2Scene.titleButton.isEnabled=true
		//		})
		
		
		//		// タスクの実行.
//		task.resume()
		print("↓受信後のローカルの状態")
		print("state:\(Cards.state),cards:\(Cards.cards),pcards:\(Cards.pcards),ccards:\(Cards.ccards)")
		print("↑受信後のローカルの状態")

	}
	
	func sendData(){
		//配列を文字列に変換
		let Scards=String(describing: Cards.cards)
		let Spcards=String(describing: Cards.pcards)
		let Sccards=String(describing: Cards.ccards)
		
		print(net.dealer)
		// APIへ飛ばすデータをJSONに変換する(sendDataはData?型)
		let sendData = String(format: "{ \"bj4\": { \"cards\":\"%@\", \"pcards\":\"%@\",\"ccards\":\"%@\",\"state\":\"%@\",\"uuid\":\"%@\", \"dealer\":\"%@\" } }", Scards, Spcards,Sccards,Cards.state,net.uuid,String(net.dealer)
			).data(using: String.Encoding.utf8)  //%@の部分にそれぞれの変数が入るようになっている？
		
//		 print(String(data: sendData!, encoding: String.Encoding.utf8)!)
//		print("↑送信予定データ")
		
		
		
		// APIへ接続するための設定
		let apiUrl = URL(string: "https://chomin-api.herokuapp.com/bj4s.json/")!  //URLを文字列から型変換してapiUrlに代入
		var request = URLRequest(url: apiUrl)   //リクエストの生成
		request.addValue("application/json", forHTTPHeaderField: "Content-type")//??
		request.addValue("application/json", forHTTPHeaderField: "Accept")//??
		request.httpMethod = "POST"
		request.httpBody = sendData //JSONデータのセット
		
		
		var data: Data?
		do {
			let res: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
			data=try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: res)
			
		} catch {
			print(error)
			self.sendData()
		}
		
		print(String(data: data!, encoding: String.Encoding.utf8)!)
		print("↑送信後に帰ってきたデータ")
		
		
//		// APIに接続
//		URLSession.shared.dataTask(with: request) {data, response, err in
//			if (err == nil) {
//				// API通信成功
//				print("APIsuccess")
//			} else {
//				// API通信失敗
//				print("APIerror")
//			}
//			
//			
//			}.resume()
		
	}
}
