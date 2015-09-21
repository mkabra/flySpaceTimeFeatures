function ftrs = gatherCompiledFeatures(savename,nframes,expdir,stationary)

params = getParams;
method = 'deep-sup';
allftrs = {};
numblocks = ceil(nframes/params.blocksize);
for ndx = 1:numblocks
  Q = load(sprintf('%s_%d.mat',savename,ndx));
  allftrs{ndx} = Q.curftrs;
  
end
ff = fields(allftrs{1});

params = getParams;
mndx = find(strcmp(params.methods,method));
flowname = params.flownames{mndx};

tt = load(fullfile(expdir,'trx.mat'));
tracks = tt.trx;

% Initialize the struct for features of all the frames
ftrs = struct;
for fly = 1:numel(tracks)
  frames_fly = tracks(fly).nframes;
  for fnum = 1:numel(ff)
    ftrsz = size(allftrs{1}.(ff{fnum}){1});
    ftrsz(end) = [];
    ftrs.(ff{fnum}){fly} = zeros([ftrsz frames_fly],'single');
  end
end

% assign the features from each block.
for fnum = 1:numel(ff)
  for flynum = 1:numel(tracks)
    count = 1;
    for bnum = 1:numel(allftrs)
      numframes = size(allftrs{bnum}.(ff{fnum}){flynum});
      numframes = numframes(end);
      if numframes < 1, continue; end
%       ftrs.(ff{fnum}){flynum}(:,count:count+numframes-1) = ...
%         single(reshape(allftrs{bnum}.(ff{fnum}){flynum},[],numframes));
      ftrs.(ff{fnum}){flynum}(:,:,:,count:count+numframes-1) = ...
        single(allftrs{bnum}.(ff{fnum}){flynum});
      count = count + numframes;
    end
  end
end

extractPerframeFtrs(fullfile(expdir,'perframe'),ftrs,stationary,flowname);
