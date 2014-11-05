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
    json.start_at program.start_at.iso8601
    json.end_at program.end_at.iso8601
    json.short_title program.start_at.strftime('%d/%m')
    json.title "#{program.channel.name} \nfrom #{program.start_at.strftime('%d/%m/%y')} \nto #{program.end_at.strftime('%d/%m/%y')}" 
    json.class program_class#'event-important'
    json.start program.start_at.to_time.to_i * 1000 #beginning_of_day.
    json.end program.end_at.to_time.to_i * 1000 #.beginning_of_day
    json.url program_url(program)#, format: :json)
    json.dangers_count program.dangers.count
    json.warnings_count program.warnings.count
  end
end
