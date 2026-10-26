% cmtk_install_notes: notes only (no code, nothing to run); how to install CMTK (the
%   command-line tools this wrapper calls) on Windows. Input: none. Output: working CMTK
%   binaries (registrationx, warpx, reformatx, ...) reachable from MATLAB.
% NOTE: Linux/Mac and cluster setups are not covered here (the cluster job script loads
%   the 'cmtk/3.3.1' and 'matlab/R2019b' modules, see batch_cmtkperfile.m).
% To check the install, run in MATLAB: system('registrationx --version')
%% Install windows:
% see https://github.com/jefferis/nat/blob/master/vignettes/Installation.Rmd

% 1 Install [Cygwin](https://www.cygwin.com/) accepting the default path `C:\cygwin64`
% 2 When you run Cygwin's setup.exe, you should also install all *fftw3* packages. 
%   (fftw3 is a CMTK dependency which provides fast Fourier transform functions)
% 3 Download `CMTK-3.3.1-CYGWIN-x86_64.tar.gz` to the cygwin folder (`C:\cygwin64`)
% 4 Start a Cygwin terminal and go to the root directory with the command `cd /`
%   (this is the same place as `C:\cygwin64` in the Windows file system).
% 5 On the Terminal, issue the following command 
%   `tar -xvf CMTK-3.3.1-CYGWIN-x86_64.tar.gz` to extract CMTK to the cygwin folder.
% 6 Optionally add `C:\cygwin64\bin` to your windows path (since v1.8.10 nat should 
%   look after this - see ?cmtk.bindir).
% 7 Add CMTK folders to your windows environment path (also cygwin binaries folder)
%   (the CMTK folder is the one holding the extracted binaries, usually
%   C:\cygwin64\usr\local\lib\cmtk\bin, plus C:\cygwin64\bin; restart MATLAB afterwards
%   so it sees the new path)
