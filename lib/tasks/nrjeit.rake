require 'nokogiri'

namespace :db do
  desc "Database Re-Install"
  task :install do  
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:seed'].invoke
  end
end 

desc "Validate new XML files"

task :validate, [:paths] => :environment do |t, args|

  args.paths.each do |path|
 
    next unless File.exists? path
    next unless File.extname(path) == ".xml"
    
    p "Processing #{path}..."

    # Wait for file to be transferred
    filesize = -1
    retries = 0
    while filesize != File.size(path)
      filesize = File.size(path)
      sleep 1
      retries += 1
      break if retries > 10
    end

    p "> Ready !"

    f, program, channel = nil
    channel_id = File.basename(File.dirname(path)).to_i
    if channel_id != 0
      channel = Channel.find(channel_id)
      p "  Channel: #{channel.name}"
    else
      p "  Channel: Not found !"
    end
 
    start_at = path.match(/_(\d+)_(\d+)_(\d+)_(\d+)_(\d+)\.xml$/) do |d|
      Time.parse("#{d[1]}/#{d[2]}/#{d[3]} #{d[4]}:#{d[5]} UTC")
    end

    chmoded = 0

    begin
      f = File.open(path)
      program = Program.find_or_create_by_xml_file_name(File.basename(path))
      program.start_at = start_at
      program.end_at = start_at
      program.program_errors.destroy_all
      program.events.destroy_all
      program.xml = f
      program.channel = channel
      program.save!
    rescue => e
      File.chmod(0755, path) rescue nil
      chmoded += 1
      retry if chmoded < 2
      puts "Program Init Error : #{e.message}"
      program.dangers.create(
        :classname => 'danger',
        :code => ProgramError::FILE,
        :msg => "#{e}",
        :line => nil
      )
    else
      begin
        program.validate
      rescue => e
        puts "Recued Error : #{e.message}"
      end
    end

    #begin
    #  if doc.errors.any?
    #    doc.errors.each do |error|
    #      program.errors.build(
    #        :classname => 'danger',
    #        :code => ProgramError::OTHER,
    #        :msg => "#{error}",
    #        :line => error.line
    #      )
    #    end
    #  else
    #    end_at = nil
    #    position = 0
    #    before_event = nil
    #    events = doc.css("EVENT")
    #    service = doc.css("SERVICE").first

    #    program.start_at = Time.parse(service['start_time']) unless service.nil?

    #    events.each do |event|
 
    #      position+=1
    #      name_node = event.css("NAME").first
    #      name = unless name_node.nil? then name_node.content else nil end
    #      description_node = event.css("DESCRIPTION").first
    #      description = unless description_node.nil? then description_node.content else nil end
    #      minimum_age_node = event.css("PARENTAL_RATING").first
    #      minimum_age = unless minimum_age_node.nil? then minimum_age_node['minimum_age'] else nil end
    #      start_at = Time.parse(event['time'])
    #      prev_end_at = end_at
    #      timegap = TimeDifference.between(prev_end_at, start_at).in_general unless end_at.nil?
    #      gap = timegap[:hours].to_i.hours + timegap[:minutes].to_i.minutes + timegap[:seconds].to_i.seconds unless timegap.nil?
    #      duration = Time.parse(event['duration'])
    #      end_at = start_at + duration.hour.hours + duration.min.minutes + duration.sec.seconds

    #      program.update_attribute :end_at, end_at if event == events.last

    #      event_node = event 

    #      event = program.events.build(
    #        name: name,
    #        description: description,
    #        minimum_age: minimum_age,
    #        start_at: start_at,
    #        end_at: end_at,
    #        position: position
    #      )
 
    #      if gap.nil?
    #      elsif gap == 0
    #        program.program_errors.build(
    #          before_event: before_event,
    #          after_event:  event,
    #          classname:    'danger',
    #          code:         ProgramError::NO_GAP,
    #          msg:          'No time gap',
    #          line:         event_node.line
    #        )
    #      elsif gap.to_i > 3600
    #        program.program_errors.build(
    #          before_event: before_event,
    #          after_event:  event,
    #          :classname => 'danger',
    #          :code => ProgramError::ERROR_GAP,
    #          :msg => 'Time gap error',
    #          :line => event_node.line
    #        )
    #      elsif gap > 600
    #        program.program_errors.build(
    #          before_event: before_event,
    #          after_event:  event,
    #          :classname => 'warning',
    #          :code => ProgramError::WARNING_GAP,
    #          :msg => 'Long time gap',
    #          :line => event_node.line
    #        )
    #      end 

    #      before_event = event

    #      #p "------------------------------------"
    #      #p "  timegap  : #{timegap[:hours].to_i}:#{timegap[:minutes].to_i}:#{timegap[:seconds].to_i}" unless timegap.nil?
    #      #p "  seconds  : #{gap}"
    #      #p "===================================="
    #      #p "#{name}:" 
    #      #p "===================================="
    #      #p "  start    : #{start_at.strftime("%d/%m/%Y %H:%M:%S")}"
    #      #p "  duration : #{duration.hour}:#{duration.min}:#{duration.sec}"
    #      #p "  end      : #{end_at.strftime("%d/%m/%Y %H:%M:%S")}"
    #    end

    #  end
    #rescue Exception => e
    #  p "Exception #{e}"                 
    #  program.errors.build(
    #    :classname => 'danger',
    #    :code => ProgramError::OTHER,
    #    :msg => "#{e}",
    #    :line => nil#e.line
    #  )
    #ensure
    #  program.save
    #end 

    #p "=> #{program.program_errors.count} errors detected"

    #if program.errors.any?
    #  A
    #else 

    #end

    #f.close
  end
end
