guard "rspec", :cli => '--colour --pattern "spec/**/*.spec"' do
  watch(%r{^spec/(.+)\.spec$})              { |m| "spec/#{m[1]}*spec" }
  watch(%r{^lib/(.+)\.rb$})                 { |m| "spec/#{m[1]}*spec" }
  watch("spec/spec_helper.rb")              { "spec/" }
  watch(%r{^spec/shared/.+\.rb$})           { "spec/" }
end