//
//  ViewController.swift
//  Stocks
//
//  Created by Mikhail Artsiukh on 11/6/20.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(companies.keys)[row]
    }
    
    
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var companyPickerView: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    private lazy var companies = [
        "Apple" : "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companyNameLabel.text = "Tinkoff"
        
        companyPickerView.dataSource = self
        companyPickerView.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        
    }
    
    private func requestQuote(for symbol: String) {
        //https://cloud.iexapis.com/stable/stock/aapl/quote?token=pk_90090d9590a6471e8be38c9e29d75d58
        
        let token = "pk_90090d9590a6471e8be38c9e29d75d58"
        
        guard let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=\(token)") else {
            return
            
        }
        let dataTask = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
            if let data = data,
               (response as? HTTPURLResponse)?.statusCode == 200,
               error == nil {
                self?.parseQuote(from: data)
            }else {
                print("Network Error!")
            }
        }
        
        dataTask.resume()
    }
    
    private func parseQuote(from data: Data) {
        do { let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String else {return print("Invalid JSON")}
            print("Company Name is " + companyName)
            
            DispatchQueue.main.async {
                [weak self] in
                self?.displayStockInfo(companyName: companyName)
            }
            
        } catch {
            print("JSON parsing error " + error.localizedDescription)
        }
    }
    
    private func displayStockInfo(companyName: String) {
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        activityIndicator.startAnimating()
        let selectedSymbol = Array(companies.values)[row]
        requestQuote(for: selectedSymbol)
    }
    
}


