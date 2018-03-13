# nagios-check-open-files
Nagios Plugin to monitor open files count for a process

Rewrite/fork of original plugin by nasim.ansari

## Usage

	check-open-files.sh  -p ProgramName -W ProgramWarnlevel -C ProgramCriticlevel

#### -p ProgramName

Program name or string listed in ps -ef

#### -W ProgramWarnlevel

Number of open files for warning threshold

#### -C ProgramCriticlevel

Number of open files for critical threshold
