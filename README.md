# Paperless App

Access all your scanned documents, wherever you are.

To use this, you need to have a Paperless server set up. See [Paperless Documentation](https://paperless.readthedocs.io/en/latest/#why-this-exists) for more information.

This open-source app allows you to easily access your documents stored in Paperless from your smartphone. If you need to access an important document on the go, you can find it in seconds.
Paper is a nightmare. Environmental issues aside, there's no excuse for it in the 21st century. It takes up space, collects dust, doesn't support any form of a search feature, indexing is tedious, it's heavy and prone to damage and loss.
Paperless takes documents from your scanner, recognises the text, extracts metadata and gives you the tools you need to manage your documents digitally. It can automatically detect the correspondent and creation date and offers you a search function - all you have to do is scan the documents. Your documents have never been so well organised.
Paperless offers a powerful web interface that is difficult to use on a smartphone. With this app you have a native option to access your documents easily.

It provides the following functionality:

-	Securely saves your credentials so you only have to login once
-	Full-text search
-	Customisable order
-	Open PDF documents
-	Dark Mode

Anything missing? Please open an issue.

## Get The App

### Android
[![Get on Google Play](assets/google-play-badge.png)](https://play.google.com/store/apps/details?id=eu.bauerj.paperless_app)

I also plan to release this to F-Droid eventually, but this has lower priority.

### iOS
The code for this app should run on iOS as well (maybe it needs a few minor modifications).
However, I do not plan to release this app for the iOS App Store, since I do not have:

- An iOS device to test this on
- A Mac, which is needed to compile the iOS app
- An Apple Developer Program Membership (USD99,-)

If anyone else happens to have all of those and wants to take care of distributing the app there, please let me know. 

## Developing

In order to build the app for local testing, follow these steps:

1. [Install Flutter](https://flutter.dev/docs/get-started/install). This is a Flutter app so you need to set up the Flutter SDK.
2. Run `flutter pub run build_runner build` to build the JSON parser for the Paperless API.
3. Open the app in [whichever editor you prefer](https://flutter.dev/docs/get-started/editor) and start it.
