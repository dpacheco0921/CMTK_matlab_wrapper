function [p, registration_params] = ...
    cmtk_editsteps(reg_edit, p, registration_params)
% cmtk_editsteps: edit steps of registration to run
%   encoded on the decimals of reg_edit
%
% Usage:
%   [p, registration_params] = ...
%       cmtk_editsteps(reg_edit, p, registration_params)
%
% Args:
%   reg_edit: string that defines steps of registration
%       to run.
%       ('a', do affine)
%       ('~a', do not affine)
%       ('a', do affine)
%       ('~a', do not affine)
%       ('ia', do intial affine)
%       ('w', do warp)
%       ('~w', do not warp)
%       ('j', generate jacobian image)
%       ('~j', do not generate jacobian image)
%       ('rch_2', register channel 2, in )
%       ('rch_3', register channel 3)
%       ('rch_4', register channel 4)
%       ('redo', redo)
%       ('ar', do affine variant)
%   p: controls which files to load, details of server usage, etc
%   registration_params: registration parameters
%
% Output:
%   p: edited controls which files to load, details of server usage, etc
%   registration_params: edited registration parameters

if ~isempty(reg_edit)
    
    % affine on
    if contains(reg_edit, '~a') && ...
            ~contains(reg_edit, '~ar')
        p.agate = 0;
    elseif (~contains(reg_edit, '~a') || ...
            contains(reg_edit, '~ar')) && ...
            contains(reg_edit, 'a')
        p.agate = 1;
    end
    
    % use external initialaffine function
    if contains(reg_edit, 'ia')
        registration_params.initf2use = 1;
    end
    
    % warp on
    if contains(reg_edit, '~w')
        p.wgate = 0;
    elseif ~contains(reg_edit, '~w') && ...
            contains(reg_edit, 'w')
        p.wgate = 1;
    end
    
    % generate jacobian image
    if contains(reg_edit, '~j')
        p.jgate = 0;
    elseif ~contains(reg_edit, '~j') && ...
            contains(reg_edit, 'j')
        p.jgate = 1;
    end
    
    % reformat extra channels
    if contains(reg_edit, '~rch2') || ...
            contains(reg_edit, '~rch3') || ...
            contains(reg_edit, '~rch4')
        
        % just channel 1
        p.rgate_ch2 = 0;
        
    elseif ~contains(reg_edit, '~rch2') && ...
            contains(reg_edit, 'rch2')
        
        % do channel 2
        p.rgate_ch2 = 1;
        p.floatiDir_2 = ['.', filesep, 'images_ch2'];
        p.ch2chSu = {'_01.nrrd', '_02.nrrd'};
        
    elseif ~contains(reg_edit, '~rch3') && ...
            contains(reg_edit, 'rch3')
        
        % do channel 3
        p.rgate_ch2 = 1;
        p.floatiDir_2 = ['.', filesep, 'images_ch3'];
        p.ch2chSu = {'_01.nrrd', '_03.nrrd'};
        
    elseif ~contains(reg_edit, '~rch4') && ...
            contains(reg_edit, 'rch4')
        
        % do channel 4
        p.rgate_ch2 = 1;
        p.floatiDir_2 = ['.', filesep, 'images_ch4'];
        p.ch2chSu = {'_01.nrrd', '_04.nrrd'};
        
    end
    
    % redo registration
    if contains(reg_edit, 'redo')
        p.redo = 1;
    end
    
    % do affine variant, where you use central brain mask for affine
    % registration
    
    if contains(reg_edit, '~ar')
        
        % do regular affine
        p.ragate = 0;
        
    elseif ~contains(reg_edit, '~ar') && ...
            contains(reg_edit, 'ar')
        
        if contains(reg_edit, 'ar2')
            
            % do affine variant but keep same affine
            p.ragate = 2;
            
        else
            
            % do affine variant and replace affine
            p.ragate = 1;
            
        end
        
    end
    
end

end
