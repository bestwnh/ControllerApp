//
//  ContentView.swift
//  ControllerApp
//
//  Created by Galvin on 2019/10/24.
//  Copyright © 2019 GalvinLi. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var usbDetector: IOUSBDetector?
    var deviceList: [Device] = []
    var body: some View {
        VStack{
            Text(DriverHelper.rootDirectory?.absoluteString ?? "null")
            Text(DriverHelper.infoPlistPath()?.absoluteString ?? "null")
            Text(String(DriverHelper.getTypes().count)).frame(width: 400, height: nil, alignment: .leading)
            Text(String(DriverHelper.getTypes().joined(separator: "\n"))).frame(width: 400, height: nil, alignment: .leading)

        }
    }
    
    init() {
        print("view init")
        
        usbDetector = IOUSBDetector(vendorID: 0x045e, productID: 0x02dd)
//        usbDetector = IOUSBDetector(vendorID: 0x045e, productID: 0x02d1)

        usbDetector?.callbackQueue = DispatchQueue.global()
        usbDetector?.callback = {
            (detector, event, service) in
                print("!!Event \(event)")
        };
        _ = usbDetector?.startDetection()
        
        self.deviceList = DriverHelper.getDeviceList()
        print(self.deviceList)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


