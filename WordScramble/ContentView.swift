//
//  ContentView.swift
//  WordScramble
//
//  Created by Mathieu Dubart on 06/08/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = "" //the one they're spelling from eight letter word
    @State private var newWord = "" //bind to text field to store word while typing
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Text("Your score: \(score)")
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement()
                        .accessibilityLabel(word)
                        .accessibilityHint("\(word.count) letters")
                    }
                }
            }
            .navigationTitle(rootWord)
            .navigationBarTitleDisplayMode(.large)
            .toolbar() {
                Button("Restart game", action: startGame)
                    .foregroundColor(.red)
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
        }
        .alert(errorTitle, isPresented: $showingError) {
            Button("OK", role:.cancel){}
        } message: {
            Text(errorMessage)
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 3 && answer != rootWord else { return }
        
        guard !isAlreadyUsed(word: answer) else {
            wordError(title: "World already used", message: "Try an other word")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word isn't possible", message: "Can't spell that word from '\(rootWord)'")
            return
        }
        
        guard isExisting(word: answer) else {
            wordError(title: "Word doesn't exist", message: "Try an existing one")
            return
        }
        
        calculateScore(word: answer)
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }

        fatalError("Could not load start.txt from bundle.")
    }
    
    func isAlreadyUsed(word: String) -> Bool {
        usedWords.contains(word) ? true : false
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isExisting(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func calculateScore(word: String) {
        score += word.count
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
