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
