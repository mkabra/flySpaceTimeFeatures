function preparePerFrameFtrs(moviefilename,trackfilename,stationary)

% function preparePerFrameFtrs(moviefilename,trackfilename,stationary)
% The perframe features are stored in perframedir.
% 
setup;
% method = 'hs-brightness';
% flowname = 'hs_ff';

method = 'hs-sup';
flowname = 'hs_sup';

% method can be LK, hs-brightness, hs-sup. 

% method = 'LK';
% flowname = 'ff';
ftrs = computeFeaturesParallel(moviefilename,trackfilename,stationary,method);
expdir = fileparts(moviefilename);
extractPerframeFtrs(fullfile(expdir,'perframe'),ftrs,stationary,flowname);
  