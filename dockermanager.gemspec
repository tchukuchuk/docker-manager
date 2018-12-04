# -*- encoding: utf-8 -*-

require File.expand_path('../lib/dockermanager/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'docker-manager'
  s.version = DockerManager::VERSION
  s.authors = ['Julien Biard']
  s.description = ''
  s.license = ''
  s.email = 'julien.biard@gmail.com'
  s.executables = ['docker-manager']
  s.extra_rdoc_files = %w[CHANGELOG.md README.md]
  s.files = `git ls-files -z`.split("\0")
  s.test_files = `git ls-files -z spec/`.split("\0")
  s.homepage = ''
  s.summary = ''

  s.add_dependency('sshkit', '1.16.1')

  s.required_ruby_version = '>= 2.0.0'
end
