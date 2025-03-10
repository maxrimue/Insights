# Insights

**Insights** is an experimental SwiftUI macOS app I've built to play with processing the user's reminders data in order to generate metrics out of that.
It accesses the user's reminders data using the `EventKit` framework, pipes that through the respective analysis functions and then displays the results in a SwiftUI view.

My main focus was to get a better understanding of developing macOS apps with SwiftUI and to play with the `EventKit` framework, as such the app is not meant to be a full-fledged product.
At the moment, the app displays:

- The percentage of due/overdue reminders done today
- The total number of reminders due/overdue today
- A graph visualizing the number of reminders due in the last 7 days

Eventually, I'd like to add more features like:

- Displaying long overdue ("forgotten") reminders
- Displaying streaks for completing recurring reminders
- Generate some sort of "suggestions" (such as to move reminders from a full to an empty day)

There's also technical considerations to be made, such as subscribing to reminders updates outside of the app and processing data more efficiently (right now, the app fetches and processes all reminders every time it's opened).

The app also comes with a debug view, meant to help query metadata of the user's reminders. It can be accessed in debug mode.

## Development

The app is built using Swift, SwiftUI and ReminderKit. Tests are written using Swift Testing. Its only dependency is [SwiftLint](https://github.com/realm/SwiftLint), managed via Swift Package Manager. To build the app, simply clone the repository using Xcode.

## Screenshot

<p align="center">
  <img width="444" alt="Screenshot of the Insights app" src="https://github.com/user-attachments/assets/c9fc6bdf-50ad-4721-9ffd-63e21981865e" />
  <img width="859" alt="Screenshot of the app's debug view" src="https://github.com/user-attachments/assets/e6fd4318-828a-4d41-87d2-2e93e9edd596" />
</p>
