//
//  net.swift
//  newblackjack
//
//  Created by Kohei Nakai on 2017/03/17.
//  Copyright © 2017年 NakaiKohei. All rights reserved.
//

import UIKit


class net:UIViewController,URLSessionDelegate{	//ネット関係の処理をする(URLSessionDelegateを継承するためにUIViewControllerを継承)
	
	
	
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
		let url:NSURL = NSURL(string: "https://chomin-api.herokuapp.com/bj2s.json")!
		
		// リクエストを生成.
		let request:NSURLRequest  = NSURLRequest(url: url as URL)

		
		var data: Data?
		do {
			let res: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
			data = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: res)	//同期通信！
			
		} catch {
			print(error)
		}
		
		// タスクの生成.
//		let task: URLSessionDataTask = session.dataTask(with: url as URL, completionHandler: { (data, response, err) -> Void in	//これは非同期通信（処理をバックグラウンドで行い、完了前でも次に進む）
			if data==nil{
				print("nilだお")
			}
			if data != nil {
				
//				let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//				print(str!)
				
				do {
					// 受け取ったJSONデータをパースする.(辞書型に変換)
					let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Dictionary<String, Any>]
					
					/*
					このAPIにおいてそれぞれのJSONは
					
					created_at（時）
					id（番号）
					updated_at
					url
					cards(String)
					pcards(String)
					ccards(String)
					state(String)
					
					
					を返す。(3/17/18:30での予定)
					*/
					
					if json.isEmpty==false{
						
						var cardS:String
						var pcardsS:String
						var ccardsS:String
						var state:String
						var cards:[Int]=[]
						var pcards:[Int]=[]
						var ccards:[Int]=[]
						
						if let tmp=json.last!["card"]{
							cardS=tmp as! String
							//それぞれの文字列を配列に戻す
							
							
							for i in 0...52{
								let hstart=cardS.characters.index(cardS.startIndex, offsetBy: 1+i)
								
								if let end=cardS.characters.index(of: ","){
									let tmp=Int(cardS[hstart..<end])
									cards.append(tmp!)
									cardS.removeSubrange(hstart...end) //半角スペースと置き換え？
								}else{
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
						
						if let tmp=json.last!["pcards"]{
							pcardsS=tmp as! String
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
						if let tmp=json.last!["ccards"]{
							ccardsS=tmp as! String
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
						if let tmp=json.last!["state"]{
							state=tmp as! String
							Cards.state=state
							
						}
					}
					
				} catch {
					print("error")
					print(error)
				}   //try
				
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

	}
	
	func sendData(){
		//配列を文字列に変換
		let Scards=String(describing: Cards.cards)
		let Spcards=String(describing: Cards.pcards)
		let Sccards=String(describing: Cards.ccards)
		
		
		// APIへ飛ばすデータをJSONに変換する(sendDataはData?型)
		let sendData = String(format: "{ \"bj2\": { \"cards\":\"%@\", \"pcards\":\"%@\",\"ccards\":\"%@\",\"state\":\"%@\" } }", Scards, Spcards,Sccards,Cards.state).data(using: String.Encoding.utf8)  //%@の部分にそれぞれの変数が入るようになっている？
		 print(String(data: sendData!, encoding: String.Encoding.utf8)!)
		
		
		
		// APIへ接続するための設定
		let apiUrl = URL(string: "https://chomin-api.herokuapp.com/bj2s.json")!  //URLを文字列から型変換してapiUrlに代入
		var request = URLRequest(url: apiUrl)   //リクエストの生成
		request.addValue("application/json", forHTTPHeaderField: "Content-type")
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.httpMethod = "POST"
		request.httpBody = sendData //JSONデータのセット
		
		
//		var data: Data?
		do {
			let res: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
			 try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: res)
			
		} catch {
			print(error)
		}

		
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
