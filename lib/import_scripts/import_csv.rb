# frozen_string_literal: true

require 'csv'

module ImportScripts
  # Import data regarding club reutation / credibility from third party data sources
  #
  # rn this is a hack; seeding w fake data
  class ImportCreditData
    def doit
      CredLog.destroy_all
      BillingEvent.destroy_all

      Rails.logger.debug { "users = #{User.all.inspect}" }

      [User.where(name: 'Travis Corcoran').first,
       User.where(name: 'Jason Osborne').first].each do |user|
        bill1 = BillingEvent.create!(amount: 10.00)
        CredLog.create!(user: user, cause: bill1, cred: 10)
        bill2 = BillingEvent.create!(amount: 20.00)
        CredLog.create!(user: user, cause: bill2, cred: 20)
      end
    end
  end

  module ImportCsv
    # Import NHLA legislator ratings
    #
    class ImportNhlaData
      private

      def setup
        nhla = ThirdPartyRatingEntity.find_or_create_by!(name: 'NHLA')
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'A+', value: 100)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'A', value: 96)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'A-', value: 92)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'B+', value: 88)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'B', value: 85)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'B-', value: 82)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'C+', value: 78)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'C', value: 75)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'C-', value: 72)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'D+', value: 68)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'D', value: 65)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'D-', value: 62)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'F', value: 50)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'CT', value: 0)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'INC', value: nil)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'SPKR', value: nil)
        ThirdPartyRatingGrade.find_or_create_by!(third_party_rating_entity: nhla, grade: 'SPEAKER', value: nil)
      end

      def shared_import(instance_name:, file_path:, interval_begin:, interval_end:, group:)
        setup
        nhla = ThirdPartyRatingEntity.find_or_create_by!(name: 'NHLA')
        nhla_instance = ThirdPartyRatingInstance.find_or_create_by!(instance: instance_name,
                                                                    third_party_rating_entity: nhla,
                                                                    interval_begin: interval_begin,
                                                                    interval_end: interval_end)

        filepath_full = Rails.root.join(file_path.to_s).to_s
        csv = CSV.read(filepath_full)
        headers = csv.first

        col_index_fullname          = headers.find_index('FullName')    # 2014 e.g. "McGuire, Carol (R)"
        col_index_fullname_reversed = headers.find_index('NoPartyName') # 2015 e.g. "McGuire, Carol"
        col_index_name              = headers.find_index('Name')        # 2016 e.g. "Carol McGuire""

        col_index_grade = headers.find_index('CombinedGrade') || headers.find_index('Grade')

        unless col_index_fullname || col_index_fullname_reversed || col_index_name
          raise 'no field found in data headers'
        end
        raise 'no CombinedGrade field found in data headers' unless col_index_grade

        csv = CSV.read(filepath_full)
        csv.each_with_index do |row, ii|
          next if ii.zero?

          # puts "row = #{row.inspect}"
          if (col_index_fullname && row[col_index_fullname].nil?) ||
             (col_index_fullname_reversed && row[col_index_fullname_reversed].nil?)
            Rails.logger.debug { "*** on row #{ii} found no name; end of data? ; breaking" }
            break
          end

          name = if col_index_fullname
                   row[col_index_fullname].gsub(/(Rep|Sen)./, '').gsub(/\([RDrd]\)/, '').strip
                 elsif col_index_fullname_reversed
                   # 2015 data
                   pair = row[col_index_fullname_reversed].gsub(/(Rep|Sen)./, '').gsub(/\([RDrd]\)/, '').split(',')
                   [pair[1].strip, pair[0].strip].join(' ')
                 elsif col_index_name
                   # 2014 data
                   pair = row[col_index_name].gsub(/(Rep|Sen)./, '').gsub(/\([RDrd]\)/, '').split(',')
                   [pair[1].strip, pair[0].strip].join(' ')
                 else
                   raise 'no implementation for this name scheme'
                 end
          person = Person.find_or_create_by!(name: name)

          # if name == 'Travis Corcoran' && person.user.nil?
          #   person.update!(user: User.where(name: 'Travis Corcoran').first)
          # elsif name == 'Jason Osborne' && person.user.nil?
          #   person.update!(user: User.where(name: 'Jason Osborne').first)
          # end

          grade_letter = row[col_index_grade].upcase
          grade = ThirdPartyRatingGrade.find_by(grade: grade_letter)

          rating = ThirdPartyRating.find_or_create_by!(person: person,
                                                       third_party_rating_instance: nhla_instance,
                                                       third_party_rating_grade: grade)

          next unless person.user

          GroupMember.find_or_create_by!(user: person.user, group: group)

          CredLog.create!(user: person.user, cause: rating, cred: grade.value,
                          created_at: nhla_instance.interval_end)
        end
      end

      public

      def import2014
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2014 house',
                      file_path: 'import_data/csv/nhla_2014_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2014'),
                      interval_end: DateTime.parse('31 Dec 2014'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2014 senate',
                      file_path: 'import_data/csv/nhla_2014_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2014'),
                      interval_end: DateTime.parse('31 Dec 2014'),
                      group: group_senate)
      end

      def import2015
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2015 house',
                      file_path: 'import_data/csv/nhla_2015_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2015'),
                      interval_end: DateTime.parse('31 Dec 2015'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2015 senate',
                      file_path: 'import_data/csv/nhla_2015_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2015'),
                      interval_end: DateTime.parse('31 Dec 2015'),
                      group: group_senate)
      end

      def import2016
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2016 house',
                      file_path: 'import_data/csv/nhla_2016_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2016'),
                      interval_end: DateTime.parse('31 Dec 2016'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2016 senate',
                      file_path: 'import_data/csv/nhla_2016_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2016'),
                      interval_end: DateTime.parse('31 Dec 2016'),
                      group: group_senate)
      end

      def import2017
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2017 house',
                      file_path: 'import_data/csv/nhla_2017_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2017'),
                      interval_end: DateTime.parse('31 Dec 2017'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2017 senate',
                      file_path: 'import_data/csv/nhla_2017_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2017'),
                      interval_end: DateTime.parse('31 Dec 2017'),
                      group: group_senate)
      end

      def import2018
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2018 house',
                      file_path: 'import_data/csv/nhla_2018_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2018'),
                      interval_end: DateTime.parse('31 Dec 2018'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2018 senate',
                      file_path: 'import_data/csv/nhla_2018_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2018'),
                      interval_end: DateTime.parse('31 Dec 2018'),
                      group: group_senate)
      end

      def import2019
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2019 house',
                      file_path: 'import_data/csv/nhla_2019_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2019'),
                      interval_end: DateTime.parse('31 Dec 2019'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2019 senate',
                      file_path: 'import_data/csv/nhla_2019_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2019'),
                      interval_end: DateTime.parse('31 Dec 2019'),
                      group: group_senate)
      end

      def import2020
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2020 house',
                      file_path: 'import_data/csv/nhla_2020_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2020'),
                      interval_end: DateTime.parse('31 Dec 202'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2020 senate',
                      file_path: 'import_data/csv/nhla_2020_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2020'),
                      interval_end: DateTime.parse('31 Dec 2020'),
                      group: group_senate)
      end

      def import2021
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2021 house',
                      file_path: 'import_data/csv/nhla_2021_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2021'),
                      interval_end: DateTime.parse('31 Dec senate'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2021 senate',
                      file_path: 'import_data/csv/nhla_2021_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2021'),
                      interval_end: DateTime.parse('31 Dec 2021'),
                      group: group_senate)
      end

      def import2022
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2022 house',
                      file_path: 'import_data/csv/nhla_2022_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2022'),
                      interval_end: DateTime.parse('31 Dec 2022'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2022 senate',
                      file_path: 'import_data/csv/nhla_2022_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2022'),
                      interval_end: DateTime.parse('31 Dec 2022'),
                      group: group_senate)
      end

      def import2023
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2023 house',
                      file_path: 'import_data/csv/nhla_2023_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2023'),
                      interval_end: DateTime.parse('31 Dec senate'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2023 senate',
                      file_path: 'import_data/csv/nhla_2023_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2023'),
                      interval_end: DateTime.parse('31 Dec 2023'),
                      group: group_senate)
      end

      def import2024
        group_house = Group.find_or_create_by!(name: 'NH State Reps', owner: User.where(name: 'root').first)
        group_senate = Group.find_or_create_by!(name: 'NH State Senators', owner: User.where(name: 'root').first)

        shared_import(instance_name: 'NHLA 2024 house',
                      file_path: 'import_data/csv/nhla_2024_rating_data_house.csv',
                      interval_begin: DateTime.parse('1 Jan 2024'),
                      interval_end: DateTime.parse('31 Dec senate'),
                      group: group_house)
        shared_import(instance_name: 'NHLA 2024 senate',
                      file_path: 'import_data/csv/nhla_2024_rating_data_senate.csv',
                      interval_begin: DateTime.parse('1 Jan 2024'),
                      interval_end: DateTime.parse('31 Dec 2024'),
                      group: group_senate)
      end

      def rebuild
        Group.find_by(name: 'NH State Reps')&.group_members&.destroy_all
        Group.find_by(name: 'NH State Senators')&.group_members&.destroy_all

        CredLog.destroy_all
        ThirdPartyRating.destroy_all
        ThirdPartyRatingGrade.destroy_all
        ThirdPartyRatingInstance.destroy_all

        import2024
        import2023
        import2022
        import2021
        import2020
        import2019
        import2018
        import2017
        import2016
        import2015
        import2014
      end
    end
  end
end
