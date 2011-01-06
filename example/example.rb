require "conditions"

bind :NoticeSignaled => lambda { invoke :Suppress }

def parse_log_entry text

  if !well_formed? text then

    restart :UseValue     => proc { |value| text = value },
            :ReparseEntry => proc { |fixed| text = parse_log_entry fixed } do

      error :MalformedLogEntryError

    end
    
  end

  text

end

def parse_log_file file

  File.open(file).each do |line|

    entry = (restart :SkipLogEntry => lambda { nil } do
      parse_log_entry line
    end)

    yield entry if entry

  end

end

def log_analyzer

  bind :ConditionNotDefined    => lambda { invoke :Define },
       :MalformedLogEntryError => lambda { invoke :UseValue, "failed\n" } do
    find_logs do |log|
      analyze_log log
    end
  end

end

def analyze_log log
  parse_log_file log do |entry|
    analyze_entry entry
  end
end

def well_formed? text
  "yes\n" == text ? true : false
end

def analyze_entry entry
  p entry
end

def find_logs
  yield "./log"
  yield "./another-log"
end

log_analyzer
