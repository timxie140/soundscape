//
//  GDATelemetry.swift
//  Soundscape
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import Foundation
//import AppCenterAnalytics
import Sentry

public class GDATelemetry {
    
    static var helper: TelemetryHelper?
    
    static var debugLog = false
    
    class var enabled: Bool {
        get {
            return !SettingsContext.shared.telemetryOptout
        }
        set {
            SettingsContext.shared.telemetryOptout = !newValue
//            Analytics.enabled = newValue
            if newValue {
                 SentrySDK.start { options in
                     options.dsn = AppContext.sentryDSN
                     options.debug = true
                     options.sampleRate = SettingsContext.shared.telemetryOptout ? 1.0 : 0.0
                     options.tracesSampleRate = 1.0
                     options.enableAutoPerformanceTracing = true
                     options.swiftAsyncStacktraces = true
                 }
             }
        }
    }
    
    class func trackScreenView(_ screenName: String, with properties: [String: String]? = nil) {
        var propertiesToSend = properties ?? [:]
        propertiesToSend["screen_name"] = screenName

        track("screen_view", with: propertiesToSend)
    }
    
    class func track(_ eventName: String, value: String) {
        track(eventName, with: ["value": value])
    }
    
    class func track(_ eventName: String, with properties: [String: String]? = nil) {
        var propertiesToSend = properties ?? [:]
        propertiesToSend["user_id"] = SettingsContext.shared.clientId
        
        // Add default event properties
        if let helper = helper {
            propertiesToSend = propertiesToSend.merging(helper.eventSnapshot) { (current, _) in current }
        }
        
        if debugLog {
            print("[TEL] Event tracked: \(eventName)" + (propertiesToSend.isEmpty ? "" : " \(propertiesToSend)"))
        }
        
//        Analytics.trackEvent(eventName, withProperties: propertiesToSend)
        
        let crumb = Breadcrumb()
        crumb.message = eventName
        crumb.type = "default"
        crumb.data = propertiesToSend
        SentrySDK.addBreadcrumb(crumb)
    }
    
}
