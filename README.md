# eCommerce Mobile Application

This is a Flutter-based eCommerce mobile application that utilizes GetX for state management and navigation, along with Firebase and Cloud Firestore for backend services. The app provides a seamless shopping experience with features such as user authentication, product browsing, cart management, and order processing.

## Features

- **User Authentication**: Sign up, sign in, and sign out functionalities using Firebase Authentication.
- **Product Listing**: Browse products in a grid view with detailed information available for each product.
- **Shopping Cart**: Add, remove, and update items in the shopping cart.
- **Order Summary**: Review order details before confirmation.
- **Modular Code Structure**: Organized folder structure for easy maintenance and scalability.

## Folder Structure

```
ecommerce_app
├── lib
│   ├── main.dart
│   ├── app
│   │   ├── bindings
│   │   ├── controllers
│   │   ├── data
│   │   ├── routes
│   │   ├── ui
│   │   └── utils
├── android
├── ios
├── pubspec.yaml
└── README.md
```

## Setup Instructions

1. **Clone the Repository**: 
   ```
   git clone <repository-url>
   cd ecommerce_app
   ```

2. **Install Dependencies**: 
   Run the following command to install the required packages:
   ```
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a Firebase project in the Firebase Console.
   - Add your Android and iOS apps to the Firebase project.
   - Download the `google-services.json` and `GoogleService-Info.plist` files and place them in the respective directories.

4. **Run the Application**: 
   Use the following command to run the app on your device or emulator:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue for any suggestions or improvements.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.