//
//  ServiceDelegate.swift
//  Flicks
//
//  Created by Nguyen Quang Ngoc Tan on 2/16/17.
//  Copyright © 2017 Nguyen Quang Ngoc Tan. All rights reserved.
//

import Foundation

protocol ServiceDelegate {
    func onLoadSuccess(response: Data?)
    func onLoadError(error: Error?)
}
