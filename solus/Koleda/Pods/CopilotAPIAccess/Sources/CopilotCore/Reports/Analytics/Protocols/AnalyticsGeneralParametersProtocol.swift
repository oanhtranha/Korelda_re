//
//  AnalyticsGeneralParametersProtocol.swift
//  AOTCore
//
//  Created by Tom Milberg on 10/04/2018.
//  Copyright © 2018 Falcore. All rights reserved.
//

import Foundation

public protocol AnalyticsGeneralParametersProtocol {
    func addGeneralParametersRepository(newGeneralParametersRepository: GeneralParametersRepository) -> Bool
    func replaceGeneralParametersRepository(newGeneralParametersRepository: GeneralParametersRepository) -> GeneralParametersRepository?
    @discardableResult
    func removeGeneralParametersRepository(generalParametersRepositoryToRemove: GeneralParametersRepository) -> Bool
}
