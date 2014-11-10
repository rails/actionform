Active Form Basics
=================

This guide provides you with all you need to get started in creating and submitting forms.

After reading this guide, you will know:

* How to create forms.
* How to use forms from controllers and views.
* How to test forms.

--------------------------------------------------------------------------------


Introduction
------------

Active Form is a framework for declaring nested forms.
It was introduced in Rails 5 to decouple form features from Active Record models,
e.g. nested and virtual attributes.

Creating a Form
--------------

Simple example of form can be a signup page with email/password fields and
"accept terms" checkbox. To avoid declaring virtual attribute in your ActiveRecord
model you can create `SignupForm` class especially for sign up page with just 2 fields
and one checkbox.

### Create the Form

Active Form provides a Rails generator to create jobs. The following will create a
form in `app/forms` (with an attached test case under `test/forms`):

```bash
$ bin/rails generate form signup
invoke  test_unit
create    test/forms/signup_form_test.rb
create  app/forms/signup_form.rb
```

As you can see, you can generate forms just like you use other generators with
Rails.

If you don't want to use a generator, you could create your own file inside of
`app/forms`, just make sure that it inherits from `ActiveForm::Base`.

Here's what a form looks like:

```ruby
class SignupForm < ActiveJob::Base
  self.main_model = :user

  attributes :email, :password, required: true
end
```

### Using from controller

In your controller you create a form instance and pass in the model you want to work on.

```ruby
class SignupController
  def new
    user = User.new
    @signup_form = SignupForm.new(user)
  end

  def create
    user = User.new
    @signup_form = SignupForm.new(user)
    @signup_form.submit(signup_params)

    respond_to do |format|
      if @signup_form.save
        format.html { redirect_to root_path, notice: "User was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  private

  def signup_params
    params.require(:signup).permit(:email, :password)
  end
end
```

## Rendering Forms

Your `@signup_form` is now ready to be rendered:

```erb
<% form_for @signup_form do |f| %>
  <% if @signup_form.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@signup_form.errors.count, "error") %> prohibited this form from being saved:</h2>

      <ul>
      <% @signup_form.errors.full_messages.each do |msg| %>
        <li><%= msg %></li>
      <% end %>
      </ul>
    </div>
  <% end %>
  <%= f.text_field :email %>
  <%= f.text_field :password %>
<% end %>
```

## Form API

`SignupForm` instance you have initialized from controller have API similar to ActiveRecord:

```ruby
# Submit empty params
@signup_form.submit({})
=> false
@signup_form.errors.count
=> 2

# Submit valid attributes
@signup_form.submit({email: "dhh@example.com", password: "secret"})
=> true
@signup_form.errors.count
=> 0

# Save the record
@signup_form.save
=> true
```


## Nesting Forms: 1-n Relations

ActiveForm also gives you nested collections.

Let's define the `has_many :speakers` collection association on the Conference model.

```ruby
class Conference < ActiveRecord::Base
  has_many :speakers
  validates :name, uniqueness: true
end
```

The form should look like this.

```ruby
class ConferenceForm < ActiveForm::Base
  attributes :name, :city, required: true

  association :speakers do
    attributes :name, :occupation, required: true
  end
end
```

By default, the `association :speakers` declaration will create a single Speaker object. You can specify how many objects you want in your form to be rendered with the `new` action as follows: `association: speakers, records: 2`. This will create 2 new Speaker objects, and ofcourse fields to create 2 Speaker objects. There are also some link helpers to dynamically add/remove objects from collection associations. Read below.

This basically works like a nested `property` that iterates over a collection of speakers.

### has_many: Rendering

ActiveForm will expose the collection using the `#speakers` method.

```erb
<% form_for @conference_form |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :city %>

  <% f.fields_for :speakers do |s| %>
    <%= s.text_field :name %>
    <%= s.text_field :occupation %>
  <% end %>
<% end %>
```

## Nesting Forms: 1-1 Relations

Speakers are allowed to have 1 Presentation.

```ruby
class Speaker < ActiveRecord::Base
  has_one :presentation
  belongs_to :conference
  validates :name, uniqueness: true
end
```

The full form should look like this:

```ruby
class ConferenceForm < ActiveForm::Base
  attributes :name, :city, required: true

  association :speakers do
    attribute :name, :occupation, required: true

    association :presentation do
      attribute :topic, :duration, required: true
    end
  end
end
```

### has_one: Rendering

Use `#fields_for` in a Rails environment to correctly setup the structure of params.

```erb
<% form_for @conference_form |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :city %>

  <% f.fields_for :speakers do |s| %>
    <%= s.text_field :name %>
    <%= s.text_field :occupation %>

    <% s.fields_for :presentation do |p| %>
      <%= p.text_field :topic %>
      <%= p.text_field :duration %>
    <% end %>
  <% end %>
<% end %>
```

## Dynamically adding/removing nested objects

ActiveForm comes with two helpers to deal with this functionality:

1. `link_to_add_association` will display a link that renders fields to create a new object
2. `link_to_remove_association` will display a link to remove a existing/dynamic object

In order to use it you have to insert this line: `//= require link_helpers` to your `application.js` file.

In our `ConferenceForm` we can dynamically create/remove Speaker objects. To do that we would write in the `conferences/_form.html.erb` partial:

```erb
<%= form_for @conference_form do |f| %>
  <% if @conference_form.errors.any? %>
    <div id="error_explanation">
      <h2><%= pluralize(@conference_form.errors.count, "error") %> prohibited this conference from being saved:</h2>

      <ul>
      <% @conference_form.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
      </ul>
    </div>
  <% end %>

  <h2>Conference Details</h2>
  <div class="field">
    <%= f.label :name, "Conference Name" %><br>
    <%= f.text_field :name %>
  </div>
  <div class="field">
    <%= f.label :city %><br>
    <%= f.text_field :city %>
  </div>

  <h2>Speaker Details</h2>
  <%= f.fields_for :speakers do |speaker_fields| %>
    <%= render "speaker_fields", :f => speaker_fields %>
  <% end %>

  <div class="links">
    <%= link_to_add_association "Add a Speaker", f, :speakers %>
  </div>

  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

Our `conferences/_speaker_fields.html.erb` would be:

```erb
<div class="nested-fields">
  <div class="field">
    <%= f.label :name, "Speaker Name" %><br>
    <%= f.text_field :name %>
  </div>

  <div class="field">
    <%= f.label :occupation %><br>
    <%= f.text_field :occupation %>
  </div>

  <h2>Presentantions</h2>
  <%= f.fields_for :presentation do |presentations_fields| %>
    <%= render "presentation_fields", :f => presentations_fields %>
  <% end %>

  <%= link_to_remove_association "Delete", f %>
</div>
```

And `conferences/_presentation_fields.html.erb` would be:

```erb
<div class="field">
  <%= f.label :topic %><br>
  <%= f.text_field :topic %>
</div>

<div class="field">
  <%= f.label :duration %><br>
  <%= f.text_field :duration %>
</div>
```

Callbacks
---------

Active Form provides `after_save` callback. Callbacks allow you to
trigger logic during the lifecycle of a form.

### Usage

```ruby
class SignupForm < ActiveForm::Base
  self.main_model = :user

  after_save :notify_with_email

  def notify_with_email
    UserMailer.signup_email(model.id)
  end
end
```

Testing forms
-------------

TODO
