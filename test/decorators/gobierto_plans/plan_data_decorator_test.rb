# frozen_string_literal: true

require "test_helper"

module GobiertoPlans
  class PlanDataDecoratorTest < ActiveSupport::TestCase
    def plan
      @plan ||= gobierto_plans_plans(:strategic_plan)
    end

    def first_category
      @first_category ||= GobiertoPlans::CategoryTermDecorator.new(plan.categories.where(level: plan.categories.maximum(:level)).order(:position).first)
    end

    def last_category
      @last_category ||= GobiertoPlans::CategoryTermDecorator.new(plan.categories.where(level: plan.categories.maximum(:level)).order(:position).last)
    end

    def first_node
      @first_node ||= first_category.nodes.first
    end

    def last_node
      @last_node ||= last_category.nodes.last
    end

    def csv_file
      @csv_file ||= Rails.root.join("test/fixtures/files/gobierto_plans/plan.csv")
    end

    def sample_import_csv_file
      @sample_import_csv_file ||= Rails.root.join("test/fixtures/files/gobierto_plans/plan2.csv")
    end

    def csv_import_statuses_vocabulary
      @csv_import_statuses_vocabulary = gobierto_common_vocabularies(:plan_csv_import_statuses_vocabulary)
    end

    def test_csv_export
      csv_output = CSV.parse(GobiertoPlans::PlanDataDecorator.new(plan).csv, headers: true)

      assert_equal first_category.parent_term.parent_term.name, csv_output.by_row[0]["Level 0"]
      assert_equal first_category.parent_term.name, csv_output.by_row[0]["Level 1"]
      assert_equal first_category.name, csv_output.by_row[0]["Level 2"]
      assert_equal first_node.name, csv_output.by_row[0]["Node.Title"]
      assert_equal first_node.status.name, csv_output.by_row[0]["Node.Status"]
      assert_equal first_node.progress, csv_output.by_row[0]["Node.Progress"].to_f
      assert_equal first_node.starts_at, Date.parse(csv_output.by_row[0]["Node.Start"])
      assert_equal first_node.ends_at, Date.parse(csv_output.by_row[0]["Node.End"])
      assert_equal last_node.options["objetivos"], csv_output.by_row[csv_output.count - 1]["Node.objetivos"]
      assert_equal last_node.options["temporality"], csv_output.by_row[csv_output.count - 1]["Node.temporality"]
    end

    def test_csv_import
      plan.update_attribute(:statuses_vocabulary_id, csv_import_statuses_vocabulary.id)

      csv_input = CSV.read(csv_file, headers: true)
      GobiertoAdmin::GobiertoPlans::PlanDataForm.new(csv_file: csv_file, plan: plan).save

      assert_equal csv_input.by_row[0]["Level 1"], first_category.parent_term.parent_term.name
      assert_equal csv_input.by_row[0]["Level 2"], first_category.parent_term.name
      assert_equal csv_input.by_row[0]["Level 3"], first_category.name
      assert_equal csv_input.by_row[0]["Node.Title"], first_node.name
      assert_equal csv_input.by_row[0]["Node.Status"], first_node.status.name
      assert_equal csv_input.by_row[0]["Node.Progress"].to_f, first_node.progress
      assert_equal Date.parse(csv_input.by_row[0]["Node.Start"]), first_node.starts_at
      assert_equal Date.parse(csv_input.by_row[0]["Node.End"]), first_node.ends_at
      assert_equal csv_input.by_row[0]["Node.Type"], first_node.options["Type"]
      assert_equal csv_input.by_row[0]["Node.Goals"], first_node.options["Goals"]
      assert_equal csv_input.by_row[0]["Node.TimePeriod"], first_node.options["TimePeriod"]
      assert_equal csv_input.by_row[0]["Node.Priority"], first_node.options["Priority"]
      assert_equal csv_input.by_row[0]["Node.Custom Field 1"], first_node.options["Custom Field 1"]
      assert first_node.published?
      assert first_node.published_version.present?
      assert first_node.moderation.approved?
     end

    def test_sample_csv_import
      plan.update_attribute(:statuses_vocabulary_id, csv_import_statuses_vocabulary.id)

      GobiertoAdmin::GobiertoPlans::PlanDataForm.new(csv_file: sample_import_csv_file, plan: plan).save

      assert_equal 2, plan.categories_vocabulary.terms.where(level: 2).with_name_translation("76. Avaluar les poítiques d'Igualtat mitjançant un sistema d'indicadors de gènere").count
      refute plan.nodes.draft.exists?
      assert_equal plan.nodes.count, plan.nodes.with_moderation_stage(:approved).count
    end
  end
end
