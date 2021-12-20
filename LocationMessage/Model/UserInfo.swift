//
//  UserInfo.swift
//  LocationMessage
//
//  Created by 張筱萍 on 2021/4/12.
//

import Foundation

public var currentUserID: Int = 0
public var currentUserName: String = "預設使用者"

public var currentLatitude: Double = 22.995
public var currentLongitude:  Double = 120.212
public var currentCity: String = "台東"      // 縣市
public var currentArea: String = "瑞穗"      // 區
public var currentPostalCode: Int = 100  // 郵政區號
public var currentUserRangeArea: String = "500 M"
public var currentRangeAreaIndex: Int = 0
public var activitySelected: [String: Bool] = ["揪團": true, "好物": true, "美食": true]
//public var activityType = ["揪團", "優惠", "美食"]
