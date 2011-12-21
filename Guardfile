guard "rspec", :version => 2, :cli => '--colour --pattern "spec/**/*.spec"' do
  watch(%r{^spec/(.+)\.spec$})                        { |m| "spec/#{m[1]}*spec" }
  watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/#{m[1]}*spec" }
  watch("spec/spec_helper.rb")                        { "spec/" }
end