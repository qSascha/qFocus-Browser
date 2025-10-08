//
//  iOSAdBlockLoad.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct iPadAdBlockLoadStatus: View {
    @InjectedObject(\.adBlockUC) var viewModel: AdBlockFilterUC


    var body: some View {
        if #available(iOS 26.0, *) {
            
            VStack {
                Spacer()
                
                HStack(spacing: 32) {
                    ProgressView()
                    VStack(alignment: .leading) {
                        
                        Text("adblock.update.message \(viewModel.updateCounter)/\(viewModel.totalCounter)")
                            .font(.caption)
                        
                        if viewModel.triggeredManually {
                            Text("adblock.update.msgManually")
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .glassEffect()
                .offset(y: -110)
                
            }
            
        } else {
            
            // Legacy Versions
            VStack {
                Spacer()
                
                HStack(spacing: 32) {
                    ProgressView()
                    VStack(alignment: .leading) {
                        
                        Text("adblock.update.message \(viewModel.updateCounter)/\(viewModel.totalCounter)")
                            .font(.caption)
                        
                        if viewModel.triggeredManually {
                            Text("adblock.update.msgManually")
                                .font(.caption)
                        }
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 24)
                .background(Color.gray.gradient.opacity(0.94))
                .cornerRadius(20)
                .offset(y: -110)
                
            }
            
        }
    }
}

