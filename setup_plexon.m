%setup_plexon
%allows Matlab to register event timestamps with Plexon for
%electrophysiology

%try to open communication with plexon server
%plx is a memory pointer to the Plexon server

try
    plx=PL_InitClient(0);
catch q
    plx=0;
end