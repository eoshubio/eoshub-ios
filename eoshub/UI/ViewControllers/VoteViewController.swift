//
//  VoteViewController.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit

class VoteViewController: BaseViewController {
    
    @IBOutlet fileprivate weak var naviBar: UINavigationBar!
    @IBOutlet fileprivate weak var lbStakedEOSTitle: UILabel!
    @IBOutlet fileprivate weak var lbStakedEOS: UILabel!
    @IBOutlet fileprivate weak var btnChangeStake: UIButton!
    @IBOutlet fileprivate weak var bpList: UITableView!
    fileprivate weak var btnApplyItem: UIBarButtonItem!
    fileprivate weak var btnVotedBPs: UIBarButtonItem!
    
    fileprivate var items: [BPCellViewModel] = []
    fileprivate var prvVotedBps: [BPCellViewModel] = []
    fileprivate var selectedBps: [BPCellViewModel] {
        return items.filter({$0.selected})
    }
    
    fileprivate var applyControlContainer: UIView? = nil
    fileprivate var btnApply: UIButton? = nil
    
    fileprivate let maxVoteCount = 30
    fileprivate let menuControlHeight: CGFloat = 90
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Vote"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        naviBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        naviBar.shadowImage = UIImage()
        naviBar.isTranslucent = true
        naviBar.tintColor = .white
        
        bpList.rowHeight = UITableViewAutomaticDimension
        bpList.estimatedRowHeight = 65
        bpList.dataSource = self
        bpList.delegate = self
        
        let applyButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        applyButton.setTitle("Apply", for: .normal)
        applyButton.titleLabel?.font = Font.appleSDGothicNeo(.medium).uiFont(12)
        applyButton.setTitleColor(UIColor.white, for: .normal)
        let applyItem = UIBarButtonItem(customView: applyButton)
        
        navigationItem.rightBarButtonItems = [applyItem]
        
    }
    
    func configure(viewModel: [BPCellViewModel]) {
        items = viewModel
        prvVotedBps = items.filter { $0.selected }
                        .sorted(by: { (lhs, rhs) -> Bool in
                            return lhs.index < rhs.index
                        })
        
        bpList.reloadData()
    }
    
    private func addApplySectionIfNeeded() {
        if applyControlContainer != nil { return }
        
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let applyView = UIView(frame: CGRect(x: 0, y: window.bounds.height, width: view.bounds.width, height: menuControlHeight))
        applyView.backgroundColor = .white
        
        let hline = UIView(frame: CGRect(x: 0, y: 0, width: applyView.bounds.width, height: 1))
        hline.backgroundColor = Color.seperator.uiColor
        applyView.addSubview(hline)
        
        let halfWidth = (applyView.bounds.width - 30 - 5 ) * 0.5
        
        let applyButton = RoundedButton(frame: CGRect(x: 15, y: 15, width: halfWidth, height: 44))
        applyButton.setTitleColor(UIColor.white, for: .normal)
        applyButton.titleLabel?.font = Font.appleSDGothicNeo(.bold).uiFont(12)
        applyButton.backgroundColor = Color.lightPurple.uiColor
        applyButton.addTarget(self, action: #selector(self.onVoteApplyClicked), for: .touchUpInside)
        
        applyView.addSubview(applyButton)
        
        let cancelButton = PurpleButton(frame: CGRect(x: applyButton.frame.maxX + 5, y: applyButton.frame.minY,
                                                      width: halfWidth, height: 44))
        cancelButton.setTitle(LocalizedString.Common.cancel, for: .normal)
        cancelButton.titleLabel?.font = Font.appleSDGothicNeo(.bold).uiFont(12)
        cancelButton.addTarget(self, action: #selector(self.onVoteCancelled), for: .touchUpInside)
        applyView.addSubview(cancelButton)

        window.addSubview(applyView)
        
        applyControlContainer = applyView
        btnApply = applyButton
        
        updateApplyButton()
    }
    
    fileprivate func updateApplyButton() {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIView.animate(withDuration: 0.25) {
            self.applyControlContainer?.frame.origin.y = window.bounds.height - self.menuControlHeight
        }
        
        let text = LocalizedString.Common.apply + " (\(selectedBps.count)/\(maxVoteCount))"
        btnApply?.setTitle(text, for: .normal)
    }
    
    @objc fileprivate func onVoteApplyClicked() {
        applySelection()
        dismissApplyView()
    }
    
    @objc fileprivate func onVoteCancelled() {
        restoreSelection()
        dismissApplyView()
    }
    
    fileprivate func dismissApplyView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.applyControlContainer?.frame.origin.y = window.bounds.height
        }
//        applyControlContainer?.removeFromSuperview()
//        applyControlContainer = nil
//        btnApply = nil
    }
    
    fileprivate func updateSelection() {
        let prv = prvVotedBps.map({"\($0.index)"}).joined(separator: "")
        let cur = selectedBps.sorted { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }.map({"\($0.index)"}).joined(separator: "")
        
        if prv == cur {
            onVoteCancelled()
        } else {
            addApplySectionIfNeeded()
            updateApplyButton()
        }
    }
    
    fileprivate func restoreSelection() {
        items.forEach { (bp) in
            var bp = bp
            bp.selected = false
        }
        prvVotedBps.forEach { (prvSelectedBp) in
            var bp = items[prvSelectedBp.index]
            bp.selected = true
        }
        
        bpList.reloadData()
        selectFromDataSource()
    }
    
    fileprivate func applySelection() {
        prvVotedBps = selectedBps.sorted(by: { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        })
        bpList.reloadData()
        selectFromDataSource()
    }
    
    fileprivate func selectFromDataSource() {
        selectedBps.map({IndexPath(row: $0.index, section: 0)})
                    .forEach({bpList.selectRow(at: $0, animated: false, scrollPosition: .none)})
    }
    
}

extension VoteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BPCell", for: indexPath) as? BPCell else { preconditionFailure() }
        
        let bp = items[indexPath.row]
        cell.configure(viewModel: bp)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var bp = items[indexPath.row]
        bp.selected = true
        updateSelection()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        var bp = items[indexPath.row]
        bp.selected = false
        updateSelection()
    }

}



