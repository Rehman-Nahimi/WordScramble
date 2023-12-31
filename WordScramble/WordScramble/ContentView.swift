//
//  ContentView.swift
//  WordScramble
//
//  Created by Ray Nahimi on 08/09/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    var body: some View {
        NavigationView{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                Section{
                    ForEach(usedWords, id:\.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).square")
                            Text(word)
                        }
                        
                    }
                }
                Section {
                    Text("Your current score is: \(score)")
                }
            }
            .toolbar{
                Button("Refresh", action: startGame)
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError){
                Button("OK", role: .cancel) { }
            
            } message: {
                Text(errorMessage)
            }
        }
    }
    func addScore() {
        score = newWord.count + score
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {return}
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "Doesn't work")
            return
        }
        guard isReal(word: answer) else{
            wordError(title: "Word doesn't exist", message: "Come on now")
            return
        }
        guard tooSmall(word: answer) else{
            wordError(title: "Word is too small", message: "We only accept words greated than 3 letters")
            return
        }
        
        withAnimation{
            
            usedWords.insert(answer, at: 0)
        }
        addScore()
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load file.txt")
    }
    func isOriginal(word:String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word:String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func tooSmall(word:String) -> Bool {
        if newWord.count <= 3 {
            return false
    }
    else {
        return true}
    }
    func isReal(word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    func wordError(title:String, message:String){
        errorTitle = title
        errorMessage = message
        showingError = true
        
    }
    
}
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

