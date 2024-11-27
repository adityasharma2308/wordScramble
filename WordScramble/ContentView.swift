//
//  ContentView.swift
//  WordScramble
//
//  Created by Aditya Sharma on 27/11/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var currWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        
        NavigationStack{
            List{
                Section{
                    TextField("Enter Your Word", text:$currWord)
                        .textInputAutocapitalization(.never)
                    
                    HStack(spacing: 10) {
                        ForEach(Array(rootWord), id: \.self) { character in
                            Button(action: {
                                currWord.append(character)
                            }) {
                                Text(String(character))
                                    .font(.largeTitle)
                                    .padding(10) // Padding to make the button large enough for tap interaction
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle()) // Make it circular
                                    .shadow(radius: 3)
                            }
                        }
                    }
                }
                
                Section {
                    ForEach(usedWords, id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError) {
                Button("Ok"){ }
            }message: {
                Text(errorMessage)
            }
        }
    }
    
    func error(Title : String, Message : String){
        errorTitle = Title
        errorMessage = Message
        showError = true
    }
    
    func addNewWord(){
        let answer = currWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isOriginal(word: answer) else {
            error(Title: "Already Taken", Message: "You have already enterd that word")
            return
        }
        
        guard isPossible(word: answer) else{
            error(Title: "Not Possible", Message: "This word is not made from the given word")
            return
        }
        
        guard isValid(word: answer) else{
            error(Title: "Invalid Word", Message: "Please Don't write anything in your mind")
            return
        }
        
        guard answer.count > 0 else {return}
        withAnimation{
            usedWords.insert(currWord, at: 0)
        }
        currWord=""
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }
            else{
                return false
            }
        }
        return true
    }
    
    func isValid(word: String) -> Bool{
        let checker = UITextChecker()
        
        let range = NSRange(location: 0, length: word.utf16.count)
        
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func startGame(){
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "gamer"
                return
            }
        }
        fatalError("Error Loding Game")
    }
}

#Preview {
    ContentView()
}
