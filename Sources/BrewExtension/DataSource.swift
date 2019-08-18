//
//  DataSource.swift
//  BrewExtension
//
//  Created by Zehua Chen on 8/18/19.
//

/// An umbrella data source protocol for datasource protocol of all operations
public protocol DataSource:
    FindUninstallablesOperationDataSource,
    UninstallOperationDataSource,
    SyncOperationDataSource {

}
