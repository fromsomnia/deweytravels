---
layout: default
title: Setting up your local dev
---

# Setting up your local dev environment
--------------

### 1. Download the postgres app
http://postgresapp.com/

### 2. Run the postgres app (you should see a little elephant icon in your status bar)
### 3. Enter postgres console (in terminal)
    => psql -d postgres

### 4. Create user
    => CREATE ROLE team_dewey_website;


### 5. Create databases

    => CREATE DATABASE team_dewey_website_test WITH OWNER team_dewey_website;
    => CREATE DATABASE team_dewey_website_development WITH OWNER team_dewey_website;
    => CREATE DATABASE team_dewey_website_production WITH OWNER team_dewey_website;

### 6. Enable login
    => ALTER ROLE team_dewey_website LOGIN;
Exit postgres console (ctrl + d)

### 7. cd into desired directory and clone heroku app
    => git clone git@heroku.com:team-dewey-website.git

### 8. if needed:
    => heroku login
    => heroku keys:add

### 9. Make sure server runs with "rails server" (crl + C to stop)

### 10. For future use: to load databases (not yet)
    => rake db:migrate

