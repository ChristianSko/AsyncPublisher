//
//  ContentView.swift
//  AsyncPublisher
//
//  Created by Skorobogatow, Christian on 1/8/22.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
        
    }
}

class AsyncPublisherViewModel: ObservableObject {
   @MainActor @Published var dataArray: [String] = []
    
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    init() {
//        addSubcribersWithCombine()
        addSubcribersWithAsyncAwait()
    }
    
    func start() async {
        await manager.addData()
    }
    
    func addSubcribersWithCombine() {
//        manager.$myData
//            .receive(on: DispatchQueue.main, options: nil)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
    
    func addSubcribersWithAsyncAwait() {
        Task {
            for await value in manager.$myData.values {
                await MainActor.run(body: {
                    self.dataArray = value
                })
            }
        }
    }
}

struct AsnycPublisherView: View {
    
    @StateObject var viewModel = AsyncPublisherViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AsnycPublisherView()
    }
}
