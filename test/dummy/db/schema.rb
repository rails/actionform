# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141227165333) do

  create_table "answers", force: true do |t|
    t.text     "content"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id"

  create_table "artists", force: true do |t|
    t.string   "name"
    t.integer  "song_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "artists", ["song_id"], name: "index_artists_on_song_id"

  create_table "assignments", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conferences", force: true do |t|
    t.string   "name"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", force: true do |t|
    t.string   "address"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["user_id"], name: "index_emails_on_user_id"

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "role"
    t.string   "description"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["project_id"], name: "index_people_on_project_id"

  create_table "presentations", force: true do |t|
    t.string   "topic"
    t.string   "duration"
    t.integer  "speaker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "presentations", ["speaker_id"], name: "index_presentations_on_speaker_id"

  create_table "producers", force: true do |t|
    t.string   "name"
    t.string   "studio"
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "producers", ["artist_id"], name: "index_producers_on_artist_id"

  create_table "profiles", force: true do |t|
    t.string   "twitter_name"
    t.string   "github_name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id"

  create_table "project_tags", force: true do |t|
    t.integer  "project_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_tags", ["project_id"], name: "index_project_tags_on_project_id"
  add_index "project_tags", ["tag_id"], name: "index_project_tags_on_tag_id"

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.datetime "published_at"
  end

  create_table "questions", force: true do |t|
    t.text     "content"
    t.integer  "survey_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["survey_id"], name: "index_questions_on_survey_id"

  create_table "songs", force: true do |t|
    t.string   "title"
    t.string   "length"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "speakers", force: true do |t|
    t.string   "name"
    t.string   "occupation"
    t.integer  "conference_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "speakers", ["conference_id"], name: "index_speakers_on_conference_id"

  create_table "sub_tasks", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "done"
    t.integer  "task_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sub_tasks", ["task_id"], name: "index_sub_tasks_on_task_id"

  create_table "surveys", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tasks", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.boolean  "done"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assignment_id"
    t.datetime "finished_at"
  end

  add_index "tasks", ["assignment_id"], name: "index_tasks_on_assignment_id"
  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.integer  "age"
    t.integer  "gender"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
