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
    @State private var score = 0.0
    
    var body: some View {
        
        NavigationStack{
            List{
                Section{
                    TextField("Enter Your Word", text:$currWord)
                        .textInputAutocapitalization(.never)
                }
                Section(header: Text("Current Score")){
                    Text("\(score)")
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
            .toolbar {
                ToolbarItem(placement: .bottomBar){
                    Button("Reset"){
                        resetGame()
                    }
                }
            }
        }
    }
    
    func resetGame(){
        usedWords = [String]()
        rootWord = ""
        currWord = ""
        errorTitle = ""
        errorMessage = ""
        showError = false
        score = 0.0
        startGame()
    }
    
    func error(Title : String, Message : String){
        errorTitle = Title
        errorMessage = Message
        showError = true
    }
    
    func addNewWord(){
        let answer = currWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isShorter(word: answer) else{
            error(Title: "Not Accepted", Message: "Word Length Is Shorter Than 3")
            return
        }
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
        scoreCalculate(word: currWord)
        
        guard answer.count > 0 else {return}
        withAnimation{
            usedWords.insert(currWord, at: 0)
        }
        currWord=""
    }
    func scoreCalculate(word: String){
        score+=2
        score+=Double(word.count) * 0.5
    }
    
    func isShorter(word: String) -> Bool{
        !(currWord.count<3)
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
