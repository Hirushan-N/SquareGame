//
//  SquareGame.swift
//  SquareGame
//
//  Created by Nadeesh Hirushan on 2025-01-11.
//

import SwiftUI

struct StartScreen: View {
    @Binding var gameState: GameState

    var body: some View {
        VStack(spacing: 30) {
            Text("Square Game")
                .font(.largeTitle)
                .fontWeight(.bold)

            Button(action: {
                gameState = .game
            }) {
                Text("Start Game")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                gameState = .guidelines
            }) {
                Text("Game Guidelines")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                gameState = .scoreboard
            }) {
                Text("Scoreboard")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: {
                exit(0) // Exit the app (works on real devices, not in the simulator)
            }) {
                Text("Exit Game")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct GuidelinesScreen: View {
    @Binding var gameState: GameState

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Guidelines")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("1. Tap two buttons to select them.\n2. Match the colors to score points.\n3. The game ends when all pairs are matched.\n4. Try to beat your high score!")
                .font(.title3)
                .multilineTextAlignment(.leading)

            Button(action: {
                gameState = .start
            }) {
                Text("Back to Start")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ScoreboardScreen: View {
    @Binding var gameState: GameState
    let highScore: Int

    var body: some View {
        VStack(spacing: 20) {
            Text("Scoreboard")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("High Score: \(highScore)")
                .font(.title)
                .padding()

            Button(action: {
                gameState = .start
            }) {
                Text("Back to Start")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct ContentView: View {
    @State private var gameState: GameState = .start
    @State private var buttonColors: [Color] = []
    @State private var selectedButtons: [Bool] = Array(repeating: false, count: 9)
    @State private var disabledButtons: [Bool] = Array(repeating: false, count: 9)
    @State private var score: Int = 0
    @State private var highScore: Int = 0
    @State private var message: String = ""
    @State private var timer: Timer? = nil
    @State private var timeRemaining: Int = 30

    init() {
        resetColors()
    }

    func checkMatch() {
        let selectedColors = zip(buttonColors, selectedButtons).filter { $0.1 == true }

        if selectedColors.count == 2 {
            if selectedColors[0].0 == selectedColors[1].0 {
                score += 1
                message = "Correct Selection!"

                if let firstIndex = selectedButtons.firstIndex(of: true),
                   let secondIndex = selectedButtons.lastIndex(of: true) {
                    disabledButtons[firstIndex] = true
                    disabledButtons[secondIndex] = true
                }
            } else {
                message = "Wrong Selection"
            }

            selectedButtons = Array(repeating: false, count: 9)
        }

        if score == 4 {
            highScore = max(highScore, score)
            displayCongratsMessage()
        }
    }

    func resetColors() {
        // Define exactly 5 colors with the required distribution
        let colors: [Color] = [.red, .red, .blue, .blue, .green, .green, .yellow, .yellow, .purple]
        buttonColors = colors.shuffled() // Shuffle the colors
    }

    func resetGame() {
        score = 0
        timeRemaining = 30
        message = ""
        disabledButtons = Array(repeating: false, count: 9)
        selectedButtons = Array(repeating: false, count: 9)
        resetColors()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                message = "Time's Up!"
                resetGame()
            }
        }
    }

    func displayCongratsMessage() {
        message = "Congratulations! You matched all pairs."
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            resetGame()
            gameState = .start
        }
    }

    var body: some View {
        switch gameState {
        case .start:
            StartScreen(gameState: $gameState)

        case .guidelines:
            GuidelinesScreen(gameState: $gameState)

        case .scoreboard:
            ScoreboardScreen(gameState: $gameState, highScore: highScore)

        case .game:
            VStack {
                Text("Score: \(score)")
                    .font(.title)
                    .padding()

                Text("High Score: \(highScore)")
                    .font(.title2)
                    .padding()

                Text("Time Remaining: \(timeRemaining) sec")
                    .font(.title3)
                    .padding()
                    .foregroundColor(timeRemaining <= 10 ? .red : .black)

                VStack(spacing: 20) {
                    ForEach(0..<3, id: \ .self) { rowIndex in
                        HStack(spacing: 20) {
                            ForEach(0..<3, id: \ .self) { columnIndex in
                                let buttonIndex = rowIndex * 3 + columnIndex
                                if buttonIndex < buttonColors.count {
                                    Button(action: {
                                        if !disabledButtons[buttonIndex] {
                                            selectedButtons[buttonIndex].toggle()
                                            checkMatch()
                                        }
                                    }) {
                                        Text("")
                                            .frame(width: 50, height: 50)
                                            .background(buttonColors[buttonIndex])
                                            .cornerRadius(10)
                                            .opacity(disabledButtons[buttonIndex] ? 0.4 : 1.0)
                                    }
                                    .disabled(disabledButtons[buttonIndex])
                                }
                            }
                        }
                    }
                }

                Text(message)
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.top, 20)

                Button(action: {
                    resetGame()
                }) {
                    Text("Reset Game")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    resetGame()
                    gameState = .start
                }) {
                    Text("Back to Start")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .onAppear {
                resetGame()
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
            .padding()
        }
    }
}

enum GameState {
    case start
    case game
    case guidelines
    case scoreboard
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
