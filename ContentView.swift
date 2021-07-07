//
//  ContentView.swift
//  BetterRest
//
//  Created by Jordi Rivera Lizarralde on 6/7/21.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWaketime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    // Properties for alert
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    @State private var numCoffee = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("When do you want to weak up?")
                        // Change font of text
                        .font(.headline)
                    
                    // Create a date with only hour and min
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        // Hide label
                        .labelsHidden()
                        // The picker is a wheel
                        .datePickerStyle(WheelDatePickerStyle())
                }
                Section {
                    Text("Desired amount of sleep")
                        // Change font of text
                        .font(.headline)
                    
                    // Create a Stepper for the amount of sleep with a step of 0.25
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                Section {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    // Picker for coffee amount
                    Picker("Number of coffee", selection: $numCoffee) {
                        ForEach(1..<21) {number in
                            Text("\(number)")
                        }
                    }
                    // Stepper for coffee amount
                    //Stepper(value: $coffeeAmount, in: 1...20) {
                        // 1 cup of coffee
                     //   if coffeeAmount == 1 {
                     //       Text("1 cup")
                     //   } else {
                            // Several cups of coffee
                     //       Text("\(coffeeAmount) cups")
                     //   }
                    //}
                }
            }
            // Add title to navigation view
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                // Calling function when using button
                Button(action: calculateBedTime) {
                    Text("Calculate")
                }
            )
            // Show alert
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    // Default wake time
    static var defaultWaketime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from:components) ?? Date()
    }
    // Function to calculate bed time
    func calculateBedTime() {
        // Create model from ML model
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        // Get hour and convert to seconds
        let hour = (components.hour ?? 0) * 60 * 60
        // Get minute and convert to seconds
        let minute = (components.minute ?? 0) * 60
        
        // Do catch block and use our model to calculate bed time
        do {
            // How much time of sleep they need in seconds
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            // Time when to go to sleep
            let sleepTime = wakeUp - prediction.actualSleep
            
            // Date to string
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bed time is..."
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bed time."
        }
        // Show the alert
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
