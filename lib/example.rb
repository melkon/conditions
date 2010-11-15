require "conditions"

# #########
#  usage
# #########

=begin

(defun parse-log-entry (text)
  (if (well-formed-log-entry-p text)
    (make-instance 'log-entry ...)
    (error 'malformed-log-entry-error :text text)))

(defun parse-log-file (file)
  (with-open-file (in file :direction :input)
    (loop for text = (read-line in nil nil) while text
       for entry = (handler-case (parse-log-entry text)
                     (malformed-log-entry-error () nil))
       when entry collect it)))

(defun parse-log-file (file)
  (with-open-file (in file :direction :input)
    (loop for text = (read-line in nil nil) while text
       for entry = (restart-case (parse-log-entry text)
                     (skip-log-entry () nil))
       when entry collect it)))

(defun log-analyzer ()
  (dolist (log (find-all-logs))
    (analyze-log log)))

=end

def well_formed? text
  "yes" == text ? true : false
end

def parse_log_entry text

  if !well_formed? text
    error :MalformedLogEntryError
  end

  text

end

def parse_log_file file

  File.new(file) do |line|

    entry = restart :SkipLogEntry => lambda { nil } do
      parse_log_entry line
    end

    if entry then entry end

  end

end

=begin
(defun log-analyzer ()
  (dolist (log (find-all-logs))
    (analyze-log log)))

(defun analyze-log (log)
  (dolist (entry (parse-log-file log))
    (analyze-entry entry)))

=end

def log_analyzer
  find_logs do |log|
    analyze_log log
  end
end

def analyze_log log
  parse_log_file log
end

def find_logs

  yield "./log"
  yield "./another-log"

end
