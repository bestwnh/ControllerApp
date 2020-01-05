//
//  DeviceRumble.swift
//  DemoApp
//
//  Created by Galvin on 2020/1/6.
//  Copyright © 2020 GalvinLi. All rights reserved.
//

import Foundation
import ForceFeedback
import ForceFeedback.ForceFeedbackConstants

class DeviceRumble {
    private var effect: FFEFFECT?
    private var customForce: FFCUSTOMFORCE?
    private var effectRef: FFEffectObjectReference?
    private var largeMotor: Int32 = 0 // 0~255
    private var smallMotor: Int32 = 0 // 0~255
    
    private var ffDevice: FFDeviceObjectReference? {
        didSet {
            stopRumbleMotor()
        }
    }
    
    deinit {
        stopRumbleMotor()
    }
}

extension DeviceRumble {
    func startRumbleMotor(ffDevice: FFDeviceObjectReference?) {
        guard let ffDevice = ffDevice else { return }
        self.ffDevice = ffDevice
        var capabs = FFCAPABILITIES()
        FFDeviceGetForceFeedbackCapabilities(ffDevice, &capabs)
        
        guard capabs.numFfAxes == 2 else { return }
        
        var effect = calloc(1, MemoryLayout<FFEFFECT>.size).load(as: FFEFFECT.self)
        var customForce = calloc(1, MemoryLayout<FFCUSTOMFORCE>.size).load(as: FFCUSTOMFORCE.self)
        self.effect = effect
        self.customForce = customForce
        
        let rglForceData = calloc(2, MemoryLayout<LPLONG>.size).load(as: LPLONG.self)
        let rgdwAxes = calloc(2, MemoryLayout<LPDWORD>.size).load(as: LPDWORD.self)
        let rglDirection = calloc(2, MemoryLayout<LPLONG>.size).load(as: LPLONG.self)
        
        rglForceData[0] = 0
        rglForceData[1] = 0
        rgdwAxes[0] = DWORD(capabs.ffAxes.0)
        rgdwAxes[1] = DWORD(capabs.ffAxes.1)
        rglDirection[0] = 0
        rglDirection[1] = 0
        
        customForce.cChannels = 2
        customForce.cSamples = 2
        customForce.rglForceData = rglForceData
        customForce.dwSamplePeriod = 100_000
        
        effect.cAxes = capabs.numFfAxes
        effect.rglDirection = rglDirection
        effect.rgdwAxes = rgdwAxes
        effect.dwSamplePeriod = 0
        effect.dwGain = 10000
        effect.dwFlags = DWORD(FFEFF_OBJECTOFFSETS) | DWORD(FFEFF_SPHERICAL)
        effect.dwSize = DWORD(MemoryLayout<FFEFFECT>.size)
        effect.dwDuration = DWORD(FF_INFINITE)
        effect.dwSamplePeriod = 100_000
        effect.cbTypeSpecificParams = DWORD(MemoryLayout<FFCUSTOMFORCE>.size)
        effect.lpvTypeSpecificParams = UnsafeMutableRawPointer(&customForce)
        effect.lpEnvelope = nil
        FFDeviceCreateEffect(ffDevice, kFFEffectType_CustomForce_ID, &effect, &effectRef)
        
        resetRumbleMotor()
        largeMotor = 0
        smallMotor = 0
    }
    
    func stopRumbleMotor() {
        resetRumbleMotor()

        guard effectRef != nil else { return }
        
        FFDeviceReleaseEffect(self.ffDevice, effectRef)
        if customForce != nil {
            free(customForce?.rglForceData)
            free(&customForce)
            customForce = nil
        }
        if effect != nil {
            free(effect?.rgdwAxes)
            free(effect?.rglDirection)
            free(&effect)
            effect = nil
        }
        effectRef = nil
    }
    func activeRumbleMotor(large: Int32) {
        activeRumbleMotor(large: large, small: nil)
    }
    func activeRumbleMotor(small: Int32) {
        activeRumbleMotor(large: nil, small: small)
    }
    func resetRumbleMotor() {
        activeRumbleMotor(large: 0, small: 0)
    }
    private func activeRumbleMotor(large: Int32?, small: Int32?) {
        largeMotor = large ?? largeMotor
        smallMotor = small ?? smallMotor
        guard effectRef != nil, effect != nil else { return }
        customForce?.rglForceData[0] = LONG(largeMotor * 10000 / 255)
        customForce?.rglForceData[1] = LONG(smallMotor * 10000 / 255)
        FFEffectSetParameters(effectRef, &effect!, FFEP_TYPESPECIFICPARAMS)
        FFEffectStart(effectRef, 1, 0)
    }
}
