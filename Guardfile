# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest' do
  watch(%r|^spec/(.*)_spec\.rb|)
  watch(%r|^lib/(.*)([^/]+)\.rb|)     { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r|^app/controllers/(.*)\.rb|) { |m| "spec/controllers/#{m[1]}_spec.rb" }
  watch(%r|^app/helpers/(.*)\.rb|)     { |m| "spec/helpers/#{m[1]}_spec.rb" }
  watch(%r|^app/models/(.*)\.rb|)      { |m| "spec/unit/#{m[1]}_spec.rb" }
end
