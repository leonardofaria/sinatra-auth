# Sinatra Auth

This project offers a simple, ready-to-go Sinatra app to deploy in Heroku to protect a directory of static pages.

Example: imagine you want to protect the content of a website created with Next.js, Hugo or your favourite static site generator. Github doesn't offer this feature or Netlify offers authentication only in their paid plans. Using the project you get authentication for free in the Heroku free tier plan.

## Using it

This app is ready to use in Heroku.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

## Running locally

1. Clone the repository
2. Install dependencies: `bundle install`
3. Create your `.env` file - check `.env-example`
4. Run: `rake db:create db:seed && ruby app.rb`

---

Based on [blog-sinatra-warden](https://bitbucket.org/pabuisson/blog-sinatra-warden/src/master/)
