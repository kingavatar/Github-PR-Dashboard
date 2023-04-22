# GitHub Pull Requests App

This Flutter app displays a list of pull requests from a GitHub repository, which can be sorted and filtered based on various parameters. The app features animated Lottie asset icons that provide visual feedback to the user, as well as handling edge cases such as 404 errors and loading states with attractive Lottie animations. The app includes settings to handle confirm-on-exit for both Android and iOS, as well as theme modes and dynamic colors using Material You. The latest Material 3 components are used throughout the app.

## Features

- Display a list of pull requests from a GitHub repository
- Sort and filter pull requests based on various parameters
- View detailed information about a pull request in a separate page
- Animated Lottie asset icons for visual feedback and loading states
- Handle 404 errors and other edge cases with attractive Lottie animations
- Confirm-on-exit settings for Android and iOS
- Theme modes and dynamic colors using Material You
- Latest Material 3 components used throughout the app
- Infinite scrolling to handle pagination

## Dependencies

This app utilizes the following dependencies:

- [Dio](https://pub.dev/packages/dio) for handling network API calls
- [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod) for state management
- [cached_network_image](https://pub.dev/packages/cached_network_image) to cache avatar images from the GitHub API
- [lottie](https://pub.dev/packages/lottie) for animated icons
- [package_info_plus](https://pub.dev/packages/package_info_plus) for getting information about the app package
- [cupertino_icons](https://pub.dev/packages/cupertino_icons) for using iOS-style icons
- [beamer](https://pub.dev/packages/beamer) for implementing navigation and routing
- [flutter_svg](https://pub.dev/packages/flutter_svg)  for rendering SVG images
- [timeago](https://pub.dev/packages/timeago)for displaying human-readable timestamps
- [auto_size_text](https://pub.dev/packages/auto_size_text) for dynamically sizing text
- [infinite_scroll_pagination](https://pub.dev/packages/infinite_scroll_pagination) for implementing infinite scrolling with pagination
- [dynamic_color](https://pub.dev/packages/dynamic_color) for implementing dynamic colors based on user's wallpaper
- [flutter_exit_app](https://pub.dev/packages/flutter_exit_app) for handling confirm-on-exit on Android and iOS


## Getting Started

To set up the app, follow these steps:

1. Clone the repository:

```
git clone https://github.com/kingavatar/github-pr-dashboard.git
```

2. Install dependencies:

```
flutter pub get
```

3. Create a `.env` file in the root directory of the project and add your GitHub personal access token:

```
GITHUB_API_TOKEN=<your token here>
```

4. Run the app:

```
flutter run
```

## Contributing

If you are interested in contributing to the project, please follow these steps:

1. Fork the repository
2. Create a new branch for your feature or bug fix
3. Make your changes and commit them
4. Push your changes to your forked repository
5. Submit a pull request to the original repository

## Issues

If you encounter any issues with the app, please submit an issue on the GitHub repository page.

## Architecture

The project follows a simple folder structure, with most of the code residing in the lib directory. The lib directory contains the main app code, with the following subdirectories:

screens: This directory contains all the screen widgets of the app. Each screen widget is self-contained and handles its own state and UI. Screens can be navigated using the navigation widgets in the widgets directory.
widgets: This directory contains common widgets used throughout the app, such as the navigation bar and navigation rail. The widgets in this directory are reusable and can be customized to fit the specific needs of each screen.
transitions: This directory contains the animation transitions used by the navigation widgets in the widgets directory. These transitions provide smooth and attractive animations when switching between screens.
In addition to the main app code, the project also utilizes several third-party libraries to handle network requests, state management, and image caching:

Dio is used to handle network API calls to the GitHub REST API. Dio is a powerful HTTP client for Dart that supports interceptors, global configuration, FormData, and more.
Riverpod is used for state management throughout the app. Riverpod is a simple yet powerful state management library for Flutter that provides a way to manage app state in a scalable and testable way.
cached_network_image is used to cache avatar images from the GitHub API. cached_network_image is a Flutter library that provides a way to cache images from the network using a simple API.
The app also features infinite scrolling to handle pagination, which is implemented using the Flutter built-in ListView.builder widget.

Finally, the app includes settings to handle confirm-on-exit for both Android and iOS, as well as theme modes and dynamic colors using Material You. The latest Material 3 components are used throughout the app to provide a modern and consistent UI.

Overall, the project follows a clean and organized architecture that separates concerns and promotes code reusability and maintainability.

## Design

The app features a modern Material 3 design, utilizing the latest components and features. The app is designed to be both visually appealing and easy to use, with a focus on user experience.

One notable design feature of the app is the use of Material You dynamic colors. This feature enables the app to dynamically adjust its color scheme based on the user's device settings. On Android S+, the app will use the color from the user's wallpaper, while on Linux, the app will use the GTK+ theme's @theme_selected_bg_color. On macOS, the app will use the system accent color, and on Windows, the app will use the accent color or window/glass color.

The app also utilizes custom Lottie animations for visual feedback, including loading animations and error animations. The animations provide an attractive and engaging user interface, while also conveying important information to the user.

The app includes support for both light and dark modes, with appropriate color schemes for each mode. The theme can be easily changed from the app settings, allowing users to customize their experience.

Overall, the app is designed to be both aesthetically pleasing and easy to use, while also being maintainable and scalable for future development.

## Challenges

One of the challenges in developing the app was handling pagination for the list of pull requests. This was addressed using infinite scrolling, which allowed the app to fetch new data as the user scrolled through the list.

Riverpod handled majority of cases for providing data from repository API calls to UI.

When enabling dark mode I had to transition all the lottie assets manually from black color to white color.

Search Page with errors with custom 404 page dealing while handling pagination made me rewrite most of the code.

BottomSheet still has some constraints needed to be handled. They are pending issues of max-width in flutter API. For now I handled using sizedBox and constrainedBox where needed.

Exiting the app was weirdly not handled using native methods which used native channels to handle the case. I has to use the flutter_exit_app to deal with that case.

Beamer, which was used for navigation and routing, also presented some challenges and took some time to get used to.

## Screenshots


### Pull to Refresh, Searching and Filtering/Sorting


<div style="display: flex; justify-content: space-around;">
<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/pulltorefresh.gif" width="200" />

<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/wezterm.gif" width="200" />

<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/filter.gif" width="200" />
</div>


### Details, Animated Icons and 404


<div style="display: flex; justify-content: space-around;">

<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/details.gif" width="200" />
<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/animatedIcons.gif" width="200" />
<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/404.gif" width="200" />

</div>


### DarkMode , Dynamic and Confirm To Exit


<div style="display: flex; justify-content: space-around;">

<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/darkmode.gif" width="200" />
<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/dynamic.gif" width="200" />
<img src="https://raw.githubusercontent.com/kingavatar/github-pr-dashboard/assets/confirmToExit.gif" width="200" />

</div>