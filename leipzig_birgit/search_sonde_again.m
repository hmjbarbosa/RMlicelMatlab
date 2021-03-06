%------------------------------------------------------------------------
% M-File:
%    search_sonde_again.m
%
% Authors:
%    H.M.J. Barbosa (hbarbosa@if.usp.br), IF, USP, Brazil
%
% Description
%
%    Use the list of AllRadioFiles and AllRadioJD generated by
%    search_sonde() to quickly find another sounding file
%    corresponding to another julian date jd.
%
% Input
%
%    allradiofiles - previous list of radio files
%    allradiojd - previous list of radio julian dates
%    jd - requested julian date
%
% Ouput
%
%
%------------------------------------------------------------------------
function [radiofile allradiofiles allradiojd] = search_sonde_again(allradiofiles,allradiojd,jd)

% from all files listed, check those closer to jd
[minjd, posjd]=min(abs(allradiojd-jd));

radiofile=allradiofiles{posjd};
disp(['search_sonde_again:: closest date = ' datestr(datestr(allradiojd(posjd)))]);
disp(['search_sonde_again:: distance to jd = ' num2str(minjd) ' days']);
%