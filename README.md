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

Like many gems, Towncrier is opinionated software. Towncrier believes that Javascript notifications are UX-sugar only and are not an integral part of you app. As a result, Towncrier intentionally has a DSL that allows you to define the notifications outside of your ActiveRecord models, so that your ActiveRecord models do not become cluttered with Towncrier code.

Similarly, when deployed to production, Towncrier will swallow any errors or glitches caused by these notifications so that a syntax error within a notification doesn't trip up your application or trigger a database transaction rollback.

In short, the idea is to provide a great DSL for these Javascript notifications while keeping them firmly out of the way of the important code.

