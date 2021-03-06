//
//  ApiDelegate.swift
//  Hyperion
//
//  Created by Hack, Thomas on 02.07.20.
//  Copyright © 2020 Hack, Thomas. All rights reserved.
//

import Foundation
import Starscream

public class ApiDelegate: WebSocketDelegate {

    let didConnect: () -> Void
    let didDisconnect: () -> Void
    let didReceiveWebSocketEvent: (ApiEvent) -> Void
    let didUpdateBrightness: (Double) -> Void
    let didUpdateInstances: ([HyperionApi.Instance]) -> Void
    let didUpdateEffects: ([HyperionApi.LightEffect]) -> Void
    let didUpdateComponent: (HyperionApi.Component) -> Void
    let didUpdateComponents: ([HyperionApi.Component]) -> Void
    let didUpdateHostname: (String) -> Void
    let didUpdateSelectedInstance: (Int) -> Void
    let didUpdatePriorities: ([HyperionApi.Priority]) -> Void
    let didUpdateHdrToneMapping: (Bool) -> Void

    public init(
        didConnect: @escaping() -> Void,
        didDisconnect: @escaping() -> Void,
        didReceiveWebSocketEvent: @escaping (ApiEvent) -> Void,
        didUpdateBrightness: @escaping (Double) -> Void,
        didUpdateInstances: @escaping ([HyperionApi.Instance]) -> Void,
        didUpdateEffects: @escaping ([HyperionApi.LightEffect]) -> Void,
        didUpdateComponent: @escaping (HyperionApi.Component) -> Void,
        didUpdateComponents: @escaping ([HyperionApi.Component]) -> Void,
        didUpdateHostname: @escaping (String) -> Void,
        didUpdateSelectedInstance: @escaping (Int) -> Void,
        didUpdatePriorities: @escaping ([HyperionApi.Priority]) -> Void,
        didUpdateHdrToneMapping: @escaping (Bool) -> Void
    ) {
        self.didConnect = didConnect
        self.didDisconnect = didDisconnect
        self.didReceiveWebSocketEvent = didReceiveWebSocketEvent
        self.didUpdateBrightness = didUpdateBrightness
        self.didUpdateInstances = didUpdateInstances
        self.didUpdateEffects = didUpdateEffects
        self.didUpdateComponent = didUpdateComponent
        self.didUpdateComponents = didUpdateComponents
        self.didUpdateHostname = didUpdateHostname
        self.didUpdateSelectedInstance = didUpdateSelectedInstance
        self.didUpdatePriorities = didUpdatePriorities
        self.didUpdateHdrToneMapping = didUpdateHdrToneMapping
    }

    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            self.didConnect()
        case .disconnected, .cancelled:
            self.didDisconnect()
        case .text(let string):
            self.didReceiveText(string)
        case .binary(let data):
            self.didReceiveWebSocketEvent(.binary(data))
        case .ping(_):
            self.didReceiveWebSocketEvent(.ping)
        case .pong(_):
            self.didReceiveWebSocketEvent(.pong)
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .error(let error):
            self.didReceiveWebSocketEvent(.error(error as NSError?))
        }
    }

    private func didReceiveText(_ string: String) {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else { return }
        do {
            let response = try JSONDecoder().decode(HyperionApi.Response.self, from: data)
            switch response {
            case .serverInfo(let serverInfo):
                self.didUpdateInstances(serverInfo.info.instances)
                self.didUpdateHostname(serverInfo.info.hostname)
                self.didUpdateEffects(serverInfo.info.effects)
                self.didUpdateComponents(serverInfo.info.components)
                self.didUpdatePriorities(serverInfo.info.priorities)
                self.didUpdateHdrToneMapping((serverInfo.info.hdrToneMapping != 0))

                if let adjustments = serverInfo.info.adjustments.first {
                    self.didUpdateBrightness(Double(adjustments.brightness))
                }
            case .adjustmentUpdate(let adjustmentUpdate):
                guard let adjustment = adjustmentUpdate.data.first else { return }
                self.didUpdateBrightness(Double(adjustment.brightness))
            case .instanceUpdate(let instanceUpdate):
                self.didUpdateInstances(instanceUpdate.data)
            case .componentUpdate(let componentUpdate):
                self.didUpdateComponent(componentUpdate.data)
            case .hdrToneMappingUpdate(let hdrToneMapping):
                self.didUpdateHdrToneMapping(hdrToneMapping.data.videomodehdr != 0)
            case .unknown:
                print("unknown")
            case .adjustmentResponse(let response), .instanceStart(let response), .instanceStop(let response), .component(let response), .hdrToneMapping(let response):
                if !response.success {
                    print("Something went wrong")
                }
            case .instanceSwitch(let instance):
                self.didUpdateSelectedInstance(instance.info.instance)
            case .priorityUpdate(let priorityUpdate):
                self.didUpdatePriorities(priorityUpdate.data.priorities)
            }
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
