//
//  CoreBluetooth.swift
//  CoreBlueTest
//
//  Created by Jhen Mu on 2022/1/25.
//

import Foundation
import CoreBluetooth

class BlueTooth: NSObject{
    
    static let instance = BlueTooth()
    
    var central:CBCentralManager?
    
    var deviceList:NSMutableArray?
    
    var peripheral:CBPeripheral!
    
    var sendCharacteristic:CBCharacteristic?
    
    
    override init() {
        super.init()
        self.central = CBCentralManager.init(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey:false])
        
        self.deviceList = NSMutableArray()
    }
    
    //MARK:-掃描裝置的方法
    func scanForPeripheralsWithService(_ serviceUUID:[CBUUID]?,options:[String:AnyObject]?){
        self.central?.scanForPeripherals(withServices: serviceUUID, options: options)
    }
    
    //MARK:-停止掃描裝置
    func stopScan(){
        self.central?.stopScan()
    }
    
    //MARK:-寫入資料
    func writeToPeripheral(_ data:Data){
        peripheral.writeValue(data, for: sendCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    }
    
    //MARK:-連線裝置
    func requestConnectPeripheral(_ modal:CBPeripheral){
        if (modal.state != CBPeripheralState.connected){
            central?.connect(modal, options: nil)
        }
    }
}


extension BlueTooth:CBCentralManagerDelegate{
    
    //MARK:-檢查裝置是否支援
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:    print("藍芽開啟")
        case .poweredOff:   print("藍芽關閉")
        case .unauthorized: print("沒有藍芽功能")
        default:            print("未知狀態")
        }
    }
    
    //MARK:-中心裝置掃描到裝置
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard peripheral.name != nil,peripheral.name!.contains("藍芽名稱") else { return }
    }
    
    //MARK:-連線外設成功，開始發現服務
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        self.peripheral = peripheral
    }
    
    //MARK:-連線外設失敗
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DidDisConnectPeriphernalNotification"), object: nil, userInfo: ["deviceList":self.deviceList as AnyObject])
    }
    
}


extension BlueTooth:CBPeripheralDelegate{
    //MARK:-配對服務UUID
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil{ return }
        for service in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //MARK:-服務下的特徵
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (error != nil){ return }
        for characteristic in service.characteristics!{
            switch characteristic.uuid.description {
            case "具體特徵值": peripheral.setNotifyValue(true, for: characteristic)
            case "*****":    peripheral.readValue(for: characteristic)
            default:         print("掃描到其他特徵")
            }
        }
    }
    
    //MARK:-特徵的訂閱體發生變化
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else { return }
        
    }
    
    //MARK:-獲外設發來的資料
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil){ return }
        switch  characteristic.uuid.uuidString{
        case "**********": print("接收到其他裝置的溫度特徵變化")
        default: print("收到了其他資料特徵資料: \(characteristic.uuid.uuidString)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil){
            print("傳送資料失敗!error資訊:\(String(describing: error))")
        }
    }
}
