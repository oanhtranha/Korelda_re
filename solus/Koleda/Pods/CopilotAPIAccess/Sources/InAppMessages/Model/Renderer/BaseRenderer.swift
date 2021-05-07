//
//  BaseRenderer.swift
//  CopilotAPIAccess
//
//  Created by Elad on 10/02/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class BaseRenderer<PresentationModel: InAppMessagePresentation> {
    let presentationModel: PresentationModel
    
    init(presentationModel: PresentationModel) {
        self.presentationModel = presentationModel
    }
}
