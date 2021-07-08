# Temporarily redirects STDOUT and STDERR to /dev/null
# but does print exceptions should there occur any.
# Call as:
#   suppress_output { puts 'never printed' }
#
def suppress_output
  original_stderr = $stderr.clone
  original_stdout = $stdout.clone
  $stderr.reopen(File.new('/dev/null', 'w'))
  $stdout.reopen(File.new('/dev/null', 'w'))
  yield
ensure
  $stdout.reopen(original_stdout)
  $stderr.reopen(original_stderr)
end
