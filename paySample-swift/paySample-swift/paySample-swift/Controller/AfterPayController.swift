//
//  AfterPayController.swift
//  paySample-swift
//
//  Created by 서정현 on 2018. 8. 3..
//  Copyright © 2018년 서정현. All rights reserved.
//

import UIKit
import WebKit
import os.log

protocol sendBackDelegate {
    func dataReceived(data: [String: Any])
}

class AfterPayController : UIViewController , WKNavigationDelegate, WKUIDelegate , WKScriptMessageHandler {
    
    @IBOutlet weak var webViewBox: UIView!
    var url = "https://pg.innopay.co.kr/pay/appLink.jsp"
    
    //결제 결과 키값
    let RESULT_PAY_METHOD = "PayMethod";
    let RESULT_MID = "MID";
    let RESULT_TID = "TID";
    let RESULT_MALL_USER_ID = "mallUserID";
    let RESULT_AMT = "Amt";
    let RESULT_NAME = "name";
    let RESULT_GOODS_NAME = "GoodsName";
    let RESULT_OID = "OID";
    let RESULT_MOID = "MOID";
    let RESULT_AUTH_DATE = "AuthDate";
    let RESULT_AUTH_CODE = "AuthCode";
    let RESULT_RESULT_CODE = "ResultCode";
    let RESULT_RESULT_MSG = "ResultMsg";
    let RESULT_MALL_RESERVED = "MallReserved";
    let RESULT_FN_CD = "fn_cd";
    let RESULT_FN_NAME = "fn_name";
    let RESULT_CARD_QUOTA = "CardQuota";
    let RESULT_BUYER_EMAIL = "BuyerEmail";
    
    var data = "";//파라메터
    var delegate : sendBackDelegate?
    
    var webView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: webViewBox.frame, configuration: WKWebViewConfiguration())//웹킷웹뷰의 설정을 초기화하여 웹뷰생성
        
        if (webView != nil) {
            webView!.frame = webViewBox.frame
            webViewBox.superview?.addSubview(webView!)
            webView.navigationDelegate = self //네비게이션데리게이트 받음
            webView.uiDelegate = self // ui데리게이트 받음
            
            webView.configuration.userContentController = WKUserContentController()//웹뷰의 컨텐츠컨트롤러 초기화
            webView.configuration.userContentController.add(self, name: "payResult")//컨텐츠 컨트롤러에서 브릿지를 사용하여 payResult로 된 자바스크립트를 사용한다고 추가
        }
        
        let encodedParam = CFURLCreateStringByAddingPercentEscapes(
            nil,
            data as CFString,
            nil,
            "+" as CFString,
            CFStringBuiltInEncodings.UTF8.rawValue
        )//파라메터중 +로 된 문자를 urlencode함
        print("url : \(url)")
        print("_data : \(data)")
        /*GET start*/
        /*
         //만약 GET방식으로 처리하려면 이블럭을 해제하면 동작 (POST블럭 주석처리 필요)
         let geturl = url + "?" + (encodedParam as! String);
         var getRequest = URLRequest(url: URL(string: geturl)!)
         getRequest.httpMethod = "GET"
         
         print("request Method : \(String(describing: getRequest.httpMethod))")
         webView.load(getRequest)*/
        /*GET end*/
        
        /*POST start*/
        // 만약 POST방식으로 처리하려면 이블럭을 해제하면 동작 (GET블럭 주석처리 필요)
        var PostRequest = URLRequest(url: URL(string: url)!)
        PostRequest.httpMethod = "POST"
        PostRequest.httpBody = (encodedParam! as String).data(using: .utf8)
        //WKWebView의 load 메소드의 경우 PostRequest.httpBody 에 데이터를 실어 POST할경우 데이터가 null로 전송되는 문제때문에 URLSession.shared.dataTask를 사용하여 POST후 웹뷰에 처리
        let task = URLSession.shared.dataTask(with: PostRequest) { (data : Data?, response : URLResponse?, error : Error?) in
            if data != nil
            {
                if let returnString = String(data: data!, encoding: .utf8)
                {
                    self.webView.loadHTMLString(returnString, baseURL: URL(string: self.url)!)
                }
            }
        }
        task.resume()
        
        print("request Method : \(String(describing: PostRequest.httpMethod))")
        print("request Body : \(encodedParam)")
        /*POST end*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPressBack(_ sender: UIBarButtonItem) {
        delegate?.dataReceived(data: [:])
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.scheme != "http" && url.scheme != "https" {//http계열 url이 아닐경우 url을 오픈처리
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 중복적으로 리로드가 일어나지 않도록 처리 필요.
        webView.reload()
    }
    
    @available(iOS 8.0 , * )
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "payResult"://인증결제후 브릿지를 통하여 리턴받는 JS함수명
            let json = convertToDictionary(text: message.body as! String)//딕셔너리로 변경
            print("[\(message.name)] = \(message.body) \n convert Json [\(json)]")
            let alertController = UIAlertController(title: "success", message: message.body as! String, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default , handler: { action in
                self.delegate?.dataReceived(data: json!) //델리게이트를 통한 데이터 전달
                self.dismiss(animated: true, completion: nil)}))
            self.present(alertController, animated: true, completion: nil)
            break
        default:
            let alertController = UIAlertController(title: "error", message: "정의된 userContentController가 없습니다.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alertController, animated: true, completion: nil)
            break
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
