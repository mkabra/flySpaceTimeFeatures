function preparePerFrameFtrs(moviefilename,trackfilename,stationary)

% function preparePerFrameFtrs(moviefilename,trackfilename)
% The perframe features are stored in perframedir.

setup;
ftrs = computeFeaturesParallel(moviefilename,trackfilename,stationary);
expdir = fileparts(moviefilename);
extractPerframeFtrs(fullfile(expdir,'perframe'),ftrs,stationary);
  