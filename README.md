# Background
This repo includes Matlab files needed to run a continuous time version of the Balloon Analogue Risk Task. In this version, subjects click the joystick trigger or the left or right arrow on the keyboard once to start the balloon inflating, once to stop. Trials come in three levels of risk (yellow, orange, red, in decreasing mean pop time). In addition, there are control trials in which a gray ring surrounds the balloon. The balloon will inflate to this point regardless of subjects' input. Some of these trials also offer 0 reward (gray balloon).

# Flow
`bartc.m` is the main task file. It calls various setup files, including 

- `setup_data_file.m` (to create the directory structure for saving files)
- `setup_audio.m` (to load the wav files stored in the directory into Matlab's memory)
- `bind_keys.m` (to define various keyboard aliases)
- `setup_geometry.m` (to define various screen constants and geometric variables)
- `setup_plexon.m` (electrophysiology recording equipment setup)
- `setup_joystick.m` (what it sounds like)
- `setup_pars.m` (to define lots of task parameters, including the distributions of balloon pop times, the numbers of trials of each type, etc.)

In its main loop, `bartc.m` checks for `ESC` with `esc_check.m`. It uses `mark_event.m` to send event timestamps to Plexon and save them to a data structure to be written out to disk. As for individual trials

- `open_trial.m` sets up variables for a given trial (in truth, not much happens here)
- `handle_input.m` and `handle_input2.m` check for user input and determine what action the program should take (only the latter is currently used)
- `run_outcome.m` displays animation related to the trial's outcome (bank, pop, etc.) and plays sound
- `paint_screen.m` is called by multiple functions to draw the display onscreen in response to a struct variable in the Matlab code
- `close_trial.m` writes out variables for this trial to a file (appending)
