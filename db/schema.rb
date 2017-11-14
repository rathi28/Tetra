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

ActiveRecord::Schema.define(version: 20170413072106) do

  create_table "action_logs", force: true do |t|
    t.string   "user"
    t.string   "action"
    t.string   "target"
    t.datetime "time_of_action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", force: true do |t|
    t.string "login"
  end

  create_table "brands", primary_key: "idBrands", force: true do |t|
    t.string "Brandname", limit: 45, null: false
  end

  add_index "brands", ["Brandname"], name: "Brandname_UNIQUE", unique: true, using: :btree

  create_table "brands_excluded_selection_workarounds", force: true do |t|
    t.string   "brand"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "brandurldata", force: true do |t|
    t.string "brand",       limit: 45,                   null: false
    t.string "development", limit: 45,                   null: false
    t.string "qa",          limit: 45,                   null: false
    t.string "prod",        limit: 45,                   null: false
    t.string "test_env",    limit: 45, default: "grdev"
    t.string "stg"
  end

  add_index "brandurldata", ["brand"], name: "Brandname_idx", using: :btree
  add_index "brandurldata", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "browsertypes", force: true do |t|
    t.string  "browser",     limit: 45, default: "chrome", null: false
    t.integer "device_type",            default: 0,        null: false
    t.integer "remote",                 default: 0,        null: false
    t.string  "human_name",  limit: 45, default: "chrome", null: false
    t.integer "active",                 default: 1
  end

  add_index "browsertypes", ["browser"], name: "browser_UNIQUE", unique: true, using: :btree

  create_table "campaigns", force: true do |t|
    t.string  "Brand",                   limit: 45,  default: "ProactivPlus",    null: false
    t.string  "grcid",                   limit: 200
    t.string  "campaignname",            limit: 400, default: "defaultname"
    t.integer "core",                                default: 0,                 null: false
    t.integer "Active",                              default: 0,                 null: false
    t.string  "DesktopBuyflow",          limit: 20,  default: "DBF4",            null: false
    t.string  "DesktopHomePageTemplate", limit: 20,  default: "DHP1",            null: false
    t.string  "DesktopSASTemplate",      limit: 20,  default: "DIL1",            null: false
    t.string  "DesktopSASPagePattern",   limit: 100, default: "kit_gift_supply", null: false
    t.string  "DesktopCartPageTemplate", limit: 20,  default: "DPC",             null: false
    t.string  "MobileBuyflow",           limit: 20,  default: "MBF4"
    t.string  "MobileHomepageTemplate",  limit: 20,  default: "MHP2"
    t.string  "MobileSASTemplate",       limit: 20,  default: "MIL2"
    t.string  "MobileSASPagePattern",    limit: 100, default: "kit_gift_supply"
    t.string  "MobileCartPageTemplate",  limit: 20,  default: "MPC"
    t.string  "UCI",                     limit: 45
    t.string  "default_offercode",       limit: 20
    t.string  "environment",             limit: 45,  default: "qa",              null: false
    t.integer "testenabled",                         default: 0,                 null: false
    t.string  "experience",              limit: 45,  default: "desktop"
    t.string  "comments",                limit: 500, default: ""
    t.string  "produrl",                 limit: 200, default: ""
    t.string  "qaurl",                   limit: 200, default: ""
    t.string  "expectedvitamin"
    t.string  "realm"
    t.boolean "is_test_panel"
  end

  add_index "campaigns", ["Brand"], name: "brand_idx", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "error_codes", force: true do |t|
    t.string   "human_name"
    t.integer  "errorcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "error_messages", force: true do |t|
    t.text     "message"
    t.text     "backtrace"
    t.text     "class_name"
    t.integer  "testrun_id"
    t.integer  "test_run_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "error_messages", ["test_run_id"], name: "index_error_messages_on_test_run_id", using: :btree
  add_index "error_messages", ["testrun_id"], name: "index_error_messages_on_testrun_id", using: :btree

  create_table "grid_processes", force: true do |t|
    t.string "ip",   limit: 45
    t.string "port", limit: 45
    t.string "name", limit: 45
    t.string "role", limit: 45
  end

  create_table "locators", force: true do |t|
    t.text "css"
    t.text "brand"
    t.text "step"
    t.text "offer"
  end

  create_table "locators_mirror", force: true do |t|
    t.text "css"
    t.text "brand"
    t.text "step"
    t.text "offer"
  end

  create_table "offer_data_details", force: true do |t|
    t.text     "offer_title"
    t.text     "offerdesc"
    t.integer  "offerdatum_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offerdata", force: true do |t|
    t.string  "OfferCode",        limit: 50,             null: false
    t.text    "SupplySize"
    t.text    "PieceCount"
    t.text    "Bonus"
    t.text    "Offer"
    t.string  "ExtraStep",        limit: 45
    t.text    "Entry"
    t.text    "Continuity"
    t.text    "StartSH"
    t.text    "ContinuitySH"
    t.text    "Rush"
    t.text    "OND"
    t.text    "grcid"
    t.text    "Brand"
    t.integer "qa",                          default: 0, null: false
    t.integer "prod",                        default: 0, null: false
    t.integer "desktop",                     default: 0
    t.integer "mobile",                      default: 0
    t.integer "isvitamin"
    t.text    "cart_description"
    t.string  "product"
    t.integer "stg"
    t.integer "campaign_id"
  end

  add_index "offerdata", ["campaign_id"], name: "index_offerdata_on_campaign_id", using: :btree

  create_table "orderforms", force: true do |t|
    t.text "orderformname"
    t.text "email"
    t.text "phone"
    t.text "phone1"
    t.text "phone2"
    t.text "phone3"
    t.text "firstname"
    t.text "lastname"
    t.text "billAddress"
    t.text "billAddress2"
    t.text "billCity"
    t.text "billState"
    t.text "billZip"
    t.text "creditCardNumber"
    t.text "creditCardMonth"
    t.text "creditCardYear"
    t.text "agreetoterms"
  end

  add_index "orderforms", ["id"], name: "id_UNIQUE", unique: true, using: :btree

  create_table "page_identifiers", force: true do |t|
    t.string "page"
    t.string "value"
  end

  create_table "pixel_data", force: true do |t|
    t.string   "pixel_handle"
    t.integer  "expected_state"
    t.integer  "test_url_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "pixel_name"
  end

  add_index "pixel_data", ["test_url_id"], name: "index_pixel_data_on_test_url_id", using: :btree

  create_table "pixel_tests", force: true do |t|
    t.string   "testname"
    t.string   "brand"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "environment"
    t.string   "testtype"
    t.text     "pixel_name"
    t.text     "mmtest"
    t.string   "suitetype"
    t.string   "uci"
  end

  create_table "recurring_schedules", force: true do |t|
    t.string   "name"
    t.string   "testtype"
    t.string   "weeklyday"
    t.integer  "dailyhour"
    t.integer  "dailyminute"
    t.string   "grcid"
    t.integer  "vanitylist"
    t.integer  "ucilist"
    t.string   "driver"
    t.string   "platform"
    t.string   "brand"
    t.string   "environment"
    t.datetime "creationdate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customurl"
    t.string   "customoffer"
    t.date     "lastrundate"
    t.integer  "active"
    t.integer  "pixel_suite"
    t.text     "email"
    t.string   "realm"
    t.text     "custom_settings"
  end

  create_table "seo_files", force: true do |t|
    t.string "filename"
    t.string "domain"
    t.string "targeturl"
    t.text   "valid_content"
  end

  create_table "seo_validations", force: true do |t|
    t.string  "realm"
    t.boolean "is_core"
    t.string  "page_name"
    t.string  "validation_type"
    t.text    "value"
    t.boolean "present"
  end

  create_table "shippingtests", force: true do |t|
    t.string   "shippingtype"
    t.string   "actual"
    t.string   "expected"
    t.integer  "testrun_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shippingtests", ["testrun_id"], name: "index_shippingtests_on_testrun_id", using: :btree

  create_table "table_enforce_buyflows", force: true do |t|
    t.string "name", limit: 45
  end

  add_index "table_enforce_buyflows", ["name"], name: "name_UNIQUE", unique: true, using: :btree

  create_table "table_enforce_cart", force: true do |t|
    t.string "name", limit: 45, null: false
  end

  create_table "table_enforce_marketing", force: true do |t|
    t.string "name", limit: 45
  end

  create_table "table_enforce_platforms", force: true do |t|
    t.string "name", limit: 10, default: "desktop", null: false
  end

  add_index "table_enforce_platforms", ["name"], name: "name_UNIQUE", unique: true, using: :btree

  create_table "table_enforce_sas_template", force: true do |t|
    t.string "name", limit: 45
  end

  create_table "test_runs", force: true do |t|
    t.string   "testtype"
    t.text     "url"
    t.text     "remote_url"
    t.string   "runby"
    t.float    "runtime",         limit: 24
    t.integer  "result"
    t.string   "brand"
    t.string   "campaign"
    t.string   "platform"
    t.string   "browser"
    t.string   "env"
    t.text     "scripterror"
    t.integer  "lock_test"
    t.string   "workerassigned"
    t.string   "driver"
    t.string   "driverplatform"
    t.integer  "test_suites_id"
    t.datetime "datetime"
    t.text     "comments"
    t.datetime "scheduledate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.text     "custom_settings"
    t.text     "Notes"
    t.integer  "isolated"
    t.string   "order_id"
    t.string   "offercode"
    t.string   "realm"
    t.string   "custom_data"
  end

  create_table "test_steps", force: true do |t|
    t.integer  "testrunid"
    t.string   "expected"
    t.string   "actual"
    t.integer  "result"
    t.integer  "errorcode"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "step_name"
    t.integer  "test_run_id"
  end

  add_index "test_steps", ["test_run_id"], name: "index_test_steps_on_test_run_id", using: :btree

  create_table "test_suites", force: true do |t|
    t.string   "Ran By",            limit: 45,  default: "Automation",   null: false
    t.datetime "DateTime"
    t.string   "Test Suite Name",   limit: 200
    t.float    "Runtime",           limit: 24
    t.integer  "Pass",                          default: 0,              null: false
    t.integer  "Fail",                          default: 0,              null: false
    t.integer  "TotalTests",                    default: 0,              null: false
    t.string   "Status",            limit: 45,  default: "Not Started",  null: false
    t.string   "SuiteType",         limit: 45,  default: "Offercode",    null: false
    t.string   "Campaign",          limit: 45,  default: "core",         null: false
    t.string   "Brand",             limit: 45,  default: "ProactivPlus", null: false
    t.string   "Browser",           limit: 45,  default: "chrome",       null: false
    t.string   "Platform",          limit: 45,  default: "Desktop",      null: false
    t.string   "URL",               limit: 45
    t.string   "offercode",         limit: 45
    t.string   "Environment",       limit: 45,  default: "qa"
    t.string   "emailnotification"
    t.datetime "scheduledate"
    t.integer  "scheduleid"
    t.string   "realm"
    t.boolean  "email_random"
    t.boolean  "is_upsell"
  end

  create_table "test_urls", force: true do |t|
    t.text     "url"
    t.text     "appendstring"
    t.string   "mode"
    t.integer  "testdata_id"
    t.string   "page_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "mmtest"
    t.integer  "vanity_uci_suite_id"
    t.integer  "pixel_test_id"
    t.string   "uci"
    t.string   "offercode"
    t.string   "campaign"
    t.string   "realm"
    t.boolean  "is_core"
  end

  add_index "test_urls", ["pixel_test_id"], name: "index_test_urls_on_pixel_test_id", using: :btree
  add_index "test_urls", ["vanity_uci_suite_id"], name: "index_test_urls_on_vanity_uci_suite_id", using: :btree

  create_table "testruns", force: true do |t|
    t.string   "test name",             limit: 200, default: "placeholder",                                            null: false
    t.string   "runby",                 limit: 45,  default: "Automation",                                             null: false
    t.float    "runtime",               limit: 24,  default: 0.0,                                                      null: false
    t.string   "result",                limit: 45,  default: "waiting",                                                null: false
    t.string   "Brand",                 limit: 45,  default: "ProactivPlus",                                           null: false
    t.string   "Campaign",              limit: 45,  default: "",                                                       null: false
    t.string   "Platform",              limit: 300, default: "Windows 7",                                              null: false
    t.string   "Browser",               limit: 100, default: "chrome",                                                 null: false
    t.string   "Env",                   limit: 45,  default: "qa",                                                     null: false
    t.string   "ExpectedOffercode",     limit: 45,                                                                     null: false
    t.string   "ActualOffercode",       limit: 45,                                                                     null: false
    t.string   "Expected UCI",          limit: 45,                                                                     null: false
    t.string   "UCI HP",                limit: 45,                                                                     null: false
    t.string   "UCI OP",                limit: 45,                                                                     null: false
    t.string   "UCI CP",                limit: 45,                                                                     null: false
    t.string   "ConfirmationNum",       limit: 45,                                                                     null: false
    t.datetime "DateTime",                                                                                             null: false
    t.integer  "test_suites_id",                    default: 0,                                                        null: false
    t.text     "Notes"
    t.string   "Driver",                limit: 45,  default: "chrome",                                                 null: false
    t.string   "DriverPlatform",        limit: 45,  default: "Desktop",                                                null: false
    t.string   "status",                limit: 45,  default: "Not Started",                                            null: false
    t.string   "url",                   limit: 500, default: "https://storefront:Grcweb123@proactiv.qa.dw.grdev.com/", null: false
    t.string   "testtype",              limit: 45,  default: "offercode"
    t.string   "expectedcampaign",      limit: 45,  default: "core"
    t.string   "Backtrace",             limit: 200, default: "",                                                       null: false
    t.string   "workerassigned",        limit: 45
    t.datetime "scheduledate"
    t.integer  "lock_test"
    t.text     "comments"
    t.string   "remote_url"
    t.string   "price_a"
    t.string   "price_e"
    t.string   "confoffercode"
    t.string   "vitamincode"
    t.string   "vitaminexpected"
    t.string   "vitamin_pricing"
    t.text     "cart_language"
    t.string   "cart_title"
    t.string   "total_pricing"
    t.string   "subtotal_price"
    t.text     "saspricing"
    t.string   "billname"
    t.string   "billemail"
    t.string   "shipaddress"
    t.string   "billaddress"
    t.string   "Standard"
    t.string   "Rush"
    t.string   "Overnight"
    t.string   "continuitysh"
    t.string   "sas_kit_name"
    t.string   "cart_quantity"
    t.string   "vitamin_title"
    t.text     "vitamin_description"
    t.string   "conf_kit_name"
    t.string   "conf_vitamin_name"
    t.string   "confvitaminpricing"
    t.string   "confpricing"
    t.string   "shipping_conf"
    t.boolean  "dummyboolean"
    t.string   "uci_sas"
    t.string   "shipping_conf_val"
    t.string   "selected_shipping"
    t.text     "kitnames"
    t.string   "sasprices"
    t.string   "lastpagefound"
    t.text     "billing_shipping_hash"
    t.integer  "isolated"
    t.string   "realm"
    t.boolean  "is_upsell",                         default: false,                                                    null: false
  end

  add_index "testruns", ["test_suites_id"], name: "Suite_id_idx", using: :btree

  create_table "users", force: true do |t|
    t.string "username",      limit: 45, default: "BadUser",                   null: false
    t.string "password",      limit: 45, default: "BadUser",                   null: false
    t.string "admin",         limit: 45, default: "No",                        null: false
    t.string "email",         limit: 45, default: "ssankara@guthy-renker.com", null: false
    t.string "login"
    t.text   "group_strings"
    t.string "ou_strings"
    t.string "name"
  end

  create_table "vanity_uci_suites", force: true do |t|
    t.string   "testname"
    t.string   "brand"
    t.string   "environment"
    t.string   "testtype"
    t.string   "group"
    t.boolean  "uci"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workers", force: true do |t|
    t.string   "name"
    t.string   "ip"
    t.integer  "pixel"
    t.integer  "buyflow"
    t.integer  "offercode"
    t.integer  "scheduled"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
