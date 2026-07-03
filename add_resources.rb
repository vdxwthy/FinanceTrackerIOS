require 'xcodeproj'

project_path = 'FinanceTracker.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

resources_group = project.main_group.new_group('Resources', 'FinanceTracker/Resources')

xcassets_ref = resources_group.new_reference('Assets.xcassets')
target.resources_build_phase.add_file_reference(xcassets_ref)

variant_group = resources_group.new_variant_group('Localizable.strings')

en_ref = variant_group.new_reference('en.lproj/Localizable.strings')
en_ref.name = 'en'
ru_ref = variant_group.new_reference('ru.lproj/Localizable.strings')
ru_ref.name = 'ru'

target.resources_build_phase.add_file_reference(variant_group)

project.root_object.known_regions = ['en', 'ru', 'Base']

project.save
puts 'Resources wired successfully'
