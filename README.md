# Where's Mo?

Where's Mo? is a social media-style iOS application to track the locations of stickers of my family's cat, Mo. Users can post a new
Mo by uploading a photo as well as providing the time, location, landmark, and optionally a description. A news feed displays posts
chronologically, while a map view allows users to search for Mo locations within a given region. Each user's profile page displays
their profile photo along with photos of the Mo locations they have recently posted.

This app was created by Neil Bassett. Mo artwork by Susan Cassada.

## Features
The app was developed with SwiftUI and follows a Model-View-ViewModel (MVVM) architecture pattern.
The backend is implemented with Google Firebase, which is used for user authentication as well as storing data and images.
Other feature of the app include:
- Infinite scrolling news feed.
- Interactive map (using Apple MapKit) showing Mo locations as pins. Tapping a pin pulls up a detail view of the location.
- Local image caching to reduce network calls.
- Use of photo metadata to set time and latitude/longitude coordinates when posting a new Mo location.

## Screenshots
A 2 minute demo video is available on [YouTube](https://youtu.be/2x1K9F4TMhk)

<img src="/readme_images/wheres_mo_login_screenshot.png" width=175 align="left">
<img src="/readme_images/wheres_mo_feed_screenshot.png" width=175 align="left">
<img src="/readme_images/wheres_mo_map_screenshot.png" width=175 align="left">
<img src="/readme_images/wheres_mo_profile_screenshot.png" width=175 align="left">
