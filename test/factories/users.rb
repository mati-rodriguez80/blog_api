FactoryBot.define do
  # Factory created after running:
  # rails g factory_bot:model user email:string name:string auth_token:string
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }
    auth_token { "xxxxx" }
  end
end
