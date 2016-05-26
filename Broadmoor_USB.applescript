on run {input, parameters}
  set firstVar to input as text
  do shell script "sudo asr restore --source " & quoted form of POSIX path of firstVar & " --target /Volumes/Service* -noprompt -erase" with administrator privileges
end run