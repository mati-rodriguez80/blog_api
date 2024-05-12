FactoryBot.define do
  # Factory created after running:
  # rails g factory_bot:model post title:string content:string published:boolean user:references
  # Regarding "user", FactoryBot is smart enough to do a reference to users factory, so it can
  # create a new user when creating a post.
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published {
      r = rand(0..1)
      if r == 0
        false
      else
        true
      end
    }
    user
  end

  factory :published_post, class: 'Post' do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published { true }
    user
  end
end
