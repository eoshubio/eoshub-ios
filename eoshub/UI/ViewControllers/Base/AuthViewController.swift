//
//  AuthManager.swift
//  eoshub
//
//  Created by kein on 2018. 7. 28..
//  Copyright © 2018년 EOS Hub. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import RxSwift
import CryptoKit
import AuthenticationServices

class AuthViewController: BaseViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func login(with type: LoginType) {
        switch type {
        case .apple:
            loginWithApple()
        case .facebook:
            loginWithFacebook()
        case .google:
            loginWithGoogle()
        case .none:
            loginAnonymously()
        
        default:
            break
        }
        
    }
    
    private func loginWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func loginWithGoogle() {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    //MARK: Facebook
    private func loginWithFacebook() {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { [weak self](result, error) in
            if let error = error {
                Log.e(error)
                self?.failToLogin(error: error)
                return
            }
            
            if result?.isCancelled == true {
                Log.e("Canceled")
                self?.failToLogin(error: nil)
                return
            } else {
                Log.i("Logged in")
                self?.handleLoggedInWithFacebook()
            }
        }
    }
    
    
    private func handleLoggedInWithFacebook() {
        if FBSDKAccessToken.current() != nil {
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
                .start { [weak self] (connection, result, error) in
                    if error == nil {
                        
                        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                        self?.handleCredential(credential: credential)
                    } else {
                        self?.failToLogin(error: error!)
                    }
            }
        }
        
        
       
    }
    
    
    //MARK: Google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            failToLogin(error: error)
        }
        
        guard let authentication = user?.authentication else {
            failToLogin(error: nil)
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        handleCredential(credential: credential)
    }
    
    //MARK: Email Password
//    @remarks Possible error codes:
//
//    + `FIRAuthErrorCodeInvalidEmail` - Indicates the email address is malformed.
//    + `FIRAuthErrorCodeEmailAlreadyInUse` - Indicates the email used to attempt sign up
//    already exists. Call fetchProvidersForEmail to check which sign-in mechanisms the user
//    used, and prompt the user to sign in with one of those.
//    + `FIRAuthErrorCodeOperationNotAllowed` - Indicates that email and password accounts
//    are not enabled. Enable them in the Auth section of the Firebase console.
//    + `FIRAuthErrorCodeWeakPassword` - Indicates an attempt to set a password that is
//    considered too weak. The NSLocalizedFailureReasonErrorKey field in the NSError.userInfo
//    dictionary object will contain more detailed explanation that can be shown to the user.
//
//    @remarks See `FIRAuthErrors` for a list of error codes that are common to all API methods.

    
    
    //MARK: EmailLink
    private func loginWithEmail(email: String) {
        //send sing in link request
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://eoshub.page.link/email")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail: email,
                                   actionCodeSettings: actionCodeSettings) { error in
                                    // ...
                                    if let error = error {
                                        Log.e(error)
                                        return
                                    }
                                    // The link was successfully sent. Inform the user.
                                    // Save the email locally so you don't need to ask the user for it again
                                    // if they open the link on the same device.
//                                    UserDefaults.standard.set(email, forKey: "Email")
//                                    self.showMessagePrompt("Check your email for link")
                                    // ...
        }
    }
    
    //MARK: Anonymous
    private func loginAnonymously() {
        Auth.auth().signInAnonymously() { [weak self](user, error) in
            guard let user = user else { return }
            
            if let error = error {
                self?.failToLogin(error: error)
                return
            }
            
            self?.loggedIn(user: user)
            
            Log.i("User is signed in Anonymously")
        }
    }
    
    
    private func handleCredential(credential: AuthCredential) {
        WaitingView.shared.start()
        Auth.auth().signInAndRetrieveData(with: credential) { [weak self](user, error) in
            WaitingView.shared.stop()
            if let error = error {
                 self?.failToLogin(error: error)
                return
            }
            
            guard let user = user else { return }
            
            
            self?.loggedIn(user: user)
        }
    }
    
   
    func loggedIn(user: AuthDataResult) {
        //override it
        Log.i("User is signed in")
    }
    
    func failToLogin(error: Error?) {
        
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)

            Auth.auth().signIn(with: credential) { [weak self](result, error) in
                if error == nil, let result = result {
                    self?.loggedIn(user: result)
                } else {
                    debugPrint(error!.localizedDescription)
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        preconditionFailure()
//    }
    
}
