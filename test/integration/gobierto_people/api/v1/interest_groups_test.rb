# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  module Api
    module V1
      class InterestGroupsTest < ActionDispatch::IntegrationTest

        def madrid
          @madrid ||= sites(:madrid)
        end

        def justice_department
          @justice_department ||= gobierto_people_departments(:justice_department)
        end

        def pepsi
          @pepsi ||= gobierto_people_interest_groups(:pepsi)
        end

        def tamara
          @tamara ||= gobierto_people_people(:tamara)
        end

        def interest_group_attributes
          %w(key value properties)
        end

        def interest_groups_with_events_count
          ::GobiertoCalendars::Event.with_interest_group.pluck(:interest_group_id).uniq.size
        end

        def test_interest_groups_index_test
          with_current_site(madrid) do

            get gobierto_people_api_v1_interest_groups_path

            assert_response :success

            interest_groups = JSON.parse(response.body)

            assert_equal interest_groups_with_events_count, interest_groups.size

            assert array_match(interest_group_attributes, interest_groups.first.keys)
          end
        end

        def test_interest_groups_index_with_filters_test
          with_current_site(madrid) do

            get(
              gobierto_people_api_v1_interest_groups_path,
              params: {
                department_id: justice_department.id,
                person_id: tamara.id
              }
            )

            assert_response :success

            interest_groups = JSON.parse(response.body)

            assert_equal 2, interest_groups.size
            assert_equal interest_groups.first["key"], pepsi.name
          end
        end

      end
    end
  end
end
