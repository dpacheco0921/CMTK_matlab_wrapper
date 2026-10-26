function [p, registration_params] = ...
    cmtk_editsteps(reg_edit, p, registration_params)
% cmtk_editsteps: switch registration steps on/off from a text code; reads reg_edit and
%   sets p.agate, p.wgate, p.jgate, p.rgate_ch2, p.floatiDir_2, p.ch2chSu, p.redo, p.ragate and
%   registration_params.initf2use; returns the edited p and registration_params.
%   (the codes are looked for as substrings of the string reg_edit)
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
%       ('ia', do initial affine)
%       ('w', do warp)
%       ('~w', do not warp)
%       ('j', generate jacobian image)
%       ('~j', do not generate jacobian image)
%       ('rch2', reformat channel 2, from images_ch2)
%       ('rch3', reformat channel 3, from images_ch3)
%       ('rch4', reformat channel 4, from images_ch4)
%       ('~rch2', '~rch3' or '~rch4', reformat channel 1 only)
%       ('redo', redo)
%       ('ar', do affine variant and replace the old affine)
%       ('ar2', do affine variant but keep the old affine)
%       ('~ar', do not do the affine variant)
%       (combine with any separator, e.g. 'a_~w'; the codes are not
%       delimited, so 'ia' and 'ar' also contain 'a')
%       NOTE (known issue, not yet fixed): because of substring matching,
%       'ia' and 'ar' also set p.agate = 1.
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
    
    % reformat extra channels (the code is 'rch2', 'rch3' or 'rch4', no underscore);
    %   only one extra channel can be selected, the first match wins
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
