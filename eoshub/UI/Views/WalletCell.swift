//
//  WalletCell.swift
//  eoshub
//
//  Created by kein on 2018. 7. 9..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class WalletCell: UITableViewCell {
    @IBOutlet fileprivate weak var account: UILabel!
    @IBOutlet fileprivate weak var lbReceive: UILabel!
    @IBOutlet fileprivate weak var total: UILabel!
    @IBOutlet fileprivate weak var estimatedPrice: UILabel!
    @IBOutlet fileprivate weak var progress: MultiProgressBar!
    @IBOutlet fileprivate weak var availableEOS: UILabel!
    @IBOutlet fileprivate weak var lbDetail: UILabel!
    @IBOutlet fileprivate weak var layoutContainerY: NSLayoutConstraint!
    @IBOutlet fileprivate weak var buttonContainer: UIView!
    @IBOutlet fileprivate weak var btnSend: UIButton!
    @IBOutlet fileprivate weak var btnReceive: UIButton!
    @IBOutlet fileprivate weak var btnAddTokens: UIButton!
    @IBOutlet fileprivate weak var bg: UIImageView!
    @IBOutlet fileprivate weak var icon0: UIButton!
    @IBOutlet fileprivate weak var icon1: UIButton!
    
    private var bag: DisposeBag? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = nil
    }
    
    deinit {
        bag = nil
        NSLog("deinit")
    }
    
    private func setupUI() {
        lbReceive.text = LocalizedString.Wallet.receive
        
        lbDetail.text = LocalizedString.Wallet.details

        btnSend.setTitle(LocalizedString.Wallet.send, for: .normal)
        btnAddTokens.setTitle(LocalizedString.Wallet.Option.addToken, for: .normal)
        
        let eosStates: [EOSState] = [.available, .staked, .refunding]
        
        progress.configure(items: eosStates)
    }
    
    
    func configure(viewModel: AccountInfo,
                   sendObserver: PublishSubject<AccountInfo>,
                   receiveObserver: PublishSubject<AccountInfo>,
                   menuObserver: PublishSubject<AccountInfo>) {
        
        let bag = DisposeBag()
        
        account.text = viewModel.account
        total.text = viewModel.totalEOS.dot4String
        
        availableEOS.text =  "(\(viewModel.availableEOS.dot4String) EOS" + LocalizedString.Wallet.available + ")"
        
       
        let marginBottom: CGFloat = 35
        if viewModel.ownerMode == false {
            buttonContainer.isHidden = true
            layoutContainerY.constant = -buttonContainer.bounds.height + marginBottom
        } else {
            buttonContainer.isHidden = false
            layoutContainerY.constant = marginBottom
        }
        layoutIfNeeded()
        
        let staked = EOSAmount(id: EOSState.staked.id, value: viewModel.stakedEOS.f)
        let refunding = EOSAmount(id: EOSState.refunding.id, value: viewModel.refundingEOS.f)
        let available = EOSAmount(id: EOSState.available.id, value: viewModel.availableEOS.f)
        
        progress.setProgressValues(values: [available, staked, refunding])
        
        btnSend.rx.singleTap
            .bind {
                sendObserver.onNext(viewModel)
            }
            .disposed(by: bag)
        
        btnReceive.rx.singleTap
            .bind {
                receiveObserver.onNext(viewModel)
            }
            .disposed(by: bag)
        
        btnAddTokens.rx.singleTap
            .bind {
                menuObserver.onNext(viewModel)
            }
            .disposed(by: bag)
        
        if viewModel.ownerMode {
            bg.image = #imageLiteral(resourceName: "walletbg0")
        } else {
            bg.image = #imageLiteral(resourceName: "walletbg2")
        }
        
        //refund
//        remainTimeView.isHidden = (viewModel.refundingEOS == 0)
//        if viewModel.refundRequestTime > 0 {
//            refundingEOS.text = viewModel.refundingEOS.dot4String
//
//            let remain = viewModel.refundingTime - Date().timeIntervalSince1970
//            remainTime.text = remain.stringTime
//
//            let _ = Observable<Int>
//                .interval(1, scheduler: MainScheduler.instance)
//                .subscribe(onNext: { [weak self] (_) in
//                    let remain = viewModel.refundingTime - Date().timeIntervalSince1970
//                    self?.remainTime.text = remain.stringTime
//                })
//                .disposed(by: bag)
//
//        }
        
        //estimatedPrice
        let repoKeychain = viewModel.hasRepoKeychain
        let repoSE = viewModel.hasRepoSE
       
        if repoSE && repoKeychain == false {
            icon0.setImage(#imageLiteral(resourceName: "shield"), for: .normal)
            icon0.tintColor = Color.progressMagenta.getUIColor()
            icon0.isHidden = false
            icon1.isHidden = true
        } else if repoSE == false && repoKeychain {
            icon0.setImage(#imageLiteral(resourceName: "keychain"), for: .normal)
            icon0.tintColor = Color.progressOrange.getUIColor()
            icon0.isHidden = false
            icon1.isHidden = true
        } else if repoSE && repoKeychain {
            icon0.setImage(#imageLiteral(resourceName: "shield"), for: .normal)
            icon0.tintColor = Color.progressMagenta.getUIColor()
            icon1.setImage(#imageLiteral(resourceName: "keychain"), for: .normal)
            icon1.tintColor = Color.progressOrange.getUIColor()
            icon0.isHidden = false
            icon1.isHidden = false
        } else {
            icon0.isHidden = true
            icon1.isHidden = true
        }
        
        
        ExchangeManager.shared.lastPrice
            .asObservable()
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self](price) in
                if viewModel.isInvalidated {
                    return
                }
                
                if let estimatedString = price?.estimatedPrice(eosQuantity: viewModel.totalEOS) {
                    self?.estimatedPrice.text = "≈ " + estimatedString
                } else {
                    self?.estimatedPrice.text = nil
                }
            })
            .disposed(by: bag)
        
        
        
        self.bag = bag
        
    }

}
