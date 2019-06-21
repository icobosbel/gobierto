# frozen_string_literal: true

module GobiertoCommon::CustomFieldFunctions
  class Budget < Base
    def progress(_options = {})
      progress_percentages.instance_eval do
        return nil if blank?

        sum / size.to_f
      end
    end

    def cost(_options = {})
      @cost ||= data.map do |line|
        next unless line.weight.present? && line.execution.present?

        line.weight * line.execution
      end.compact.sum
    end

    private

    def data
      @data ||= begin
                  lines = value.dig("budget_lines") || []

                  lines.map do |line|
                    line_details = GobiertoBudgets::BudgetLine.find_details(type: line["area"], id: line["id"])

                    OpenStruct.new(
                      forecast: line_details.forecast.updated_amount || line_details.forecast.original_amount,
                      execution: line_details.execution.amount,
                      weight: numeric?(line["weight"]) ? line["weight"].to_f / 100.0 : nil
                    )
                  end
                end
    end

    def numeric?(data)
      Float(data).present?
    rescue ArgumentError, TypeError
      false
    end

    def progress_percentages
      @progress_percentages ||= data.map do |line|
        next unless line.execution.present? && line.forecast.present?

        line.execution > line.forecast ? 1.0 : line.execution / line.forecast.to_f
      end.compact
    end
  end
end