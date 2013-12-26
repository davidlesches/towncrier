# Towncrier

Consider Facebook. When a friend posts an update a growl notifications pops up on your screen. When someone send you a message your "messages" icon becomes highlighted. A friend uploads a new profile photo and that triggers your notifications counter being incremented.

Towncrier provides a handy DSL for replicating that kind of UX experience.

Towncrier is a Ruby on Rails gem that allows you to speedily create Javascript notifications for your app. It watches your models, and as resources are created or updated it pushes a Javascript data payload to the users you specify. In your assets/javascripts files you can intercept these payloads and react to them, using the data within them to tweak the page in any way you desire.

## Cheat Sheet

If you've used Towncrier before, he is a refresher. If you haven't, please read the more detailed instructions below.

Step 1: In the app/criers directory, add a new crier, using the same name as the model you are observing.

```ruby
class AnswerCrier < Towncrier::Base

  on :create do
    target answer.question.author
    payload answer
  end

end
```

Step 2: In the assets/javascripts directory, add a listener for the cry and use the payload as you wish.

```javascript
townCry.hearAnswer = function(action, payload) {
  console.log(payload);
}
```

## Opinion

Like many gems, Towncrier is opinionated software. Towncrier believes that Javascript notifications are UX-sugar only and are not an central part of any app. As a result, Towncrier intentionally has a DSL that forces you to define the notifications outside of your ActiveRecord models, so that your ActiveRecord models do not become cluttered with Towncrier code.

Similarly, when deployed to production, Towncrier will swallow any errors or glitches caused by these notifications so that a syntax error within a notification doesn't trip up your application or trigger a database transaction rollback.

In short, the idea is to provide a great DSL for these Javascript notifications while keeping them firmly out of the way of the important code.

## Setup

Towncrier relies on Ryan Bates' excellent [Private Pub gem](https://github.com/ryanb/private_pub) to handle the Javascript pub/sub system under the hood. Towncrier also requires a background process queue. You can use [Sidekiq](https://github.com/mperham/sidekiq) or [Resque](https://github.com/resque/resque), though Sidekiq is recommended.

Step 1: Install Private Pub and Sidekiq (or Resque). Both Private Pub and Sidekiq (or Resque) are somewhat involved to set up. Please see their homepages respectively and ensure they are set up and operating correctly before proceeding with installing Towncrier.

Step 2: Add Towncrier to your gemfile.

```
gem 'towncrier'
```

Step 3: Run the generator.

```
rails generate towncrier
rake db:migrate
```

Step 4: You need to define which model in your app represents the users who will be receiving these notifications. In 95% of apps, this will be the User model, but if you have a school app with teachers and students, the Teacher and Student models are the targets.

```ruby
class User < ActiveRecord::Base
  acts_as_towncrier_targets
end
```

Then add a string column names "towncry_token" to that model.

```
rails generate migration add_towncry_token_to_users towncry_token
rake db:migrate
```

Step 5: Remember to start up the Private Pub and Sidekiq (or Resque) processes as explained in their respective documentation.

## Usage





## Advanced Usage

## Configuration

## License, Copyright etc








