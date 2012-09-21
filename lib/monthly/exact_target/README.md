Exact Target Integration
########################

Exact Target is an enterprise scale system for managing your email activity.

Among many things It allows you to:
- send email blasts to a large list of subscribers based on an arbitrary set of filter criteria.
- send triggered emails from within your application at definable events within your user's experience
- set up drip campaigns, or transactional emails, which are series of email messages sent at defined time intervals in response to events within your user's experience
- maintain an up to date list of email subscribers with their own profiles which contain an arbitrary set of attributes which can be used to customize your email messaging, or filter your subscribers for the purpose of creating mailing lists, email campaigns, drip campaigns
- track / report on / optimize email delivery, click rates, and open rates

The number one advantage of Exact Target is that there is very little you need to do within your application to give a majority of control over your email marketing strategy to non-technical members of your team.

### How do we accomplish the integration?

```ruby
  Monthly::ExactTarget::EmailRecipient
```

This simple mixin can be included in an ActiveRecord model so that after that model is created or updated, it schedules an update to the EmailRecipient table.

```ruby
  class User < ActiveRecord::Base
    include Monthly::ExactTarget::EmailRecipient

    # keep this model in sync with the exact target email recipient table
    # and track the first name and last name attributes
    acts_as_exact_target_subscriber :attributes => [:first_name, :last_name]
  end
```

For more information on Exact Target Subscriber API see:

http://docs.code.exacttarget.com/040_XML_API/XML_API_Calls_and_Sample_Code/API_Error_Codes/Error_Code_Numbers_and_Descriptions


acts_as_exact_target_subscriber
###############################

This module accepts a hash with a key named :attributes.  The attributes correspond to method name or active record attributes on the model.  These attributes will be used to build a hash that gets set in a serialize column on the EmailRecipient model.

The Email Recipient Model
#########################
The EmailRecipient model is an abstraction layer that represents any emailable entity in your database.  Any emailable model has the capability of acting as an exact target subscriber.  The current MVP of the exact target integration treats users, and merchants as exact target subscribers.  You will have to modify the acts_as_exact_target_subscriber call so that it includes the attributes you want.

Whenever an emailable entity is updated, or created, it creates a corresponding record in EmailRecipient.  Whenever EmailRecipient gets created, it sends an 'add' request to the Exact Target API and creates the subscriber in the All Subscriber's list.  Whenever an EmailRecipient is updated, it sends an 'update' request to the Exact Target API and syncs their profile.

These operations will happen in the background through Resque.

The attributes which are stored in the EmailRecipient#profile_attributes method will be a part of the subscriber's profile, and thus available as part of your list building filters, or as customization variables for interpolated variables in your emails.

Variable Interpolation and Subscriber List Filtering
###################################################
Interpolated variables are accessible in your Email content through the following convention.  %%full_name%% corresponds to a full_name attribute or method that exists on the exact target subscriber model.

```html
<h1>Welcome to Monthlys %%full_name%%</h1>
<p>lorem ipsum...</p>
```

Triggered Emails
################

Beyond building a subscriber list, you can send 'triggered emails' from your code.  For more information on Triggered Emails, see the following documentation:

http://docs.code.exacttarget.com/020_Web_Service_Guide/Triggered_Email_Scenario_Guide_For_Developers

The way this works in practice in our code base is simple.

We create a triggered email with the following:

```ruby
triggered_email = Monthly::ExactTarget::TriggeredEmail.new("jonathan.soeder@gmail.com","email_name", :attributes=>{:variable=>"value",:other_variable=>"other_value"})
triggered_email.deliver!
```

This assumes 'email_name' which corresponds to the name of an Email that you set up in your Exact Target content panel.  The additional values you supply in the :attributes option will be available as %%variable%% and %%other_variable%% within your HTML email templates.

# Example Usage

From the rails console, see how I create a user:

http://bit.ly/HFXpAN

The following actions get automatically queued to be run in the
background by Resque:

http://bit.ly/IMVRIP

The end result of this is that the user ends up as a subscriber in exact
target

http://bit.ly/HFXDrP

I create an email template in exact target

http://bit.ly/IMWp1b

then to make that email available to
Monthly::ExactTarget::TriggeredEmail, I go to the interactions menu

http://bit.ly/HFYZTg

and make my email available as a triggered send. 

I can now send this email by:

```ruby
  Monthly::ExactTarget::TriggeredEmail.new("jonathan.soeder@gmail.com","test_email").deliver!
```

