module ProgramsHelper

  def program_class(program)
    if    program.new_record? then "default"
    elsif program.errors.any? then "danger"
    else "success" end
  end

end
