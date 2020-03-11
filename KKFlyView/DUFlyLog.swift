//
//  DUFlyLog.swift
//  DUCommunity
//
//  Created by 王铁山 on 2019/12/15.
//  Copyright © 2019 DuApp. All rights reserved.
//

import Foundation

import UIKit

import Alamofire

public class DUFlyLog {
    
    /// 缓存的数据
    public var history = [[String: Any]]()
    
    /// 收集的最大数量
    public var masLength: Int = 100
    
    /// 是否已经开始
    private var hasStart: Bool = false

    /// 是否已经弹起ViewController
    private var showing: Bool = false
    
    // construct
    public init() {
        
    }
    
    // start
    public func start() {
        guard !hasStart else { return }
        hasStart = true
        NotificationCenter.default.addObserver(self, selector: #selector(requestDidResume(notification:)), name: NSNotification.Name.Task.DidResume, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestDidComplete(notification:)), name: NSNotification.Name.Task.DidComplete, object: nil)
    }
    
    // stop
    public func stop() {
        if hasStart {
            NotificationCenter.default.removeObserver(self)
        }
    }

    // request begin
    @objc private func requestDidResume(notification: Notification) {
        
        // get task
        guard let request = notification.object as? Request, let task = request.task else { return }
      
        // cache
        if let info = getRequestInfoByTask(task: task) {
            append(info: info)
        }
    }

    // request end
    @objc private func requestDidComplete(notification: Notification) {
                
        // get task
        guard let sessionDelegate = notification.object as? Alamofire.SessionDelegate, let userinfo = notification.userInfo, let task = userinfo[Notification.Key.Task] as? URLSessionTask else {
          return
        }

        // get data
        guard let data = sessionDelegate[task]?.delegate.data  else { return }

        // to obj
        var content: Any?
        if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.init(rawValue: 0)) {
          content = jsonObj
        } else {
          content = String.init(data: data, encoding: String.Encoding.utf8)
        }

        // cache
        if let info = getResponseByTask(task: task, content: content) {
            append(info: info)
        }
    }
    
    // insert
    private func append(info: [String: Any]) {
        objc_sync_enter(self)
        history.insert(info, at: 0)
        if history.count > masLength {
            history.removeLast()
        }
        objc_sync_exit(self)
    }
    
    private func clear() {
        objc_sync_enter(self)
        history.removeAll()
        objc_sync_exit(self)
    }
    
    // request to obj
    private func getRequestInfoByTask(task: URLSessionTask) -> [String: Any]? {
        
        guard let request = task.originalRequest else {
            return nil
        }
        
        var body: String?
        
        if let b = request.httpBody {
            
            body = String.init(data: b, encoding: String.Encoding.utf8)
        }
        
        var result = [String: Any]()
        
        result["Method"] = request.httpMethod ?? ""
        
        result["URL"] = request.url?.absoluteString ?? ""
        
        result["Headers"] = request.allHTTPHeaderFields
        
        result["Body"] = body ?? ""
        
        result["title"] = "Request:   "
        
        return result
    }
    
    // response to obj
    private func getResponseByTask(task: URLSessionTask, content: Any?) -> [String: Any]? {
        
        guard let request = task.originalRequest else {
            return nil
        }
        
        var body: String?
        
        if let b = request.httpBody {
            
            body = String.init(data: b, encoding: String.Encoding.utf8)
        }
        
        var result = [String: Any]()
        
        result["title"] = "Response: "
         
        result["Method"] = request.httpMethod ?? ""
        
        result["URL"] = request.url?.absoluteString ?? ""
        
        result["Headers"] = request.allHTTPHeaderFields ?? ""
        
        result["Body"] = body ?? ""
        
        if let eTask = task.response as? HTTPURLResponse {
            
            result["StatusCode"] = "\(eTask.statusCode)"
            
            result["ResponseHeaders"] = eTask.allHeaderFields
        }
        
        result["Content"] = content
        
        if let e = task.error {
            
            result["Error"] = e.localizedDescription
            
        } else {
            
            if let obj = task.response, let des = (obj as AnyObject).description {
                
                result["Response"] = des
                
            }
        }
        
        return result
    }

    /// show ui
    public func showLog() {
        
        guard !self.showing else {
            return
        }
        var top: UIViewController? = window()?.rootViewController
        while top?.presentedViewController != nil {
            top = top?.presentedViewController
        }
        let list = DUFlyLogVC.init(data: self.history)
        list.dismissBlock = { [weak self] in
            self?.showing = false
        }
        list.cleanBlock = { [weak self] in
            self?.clear()
        }
        top?.present(UINavigationController.init(rootViewController: list), animated: true, completion: nil)
    }
    
    func window() -> UIWindow? {
        guard let ww = UIApplication.shared.delegate?.window, let w = ww else {
            return nil
        }
        return w
    }
    
    deinit {
        stop()
    }
    
}

/// 历史网络请求展示控制器
private class DUFlyLogVC: UITableViewController {

    struct Model {
        
        var title: NSAttributedString
        
        var content: NSAttributedString
        
    }
    
    var shareText: String?
    
    /// model data
    var sourceData: [Model] = []
    
    /// origin data
    var data: [[String: Any]] = []
    
