source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"
gem "trollop", "~> 1.16.2"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rspec", "~> 2.5.0"
  gem "yard", "~> 0.6.0"
  gem "cucumber", ">= 0"
  gem "bundler", "~> 1.0.0"
  gem "jeweler", "~> 1.5.2"
  # rcov is good only for MRI 1.8.x
  if RUBY_VERSION.start_with? '1.8'
    if !RUBY_ENGINE or RUBY_ENGINE == 'ruby'
      gem "rcov", ">= 0"
    end
  end
  gem "fakefs", "~> 0.3.1"
end
