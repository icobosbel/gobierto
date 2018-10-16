# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCitizensCharters
    class BaseForm < ::BaseForm
      class NotImplementedError < StandardError; end

      attr_accessor :id, :site_id
      attr_writer(
        :visibility_level
      )

      validates :site, presence: true
      delegate :persisted?, to: :resource

      def resource
        @resource ||= resources_relation.find_by(id: id) || build_resource
      end

      def build_resource
        resources_relation.new
      end

      def visibility_level
        @visibility_level ||= "draft"
      end

      def save
        save_resource if valid?
      end

      def site
        @site ||= Site.find_by(id: site_id)
      end

      def available_visibility_levels
        resources_relation.try(:visibility_levels)
      end

      private

      def save_resource
        @resource = resource.tap do |attributes|
          attributes.assign_attributes(visibility_level: visibility_level) if attributes.has_attribute? :visibility_level
          attributes.assign_attributes(attributes_assignments) if respond_to? :attributes_assignments
        end

        return @resource if @resource.save

        promote_errors(@resource.errors)
        false
      end

      def resources_relation
        raise NotImplementedError, "Override this with a method returning an ActiveRecord::Relation"
      end
    end
  end
end