Module 11: Process Management — Quick Notes
═══════════════════════════════════════════

FOREGROUND / BACKGROUND
  cmd &          run in background
  $!             PID of last background job
  Ctrl+C         interrupt (SIGINT)
  Ctrl+Z         suspend to background

JOB CONTROL
  jobs           list background jobs
  fg %1          bring job 1 to foreground
  bg %1          resume job 1 in background
  disown %1      detach job from shell (survives exit)

PROCESS INFO
  ps aux                     all processes
  ps aux --sort=-%cpu        sort by CPU
  pgrep nginx                find PID by name
  pgrep -a nginx             PID + full command
  pidof nginx                PID of exact name

KILLING
  kill 1234          send SIGTERM to PID
  kill -9 1234       send SIGKILL (force)
  killall nginx      kill all by name
  pkill -f "python"  kill by pattern

SIGNALS
  SIGTERM  (15)   graceful shutdown  ← default
  SIGKILL   (9)   force kill, no cleanup
  SIGINT    (2)   Ctrl+C
  SIGHUP    (1)   reload config

EXIT CODES
  $?              exit code of last command
  $pipestatus     array — exit code of each pipe stage
  exit 0          success
  exit 1          failure

  ls /bad 2>/dev/null
  print $?        # 1 or 2

  ls /etc | grep hosts | wc -l
  print $pipestatus   # e.g. (0 0 0)

PRIORITY
  nice -n 10 cmd       run at lower priority (10)
  nice -n -5 cmd       higher priority (needs root)
  renice 15 -p 1234    change running process priority
  range: -20 (highest) → 19 (lowest)

NOHUP
  nohup cmd &          survives terminal close
  nohup cmd >> out.log 2>&1 &

SUBSHELL  ( )
  ( x=99; print $x )   runs in child shell
  print $x             unchanged in parent

COMMAND GROUP  { }
  { x=99; print $x; }  runs in current shell
  print $x             changed in parent

QUICK REFERENCE
  run bg               cmd &
  get its PID          $!
  see jobs             jobs
  bring back           fg %1
  detach               disown
  find process         pgrep name
  graceful kill        kill PID
  force kill           kill -9 PID
  check exit           $?
  pipeline exit        $pipestatus
  low priority         nice -n 19 cmd
  survive logout       nohup cmd &