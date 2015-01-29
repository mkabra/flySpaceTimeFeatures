function preparePerFrameFtrs(moviefilename,trackfilename)

% function preparePerFrameFtrs(moviefilename,trackfilename)
% The perframe features are stored in perframedir.

setup;
ftrs = computeFeaturesParallel(moviefilename,trackfilename);
expdir = fileparts(moviefilename);
extractPerframeFtrs(fullfile(expdir,'perframe'),ftrs);
  