//
//  ContentView.swift
//  FetchData
//
//  Created by Pedro Alejandro on 9/29/22.
//https://bible-api.com/john%203:16
//https://iosacademy.io/api/v1/courses/

import SwiftUI

struct Bible:Codable {
//    var id = UUID()
    var reference:String
    var text:String
//    var verses:[Verse]


}

enum ApiError: Error {
    case dataIsNil
}


struct Verse:Decodable,Hashable {
    var book_id:String
    var book_name:String
    var chapter:Int
    var verse:Int
    var text:String
}


class ApiCall{
    
    //https://bible-api.com/\($chapter)%20\($verseNumber):\($verseParahgrap)"
    
    func getData(completion:@escaping(Result<Bible,Error>)->(), Search: String?) {
        guard let url = URL(string: "https://bible-api.com/\(Search ?? "")") else {return}
        URLSession.shared.dataTask(with: url) { data, res, error in
            if let error = error{
                print(error)
                completion(.failure(error))
                return
            }
            
            guard let data = data else{
                print("data is nil")
                completion(.failure(ApiError.dataIsNil))
                return
            }
            
            do{
                let info = try JSONDecoder().decode(Bible.self, from: data)
                print(info)
                DispatchQueue.main.async {
                    completion(.success(info))
                    
                }
                
            }catch{
                print(error)
                completion(.failure(error))
                
            }
        }
        .resume()
    }
}
    







struct ContentView: View {
    
    @State var bibleData:Bible?
    @State var search = ""
    @State var showSheetView = false
    @State private var navigationButtonID = UUID()
       


    
    var body: some View {
        NavigationView {
            VStack{
                
                TextField("Search Verse Example(john3:16)", text: $search)
                
                Button {
                    ApiCall().getData(completion: { result in
                        switch result {
                        case .success(let data):
                            self.bibleData = data
                            search = ""
                            
                        case .failure(let err):
                            print(err)
                        }
                    }, Search: search)
                } label: {
                    Text("search")
                   
                }
                Spacer()
                
                Text(bibleData?.text ?? "")

                
            }
            .padding()
           
                   .navigationBarTitle(bibleData?.reference ?? "Loading")
        
    }
}





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}






struct SearchView:View{
    @Environment(\.dismiss) var dismiss
    @State var info:String?
    @State var isShowing = false
    @State var bibleData:Bible?
    @State var chapterName = ""
    @State var chapterverse = ""
    
    
    
    
    var body: some View{
        VStack{
            Text("search Verse")
                .font(.title)
                .padding()
            
            
            
            Form {
                Section{
                    TextField("Chapter Name", text: $chapterName)
                    TextField("chapter Verse", text: $chapterverse)
                    
                }
                
            }
        }
        
        
        Button {
            dismiss()
            //TODO:Search for the data and send the result to the main page
            ApiCall().getData(completion: { result in
                switch result {
                case .success(let data):
                    self.bibleData = data
                    self.info?.append(data.reference)
                    
                case .failure(let err):
                    print(err)
                }
            }, Search: chapterName)
            
        } label: {
            Text("search verse")
                .frame(width: 200,height: 50,alignment: .center)
                .background(Color.blue)
                .foregroundColor(.white)
            
                .cornerRadius(8)
            }
        
        }
    }
        
}
