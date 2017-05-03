require 'test_helper'
require_relative '../fixtures/user_form_fixture'
require_relative '../fixtures/user_with_email_form_fixture'

class NestedModelRenderingTest < ActionView::TestCase
  fixtures :all

  def form_for(*)
    @output_buffer = super
  end

  test "form_for renders correctly a new instance of UserFormFixture" do
    user = User.new
    user_form = UserFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.submit
    end

    assert_match(/action="\/users"/, output_buffer)
    assert_match(/class="new_user"/, output_buffer)
    assert_match(/id="new_user"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="user_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="user\[name\]" id="user_name" \/>/, output_buffer)

    assert_match(/<label for="user_age">Age<\/label>/, output_buffer)
    assert_match(/<input type="number" name="user\[age\]" id="user_age" \/>/, output_buffer)

    assert_match(/<label for="user_gender">Gender<\/label>/, output_buffer)

    assert_match(/<select name="user\[gender\]" id="user_gender">/, output_buffer)
    assert_match(/<option value="0">Male<\/option>/, output_buffer)
    assert_match(/<option value="1">Female<\/option>/, output_buffer)
    assert_match(/<\/select>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Create User" \/>/, output_buffer)
  end

  test "form_for renders correctly a existing instance of UserFormFixture" do
    user = users(:peter)
    user_form = UserFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.submit
    end

    id = user.id

    assert_match(/action="\/users\/#{id}"/, output_buffer)
    assert_match(/class="edit_user"/, output_buffer)
    assert_match(/id="edit_user_#{id}"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="user_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{user_form.name}" name="user\[name\]" id="user_name" \/>/, output_buffer)
    assert_match(/<label for="user_age">Age<\/label>/, output_buffer)
    assert_match(/<input type="number" value="#{user_form.age}" name="user\[age\]" id="user_age" \/>/, output_buffer)
    assert_match(/<label for="user_gender">Gender<\/label>/, output_buffer)
    assert_match(/<select name="user\[gender\]" id="user_gender">/, output_buffer)
    assert_match(/<option selected="selected" value="0">Male<\/option>/, output_buffer)
    assert_match(/<option value="1">Female<\/option>/, output_buffer)
    assert_match(/<\/select>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Update User" \/>/, output_buffer)
  end

  test "form_for renders correctly a new instance of UserWithEmailFormFixture" do
    user = User.new
    user_form = UserWithEmailFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
      }

      concat f.submit
    end

    assert_match(/action="\/users"/, output_buffer)
    assert_match(/class="new_user"/, output_buffer)
    assert_match(/id="new_user"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="user_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="user\[name\]" id="user_name" \/>/, output_buffer)
    assert_match(/<label for="user_age">Age<\/label>/, output_buffer)
    assert_match(/input type="number" name="user\[age\]" id="user_age" \/>/, output_buffer)
    assert_match(/<label for="user_gender">Gender<\/label>/, output_buffer)
    assert_match(/<select name="user\[gender\]" id="user_gender">/, output_buffer)
    assert_match(/<option value="0">Male<\/option>/, output_buffer)
    assert_match(/<option value="1">Female<\/option>/, output_buffer)
    assert_match(/<\/select>/, output_buffer)

    assert_match(/<label for="user_email_attributes_address">Address<\/label>/, output_buffer)
    assert_match(/<input type="text" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" \/>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Create User" \/>/, output_buffer)
  end

  test "form_for renders correctly a existing instance of UserWithEmailFormFixture" do
    user = users(:peter)
    user_form = UserWithEmailFormFixture.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
      }

      concat f.submit
    end

    id = user.id

    assert_match(/action="\/users\/#{id}"/, output_buffer)
    assert_match(/class="edit_user"/, output_buffer)
    assert_match(/id="edit_user_#{id}"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="user_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{user_form.name}" name="user\[name\]" id="user_name" \/>/, output_buffer)
    assert_match(/<label for="user_age">Age<\/label>/, output_buffer)
    assert_match(/<input type="number" value="#{user_form.age}" name="user\[age\]" id="user_age" \/>/, output_buffer)
    assert_match(/<label for="user_gender">Gender<\/label>/, output_buffer)
    assert_match(/<select name="user\[gender\]" id="user_gender">/, output_buffer)
    assert_match(/<option selected="selected" value="0">Male<\/option>/, output_buffer)
    assert_match(/<option value="1">Female<\/option>/, output_buffer)
    assert_match(/<\/select>/, output_buffer)

    assert_match(/<label for="user_email_attributes_address">Address<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{user_form.email.address}" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" \/>/, output_buffer)
    assert_match(/<input type="hidden" value="#{user_form.email.id}" name="user\[email_attributes\]\[id\]" id="user_email_attributes_id" \/>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Update User" \/>/, output_buffer)
  end

  test "form_for renders correctly a new instance of UserWithEmailAndProfileFormFixture" do
    user = User.new
    user_form = UserForm.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
      }

      concat f.fields_for(:profile, user_form.profile) { |profile_fields|
        concat profile_fields.label(:twitter_name)
        concat profile_fields.text_field(:twitter_name)

        concat profile_fields.label(:github_name)
        concat profile_fields.text_field(:github_name)
      }

      concat f.submit
    end

    assert_match(/action="\/users"/, output_buffer)
    assert_match(/class="new_user"/, output_buffer)
    assert_match(/id="new_user"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="user_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="user\[name\]" id="user_name" \/>/, output_buffer)
    assert_match(/<label for="user_age">Age<\/label>/, output_buffer)
    assert_match(/input type="number" name="user\[age\]" id="user_age" \/>/, output_buffer)
    assert_match(/<label for="user_gender">Gender<\/label>/, output_buffer)
    assert_match(/<select name="user\[gender\]" id="user_gender">/, output_buffer)
    assert_match(/<option value="0">Male<\/option>/, output_buffer)
    assert_match(/<option value="1">Female<\/option>/, output_buffer)
    assert_match(/<\/select>/, output_buffer)

    assert_match(/<label for="user_email_attributes_address">Address<\/label>/, output_buffer)
    assert_match(/<input type="text" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" \/>/, output_buffer)

    assert_match(/<label for="user_profile_attributes_twitter_name">Twitter name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="user\[profile_attributes\]\[twitter_name\]" id="user_profile_attributes_twitter_name" \/>/, output_buffer)
    assert_match(/<label for="user_profile_attributes_github_name">Github name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="user\[profile_attributes\]\[github_name\]" id="user_profile_attributes_github_name" \/>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Create User" \/>/, output_buffer)
  end

  test "form_for renders correctly an existing instance of UserWithEmailAndProfileFormFixture" do
    user = users(:peter)
    user_form = UserForm.new(user)

    form_for user_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:age)
      concat f.number_field(:age)

      concat f.label(:gender)
      concat f.select(:gender, User.get_genders_dropdown)

      concat f.fields_for(:email, user_form.email) { |email_fields|
        concat email_fields.label(:address)
        concat email_fields.text_field(:address)
      }

      concat f.fields_for(:profile, user_form.profile) { |profile_fields|
        concat profile_fields.label(:twitter_name)
        concat profile_fields.text_field(:twitter_name)

        concat profile_fields.label(:github_name)
        concat profile_fields.text_field(:github_name)
      }

      concat f.submit
    end

    id = user.id

    assert_match(/action="\/users\/#{id}"/, output_buffer)
    assert_match(/class="edit_user"/, output_buffer)
    assert_match(/id="edit_user_#{id}"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="user_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{user_form.name}" name="user\[name\]" id="user_name" \/>/, output_buffer)
    assert_match(/<label for="user_age">Age<\/label>/, output_buffer)
    assert_match(/<input type="number" value="#{user_form.age}" name="user\[age\]" id="user_age" \/>/, output_buffer)
    assert_match(/<label for="user_gender">Gender<\/label>/, output_buffer)
    assert_match(/<select name="user\[gender\]" id="user_gender">/, output_buffer)
    assert_match(/<option selected="selected" value="0">Male<\/option>/, output_buffer)
    assert_match(/<option value="1">Female<\/option>/, output_buffer)
    assert_match(/<\/select>/, output_buffer)

    assert_match(/<label for="user_email_attributes_address">Address<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{user_form.email.address}" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" \/>/, output_buffer)
    assert_match(/<input type="hidden" value="#{user_form.email.id}" name="user\[email_attributes\]\[id\]" id="user_email_attributes_id" \/>/, output_buffer)

    assert_match(/<label for="user_profile_attributes_twitter_name">Twitter name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{user_form.profile.twitter_name}" name="user\[profile_attributes\]\[twitter_name\]" id="user_profile_attributes_twitter_name" \/>/, output_buffer)
    assert_match(/<label for="user_profile_attributes_github_name">Github name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{user_form.profile.github_name}" name="user\[profile_attributes\]\[github_name\]" id="user_profile_attributes_github_name" \/>/, output_buffer)
    assert_match(/<input type="hidden" value="#{user_form.profile.id}" name="user\[profile_attributes\]\[id\]" id="user_profile_attributes_id" \/>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Update User" \/>/, output_buffer)
  end

  test "form_for renders correctly a new instance of SongsFormFixture" do
    song = Song.new
    song_form = SongForm.new(song)
    artist = song_form.artist
    producer = artist.producer

    form_for song_form do |f|
      concat f.label(:title)
      concat f.text_field(:title)

      concat f.label(:length)
      concat f.text_field(:length)

      concat f.fields_for(:artist, artist) { |artist_fields|
        concat artist_fields.label(:name)
        concat artist_fields.text_field(:name)

        concat artist_fields.fields_for(:producer, producer) { |producer_fields|
          concat producer_fields.label(:name)
          concat producer_fields.text_field(:name)

          concat producer_fields.label(:studio)
          concat producer_fields.text_field(:studio)
        }
      }

      concat f.submit
    end

    assert_match(/action="\/songs"/, output_buffer)
    assert_match(/class="new_song"/, output_buffer)
    assert_match(/id="new_song"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="song_title">Title<\/label>/, output_buffer)
    assert_match(/<input type="text" name="song\[title\]" id="song_title" \/>/, output_buffer)
    assert_match(/<label for="song_length">Length<\/label>/, output_buffer)
    assert_match(/input type="text" name="song\[length\]" id="song_length" \/>/, output_buffer)

    assert_match(/<label for="song_artist_attributes_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="song\[artist_attributes\]\[name\]" id="song_artist_attributes_name" \/>/, output_buffer)

    assert_match(/<label for="song_artist_attributes_producer_attributes_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="song\[artist_attributes\]\[producer_attributes\]\[name\]" id="song_artist_attributes_producer_attributes_name" \/>/, output_buffer)
    assert_match(/<label for="song_artist_attributes_producer_attributes_studio">Studio<\/label>/, output_buffer)
    assert_match(/<input type="text" name="song\[artist_attributes\]\[producer_attributes\]\[studio\]" id="song_artist_attributes_producer_attributes_studio" \/>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Create Song" \/>/, output_buffer)
  end

  test "form_for renders correctly a existing instance of SongsFormFixture" do
    song = songs(:lockdown)
    song_form = SongForm.new(song)
    artist = song_form.artist
    producer = artist.producer

    form_for song_form do |f|
      concat f.label(:title)
      concat f.text_field(:title)

      concat f.label(:length)
      concat f.text_field(:length)

      concat f.fields_for(:artist, artist) { |artist_fields|
        concat artist_fields.label(:name)
        concat artist_fields.text_field(:name)

        concat artist_fields.fields_for(:producer, producer) { |producer_fields|
          concat producer_fields.label(:name)
          concat producer_fields.text_field(:name)

          concat producer_fields.label(:studio)
          concat producer_fields.text_field(:studio)
        }
      }

      concat f.submit
    end

    id = song.id

    assert_match(/action="\/songs\/#{id}"/, output_buffer)
    assert_match(/class="edit_song"/, output_buffer)
    assert_match(/id="edit_song_#{id}"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="song_title">Title<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{song_form.title}" name="song\[title\]" id="song_title" \/>/, output_buffer)
    assert_match(/<label for="song_length">Length<\/label>/, output_buffer)
    assert_match(/input type="text" value="#{song_form.length}" name="song\[length\]" id="song_length" \/>/, output_buffer)

    assert_match(/<label for="song_artist_attributes_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{artist.name}" name="song\[artist_attributes\]\[name\]" id="song_artist_attributes_name" \/>/, output_buffer)
    assert_match(/<input type="hidden" value="#{artist.id}" name="song\[artist_attributes\]\[id\]" id="song_artist_attributes_id" \/>/, output_buffer)

    assert_match(/<label for="song_artist_attributes_producer_attributes_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{producer.name}" name="song\[artist_attributes\]\[producer_attributes\]\[name\]" id="song_artist_attributes_producer_attributes_name" \/>/, output_buffer)
    assert_match(/<label for="song_artist_attributes_producer_attributes_studio">Studio<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{producer.studio}" name="song\[artist_attributes\]\[producer_attributes\]\[studio\]" id="song_artist_attributes_producer_attributes_studio" \/>/, output_buffer)
    assert_match(/<input type="hidden" value="#{producer.id}" name="song\[artist_attributes\]\[producer_attributes\]\[id\]" id="song_artist_attributes_producer_attributes_id" \/>/, output_buffer)

    assert_match(/<input type="submit" name="commit" value="Update Song" \/>/, output_buffer)
  end

  test "form_for renders correctly a new instance of ConferenceFormFixture" do
    conference = Conference.new
    conference_form = ConferenceForm.new(conference)
    speaker = conference_form.speaker
    presentations = speaker.presentations

    form_for conference_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:city)
      concat f.text_field(:city)

      concat f.fields_for(:speaker, speaker) { |speaker_fields|
        concat speaker_fields.label(:name)
        concat speaker_fields.text_field(:name)

        concat speaker_fields.label(:occupation)
        concat speaker_fields.text_field(:occupation)

        concat speaker_fields.fields_for(:presentations, presentations) { |presentation_fields|
          concat presentation_fields.label(:topic)
          concat presentation_fields.text_field(:topic)

          concat presentation_fields.label(:duration)
          concat presentation_fields.text_field(:duration)
        }
      }

      concat f.submit
    end

    assert_match(/action="\/conferences"/, output_buffer)
    assert_match(/class="new_conference"/, output_buffer)
    assert_match(/id="new_conference"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="conference_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="conference\[name\]" id="conference_name" \/>/, output_buffer)
    assert_match(/<label for="conference_city">City<\/label>/, output_buffer)
    assert_match(/<input type="text" name="conference\[city\]" id="conference_city" \/>/, output_buffer)

    assert_match(/<label for="conference_speaker_attributes_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="conference\[speaker_attributes\]\[name\]" id="conference_speaker_attributes_name" \/>/, output_buffer)
    assert_match(/<label for="conference_speaker_attributes_occupation">Occupation<\/label>/, output_buffer)
    assert_match(/<input type="text" name="conference\[speaker_attributes\]\[occupation\]" id="conference_speaker_attributes_occupation" \/>/, output_buffer)

    [0, 1].each do |i|
      assert_match(/<label for="conference_speaker_attributes_presentations_attributes_#{i}_topic">Topic<\/label>/, output_buffer)
      assert_match(/<input type="text" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[topic\]" id="conference_speaker_attributes_presentations_attributes_#{i}_topic" \/>/, output_buffer)
      assert_match(/<label for="conference_speaker_attributes_presentations_attributes_#{i}_duration">Duration<\/label>/, output_buffer)
      assert_match(/<input type="text" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[duration\]" id="conference_speaker_attributes_presentations_attributes_#{i}_duration" \/>/, output_buffer)
    end

    assert_match(/<input type="submit" name="commit" value="Create Conference" \/>/, output_buffer)
  end

  test "form_for renders correct a existing instance of ConferenceFormFixture" do
    conference = conferences(:ruby)
    conference_form = ConferenceForm.new(conference)
    speaker = conference_form.speaker
    presentations = speaker.presentations

    form_for conference_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.label(:city)
      concat f.text_field(:city)

      concat f.fields_for(:speaker, speaker) { |speaker_fields|
        concat speaker_fields.label(:name)
        concat speaker_fields.text_field(:name)

        concat speaker_fields.label(:occupation)
        concat speaker_fields.text_field(:occupation)

        concat speaker_fields.fields_for(:presentations, presentations) { |presentation_fields|
          concat presentation_fields.label(:topic)
          concat presentation_fields.text_field(:topic)

          concat presentation_fields.label(:duration)
          concat presentation_fields.text_field(:duration)
        }
      }

      concat f.submit
    end

    id = conference.id

    assert_match(/action="\/conferences\/#{id}"/, output_buffer)
    assert_match(/class="edit_conference"/, output_buffer)
    assert_match(/id="edit_conference_#{id}"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="conference_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{conference_form.name}" name="conference\[name\]" id="conference_name" \/>/, output_buffer)
    assert_match(/<label for="conference_city">City<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{conference_form.city}" name="conference\[city\]" id="conference_city" \/>/, output_buffer)

    assert_match(/<label for="conference_speaker_attributes_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{speaker.name}" name="conference\[speaker_attributes\]\[name\]" id="conference_speaker_attributes_name" \/>/, output_buffer)
    assert_match(/<label for="conference_speaker_attributes_occupation">Occupation<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{speaker.occupation}" name="conference\[speaker_attributes\]\[occupation\]" id="conference_speaker_attributes_occupation" \/>/, output_buffer)
    assert_match(/<input type="hidden" value="#{speaker.id}" name="conference\[speaker_attributes\]\[id\]" id="conference_speaker_attributes_id" \/>/, output_buffer)

    [0, 1].each do |i|
      assert_match(/<label for="conference_speaker_attributes_presentations_attributes_#{i}_topic">Topic<\/label>/, output_buffer)
      assert_match(/<input type="text" value="#{presentations[i].topic}" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[topic\]" id="conference_speaker_attributes_presentations_attributes_#{i}_topic" \/>/, output_buffer)
      assert_match(/<label for="conference_speaker_attributes_presentations_attributes_#{i}_duration">Duration<\/label>/, output_buffer)
      assert_match(/<input type="text" value="#{presentations[i].duration}" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[duration\]" id="conference_speaker_attributes_presentations_attributes_#{i}_duration" \/>/, output_buffer)
    end

    assert_match(/<input type="submit" name="commit" value="Update Conference" \/>/, output_buffer)
  end

  test "form_for renders correctly a new instance of SurveyFormFixture" do
    survey = Survey.new
    survey_form = SurveyForm.new(survey)
    questions = survey_form.questions

    form_for survey_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:questions, questions) { |question_fields|
        concat question_fields.label(:content)
        concat question_fields.text_field(:content)

        concat question_fields.fields_for(:answers, question_fields.object.answers) { |answer_fields|
          concat answer_fields.label(:content)
          concat answer_fields.text_field(:content)
        }
      }

      concat f.submit
    end

    assert_match(/action="\/surveys"/, output_buffer)
    assert_match(/class="new_survey"/, output_buffer)
    assert_match(/id="new_survey"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="survey_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" name="survey\[name\]" id="survey_name" \/>/, output_buffer)

    assert_match(/<label for="survey_questions_attributes_0_content">Content<\/label>/, output_buffer)
    assert_match(/<input type="text" name="survey\[questions_attributes\]\[0\]\[content\]" id="survey_questions_attributes_0_content" \/>/, output_buffer)

    [0, 1].each do |i|
      assert_match(/<label for="survey_questions_attributes_0_answers_attributes_#{i}_content">Content<\/label>/, output_buffer)
      assert_match(/<input type="text" name="survey\[questions_attributes\]\[0\]\[answers_attributes\]\[#{i}\]\[content\]" id="survey_questions_attributes_0_answers_attributes_#{i}_content" \/>/, output_buffer)
    end

    assert_match(/<input type="submit" name="commit" value="Create Survey" \/>/, output_buffer)
  end

  test "form_for renders correctly a existing instance of SurveyFormFixture" do
    survey = surveys(:programming)
    survey_form = SurveyForm.new(survey)
    questions = survey_form.questions

    form_for survey_form do |f|
      concat f.label(:name)
      concat f.text_field(:name)

      concat f.fields_for(:questions, questions) { |question_fields|
        concat question_fields.label(:content)
        concat question_fields.text_field(:content)

        concat question_fields.fields_for(:answers, question_fields.object.answers) { |answer_fields|
          concat answer_fields.label(:content)
          concat answer_fields.text_field(:content)
        }
      }

      concat f.submit
    end

    id = survey.id

    assert_match(/action="\/surveys\/#{id}"/, output_buffer)
    assert_match(/class="edit_survey"/, output_buffer)
    assert_match(/id="edit_survey_#{id}"/, output_buffer)
    assert_match(/method="post"/, output_buffer)

    assert_match(/<label for="survey_name">Name<\/label>/, output_buffer)
    assert_match(/<input type="text" value="#{survey_form.name}" name="survey\[name\]" id="survey_name" \/>/, output_buffer)

    assert_match(/<label for="survey_questions_attributes_0_content">Content<\/label>/, output_buffer)
    assert_match(/<input type="text" value="Which language allows closures\?" name="survey\[questions_attributes\]\[0\]\[content\]" id="survey_questions_attributes_0_content" \/>/, output_buffer)
    assert_match(/<input type="hidden" value="#{questions[0].id}" name="survey\[questions_attributes\]\[0\]\[id\]" id="survey_questions_attributes_0_id" \/>/, output_buffer)

    [0, 1].each do |i|
      assert_match(/<label for="survey_questions_attributes_0_answers_attributes_#{i}_content">Content<\/label>/, output_buffer)
      assert_match(/<input type="text" value="#{questions[0].answers[i].content}" name="survey\[questions_attributes\]\[0\]\[answers_attributes\]\[#{i}\]\[content\]" id="survey_questions_attributes_0_answers_attributes_#{i}_content" \/>/, output_buffer)
    end

    assert_match(/<input type="submit" name="commit" value="Update Survey" \/>/, output_buffer)
  end
end
