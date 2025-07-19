//
//  6.ABS-Explanation.swift
//  qFocus Browser
//
//

import SwiftUI



struct ABSExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    let filter: AdBlockFilterDisplayItem



    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 6) {

                if filter.preSelectediOS {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                        Text("adblock.label.advised")
                            .font(.callout)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .padding()
                }

                Text(filter.explanation)
                    .padding()

                Spacer()
            }
            .navigationTitle(filter.identName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}
