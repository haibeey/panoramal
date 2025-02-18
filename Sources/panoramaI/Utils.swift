//
//  Utils.swift
//  
//
//  Created by Akerele Abraham on 28/01/2025.
//
import Foundation
import UIKit

class Utils{
    func downloadFileAndReturnLocalURL(from url: URL) throws -> URL {
        var result: Result<URL, Error>?
        let semaphore = DispatchSemaphore(value: 0)
        
        downloadFile(from: url) { localURL, error in
            if let error = error {
                result = .failure(error)
            } else if let localURL = localURL {
                result = .success(localURL)
            } else {
                result = .failure(NSError(domain: "DownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred during download."]))
            }
            semaphore.signal()
        }
        
        semaphore.wait()
        
        switch result {
        case .success(let localURL):
            return localURL
        case .failure(let error):
            throw error
        case .none:
            throw NSError(domain: "DownloadError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Download did not complete."])
        }
    }
    
    func downloadFile(from url: URL, completion: @escaping (URL?, Error?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
            guard let localURL = localURL, error == nil else {
                completion(nil, error)
                return
            }
            
            do {
                let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                let destinationDirectory = applicationSupportURL.appendingPathComponent("HiddenFiles", isDirectory: true)
                
                if !FileManager.default.fileExists(atPath: destinationDirectory.path) {
                    try FileManager.default.createDirectory(at: destinationDirectory, withIntermediateDirectories: true, attributes: nil)
                }
                
                let destinationURL = destinationDirectory.appendingPathComponent(url.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                try FileManager.default.moveItem(at: localURL, to: destinationURL)
                completion(destinationURL, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    
    
    func readShader() -> String? {
        
        guard let url = Bundle.module.url(forResource: "Shader", withExtension: "txt") else { return nil }
        return try? String(contentsOf: url, encoding: .utf8)
    }
    
}
