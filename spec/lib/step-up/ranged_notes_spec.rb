require "spec_helper"

describe StepUp::RangedNotes do
  before do
    @driver = StepUp::Driver::Git.new
  end

  context "checking notes" do
    it "should bring all notes between v0.0.2 and v0.1.0" do
      @notes = StepUp::RangedNotes.new(@driver, "v0.0.2", "v0.1.0")
      @notes.all_notes.should be == [
        [3, "features", 1, "3baad37d5098ad3b09935229e14e617c3ec8b7ee",
         "command line to show notes for the next version (unversioned notes)\n"]
      ]
    end
  end

  context "testing notes" do
    before do
      notes_sections = [{"name"=>"test_changes"}, {"name"=>"test_bugfixes"}, {"name"=>"test_features"}]
      class << notes_sections
        include StepUp::ConfigSectionsExt
      end
      StepUp::CONFIG.stubs(:notes_sections).returns(notes_sections)
      StepUp::CONFIG.notes.after_versioned.stubs(:section).returns("test_versioning")
    end

    context "until object f4cfcc2" do
      before do
        @notes = StepUp::RangedNotes.new(@driver, nil, "f4cfcc2")
      end
      it "should get all detached notes" do
        @notes.notes.should be == [
          [5, "test_changes", 1, "8299243c7dac8f27c3572424a348a7f83ef0ce28",
           "removing files from gemspec\n  .gitignore\n  lastversion.gemspec\n"],
          [2, "test_bugfixes", 1, "d7b0fa26ca547b963569d7a82afd7d7ca11b71ae",
           "sorting tags according to the mask parser\n"],
          [1, "test_changes", 1, "2fb8a3281fb6777405aadcd699adb852b615a3e4",
           "loading default configuration yaml\n\nloading external configuration yaml\n"]
        ]
      end
      it "should get a hash of distinct notes" do
        @notes.notes.should respond_to :as_hash
        @notes.notes.as_hash.should be == {
          "test_changes" => [
            ["8299243c7dac8f27c3572424a348a7f83ef0ce28",
             "removing files from gemspec\n  .gitignore\n  lastversion.gemspec\n", 1],
            ["2fb8a3281fb6777405aadcd699adb852b615a3e4",
             "loading default configuration yaml\n\nloading external configuration yaml\n", 1]
          ],
          "test_bugfixes" => [
            ["d7b0fa26ca547b963569d7a82afd7d7ca11b71ae",
             "sorting tags according to the mask parser\n", 1]
          ]
        }
      end
      it "should get the changelog message without objects" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Test changes:
        
          - removing files from gemspec
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml
          - loading external configuration yaml
        
        Test bugfixes:
        
          - sorting tags according to the mask parser
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        @notes.notes.as_hash.to_changelog.should be == changelog
      end
      it "should get the changelog message with objects" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Test changes:
        
          - removing files from gemspec (8299243c7dac8f27c3572424a348a7f83ef0ce28)
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml (2fb8a3281fb6777405aadcd699adb852b615a3e4)
          - loading external configuration yaml
        
        Test bugfixes:
        
          - sorting tags according to the mask parser (d7b0fa26ca547b963569d7a82afd7d7ca11b71ae)
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        @notes.notes.as_hash.to_changelog(:mode => :with_objects).should be == changelog
      end
      it "should get the changelog message with custom message" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Custom message:
        
          - New version create feature
          - Removed old version create feature
        
        Test changes:
        
          - removing files from gemspec
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml
          - loading external configuration yaml
        
        Test bugfixes:
        
          - sorting tags according to the mask parser
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        message_option = {:custom_message => "New version create feature\n\nRemoved old version create feature"}
        @notes.notes.as_hash.to_changelog(message_option).should be == changelog
      end
      it "should get the changelog message without custom message" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Test changes:
        
          - removing files from gemspec
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml
          - loading external configuration yaml
        
        Test bugfixes:
        
          - sorting tags according to the mask parser
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        @notes.notes.as_hash.to_changelog.should be == changelog
      end
    end

    context "until object f4cfcc2 with specific notes sections" do
      before do
        @notes = StepUp::RangedNotes.new(@driver, nil, "f4cfcc2", {:notes_sections => ["test_changes", "test_features"]})
      end
      it "should get all detached notes" do
        @notes.notes.should be == [
          [5, "test_changes", 1, "8299243c7dac8f27c3572424a348a7f83ef0ce28",
           "removing files from gemspec\n  .gitignore\n  lastversion.gemspec\n"],
          [1, "test_changes", 1, "2fb8a3281fb6777405aadcd699adb852b615a3e4",
           "loading default configuration yaml\n\nloading external configuration yaml\n"]
        ]
      end
      it "should get a hash of distinct notes" do
        @notes.notes.should respond_to :as_hash
        @notes.notes.as_hash.should be == {
          "test_changes" => [
            ["8299243c7dac8f27c3572424a348a7f83ef0ce28",
             "removing files from gemspec\n  .gitignore\n  lastversion.gemspec\n", 1],
            ["2fb8a3281fb6777405aadcd699adb852b615a3e4",
             "loading default configuration yaml\n\nloading external configuration yaml\n", 1]
          ]
        }
      end
      it "should get the changelog message without objects" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Test changes:
        
          - removing files from gemspec
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml
          - loading external configuration yaml
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        @notes.notes.as_hash.to_changelog.should be == changelog
      end
      it "should get the changelog message with objects" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Test changes:
        
          - removing files from gemspec (8299243c7dac8f27c3572424a348a7f83ef0ce28)
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml (2fb8a3281fb6777405aadcd699adb852b615a3e4)
          - loading external configuration yaml
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        @notes.notes.as_hash.to_changelog(:mode => :with_objects).should be == changelog
      end
      it "should get the changelog message with custom message" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Custom message:
        
          - New version create feature
          - Removed old version create feature
        
        Test changes:
        
          - removing files from gemspec
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml
          - loading external configuration yaml
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        message_option = {:custom_message => "New version create feature\n\nRemoved old version create feature"}
        @notes.notes.as_hash.to_changelog(message_option).should be == changelog
      end
      it "should get the changelog message without custom message" do
        @notes.notes.as_hash.should respond_to :to_changelog
        changelog = <<-EOF
        Test changes:
        
          - removing files from gemspec
            - .gitignore
            - lastversion.gemspec
          - loading default configuration yaml
          - loading external configuration yaml
        EOF
        changelog.gsub!(/^\s{8}/, '')
        changelog = changelog.rstrip
        @notes.notes.as_hash.to_changelog.should be == changelog
      end
    end
    
    context "with specific notes section that doesn't exists" do
      it "should raise an exception" do
        block = lambda do
          StepUp::RangedNotes.new(@driver, nil, "f4cfcc2", {:notes_sections => ["invalid_note_section"]})
        end
        
        block.should raise_error(ArgumentError)
      end
    end
  end
end
