# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "voter-gateway"
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["brettbevers"]
  s.date = "2013-05-31"
  s.email = "brett@nationbuilder.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/voter-gateway.rb",
    "lib/voter_file/csv_audit.rb",
    "lib/voter_file/csv_driver.rb",
    "lib/voter_file/csv_driver/csv_file.rb",
    "lib/voter_file/csv_driver/database_table.rb",
    "lib/voter_file/csv_driver/fuzzy_merger.rb",
    "lib/voter_file/csv_driver/record_matcher.rb",
    "lib/voter_file/csv_driver/record_merger.rb",
    "lib/voter_file/csv_driver/working_table.rb",
    "lib/voter_file/database_audit.rb",
    "lib/voter_file/dedup_audit.rb",
    "lib/voter_file/dedup_driver.rb",
    "lib/voter_file/dedup_job.rb",
    "lib/voter_file/import_job.rb",
    "lib/voter_file/merge_audit.rb",
    "lib/voter_file/merge_audit_sql.rb",
    "spec/csv_driver_csv_file_spec.rb",
    "spec/csv_driver_database_table_spec.rb",
    "spec/csv_driver_record_matcher_spec.rb",
    "spec/csv_driver_record_merger_spec.rb",
    "spec/csv_driver_spec.rb",
    "spec/csv_driver_working_table_spec.rb",
    "spec/import_job_base_spec.rb",
    "spec/merge_audit_spec.rb",
    "spec/spec_helper.rb",
    "voter-gateway.gemspec"
  ]
  s.homepage = "http://github.com/3dna/voter-gateway"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "A database gateway for importing and merging records."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.2.13"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.4"])
      s.add_development_dependency(%q<awesome_print>, ["~> 1.1.0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<pry-nav>, [">= 0"])
      s.add_development_dependency(%q<pry-rails>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.2.13"])
      s.add_dependency(%q<rspec>, ["~> 2.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.4"])
      s.add_dependency(%q<awesome_print>, ["~> 1.1.0"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<pry-nav>, [">= 0"])
      s.add_dependency(%q<pry-rails>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.2.13"])
    s.add_dependency(%q<rspec>, ["~> 2.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<simplecov>, ["~> 0.7.1"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.4"])
    s.add_dependency(%q<awesome_print>, ["~> 1.1.0"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<pry-nav>, [">= 0"])
    s.add_dependency(%q<pry-rails>, [">= 0"])
  end
end

