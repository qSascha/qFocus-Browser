//
//  iOSAdBlockLoad.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct AdBlockLoadStatus: View {
    @InjectedObject(\.adBlockUC) var viewModel: AdBlockFilterUC


    
    var body: some View {

        VStack {
            Spacer()
            
            HStack(spacing: 32) {
                ProgressView()
                Text("adblock.update.message \(viewModel.updateCounter)/\(viewModel.totalCounter)")
                    .font(.caption)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .glassEffect()
            .offset(y: -110)

        }
    }
}

