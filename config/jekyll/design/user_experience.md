---
layout: default
title: User Experience Design Process
---

# User Experience Design Process
--------------
by John Pulvera

## Mobile-First

![Mobile Design](/assets/mockups_mobile.png)

I went with the mobile first approach after reading articles about it and hearing other advocate this philosophy.  Mobile first prioritizes the mobile context when creating user experiences.

* reach more people
* focus on core content and functionality
* take advantage of new technologies

The experience was initially designed for a mobile web app experience.  For instance, the experience is simplistic and the inputs and buttons have larger real estate for fingers.  For the tablet and desktop version, the app adjusts to a more high-resolution-friendly experience.  Inputs and buttons are smaller.

## Responsive Web Design

![Desktop / Tablet Design](/assets/mockups_desktop_tablet.png)

Additionally, I went with the responsive web design approach after reading articles about it and agreeing with the philosophy.  Responsive web design articulates how to adapt a website's layout for multiple screen resolutions.

* fluid grids ebb and flow with a device's screen size
* flexible images and media that keep content intact at any resolution
* media queries allowing designs to adapt by establishing dimension breakpoints

A media query of 640px (iPhone resolution width) is the threshold for our web app's styles.  Below 640px, our app is more of a mobile experience with view options for a more textual view or a data visualization view.  Above 640px, our app has more of a focus the data visualization view but also lays the textual view as a control panel on top of (but not interfering with) the data visualization.

## Flat Design

Flat design was chosen for the aesthetics of our application because of simplicity and clarity of design.  Moroever, it is much easier and less time-consuming to create flat design elements as opposed to creating non-flat elements (using gradients, textures, and other details to make digital objects look "real").

## Colors and Fonts

I didn't want to spend too much time designing a great interface at first, but I wanted something that looked decent for a first iteration.  So for the color, I used "brandcolors.net" and filtered color collections by most popular.  I went with a blue primary color because most web apps have some blue nowadays.  Foursquare's blue seemed okay, so I went with it.  To balance the blue, I went with Google's white.  I designed the logo using these colors, which then translated into these colors being used throughout our interface.

When designing the initial logo on Google Drawing, Trebuchet was chosen because it was the best-looking font for the logo name "dewey" of the set of default fonts available on Google Drawing.  Again, I didn't want to spend too much time searching and looking for the best font-style.  I just needed something that worked.

## Inspiration

Inspiration for the mobile user experience was from flat designed mobile apps.  I wanted it to resemble the experience of a native app (although it is on the web) because native apps have a nice flow and reactiveness to them.  It relies on simplicity, clarity, and hopefully high-quality images (for profile pictures).

As for the tablet and desktop views, inspiration was drawn from the new Google Maps interface and experience.  That experience showcases a pannable and zoommable map that fills the viewport and lays a control panel on top of this map (fixed on the screen but positioned relative to the upper-right corner).  The panel allows users to search and perform other Google Map features.  Thus, our app mimiced this approach by envisioning a large pannable and zoommable data visualization that fills the screen and a complementary control panel.  Searching and exploring is available in the textual panel, but only exploring is available in the data visualization.
