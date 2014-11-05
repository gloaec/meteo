class ProgramError < ActiveRecord::Base
  belongs_to :program
  belongs_to :before_event, class_name: 'Event'
  belongs_to :after_event, class_name: 'Event'
  accepts_nested_attributes_for :before_event, :after_event

  FILE = -2
  OTHER = -1
  DURATION_ERROR = 0
  DURATION_WARNING = 1
  GAP_ERROR = 3
  GAP_WARNING = 4
  #NO_DURATION = 0
  #NO_GAP = 1
  #WARNING_GAP = 2
  #ERROR_GAP = 3
end
