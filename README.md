# inmax

A new Flutter project.

# Running the API Documentation

To serve the API documentation locally, follow these simple steps:

## 1. Install `dhttpd`

First, install the `dhttpd` web server globally using Dart:

```bash
dart pub global activate dhttpd
```

## 2. Serve the Documentation

Run the following command to serve the documentation folder:

```bash
dart pub global run dhttpd --path doc/api
```

This will start a local web server.

## 3. Access the Documentation

After starting the server, open your browser and go to:

```
http://localhost:<PORT>
```

Replace `<PORT>` with the port number displayed in the terminal after running the command (usually `8080` by default).

---

Now your API documentation should be accessible locally in your browser.
