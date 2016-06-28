Pod::Spec.new do |s|
  s.name             = 'Pdfty'
  s.version          = '0.1.2'
  s.summary          = 'A simple pdf utility with horizontal scrolling.'

  s.description      = <<-DESC
                       A wrapper of CGPDFDocument and custom scroll view to horizontal scroll.
                       DESC

  s.homepage         = 'https://github.com/tnantoka/Pdfty'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tnantoka' => 'tnantoka@bornneet.com' }
  s.source           = { :git => 'https://github.com/tnantoka/Pdfty.git', :tag => "v#{s.version}" }
  s.social_media_url = 'https://twitter.com/tnantoka'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Pdfty/**/*.{h,swift}'
end
