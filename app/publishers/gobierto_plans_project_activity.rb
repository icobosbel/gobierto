# frozen_string_literal: true

module Publishers
  class GobiertoPlansProjectActivity
    include Publisher
    self.pub_sub_namespace = "activities/gobierto_plans_projects"
  end
end
