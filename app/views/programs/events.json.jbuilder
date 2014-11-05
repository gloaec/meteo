json.request do |json|
  json.message "your message"
  json.status 200
end

json.success true
json.result do
  i = 0
  json.array!(@programs) do |program|

    program_class = 
       if program.dangers.any? then "event-important"
       elsif program.warnings.any? then "event-warning"
       else "event-success" end

    json.i i += 1
    json.extract! program, :id
    json.channel do json.name program.channel.name end
    unless program.start_at.nil?
      json.start_at program.start_at.iso8601
      json.start program.start_at.to_time.to_i * 1000 #beginning_of_day.
    end
    unless program.end_at.nil?
      json.end_at program.end_at.iso8601
      json.end program.end_at.to_time.to_i * 1000 #.beginning_of_day
    end
    unless program.end_at.nil? or program.start_at.nil?
      json.title "#{program.channel.name} \nfrom #{program.start_at.strftime('%d/%m/%y')} \nto #{program.end_at.strftime('%d/%m/%y')}" 
    end
    json.short_title program.channel.name
    json.class program_class#'event-important'
    json.url program_url(program)#, format: :json)
    json.dangers_count program.dangers.count
    json.warnings_count program.warnings.count
  end
end
