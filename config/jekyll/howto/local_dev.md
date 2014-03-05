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


# Possible Problems
-------------
     Running "rails server" didn't work because I was missing ruby gems. However when I run "bundle install", it tells me to make sure that "gem install pg -v '0.17.1' succeeds before bundling. But when I run " gem install pg -v '0.17.1' ", I get the following error:
     
     pg.c: In function ‘pg_s_library_version’:
     pg.c:272: warning: implicit declaration of function ‘PQlibVersion’
     pg.c: In function ‘Init_pg_ext’:
     pg.c:375: error: ‘PQPING_OK’ undeclared (first use in this function)
     pg.c:375: error: (Each undeclared identifier is reported only once
     pg.c:375: error: for each function it appears in.)
     pg.c:377: error: ‘PQPING_REJECT’ undeclared (first use in this function)
     pg.c:379: error: ‘PQPING_NO_RESPONSE’ undeclared (first use in this function)
     pg.c:381: error: ‘PQPING_NO_ATTEMPT’ undeclared (first use in this function)
     make: *** [pg.o] Error 1
     
     
     Gem files will remain installed in /.rvm/gems/ruby-1.9.3-p392/gems/pg-0.17.1 for inspection.
     Results logged to /.rvm/gems/ruby-1.9.3-p392/gems/pg-0.17.1/ext/gem_make.out
     
     How do I fix this??

Solution:

    Follow these instructions:

    1. In terminal, run "brew update"
    2. In terminal, run "brew install postgresql"
    3. In terminal, run "gem install pg -v '0.17.1'"
    
    For more info, see: http://stackoverflow.com/questions/19262312/installing-pg-gem-failure-to-build-native-extension/19620569#19620569
