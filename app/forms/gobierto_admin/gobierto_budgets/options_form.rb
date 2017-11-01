module GobiertoAdmin
  module GobiertoBudgets
    class OptionsForm
      include ActiveModel::Model

      attr_accessor(
        :site,
        :elaboration_enabled,
        :budget_lines_feedback_enabled,
        :feedback_emails
      )

      validates :site, presence: true
      validates :feedback_emails, presence: true, if: Proc.new{ |of| of.budget_lines_feedback_enabled? }

      def elaboration_enabled
        @elaboration_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budgets_elaboration"]
      end

      def elaboration_enabled?
        elaboration_enabled == true || elaboration_enabled == '1'
      end

      def budget_lines_feedback_enabled
        @budget_lines_feedback_enabled ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["budget_lines_feedback_enabled"]
      end

      def budget_lines_feedback_enabled?
        budget_lines_feedback_enabled == true || budget_lines_feedback_enabled == '1'
      end

      def feedback_emails
        @feedback_emails ||= site.gobierto_budgets_settings && site.gobierto_budgets_settings.settings["feedback_emails"]
      end

      def save
        save_options if valid?
      end

      private

      def save_options
        settings = {}
        settings[:budgets_elaboration] = elaboration_enabled if elaboration_enabled?
        settings[:budget_lines_feedback_enabled] = budget_lines_feedback_enabled if budget_lines_feedback_enabled?
        settings[:feedback_emails] = budget_lines_feedback_enabled? ? feedback_emails : nil

        if site.gobierto_budgets_settings.nil?
          GobiertoModuleSettings.create! site: site, module_name: "GobiertoBudgets", settings: settings
        else
          site.gobierto_budgets_settings.update_attribute :settings, settings
        end
      end
    end
  end
end
