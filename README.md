# Active Form

[![Build Status](https://api.travis-ci.org/rails/activeform.svg?branch=master)](https://travis-ci.org/rails/activeform)

Set your models free from the `accepts_nested_attributes_for` helper. Active Form provides an object-oriented approach to represent your forms by building a form object, rather than relying on Active Record internals for doing this. Form objects provide an API to describe the models involved in the form, their attributes and validations. A form object deals with create/update actions of nested objects in a more seamless way.

## Installation

Add this line to your `Gemfile`:

```ruby
gem 'active_form'
```

## Defining Forms

Consider an example where you want to create/update a conference that can have many speakers which can present a single presentation with one form submission. You start by defining a form to represent the root model, `Conference`:

```ruby
class ConferenceForm < ActiveForm::Base
  self.main_model = :conference

  attributes :name, :city

  validates :name, :city, presence: true
end
```

Your form object has to subclass `ActiveForm::Base` in order to gain the necessary API. When defining the form, you have to specify the main_model the form represents with the following line:

```ruby
self.main_model = :conference
```

To add fields to the form, use the `attributes` or `attribute` class method. The form can also define validation rules for the model it represents. For the `presence` validation rule there is a short inline syntax:

```ruby
class ConferenceForm < ActiveForm::Base
  attributes :name, :city, required: true
end
```

## The API

The `ActiveForm::Base` class provides a simple API with only a few instance/class methods. Below are listed the instance methods:

1. `initialize(model)` accepts an instance of the model that the form represents.
2. `submit(params)` updates the main form's model and nested models with the posted parameters. The models are not saved/updated until you call `save`.
3. `errors` returns validation messages in a classy Active Model style.
4. `save` will call `save` on the model and nested models. This method will validate the model and nested models and if no error arises then it will save them and return true.

The following are the class methods:

1. `attributes` accepts the names of attributes to define on the form. If you want to declare a presence validation rule for the given attributes, you can pass in the `required: true` option as showcased above. The `attribute` method is aliased to the `attributes` method.
2. `association(name, options={}, &block)` defines a nested form for the `name` model. If the model is a `has_many` association you can pass in the `records: x` option and fields to create `x` objects will be rendered. If you pass a block, you can define another nested form the same way.

In addition to the main API, forms expose accessors to the defined attributes. This is used for rendering or manual operations.

## Setup

In your controller you create a form instance and pass in the model you want to work on.

```ruby
class ConferencesController
  def new
    conference = Conference.new
    @conference_form = ConferenceForm.new(conference)
  end
end
```

You can also setup the form for editing existing items.

```ruby
class ConferencesController
  def edit
    conference = Conference.find(params[:id])
    @conference_form = ConferenceForm.new(conference)
  end
end
```

Active Form will read property values from the model in setup. Given the following form class.

```ruby
class ConferenceForm < ActiveForm::Base
  attribute :name
end
```

Internally, this form will call `conference.name` to populate the name field.

## Rendering Forms

Your `@conference_form` is now ready to be rendered, either do it yourself or use something like Rails' `form_for`, `simple_form` or `formtastic`.

```erb
<%= form_for @conference_form do |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :city %>
<% end %>
```

Nested forms and collections can be easily rendered with `fields_for`, etc. Just use Active Form as if it would be an Active Model instance in the view layer.

## Syncing Back

After setting up your form object, you can populate the models with the submitted parameters.

```ruby
class ConferencesController
  def create
    conference = Conference.new
    @conference_form = ConferenceForm.new(conference)
    @conference_form.submit(conference_params)
  end
end
```

This will write all the properties back to the model. In a nested form, this works recursively, of course.

## Saving Forms

After the form is populated with the posted data, you can save the model by calling `save`.

```ruby
class ConferencesController
  def create
    conference = Conference.new
    @conference_form = ConferenceForm.new(conference)
    @conference_form.submit(conference_params)

    if @conference_form.save
      redirect_to @conference_form, notice: "Conference: #{@conference_form.name} was successfully created." }
    else
      render :new
    end
  end
end
```

If the `save` method returns false due to validation errors defined on the form, you can render it again with the data that has been submitted and the errors found.

## Nesting Forms: 1-n Relations

Active Form also gives you nested collections.

Let's define the `has_many :speakers` collection association on the `Conference` model.

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

By default, the `association :speakers` declaration will create a single `Speaker` object. You can specify how many objects you want in your form to be rendered with the `new` action as follows: `association: speakers, records: 2`. This will create 2 new `Speaker` objects, and of course fields to create 2 `Speaker` objects. There are also some link helpers to dynamically add/remove objects from collection associations. Read below.

This basically works like a nested `property` that iterates over a collection of speakers.

### has_many: Rendering

Active Form will expose the collection using the `speakers` method.

```erb
<%= form_for @conference_form |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :city %>

  <%= f.fields_for :speakers do |s| %>
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

Use `fields_for` in a Rails environment to correctly setup the structure of params.

```erb
<%= form_for @conference_form |f| %>
  <%= f.text_field :name %>
  <%= f.text_field :city %>

  <%= f.fields_for :speakers do |s| %>
    <%= s.text_field :name %>
    <%= s.text_field :occupation %>

    <%= s.fields_for :presentation do |p| %>
      <%= p.text_field :topic %>
      <%= p.text_field :duration %>
    <% end %>
  <% end %>
<% end %>
```

## Dynamically Adding/Removing Nested Objects

Active Form comes with two helpers to deal with this functionality:

1. `link_to_add_association` will display a link that renders fields to create a new object.
2. `link_to_remove_association` will display a link to remove a existing/dynamic object.

In order to use it you have to insert this line: `//= require activeform` to your `app/assets/javascript/application.js` file.

In our `ConferenceForm` we can dynamically create/remove `Speaker` objects. To do that we would write in the `app/views/conferences/_form.html.erb` partial:

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

  <%= render_association_template f, :speakers %>
  <div class="speakers_list">
    <%= f.fields_for :speakers do |speaker_fields| %>
      <%= render "speaker_fields", :f => speaker_fields %>
    <% end %>
  </div>

  <div class="links">
    <%= link_to_add_association "Add a Speaker", f, :speakers, data: { "association-insertion-node" => ".speakers_list" } %>
  </div>

  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

Our `app/views/conferences/_speaker_fields.html.erb` would be:

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

And `app/views/conferences/_presentation_fields.html.erb` would be:

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

## Plain Old Ruby Object Forms

ActiveForm also can accept `ActiveModel::Model` instances as a model.

```ruby
class Feedback
  include ActiveModel::Model

  attr_accessible :name, :body, :email

  def save
    FeedbackMailer.send_email(email, name, body)
  end
end
```

The form should look like this.

```ruby
class FeedbackForm < ActiveForm::Base
  attributes :name, :body, :email, required: true
end
```

And then in controller:

```ruby
class FeedbacksController
  def create
    feedback = Feedback.new
    @feedback_form = FeedbackForm.new(feedback)
    @feedback_form.submit(feedback_params)

    if @feedback_form.save
      head :ok
    else
      render json: @feedback_form.errors
    end
  end
```

## Demos

You can find a list of applications using this gem in this repository: https://github.com/m-Peter/nested-form-examples .
All the examples are implemented in before/after pairs. The before is using the `accepts_nested_attributes_for`, while the after uses this gem to achieve the same functionality.

## Credits

Special thanks to the owners of the great gems that inspired this work:

* [Nick Sutterer](https://github.com/apotonick) - creator of [reform](https://github.com/apotonick/reform)
* [Nathan Van der Auwera](https://github.com/nathanvda) - creator of [cocoon](https://github.com/nathanvda/cocoon)
