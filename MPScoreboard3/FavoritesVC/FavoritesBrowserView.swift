//
//  FavoritesBrowserView.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/13/21.
//

import UIKit
import WebKit

protocol FavoritesBrowserViewDelegate: AnyObject
{
    func favoritesBrowserScrollViewDidScroll(_ value : Int)
}

class FavoritesBrowserView: UIView, UIScrollViewDelegate, WKNavigationDelegate, WKUIDelegate
{
    private var browserView: WKWebView = WKWebView()
    private var loadingContainer : UIView = UIView()
    private var loadingLabel: UILabel = UILabel()
    private var navContainerView : UIView!
    private var backButton: UIButton!
    private var forwardButton: UIButton!
    
    private let kIndicatorHeight = 20
    weak var delegate: FavoritesBrowserViewDelegate?
    
    // MARK: - Load URL Method
    
    func loadUrl(_ urlString: String)
    {
        let url = URL(string: urlString)!
        browserView.load(URLRequest(url: url))
    }
    
    // MARK: - Browser UI Delegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        if navigationAction.targetFrame == nil
        {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    // MARK: - Navigaton Delegates
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let urlString = navigationAction.request.url?.absoluteString
        {
            //print("Decide Policy for URL: " + urlString);
            if urlString.contains("about:blank")
            {
               // print("Rejected URL, about:blank")
                decisionHandler(.cancel)
                return
            }
        }
        
        //print("Allowed")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
    {
        print("Did Commit")
        
        self.animateLoadingContainer(show: true)
        
        // Deadman timer for the overlay view
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        { [self] in
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.animateLoadingContainer(show: false)
            }
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print("Did Finish")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.animateLoadingContainer(show: false)
            }
        }
        
        if (browserView.canGoBack == true) || (browserView.canGoForward == true)
        {
            navContainerView.isHidden = false
        }
        else
        {
            navContainerView.isHidden = true
        }
        
        if (browserView.canGoBack == true)
        {
            backButton.isEnabled = true
            backButton.alpha = 1
        }
        else
        {
            backButton.isEnabled = false
            backButton.alpha = 0.5
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButton.isEnabled = true
            forwardButton.alpha = 1
        }
        else
        {
            forwardButton.isEnabled = false
            forwardButton.alpha = 0.5
        }

    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error)
    {
        print("Did Fail")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.animateLoadingContainer(show: false)
            }
        }
        
        if (browserView.canGoBack == true) || (browserView.canGoForward == true)
        {
            navContainerView.isHidden = false
        }
        else
        {
            navContainerView.isHidden = true
        }
        
        if (browserView.canGoBack == true)
        {
            backButton.isEnabled = true
        }
        else
        {
            backButton.isEnabled = false
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButton.isEnabled = true
        }
        else
        {
            forwardButton.isEnabled = false
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        print("Did Fail")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.animateLoadingContainer(show: false)
            }
        }
        
        if (browserView.canGoBack == true) || (browserView.canGoForward == true)
        {
            navContainerView.isHidden = false
        }
        else
        {
            navContainerView.isHidden = true
        }
        
        if (browserView.canGoBack == true)
        {
            backButton.isEnabled = true
        }
        else
        {
            backButton.isEnabled = false
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButton.isEnabled = true
        }
        else
        {
            forwardButton.isEnabled = false
        }
    }
    
    // MARK: - Loading Container
    
    private func animateLoadingContainer(show: Bool)
    {
        if (show)
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.loadingContainer.transform = CGAffineTransform(translationX: 0, y: 0)
            }
        }
        else
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.loadingContainer.transform = CGAffineTransform(translationX: 0, y: CGFloat(-kIndicatorHeight))
            }
        }
        
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.delegate?.favoritesBrowserScrollViewDidScroll(Int(scrollView.contentOffset.y))
    }
    
    // MARK: - Nav Button Methods
    
    @objc func backButtonTouched()
    {
        if (browserView.canGoBack == true)
        {
            browserView.goBack()
        }
    }
    
    @objc func forwardButtonTouched()
    {
        if (browserView.canGoForward == true)
        {
            browserView.goForward()
        }
    }
    
    // MARK: - Update Frame Method
    
    func updateFrame(_ frame: CGRect)
    {
        self.frame = frame
        browserView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        navContainerView.frame = CGRect(x: 20, y: frame.size.height - 48, width: 80, height: 32)
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // UIViews don't clip to bounds automatically
        self.clipsToBounds = true
        
        browserView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        browserView.navigationDelegate = self
        browserView.uiDelegate = self
        browserView.scrollView.delegate = self
        browserView.scrollView.bounces = false
        self.addSubview(browserView)
        
        // Add the loading container
        loadingContainer.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kIndicatorHeight)
        loadingContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.33)
        self.addSubview(loadingContainer)
        
        loadingContainer.transform = CGAffineTransform(translationX: 0, y: -CGFloat(kIndicatorHeight))
        
        loadingLabel.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kIndicatorHeight)
        loadingLabel.backgroundColor = .clear
        loadingLabel.textColor = UIColor.mpWhiteColor()
        loadingLabel.text = "Loading..."
        loadingLabel.textAlignment = .center
        loadingLabel.font = .systemFont(ofSize: 11)
        loadingContainer.addSubview(loadingLabel)
        
        navContainerView = UIView(frame: CGRect(x: 20, y: frame.size.height - 48, width: 80, height: 32))
        navContainerView.layer.cornerRadius = 16
        navContainerView.layer.borderWidth = 1
        navContainerView.layer.borderColor = UIColor.init(white: 0.33, alpha: 0.5).cgColor
        navContainerView.clipsToBounds = true
        navContainerView.backgroundColor = UIColor.init(white: 0.9, alpha: 0.5)
        self.addSubview(navContainerView)
        
        backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 32)
        backButton.setImage(UIImage(named: "ArrowLeftGray"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
        navContainerView.addSubview(backButton)
        
        forwardButton = UIButton(type: .custom)
        forwardButton.frame = CGRect(x: 40, y: 0, width: 40, height: 32)
        forwardButton.setImage(UIImage(named: "ArrowRightGray"), for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardButtonTouched), for: .touchUpInside)
        navContainerView.addSubview(forwardButton)
        
        navContainerView.isHidden = true
        backButton.alpha = 0.5
        forwardButton.alpha = 0.5
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
