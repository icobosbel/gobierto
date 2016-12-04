class Site < ApplicationRecord

  RESERVED_SUBDOMAINS = %W(presupuestos)

  has_many :admin_sites, dependent: :destroy, class_name: "GobiertoAdmin::AdminSite"
  has_many :admins, through: :admin_sites, class_name: "GobiertoAdmin::Admin"
  has_many :census_imports, dependent: :destroy, class_name: "GobiertoAdmin::CensusImport"

  serialize :configuration_data

  before_save :store_configuration
  before_create :initialize_admins

  validates :title, presence: true
  validates :name, presence: true, uniqueness: true
  validates :location_name, presence: true
  validates :domain, presence: true, uniqueness: true, domain: true

  scope :sorted, -> { order(created_at: :desc) }
  scope :alphabetically_sorted, -> { order(name: :asc) }

  enum visibility_level: { draft: 0, active: 1 }

  def self.reserved_domain?(domain)
    RESERVED_SUBDOMAINS.map do |subdomain|
      "#{subdomain}." + Settings.gobierto_host
    end.any?{ |reserved_domain| domain == reserved_domain }
  end

  def subdomain
    if domain.present? and domain.include?('.')
      domain.split('.').first
    end
  end

  def place
    @place ||= INE::Places::Place.find self.municipality_id
  end

  def configuration
    @configuration ||= SiteConfiguration.new(read_attribute(:configuration_data))
  end

  def password_protected?
    draft?
  end

  private

  def store_configuration
    self.configuration_data = self.configuration.instance_values
  end

  def initialize_admins
    self.admins = Array(GobiertoAdmin::Admin.preset)
  end
end
