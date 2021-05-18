//  Clone_clarknt
//
//  ContentView.swift
//  day34_pro6_pa3
//  Day34 : Challenge
//  1. When you tap the correct flag, make it spin around 360 degrees on the Y axis.
//  2. Make the other two buttons fade out to 25% opacity.
//  3. And if you tap on the wrong flag? Well, that's down to you - get createive!
//
//  Created by John Hur on 2021/05/14.
//

import SwiftUI

struct FlagImage: View {
    var name: String
    
    var body: some View {
        Image(name)
            .renderingMode(.original)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
            .shadow(color: .black, radius: 2)
    }
}

struct ShakeEffect: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: -30 * sin(position * 2 * .pi), y:0))
    }
    
    init(shakes: Int) {
        position = CGFloat(shakes)
    }
    
    var position: CGFloat
    var animatableData: CGFloat {
        get { position }
        set { position = newValue }
    }
}

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    
    @State private var correctAnswer = Int.random(in: 0...2)
    @State private var scoreTitle = ""
    @State private var score = 0
    
    // chall 1
    @State private var spinAnimationAmounts = [0.0,0.0,0.0]
    @State private var animatingIncreaseScore = false
    
    // chall 3
    @State private var shakeAnimationAmounts = [0,0,0]
    @State private var animatingDecreaseScore = false
    
    // chall 2
    @State var animateOpacity = false
    
    @State private var wrongCountry = ""
    
    @State private var allowSubmitAnswer = true
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                VStack {
                    Text("Find the flag of")
                        .foregroundColor(.white)
                    
                    HStack {
                        Spacer()
                        
                        Text(countries[correctAnswer])
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .fontWeight(.black)
                        
                        Spacer()
                        
                    }
                }
                
                ForEach(0 ..< 3) { number in FlagImage(name: self.countries[number])
                    // chall 1
                    .rotation3DEffect(.degrees(self.spinAnimationAmounts[number]), axis: (x: 0, y: 1, z: 0))
                    .modifier(ShakeEffect(shakes: self.shakeAnimationAmounts[number] * 2))
                    .opacity(self.animateOpacity ? (number == self.correctAnswer ? 1: 0.25) : 1)
                    .onTapGesture {
                        self.flagTapped(number)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    Text("Score")
                        .foregroundColor(.white)
                    
                    ZStack {
                        // chall 1 & 3
                        Text("\(score)")
                            .foregroundColor(animatingIncreaseScore ? .green : (animatingDecreaseScore ? .red : .white))
                        
                        // chall 1
                        Text("+1")
                            .font(.headline)
                            .foregroundColor(animatingIncreaseScore ? .green : .clear)
                            .opacity(animatingIncreaseScore ? 0 : 1)
                            .offset(x: 0, y: animatingIncreaseScore ? -50 : -20)
                        
                        // chall 3
                        Text("-1")
                            .foregroundColor(animatingDecreaseScore ? .red : .clear)
                            .font(.headline)
                            .opacity(animatingDecreaseScore ? 0 : 1)
                            .offset(x: 0, y: animatingDecreaseScore ? 50 : 20)
                        
                    }
                    
                    Spacer()
                    
                }
                .offset(x: 0, y: 30)
                
                Spacer()
                
                // chall 3
                Text("That was \(wrongCountry)")
                    .font(.headline)
                    .foregroundColor(animatingDecreaseScore ? .red : .clear)
                
            }
        }
    }
    
    func flagTapped(_ number: Int) {
        // chall 1
        guard allowSubmitAnswer else { return }
        allowSubmitAnswer = false
        
        // chall 1
        let nextQuestionDelay = 1.5
        let flagAnimationDuration = 0.5
        let scoreUpdateDuration = 1.5
        
        // chall 2
        withAnimation(Animation.easeInOut(duration: flagAnimationDuration)) {
            self.animateOpacity = true
        }
        
        if number == correctAnswer {
            score += 1
            // chall 1
            withAnimation(Animation.easeInOut(duration: flagAnimationDuration)) {
                self.shakeAnimationAmounts[number] += 360
            }
            withAnimation(Animation.linear(duration: scoreUpdateDuration)) {
                self.animatingIncreaseScore = true
            }
        }
        else {
            wrongCountry = countries[number]
            score -= 1
            // chall 3
            withAnimation(Animation.easeInOut(duration: flagAnimationDuration)) {
                self.shakeAnimationAmounts[number] = 2
            }
            withAnimation(Animation.linear(duration : scoreUpdateDuration)) {
                self.animatingDecreaseScore = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + nextQuestionDelay) {
            self.askQuestion()
        }
    }
     
    func askQuestion() {
        // chall 1
        self.spinAnimationAmounts = [0.0, 0.0, 0.0]
        self.animatingIncreaseScore = false
        // chall 2
        self.animateOpacity = false
        // chall 3
        self.shakeAnimationAmounts = [0,0,0]
        self.animatingDecreaseScore = false
        
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        // chall 1
        allowSubmitAnswer = true
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
 



}
