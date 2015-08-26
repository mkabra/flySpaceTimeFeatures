function preparePerFrameFtrs(moviefilename,trackfilename,stationary,usedeep)

% function preparePerFrameFtrs(moviefilename,trackfilename,stationary)
% The perframe features are stored in perframedir.
% 
setup;
% method = 'hs-brightness';
% flowname = 'hs_ff';
if nargin<4,
  usedeep = true;
end

if usedeep,
  method = 'deep-sup';
  flowname = 'DS';
else
  method = 'hs-sup';
  flowname = 'hs_sup';
end
% method can be LK, hs-brightness, hs-sup. 

% method = 'LK';
% flowname = 'ff';
ftrs = computeFeaturesParallel(moviefilename,trackfilename,stationary,method);
expdir = fileparts(moviefilename);
extractPerframeFtrs(fullfile(expdir,'perframe'),ftrs,stationary,flowname);
  