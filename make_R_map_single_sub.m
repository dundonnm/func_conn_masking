clear all;
close all;

where_is_SPM = '/home/nmd/Documents/MATLAB/spm12';
addpath(genpath(where_is_SPM));

subject = 'control_02';

BOLD_dir_file = ['/home/nmd/l/ASAP/protocols/func_conn_masking/7T_',subject,'_preprocessed_func.nii'];
ROImask_dir_file = ['/home/nmd/l/ASAP/protocols/func_conn_masking/7T_',subject,'_amy_mask.nii'];

BOLD_hdr = spm_vol(BOLD_dir_file);
BOLD_data = spm_read_vols(BOLD_hdr);

ROImask_hdr = spm_vol(ROImask_dir_file);
ROImask_data = spm_read_vols(ROImask_hdr);

%find inds of ROI
ROI_inds = find(ROImask_data);
[xm, ym, zm] = ind2sub(size(ROImask_data), ROI_inds);

seed = zeros(1,size(BOLD_data,4));
for vox = 1:size(ROI_inds,1)
    seed = seed+squeeze(BOLD_data(xm(vox),ym(vox),zm(vox),:))';
end
seed = seed/size(ROI_inds,1);

[X,Y,Z,T]=size(BOLD_data);

R_map = zeros(X,Y,Z);

for x = 1:X;
    for y = 1:Y;
        for z = 1:Z;
            if mean(squeeze(BOLD_data(x,y,z,:)))~=0; % OUR TEST FOR NOW OF INSIDE BRAIN OR NOT
                fishZ = fisherZcorr(seed,squeeze(BOLD_data(x,y,z,:))');
                R_map(x,y,z)=fishZ;
            end
        end
    end
end

Vout=ROImask_hdr;
Vout.fname=[subject,'_FishZmap.nii'];
spm_write_vol(Vout,R_map);

%% SUNDRY:

% r_amy = zeros(size(ROImask_data));
% r_amy(32:end,:,:) = ROImask_data(32:end,:,:);
% ramy_inds = find(r_amy);
% [x, y, z] = ind2sub(size(r_amy), ramy_inds);
% ROI_inds = ramy_inds;