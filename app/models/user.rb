class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable, :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  #has_and_belongs_to_many :channels

  has_many :user_channels, class_name: 'ChannelUser', foreign_key: :user_id, dependent: :destroy
  has_many :admin_channels, -> { where role: 'admin' }, class_name: 'ChannelUser', foreign_key: :user_id, dependent: :destroy
  has_many :channels, -> { where role: ['user', 'admin'] }, through: :user_channels, source: :channel
  #has_many :readable_channels, through: :user_channels, source: :channel
  #has_many :manageable_channels, through: :admin_channels, source: :channel

  #has_many :success_channels, -> { where success: true }, class_name: 'ChannelUser', foreign_key: :user_id
  #has_many :error_channels, -> { where error: true }, class_name: 'ChannelUser', foreign_key: :user_id
  has_many :success_contact_channels, class_name: 'ChannelSuccessContact', dependent: :destroy
  has_many :error_contact_channels, class_name: 'ChannelErrorContact', dependent: :destroy
  has_many :success_channels, through: :success_contact_channels, source: :channel
  has_many :error_channels, through: :error_contact_channels, source: :channel

  accepts_nested_attributes_for :user_channels
  accepts_nested_attributes_for :success_contact_channels
  accepts_nested_attributes_for :error_contact_channels

  ROLES = %w[guest contact user admin superadmin]

  delegate :can?, :cannot?, :to => :ability

  after_initialize :init

  def init
    self.role  ||= 'guest'
  end

  def role?(base_role)
    ROLES.index(base_role.to_s) <= ROLES.index(role)
  end

  def ability
    @ability ||= Ability.new(self)
  end
end