    /// 控制器 dismiss 回调
    var dismissBlock: (()->Void)?
    
    /// 清空展示历史记录回调
    var cleanBlock: (()->Void)?
    
    init(data: [[String: Any]]) {
        super.init(nibName: nil, bundle: nil)
        self.data = data
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Net Log List"
        
        self.tableView.estimatedRowHeight = 40
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        self.tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.isOpaque = true
        navigationController?.navigationBar.barTintColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Clear", style: .plain, target: self, action: #selector(clean))
        
        self.sourceData = data.map({ (item) -> Model in
            let title = NSMutableAttributedString.init()
            if (item["title"] as! String).contains("Response") {
                title.append(responseAtt(item["title"] as! String))
            } else {
                title.append(keyAtt(item["title"] as! String))
            }
            title.append(attNormal(item["URL"] as! String))
            
            let content = NSMutableAttributedString()
            content.append(getStringFromDic(item))
            
            return Model.init(title: title, content: content)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidLoad()
    }
    
    @objc func dismissAction() {
        self.dismissBlock?()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func clean() {
        self.data.removeAll()
        self.tableView.reloadData()
        self.cleanBlock?()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sourceData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let model = sourceData[indexPath.row]
        cell.textLabel?.attributedText = model.title
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let content = sourceData[indexPath.row]
        self.shareText = content.content.string
        
        let detail = UIViewController.init()
        detail.view.backgroundColor = .white
        detail.automaticallyAdjustsScrollViewInsets = false
        detail.title = "Detail"
        detail.edgesForExtendedLayout = .init(rawValue: 0)
        
        let textView = UITextView.init(frame: detail.view.bounds)
        if #available(iOS 11.0, *) {
            textView.contentInsetAdjustmentBehavior = .never
        }
        textView.alwaysBounceVertical = true
        textView.isEditable = false
        textView.attributedText = content.content
        detail.view.addSubview(textView)
        textView.frame = detail.view.bounds
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        detail.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Copy", style: .plain, target: self, action: #selector(copyText))
        detail.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Share", style: .plain, target: self, action: #selector(share))
        self.navigationController?.pushViewController(detail, animated: true)
    }
    
    @objc func copyText() {
        UIPasteboard.general.string = self.shareText
    }
    
    @objc func share() {
        
        guard let content = self.shareText else { return }
        
        let path = NSHomeDirectory().appending("/tmp/duflylog.rtf")
        
        let url = URL.init(fileURLWithPath: path)
        
        _ = try? (content as NSString).write(to: url, atomically: true, encoding: String.Encoding.utf8.rawValue)
        
        let share = UIActivityViewController.init(activityItems: [url], applicationActivities: nil)
    
        self.present(share, animated: true, completion: nil)
    }
    
    /// 根据字典返回展示的文字
    func getStringFromDic(_ dic: [String: Any]) -> NSAttributedString{
        let result = NSMutableAttributedString()
        var first: Bool = true
        sortKeys().forEach { (key) in
            if let value = dic[key] {
                if !first {
                  result.append(attNormal("\n\n"))
                }
                first = false
                result.append(keyAtt(key + ": "))
                if key.lowercased().contains("header"), let v = value as? [String: String] {
                    result.append(attNormal("["))
                    result.append(dealHeaders(headers: v))
                    result.append(attNormal("\n]"))
                } else {
                    result.append(attNormal("\(value)"))
                }
            }
        }
        return result
    }
    
    func sortKeys() -> [String] {
        return ["URL", "Method", "Headers", "Body", "StatusCode", "ResponseHeaders", "Content", "Response", "Error"]
    }
    
    func dealHeaders(headers: [String: String]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        headers.forEach { (key, value) in
            result.append(subkeyAtt("\n" + key + " = "))
            result.append(attNormal(value))
        }
        return result
    }

    /// 获取正常 att 文字
    func attNormal(_ key: String) -> NSAttributedString {
        return NSAttributedString.init(string: key, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
    }
    
    /// 获取子标题 att 文字 如：app-agent
    func subkeyAtt(_ key: String) -> NSAttributedString {
        return NSAttributedString.init(string: key, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    }
    
    /// 获取主标题 att 文字, 如： URL
    func responseAtt(_ key: String) -> NSAttributedString {
        return NSAttributedString.init(string: key, attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 103 / 255.0, green: 194 / 255.0, blue: 58 / 255.0, alpha: 1), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    }
    
    /// 获取主标题 att 文字, 如： URL
    func keyAtt(_ key: String) -> NSAttributedString {
        return NSAttributedString.init(string: key, attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(red: 100 / 255.0, green: 124 / 255.0, blue: 1, alpha: 1), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
    }
    
    /// 将 Unicode 转换
    func logString(_ str: String) -> String {
        
        var result = str
        result = result.replacingOccurrences(of: "\\u", with: "\\U")
        result = result.replacingOccurrences(of: "\"", with: "\\\"")
        
        let tmp = "\"".appending(result).appending("\"")
        
        if let data = tmp.data(using: String.Encoding.utf8) {
        
            let r = try? PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.ReadOptions.mutableContainers, format: nil)
            
            return (r as? String) ?? ""
        }
        
        return ""
    }

}




