# Towncrier

Consider Facebook. When a friend posts an update a growl notifications pops up on your screen. When someone send you a message your "messages" icon becomes highlighted. A friend uploads a new profile photo and that triggers your notifications counter being incremented.

Towncrier provides a handy DSL for replicating that kind of UX experience.

Towncrier is a Ruby on Rails gem that allows you to speedily create Javascript notifications for your app. It watches your models, and as resources are created or updated it pushes a Javascript data payload to the users you specify. In your assets/javascripts files you can intercept these payloads and react to them, using the data within them to tweak the page in any way you desire.

## Cheat Sheet

If you've used Towncrier before, here is a refresher. If you haven't, please read the more detailed instructions below.

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

Like many gems, Towncrier is opinionated software. Towncrier believes that Javascript notifications are UX-sugar only and are not a central part of any app. As a result, Towncrier intentionally has a DSL that forces you to define the notifications outside of your ActiveRecord models, so that your ActiveRecord models do not become cluttered with notification code.

Similarly, when deployed to production, Towncrier will swallow any errors or glitches caused by these notifications so that a syntax error within a notification doesn't trip up your application or trigger a database transaction rollback.

In short, the idea is to provide a great DSL for these Javascript notifications while keeping them firmly out of the way of the important code.

## App Setup

Towncrier relies on Ryan Bates' excellent [Private Pub gem](https://github.com/ryanb/private_pub) to handle the Javascript pub/sub system under the hood. Towncrier also requires a background process queue. You can use [Sidekiq](https://github.com/mperham/sidekiq) or [Resque](https://github.com/resque/resque), though Sidekiq is recommended.

**Step 1:** Install Private Pub and Sidekiq (or Resque). Both Private Pub and Sidekiq (or Resque) are somewhat involved to set up. Please see their homepages respectively and ensure they are set up and operating correctly before proceeding with installing Towncrier.

**Step 2:** Add Towncrier to your gemfile.

```
gem 'towncrier'
```

**Step 3:** Run the generator.

```
rails generate towncrier
rake db:migrate
```

**Step 4:** Add the JavaScript file to your application.js file manifest.

```
//= require towncrier
```

Remember to start up the Private Pub and Sidekiq (or Resque) processes as explained in their respective documentation.

## Setting Up the Targets

You need to define which model in your app represents the users ("targets") who will be receiving the notifications. In 95% of apps, this will be a User model.

```ruby
class User < ActiveRecord::Base
  acts_as_towncrier_targets
end
```

Next, add a string column named "towncrier_token" to that model.

```
rails generate migration add_towncrier_token_to_users towncrier_token
rake db:migrate
```

From this point on, each user's towncrier_token will be populated on create. If you already have users in your app, simply re-save them to populate their tokens.

```
User.find_each(&:save)
```

Finally, in your application **layout**, add a Javascript listener *before the closing /body tag*. This listens for the notifications coming in for the target.

```
<%= subscribe_to(current_user.towncrier_channel) if current_user %>
```

## Usage

Now it's time to go notification crazy :)

For the purposes of this demo, we'll use a fictional StackOverflow app, where users post questions and answers.

Let's say that every time a question is answered a notification should be pushed to the author of the original question. Create a new file called 'answer_crier.rb' in the 'app/criers' directory.

```ruby
class AnswerCrier < Towncrier::Base

  on :create do
    target answer.question.author
    payload answer # => auto-converted to answer.to_json
  end

end
```

Notice the pattern. Naming conventions are everything. Because we are creating notifications when users submit answers, we create a crier class named AnswerCrier. This class inherits from Towncrier::Base, and because it is named AnswerCrier, Towncrier will watch for Answer resources being created or updated and will send out the appropriate notifications.

Notifications can be sent on creates, updates, or both, and you can send multiple notifications each time an answer is submitted.

```ruby
class AnswerCrier < Towncrier::Base

  on :create do
    target answer.question.author
    payload :foo => :bar
  end

  on :update do
    target answer.question.author
    payload :abc => :xyz
  end

  on :create, :update do
    target answer.author.followers
    payload :foo => :bar
  end

end
```

For every notification you must define two things, the target and the payload. The target (see section [Setting Up the Targets above](#setting-up-the-targets)) can be one user, or multiple.

```ruby
class AnswerCrier < Towncrier::Base

  # one target
  on :create do
    target answer.question.author
    payload :foo => :bar
  end

  # lots and lots of targets
  on :create do
    target (answer.question.author + answer.followers + answer.author.followers)
    payload :foo => :bar
  end

end
```

The payload can be anything that `.to_json` can be called on.

```ruby
class AnswerCrier < Towncrier::Base

  # a hash payload
  on :create do
    target answer.question.author
    payload :foo => :bar
  end

  # a resource payload
  on :create do
    target answer.question.author
    payload answer # => equivalent of answer.to_json
  end

  # a complex hash payload
  on :create do
    target answer.question.author
    payload({
      :answer => answer,
      :answer_count => answer.author.answers.count,
      :complex_stuff => {
        :foo => :bar,
        :bar => :foo
      }
    })
  end

end
```

Notice that in all the examples above, we were able to call 'answer' within the target (eg answer.author) and within the payload. Towncrier does some magic behind the scenes to enable this. Because this crier is the AnswerCrier, Towncrier sets up an 'answer' method that returns the newly created/updated answer resource, allowing you to call 'answer' within the target and payload declarations.

Now all this is for sending out the notifications. On the Javascript side, you listen for these notifications by following the same naming convention.

```javascript
townCry.hearAnswer = function(action, payload) {
  // action will be a string, either 'create' or 'update'
  // payload will be the payload in JSON format
  // for example:
  console.log("A new answer was just " + action + "d.")
  console.log(payload);
}
```

## Advanced Usage

#### Custom Naming

For each notification, you can use the `as` option to give the notification a more specific name. This is imperative when you have multiple notifications for a single resource.

```ruby
class AnswerCrier < Towncrier::Base

  on :create, :update, as: :answer_for_question_author do
    target answer.question.author
    payload :foo => :bar
  end

  on :create, :update, as: :answer_for_followers do
    target answer.author.followers
    payload :foo => :bar
  end

end
```

```javascript
townCry.hearAnswerForQuestionAuthor = function(action, payload) {
  // do something
}

townCry.hearAnswerForFollowers = function(action, payload) {
  // do something
}
```

#### Persistence

By default, every time a notification is sent a copy of it is stored in the Towncry ActiveRecord table. This allows you to reference those notifications later. An obvious use case for this is to populate a Past Notification Feed. If you do not want to save copies to the database, set the `record` option to false.

```ruby
class AnswerCrier < Towncrier::Base

  on :create, :update, record: false do
    target answer.question.author
    payload :foo => :bar
  end

end
```

## Configuration

A configuration file located at 'config/towncrier.yml' can be edited to tweak the settings.

- **enabled:** whether or not Towncrier runs at all
- **raise_errors:** whether to throw or swallow errors that occur when Towncrier is queueing a notification to the background process
- **background_worker:** the type of background process to use. Valid values are `:sidekiq` and `:resque`. This can also be set to `false` to run everything in the main process, but doing so is a catastrophically terrible idea.

## License and Copyright

Copyright (C) 2014 David Lesches
[@davidlesches](http://twitter.com/davidlesches)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.




