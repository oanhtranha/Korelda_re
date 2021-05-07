//
//  InAppManager.swift
//  CopilotAPIAccess
//
//  Created by Elad on 13/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation
import CopilotLogger

class InAppManager: InAppManagerAPIAccess, SessionLifeTimeObserver {
    
    private struct Consts {
        static let triggerTimerTimeInterval: TimeInterval = 30
    }
    
    enum InAppActivatedStatus {
        case enable
        case disable
    }
    
    typealias Dependencies = HasReporter & HasInAppServiceInteraction
    private var dependencies: Dependencies
        
    let sessionLifeTimeProvider = SessionLifeTimeProvider()

    private var inAppServerActiveated : InAppActivatedStatus = .disable
    private var inAppUserActivated: InAppActivatedStatus = .enable
    
    private var touchPolicyValidator: TouchPolicyValidator = TouchPolicyValidatorInactive()
    private var configurationManager: InAppConfigurationManagerApi
    private var fetcher: InAppFetcher = InAppFetcherManagerInactive()
    private var inbox: InAppInboxInteractable = InAppInboxInactive()
    private var render: InAppRenderer = InAppRenderingManagerInactive()
    private var reporter: InAppReporter = InAppReporterManagerInactive()
    
    private var triggerTimer: Timer?
    
    @AtomicWrite private var isInSession =  false
    @AtomicWrite private var userId: String? = nil
    
    //in-app messages delegate
    private weak var delegate: InAppMessagesDelegate?
    
    //MARK: - Initializer
    init(reportApiAccess: ReportAPIAccess, sequentialExecutionHelper: MoyaSequentialExecutionHelper) {
        
        
        let bundleConfigurationProvider: ConfigurationProvider = BundleConfigurationProvider()
        
        let inAppServiceInteraction: InAppServiceInteraction = InAppServiceInteraction(configurationProvider: bundleConfigurationProvider, sequentialExecutionHelper: sequentialExecutionHelper)
        
        self.dependencies = InAppDependencies(inAppServiceInteraction: inAppServiceInteraction, reporter: reportApiAccess)
        configurationManager = InAppConfigurationManager(dependencies: dependencies)
        
        //configuration fetched
        configurationManager.configutationRecieved = {[weak self] (configuration) in
            self?.configurationRetrieved(configuration: configuration)
        }
        
        //session awareness
        sessionLifeTimeProvider.add(observer: self)
        
        
        //application did become active
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        //application will resign active
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    
    //MARK: - InAppMessages API
    
    public func enable() {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "In app enabled")
        inAppUserActivated = .enable
        readyToTriggerWhenAvailable()
    }
    
