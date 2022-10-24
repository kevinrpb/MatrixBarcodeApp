//
//  ContentView.swift
//  MatrixBarcodeApp
//
//  Created by Romero Peces Barba, Kevin on 24/10/22.
//

import SwiftUI

import QRCode

struct BarcodeItem: Identifiable, Codable, Hashable {
    let id: UUID
    let created: Date
    
    var title: String
    var content: String
    var updated: Date
    
    init(title: String, content: String) {
        self.id = .init()
        
        self.title = title
        self.content = content
        
        self.created = .now
        self.updated = .now
    }
    
    mutating func setTitle(_ title: String) {
        self.title = title
        self.updated = .now
    }
    
    mutating func setContent(_ content: String) {
        self.content = content
        self.updated = .now
    }
    
    mutating func set(title: String, content: String) {
        self.title = title
        self.content = content
        self.updated = .now
    }
}

struct ItemImageView: View {
    @Binding var image: UIImage?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(1))
                .aspectRatio(1, contentMode: .fit)
                .shadow(radius: 2)
            
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

struct ItemGridView: View {
    let item: BarcodeItem
    let action: () -> Void
    
    @State private var image: UIImage? = nil
    
    init(item: BarcodeItem, action: @escaping () -> Void) {
        self.item = item
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            VStack {
                ItemImageView(image: $image)
                
                Text(item.title)
            }
        }
        .buttonStyle(.plain)
        .task {
            withAnimation {
                self.image = QRCode.defaultImage(string: item.content)
            }
        }
    }
}

struct ItemDetailView: View {
    let item: BarcodeItem
    let onClose: (BarcodeItem) -> Void
    
    @State private var editting: Bool = false
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var image: UIImage? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if editting {
                        EdittingRows()
                    } else {
                        StaticRows()
                    }
                } header: {
                    ItemImageView(image: $image)
                        .padding(.bottom)
                }
            }
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if editting {
                        Button("Done") {
                            withAnimation {
                                editting = false
                            }
                        }
                    } else {
                        Button("Edit") {
                            withAnimation {
                                editting = true
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: handleClose) {
                        Label("Close", systemImage: "xmark")
                    }
                }
            }
            .onChange(of: content) { newContent in
                Task {
                    withAnimation {
                        self.image = QRCode.defaultImage(string: newContent)
                    }
                }
            }
            .onAppear {
                title = item.title
                content = item.content
            }
        }
    }
    
    @ViewBuilder
    private func StaticRows() -> some View {
        StaticRow("Title", value: title)
            .id("TitleRow")
        StaticRow("Content", value: content)
            .id("ContentRow")
    }
    
    @ViewBuilder
    private func EdittingRows() -> some View {
        EdittingRow("Title", value: $title)
            .id("TitleRow")
        EdittingRow("Content", value: $content)
            .id("ContentRow")
    }
    
    private func StaticRow(_ titleKey: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(titleKey)
                .font(.body.bold())
            Spacer()
            Text(value)
        }
    }
    
    private func EdittingRow(_ titleKey: LocalizedStringKey, value: Binding<String>) -> some View {
        HStack {
            Text(titleKey)
                .font(.body.bold())
            Spacer()
            TextField(titleKey, text: value)
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.never)
        }
    }
    
    private func handleClose() {
        var newItem = item
        
        newItem.setTitle(title)
        newItem.setContent(content)
        
        onClose(newItem)
    }
}

struct ContentView: View {
    @State private var navigationPath: NavigationPath = .init()
    @State private var sheetItem: BarcodeItem? = nil
    
    @State var columns: Int = 2
    @State var items: [BarcodeItem] = [
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: columns)) {
                    ForEach(items) { item in
                        ItemGridView(item: item) {
                            sheetItem = item
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("MaQRix")
            .sheet(item: $sheetItem) { item in
                ItemDetailView(item: item) { item in
                    updateItem(item)
                    sheetItem = nil
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Label("New code", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func updateItem(_ newItem: BarcodeItem) {
        guard
            let oldItem = items.first(where: { $0.id == newItem.id }),
            let index = items.firstIndex(of: oldItem)
        else { return }
        
        withAnimation {
            items[index] = newItem
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
