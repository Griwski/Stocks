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
    
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var companyPickerView: UIPickerView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var symbolLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var priceChangeLabel: UILabel!
    
    private lazy var companies = [
        "Apple" : "AAPL",
        "Microsoft": "MSFT",
        "Google": "GOOG",
        "Amazon": "AMZN",
        "Facebook": "FB"
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestedQuoteUpdate()
        
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
        
        guard let logoURL = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/logo?token=\(token)") else {
            return
            
        }
        
        let dataTaskQuote = URLSession.shared.dataTask(with: url) {[weak self] (data, response, error) in
            if let data = data,
               (response as? HTTPURLResponse)?.statusCode == 200,
               error == nil {
                self?.parseQuote(from: data)
            }else {
                print("Network Error!")
            }
        }

        dataTaskQuote.resume()
        
            let dataTaskLogo = URLSession.shared.dataTask(with: logoURL) {[weak self] (data, response, error) in
                if let data = data,
                   (response as? HTTPURLResponse)?.statusCode == 200,
                   error == nil {
                    self?.parseLogo(from: data)
                }else {
                    print("Network Error!")
                }
            }
        
            dataTaskLogo.resume()
        
    }
    

    
    private func parseQuote(from data: Data) {
        do { let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double else {return print("Invalid JSON")}
                
            
            
            DispatchQueue.main.async {
                [weak self] in
                self?.displayStockInfo(companyName: companyName, companySymbol: companySymbol, price: price, priceChange: priceChange)
            }
            
        } catch {
            print("JSON parsing error " + error.localizedDescription)
        }
    }
    
    private func parseLogo(from data: Data) {
        do {let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard let json = jsonObject as? [String: Any],
                  let logoLink = json["url"] as? String else {return print("Invalid JSON")}
            
            DispatchQueue.main.async {
                [weak self] in
                self?.displayLogo(logoLink: logoLink)
            }
            
        } catch {
            print("JSON parsing error " + error.localizedDescription)
        
        }
    }
    
    private func displayStockInfo(companyName: String, companySymbol: String, price: Double, priceChange: Double) {
        activityIndicator.stopAnimating()
        companyNameLabel.text = companyName
        symbolLabel.text = companySymbol
        priceLabel.text = String(price)
        priceChangeLabel.text = String(priceChange)
        
        switch priceChange {
        case 0... :
            priceChangeLabel.textColor = UIColor.green
        case ...0 :
            priceChangeLabel.textColor = UIColor.red
        default:
            priceChangeLabel.textColor = UIColor.black
        }
    }
    
    private func displayLogo(logoLink: String) {
        
        guard let url = URL(string: logoLink) else { return print("No logo") }

            // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
                // Create Image and Update Image View
                logoImageView.image = UIImage(data: data)
            }
        }
        
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        requestedQuoteUpdate()
       
    }
    private func requestedQuoteUpdate() {
        activityIndicator.startAnimating()
        companyNameLabel.text = "-"
        symbolLabel.text = "-"
        priceLabel.text = "-"
        priceChangeLabel.text = "-"
        
        let selectedRow = companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(companies.values)[selectedRow]
        requestQuote(for: selectedSymbol)
    }
}


