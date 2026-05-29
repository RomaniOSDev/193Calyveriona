import Foundation

struct WorkoutTemplate: Identifiable {
    let id: String
    let name: String
    let description: String
    let systemImage: String
    let exercises: [Exercise]
    let timerWorkSec: Int?
    let timerRestSec: Int?
    let timerRounds: Int?

    static let builtIn: [WorkoutTemplate] = [
        WorkoutTemplate(
            id: "hiit",
            name: "HIIT",
            description: "High-intensity intervals with short rest periods.",
            systemImage: "bolt.heart.fill",
            exercises: [
                Exercise(name: "Jumping Jacks", repsOrDuration: "45 sec"),
                Exercise(name: "Burpees", repsOrDuration: "30 sec"),
                Exercise(name: "Mountain Climbers", repsOrDuration: "45 sec"),
                Exercise(name: "High Knees", repsOrDuration: "30 sec"),
                Exercise(name: "Rest", repsOrDuration: "60 sec")
            ],
            timerWorkSec: 45,
            timerRestSec: 15,
            timerRounds: 8
        ),
        WorkoutTemplate(
            id: "tabata",
            name: "Tabata",
            description: "Classic 20 seconds on, 10 seconds off protocol.",
            systemImage: "flame.fill",
            exercises: [
                Exercise(name: "Squats", repsOrDuration: "20 sec"),
                Exercise(name: "Push-ups", repsOrDuration: "20 sec"),
                Exercise(name: "Lunges", repsOrDuration: "20 sec"),
                Exercise(name: "Plank", repsOrDuration: "20 sec")
            ],
            timerWorkSec: 20,
            timerRestSec: 10,
            timerRounds: 8
        ),
        WorkoutTemplate(
            id: "emom",
            name: "EMOM",
            description: "Every minute on the minute — steady pacing.",
            systemImage: "clock.arrow.2.circlepath",
            exercises: [
                Exercise(name: "Kettlebell Swings", repsOrDuration: "10 reps"),
                Exercise(name: "Box Jumps", repsOrDuration: "8 reps"),
                Exercise(name: "Pull-ups", repsOrDuration: "6 reps"),
                Exercise(name: "Row", repsOrDuration: "12 reps")
            ],
            timerWorkSec: 40,
            timerRestSec: 20,
            timerRounds: 12
        ),
        WorkoutTemplate(
            id: "warmup",
            name: "Warm-up",
            description: "Dynamic warm-up to prepare your body.",
            systemImage: "figure.walk",
            exercises: [
                Exercise(name: "Arm Circles", repsOrDuration: "30 sec"),
                Exercise(name: "Leg Swings", repsOrDuration: "30 sec each"),
                Exercise(name: "Hip Circles", repsOrDuration: "30 sec"),
                Exercise(name: "Light Jog", repsOrDuration: "2 min"),
                Exercise(name: "Dynamic Stretch", repsOrDuration: "3 min")
            ],
            timerWorkSec: 30,
            timerRestSec: 10,
            timerRounds: 5
        )
    ]
}
