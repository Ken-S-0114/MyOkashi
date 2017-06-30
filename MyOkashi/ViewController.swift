//
//  ViewController.swift
//  MyOkashi
//
//  Created by 佐藤賢 on 2017/04/24.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SFSafariViewControllerDelegate{

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    searchText.delegate = self
    searchText.placeholder = "お菓子の名前を入力してください"
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBOutlet weak var searchText: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  var okashiList : [(maker:String , name:String , link:String , image:String)] = []
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    view.endEditing(true)
    print(searchBar.text!)
  
  if let searchWord = searchBar.text {
    searchOkashi(keyword: searchWord)
    }
  }
  
  func searchOkashi(keyword : String) {
    let keyword_encode = keyword.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let URL = Foundation.URL(string: "http://www.sysbird.jp/toriko/api/?apikey=guest&format=json&keyword=\(keyword_encode!)&max=10&order=r")
    print(URL!)
    
    let req = URLRequest(url: URL!)
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: req, completionHandler: {
      (data,response,error) in
      do{
        // 受け取ったJSONデータをパース（解析）して格納
        let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
        // お菓子リストを初期化
        self.okashiList.removeAll()
        
        if let items = json["item"] as? [[String:Any]] {
          // 取得しているお菓子の数だけ処理
          for item in items {
            guard let maker = item["maker"] as? String else {
              continue
            }
            guard let name = item["name"] as? String else {
              continue
            }
            guard let link = item["url"] as? String else {
              continue
            }
            guard let image = item["image"] as? String else {
              continue
            }
            let okashi = (maker,name,link,image)
            self.okashiList.append(okashi)
          }
        }
        
        print("--------------------")
        print("okashiList[0] = \(self.okashiList[0])")
        // Table Viewを更新
        self.tableView.reloadData()
      } catch {
        print("エラーが出ました")
      }
    })
    task.resume()   // タスクの実行
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return okashiList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "okashiCell", for: indexPath)
    cell.textLabel?.text = okashiList[indexPath.row].name
    // お菓子画像のURLを取り出す
    let url = URL(string: okashiList[indexPath.row].image)
    // URLから画像を取得
    if let image_data = try? Data(contentsOf: url!) {
      // 正常に取得できた場合は、UIImageで画像オブジェクトを生成して、Cellにお菓子画像を設定
      cell.imageView?.image = UIImage(data: image_data)
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let urlToLink = URL(string: okashiList[indexPath.row].link)
    let safariViewController = SFSafariViewController(url: urlToLink!)
    safariViewController.delegate = self
    present(safariViewController, animated: true, completion: nil)
  }
  
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    dismiss(animated: true, completion: nil)
  }
}

