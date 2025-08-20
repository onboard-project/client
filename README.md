# 📱 Onboard Client

>[!Note]
> **EDUCATIONAL PROJECT DISCLAIMER**
>
>This project is developed purely for **educational and demonstrative purposes**. While it aims to provide useful public transport information for Milan, it relies on data sources, including scraping information from `giromilano.atm.it`.
>
>**The terms of service for ATM (Azienda Trasporti Milanesi) regarding data usage are not explicitly clear, and this project may potentially violate them.**
>
>Therefore:
>- **Use at Your Own Risk:** We do not guarantee the accuracy or continued availability of the data, nor do we assume responsibility for any consequences arising from its use.
>- **Unscheduled Discontinuation:** This project, or parts of it, may be taken down or become non-functional unexpectedly if ATM's policies change or if the data sources become inaccessible.
>
>We advise caution and understanding of these limitations.

The **Onboard Client** is the user-facing application for the [Onboard Project](https://github.com/onboard-project), built with Flutter. It provides an intuitive interface for users to explore Milan's public transport network, view real-time vehicle arrivals, and navigate using a custom map. Available on Windows, Android, and Web, this client brings all the underlying data and services to your fingertips.

## ✨ Key Features

*   **Interactive Map:** Displays all public transport stops and lines on custom raster tiles sourced from [Onboard Maps](https://github.com/onboard-project/maps).
*   **Real-time Arrivals:** Shows live waiting times and arrival predictions for vehicles at each stop, fetched from the [Onboard Server](https://github.com/onboard-project/server).
*   **Line Information:** View detailed information for each transport line, including its route and associated stops.
*   **Stop Details:** Tap on any stop to see its name, associated lines, and upcoming arrivals.
*   **Search & Favorites:** Easily find specific stops or lines and save your frequently used ones.
*   **Cross-platform Experience:** Enjoy a consistent user interface and functionality across Windows, Android, and Web.

## 🚀 Getting Started

### Installation

**Android:**
*   Download the latest APK from the [Releases](https://github.com/onboard-project/client/releases) page.
*   Enable "Install from unknown sources" if prompted, and install the APK.

**Windows:**
*   Download the latest `.zip` file from the [Releases](https://github.com/onboard-project/client/releases) page.
*   Extract the contents to a folder of your choice (e.g., `C:\Program Files\Onboard`).
*   Run `onboard.exe`.

**Web:**
*   Access the web application directly at [onboard-project.github.io/client](https://onboard-project.github.io/client) (or your deployed URL).

### Local Development

To run the Onboard Client locally or contribute to its development:

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/onboard-project/client.git
    cd client
    ```
2.  **Install Flutter:** Ensure you have Flutter installed and configured on your system.
> [!TIP]
> If you don't have Flutter installed, follow the official guide: [flutter.dev/docs/get-started](https://flutter.dev/docs/get-started)

3.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the Application:**
    You can run the app on various platforms:
    *   **Android:**
        ```bash
        flutter run
        ```
        (Ensure an Android emulator is running or a device is connected.)
    *   **Windows:**
        ```bash
        flutter run -d windows
        ```
    *   **Web:**
        ```bash
        flutter run -d web
        ```
        The app will open in your default browser.


## 🤝 Contributing

We highly encourage contributions to the Onboard Client! Whether it's reporting bugs, suggesting new features, improving the UI/UX, or submitting code, your input is invaluable. Please open issues or submit pull requests following our contribution guidelines.

## 📄 License

This project is licensed under the [GNU GPL v3.0 License](LICENSE.md).
