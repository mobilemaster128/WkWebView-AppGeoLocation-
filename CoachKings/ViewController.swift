//
//  ViewController.swift
//  CoachKings
//
//  Created by Sierra on 3/17/17.
//  Copyright © 2017 CoachKings. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //var webView: UIWebView!
    var webView: WKWebView!
    var config: WKWebViewConfiguration!
    var locationManger: CLLocationManager!
    var currentLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        progressView.setProgress(0, animated: false)
        SVProgressHUD.show(withStatus: "Loading...")
        
        theWebView()
        
        locationInit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationInit() {
        locationManger = CLLocationManager()
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.distanceFilter = kCLDistanceFilterNone
        
        /*if locationManger.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)) {
            locationManger.requestAlwaysAuthorization()
        }*/
        
        if locationManger.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) {
            locationManger.requestWhenInUseAuthorization()
        }
        
        /*if locationManger.responds(to: #selector(CLLocationManager.requestLocation)) {
            locationManger.requestLocation()
        }*/
        
        locationManger.startUpdatingLocation()
    }
    
    // initialize webVIew
    func theWebView(){
        
        config = WKWebViewConfiguration()
        config.preferences = WKPreferences()
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.userContentController = WKUserContentController()
        config.userContentController.add(self, name: "myHandler")
        //webView = WKWebView(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height-20), configuration: config)
        webView = WKWebView(frame: self.webViewContainer.frame, configuration: config)
        //webView = WKWebView(frame: self.view.frame, configuration: config)
        //webView = UIWebView(frame: self.view.frame)
        
        webView.autoresizingMask.insert(UIViewAutoresizing.flexibleHeight)
        webView.autoresizingMask.insert(UIViewAutoresizing.flexibleWidth)
        
        webView.navigationDelegate = self
        //webView.uiDelegate = self
        
        //self.view.addSubview(webView)
        self.webViewContainer.addSubview(webView)
        
        let url = URL(string: "https://app.coachkings.com.au?appver=265")
        let urlRequest = URLRequest(url: url!)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        webView.load(urlRequest)
        //webView.loadRequest(urlRequest)
        webView.allowsBackForwardNavigationGestures = true
    }
    
    @IBAction func back(_ sender: Any) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    @IBAction func forward(_ sender: Any) {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        if self.webView.isLoading {
            self.webView.stopLoading()
        } else {
            self.webView.reload()
        }
    }
    
    @IBAction func share(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let safariAction = UIAlertAction(title: "Open in Safari", style: .default) { (action: UIAlertAction) in
            UIApplication.shared.open(self.webView.url!, options: ["": ""], completionHandler: nil)
            alert.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action: UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(safariAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "loading") {
            backButton.isEnabled = self.webView.canGoBack
            forwardButton.isEnabled = self.webView.canGoForward
        }
        if (keyPath == "estimatedProgress") {
            print(Float(webView.estimatedProgress))
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            progressView.isHidden = self.webView.estimatedProgress == 1
            if webView.estimatedProgress == 1 {
                SVProgressHUD.dismiss()
            }
        }
        if keyPath == "title" {
            self.appTitle.text = self.webView.title
            self.title = self.webView.title
        }
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.setProgress(0, animated: false)
        progressView.isHidden = self.webView.estimatedProgress == 1
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print(message.debugDescription)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print(message.debugDescription)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print(prompt.debugDescription)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        print("close")
    }
    
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.debugDescription)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError: \(error)")
        
        let alert = UIAlertController(title: "Error", message: "Failed to Get Your Location", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        //present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateToLocation: \(locations.last)")
        
        currentLocation = locations.last
        
        let alert = UIAlertController(title: "Location", message: "Your Location \(locations.last?.coordinate.latitude)", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        //present(alert, animated: true, completion: nil)
    }
    
}
