Pod::Spec.new do |s|
  s.name = "CSDownLoader"
  s.version = "0.2.0"
  s.summary = "CSDownLoader."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"CoderSahara"=>"sahara@github.com"}
  s.homepage = "https://github.com/CoderSahara/CSDownLoader"
  s.description = "\u4E00\u4E2A\u4E0B\u8F7D\u7EC4\u4EF6"
  s.source = { :path => '.' }

  s.ios.deployment_target    = '8.0'
  s.ios.vendored_framework   = 'ios/CSDownLoader.framework'
end
