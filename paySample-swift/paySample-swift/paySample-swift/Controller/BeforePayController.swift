//
//  BeforePayController.swift
//  paySample-swift
//
//  Created by 서정현 on 2018. 8. 3..
//  Copyright © 2018년 서정현. All rights reserved.
//

import UIKit

class BeforePayController : UIViewController , sendBackDelegate , UITextFieldDelegate{
    
    @IBOutlet weak var moidTextField: UITextField!
    @IBOutlet weak var goodsNameTextField: UITextField!
    @IBOutlet weak var goodsAmtTextField: UITextField!
    @IBOutlet weak var dutyFreeAmtTextField: UITextField!
    @IBOutlet weak var goodsCntTextField: UITextField!
    @IBOutlet weak var buyerNameTextField: UITextField!
    @IBOutlet weak var mallUserIDTextField: UITextField!
    @IBOutlet weak var buyerTelTextField: UITextField!
    @IBOutlet weak var buyerEmailTextField: UITextField!
    @IBOutlet weak var offeringPeriodTextField: UITextField!
    
    let mid = "testpay01m"//발급받은 mid
    let merchantKey = "Ma29gyAFhvv/+e4/AHpV6pISQIvSKziLIbrNoXPbRS5nfTx2DOs8OJve+NzwyoaQ8p9Uy1AN4S1I0Um5v7oNUg=="; //발급받은 라이센스키 입력
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        moidTextField.delegate = self
        goodsNameTextField.delegate = self
        goodsAmtTextField.delegate = self
        dutyFreeAmtTextField.delegate = self
        goodsCntTextField.delegate = self
        buyerNameTextField.delegate = self
        mallUserIDTextField.delegate = self
        buyerTelTextField.delegate = self
        buyerEmailTextField.delegate = self
        offeringPeriodTextField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        makeMoid()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    @IBAction func onPressPost(_ sender: UIButton) {
//        let afterpay = self.storyboard?.instantiateViewController(withIdentifier: "afterPay")
//        
//        afterpay?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//        self.present(afterpay!, animated: true, completion: nil)
//    }

    @IBAction func onPressPost(_ sender: UIButton) {
        performSegue(withIdentifier: "goWeb", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goWeb"{//웹뷰 호출시 data부분을 파라메터 생성후 화면전환
            let afterPayController = segue.destination as! AfterPayController
            afterPayController.data = makeStringPostParameter()
            afterPayController.delegate = self
            
            makeMoid()
        }
    }
    
    func dataReceived(data: [String: Any]) {
        let receivedData = data
        print("dataReceived [\(receivedData)]")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    
    func makeMoid (){//moid임의생성
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmssSSS"
        moidTextField.text="test" + dateFormatter.string(from: now)
    }
    
    func makeStringPostParameter () -> String {//파라메터생성
        var returnVal = "";
        
        returnVal += "mid=\(mid)"
        returnVal += "&moid=\(moidTextField.text!)"
        returnVal += "&goodsName=\(goodsNameTextField.text!)"
        returnVal += "&goodsAmt=\(goodsAmtTextField.text!)"
        returnVal += "&dutyFreeAmt=\(dutyFreeAmtTextField.text!)"
        returnVal += "&goodsCnt=\(goodsCntTextField.text!)"
        returnVal += "&buyerName=\(buyerNameTextField.text!)"
        returnVal += "&mallUserID=\(mallUserIDTextField.text!)"
        returnVal += "&buyerTel=\(buyerTelTextField.text!)"
        returnVal += "&buyerEmail=\(buyerEmailTextField.text!)"
        returnVal += "&offeringPeriod=\(offeringPeriodTextField.text!)"
        returnVal += "&merchantKey=\(merchantKey)"
        
        return returnVal
        
    }
    
}