    public func disable() {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "In app disabled")
        inAppUserActivated = .disable
    }
    
    public func setDelegate(_ delegate: InAppMessagesDelegate) {
        self.delegate = delegate
    }
    
    func setAuthProvider(_ authenticationProvider: AuthenticationProvider) {
        dependencies.inAppServiceInteraction.setAuthProvider(authenticationProvider)
    }
    
    //MARK: - SessionLifeTime notifyer
    
    //NOTE! that userId may not exist at this point (because "me" request may not be completed yet)
    func sessionStarted(_ userId: String? = nil) {
        self.userId = userId
        if isInSession == false {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "session started with userId: \(userId ?? "NONE")")
            isInSession = true
            configurationManager.start()
        } else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "already in session with userId: \(userId ?? "NONE")")
        }
    }
    
    func sessionEnded() {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "session ended")
        userId = nil
        isInSession = false
        configurationManager.clear()
        applyInactiveState()
    }

    //MARK: - Private
    
    private func applyActiveState() {
        
        fetcher = InAppFetcherManager(dependencies: dependencies)
        //messages fetched
        fetcher.messagesArrived = {[weak self] (messages) in
            self?.messagesArrived(messages: messages)
        }
        
        inbox = InAppInbox()
        //message triggered
        inbox.messageTriggered = { [weak self] (message) in
            self?.messageTriggered(message: message)
        }
        
        render = InAppRenderingManager()
        
        reporter = InAppReporterManager(dependencies: dependencies)
        
        //register to analytics events
        AnalyticsEventsManager.sharedInstance.eventsDispatcher.eventsListener = self
        
        touchPolicyValidator = DefaultTouchPolicyValidator()
        
        startTriggerTimer()
    }
    
    private func applyInactiveState() {
        
        AnalyticsEventsManager.sharedInstance.eventsDispatcher.eventsListener = nil
        
        fetcher.stop()
        inbox.resetInbox()
        
        reporter = InAppReporterManagerInactive()
        inbox = InAppInboxInactive()
        render = InAppRenderingManagerInactive()
        touchPolicyValidator = TouchPolicyValidatorInactive()
        fetcher = InAppFetcherManagerInactive()
        stopTriggerTimer()
    }
    
    private func messagesArrived(messages: [InAppMessage]) {
        inbox.populateMessages(messages)
        ZLogManagerWrapper.sharedInstance.logInfo(message: "Retrieved in app message list with size \(messages.count)")
    }
    
    private func configurationRetrieved(configuration: InAppMessagesConfiguration) {
        
        let shouldApplyActive = configuration.activated && canAuthenticateInApp(with: configuration.authorizationType)
        
        if shouldApplyActive {
            dependencies.inAppServiceInteraction.setAuthType(authType: configuration.authorizationType, userId: userId)
            applyActiveState()
            inAppServerActiveated = .enable
            touchPolicyValidator = configuration.touchPolicy
            fetcher.pollingInterval = configuration.pollingInterval
            fetcher.start()
        } else {
            inAppServerActiveated = .disable
            applyInactiveState()
        }
    }
    
    private func canAuthenticateInApp(with authType: CopilotAuthType) -> Bool {
        switch authType {
        case .bearer:
            return true
        case .basic:
            return userId != nil
        }
    }
    
    private func messageTriggered(message: InAppMessage) {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "message with \(message.id) messageId was triggered")
        reporter.reportMessageTriggered(generalParameters: message.report.parameters)
        if inAppUserActivated == .enable {
            if touchPolicyValidator.canInteractWithUser() {
                render.render(inAppMessage: message, reporter: reporter, delegate: delegate) { [weak self] (success) in
                     if success {
                        self?.reporter.reportMessageDisplayed(generalParameters: message.report.parameters)
                        message.markAsEvicted()
                        self?.touchPolicyValidator.setInteracted()
                        self?.dependencies.inAppServiceInteraction.postMessageDisplayed(messageId: message.id) { (result) in
                            //TODO: handle errors
                            switch result {
                            case .success(let status):
                                ZLogManagerWrapper.sharedInstance.logInfo(message: "message displayed result success with status: \(status)")
                            case .failure(let error):
                                ZLogManagerWrapper.sharedInstance.logError(message: "message displayed result failure with error: \(error.errorDescription ?? "no error description")")
                            }
                        }
                    } else {
                        //message didn't displayed
                    }
                }
            } else {
                ZLogManagerWrapper.sharedInstance.logInfo(message: "message with \(message.id) wont be dispatched - touch policy blocked")
            }
        } else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "In app disabled")
        }
    }
    
    private func readyToTriggerWhenAvailable() {
        if isInSession {
            inbox.readyToTrigger()
        } else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "application in foreground - but there is no active session")
        }
    }
    
    private func stopTriggerTimer() {
        triggerTimer?.invalidate()
        triggerTimer = nil
    }
    
    private func startTriggerTimer() {
        
        guard triggerTimer == nil else {
            ZLogManagerWrapper.sharedInstance.logError(message: "trigger timer is already active")
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.triggerTimer = Timer.scheduledTimer(withTimeInterval: Consts.triggerTimerTimeInterval, repeats: true, block: { (_) in
                self?.readyToTriggerWhenAvailable()
            })
        }
    }
    
    @objc private func applicationDidBecomeActive() {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "application did become active")
        if isInSession && inAppServerActiveated == .enable {
            configurationManager.start()
            fetcher.start()
            readyToTriggerWhenAvailable()
            startTriggerTimer()
        }
        else {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "application in foreground but there is no active session or Inapp feature is not activated")
        }
    }
    
    @objc private func applicationWillResignActive() {
        ZLogManagerWrapper.sharedInstance.logInfo(message: "application did enter background")
        fetcher.stop()
        stopTriggerTimer()
        configurationManager.clear()
    }
    
}

extension InAppManager: AnalyticsEventReceiver {
    func eventLogged(_ event: AnalyticsEvent) {
        if let _ = event as? CopilotSystemEvent {
            ZLogManagerWrapper.sharedInstance.logInfo(message: "Analytics event ignored - system event")
        } else {
            inbox.analyticsEventReceived(event)
        }
    }
}
