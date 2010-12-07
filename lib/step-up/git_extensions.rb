module StepUp
  module GitExtensions
    NOTES_STRATEGIES = {}
    def self.register_notes_strategy(key, instance)
      NOTES_STRATEGIES[key] = instance
    end

    module Notes
      def steps_for_archiving_notes(objects_with_notes, tag)
        strategy = notes_after_versioned["strategy"]
        raise ArgumentError, "unknown strategy: #{ strategy }" unless NOTES_STRATEGIES.include?(strategy)
        NOTES_STRATEGIES[strategy].steps_for_archiving_notes(objects_with_notes, tag, self)
      end

      private

      def notes_sections
        CONFIG["notes"]["sections"]
      end

      def notes_after_versioned
        CONFIG["notes"]["after_versioned"]
      end
    end

    module Strategy
      class RemoveNotes
        def steps_for_archiving_notes(objects_with_notes, tag, driver)
          commands = []
          objects_with_notes.sections.each do |section|
            objects_with_notes[section].each do |object|
              commands << "git notes --ref=#{ section } remove #{ object }"
            end
            commands << "git push origin refs/notes/#{ section }" unless objects_with_notes[section].empty?
          end
          commands
        end
      end

      class KeepNotes
        def steps_for_archiving_notes(objects_with_notes, tag, driver)
          commands = []
          objects = []
          changelog_message = driver.notes_after_versioned["changelog_message"]
          objects_with_notes.sections.each do |section|
            objects_with_notes[section].each do |object|
              unless objects.include?(object)
                objects << object
                kept_message = changelog_message.gsub(/\{version\}/, tag)
                commands << "git notes --ref=#{ driver.notes_after_versioned["section"] } add -m \"#{ kept_message }\" #{ object }"
              end
            end
          end
          commands << "git push origin refs/notes/#{ driver.notes_after_versioned["section"] }" unless objects.empty?
          commands
        end
      end
    end
    register_notes_strategy "remove", Strategy::RemoveNotes.new
    register_notes_strategy "keep", Strategy::KeepNotes.new
  end
end
