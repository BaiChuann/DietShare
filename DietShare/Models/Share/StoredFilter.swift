//
//  StoredFilter.swift
//  DietShare
//
//  Created by Fan Weiguang on 26/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

class StoredFilter {
    static let shared = StoredFilter()
    private var filters = [(String, String)]()
    var count: Int {
        return filters.count
    }

    private init() {
        filters = [
            ("Normal", "No Filter"),
            ("Chrome", "CIPhotoEffectChrome"),
            ("Fade", "CIPhotoEffectFade"),
            ("Instant", "CIPhotoEffectInstant"),
            ("Mono", "CIPhotoEffectMono"),
            ("Noir", "CIPhotoEffectNoir"),
            ("Process", "CIPhotoEffectProcess"),
            ("Tonal", "CIPhotoEffectTonal"),
            ("Transfer", "CIPhotoEffectTransfer"),
            ("Tone", "CILinearToSRGBToneCurve"),
            ("Linear", "CISRGBToneCurveToLinear")
        ]
    }

    func getFilterText(_ index: Int) -> String {
        return filters[index].0
    }

    func getFilterName(_ index: Int) -> String {
        return filters[index].1
    }
}
