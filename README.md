# WorthStack

WorthStack is an iOS native to-do and time-value management application built with SwiftUI. It goes beyond merely tracking the passage of time; it focuses on guiding you to honestly confront your emotions and choices, visualizing the "time spent on what truly matters."

## Core Design Philosophy

"Whether tasks fall like rain, or grow into a meadow in your heart, this is simply the shape of life today. Keep hold of yourself, and tomorrow will still be waiting."

The app visualizes tasks into "Blocks" of different states. Pending tasks hang at the top as a "Rain of Tasks," while completed or abandoned events settle down into "Life's Meadow." Every completion and every bit of effort gradually builds the landscape of your life.

## Key Features

- **Intuitive Visual Metaphor (Main Page)**
  - The top section displays pending tasks.
  - The bottom section displays completed and abandoned event records.
  - Tap a block to view or edit details, and long-press to manage or delete it.

- **Multi-dimensional Value Measurement (Things To Do / Completed)**
  - Records both the "Estimated Duration" and "Actual Duration" of events.
  - Introduces a unique evaluation system combining **Objective Score** and **Subjective/Final Score**, encouraging you to re-evaluate the true meaning of a task before and after its completion.

- **Flexible State Flow**
  - **Todo**: Set countdowns to track deadlines easily.
  - **Completed**: Record the actual time spent and provide a final rating. You can revert it back to a Todo if needed.
  - **Abandon**: Instead of simply deleting unexecuted tasks, MindBlock records them properly. Honestly facing your abandoned choices is an essential part of time management.

- **Data Insights & Customization (Observe & Color)**
  - **Countdown**: Real-time tracking of active timers, highlighting overdue key tasks in red.
  - **Color Configuration**: Offers global UI color customization based on the calming Morandi palette, with a one-tap reset.
  - **Deep Observe**: A personalized analytics view integrating time investment and value assessment. Read all your task notes and reflections in one centralized place.

## Technology Stack

- Language: Swift 6
- Framework: SwiftUI
- Platform: iOS 16.0+ / iPadOS 16.0+

## 🚀 Next Steps & Future Plans

To provide users with a more comprehensive and enduring experience, I plan to introduce the following architectural upgrades in future versions:

1. **Long-term Secure Data Management**
   - Currently, data is mainly stored locally. The plan is to integrate a robust local database (such as CoreData or SwiftData) combined with a secure cloud backup mechanism (like iCloud CloudKit automatic synchronization).
   - Implement data import/export (JSON/CSV formats) and snapshot retention features, ensuring users' effort records remain perfectly secure and persistent for years or even decades, effectively preventing data loss.

2. **Authentication & Non-local Login Support**
   - Break free from the limitations of a purely offline standalone app by integrating a secure authentication system (e.g., Sign in with Apple or Email registration/login).
   - Allow long-term managed time and value data to flow seamlessly across different devices with multi-device synchronization, providing a much more flexible and resilient usage experience.

3. **Optimizing & Deepening Value Measurement**
   - Introduce more multi-dimensional and dynamic evaluation metrics (for example: short-term excitement vs. long-term compounding value, or energy depletion vs. emotional replenishment).
   - Leverage automated data analysis and charts (adding more line charts and quadrant diagrams in the Observe interface) to intuitively demonstrate the true correlation between a user's time investment and personal value growth, assisting them in making wiser energy allocations and life decisions.
