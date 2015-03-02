function ftrs = computeFeaturesParallel(moviename,trackfilename)

tracks = load(trackfilename);
tracks = tracks.trx;

[readfcn,nframes,fid,headerinfo] = get_readframe_fcn(moviename);
fclose(fid);

blocksize = 500;
nblocks = ceil((nframes-1)/blocksize);

allftrs ={};

% compute features in parallel for different intervals of frames.
parfor ndx = 1:nblocks
  [readfcn,nframes,fid,headerinfo] = get_readframe_fcn(moviename);
  fstart = (ndx-1)*blocksize+1;
  fend = min(nframes,ndx*blocksize);
  allftrs{ndx} = genFeatures(readfcn,headerinfo,fstart,fend,tracks);
  
  fclose(fid);
  fprintf('.');
  if mod(ndx,20)==0, fprintf('\n'); end
end

ff = fields(allftrs{1});

% Initialize the struct for features of all the frames
ftrs = struct;
for fly = 1:numel(tracks)
  frames_fly = tracks(fly).nframes;
  for fnum = 1:numel(ff)
    ftrsz = size(allftrs{1}.(ff{fnum}){1});
    ftrsz(end) = [];
    ftrs.(ff{fnum}){fly} = zeros([prod(ftrsz) frames_fly],'single');
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
      ftrs.(ff{fnum}){flynum}(:,count:count+numframes-1) = ...
        single(reshape(allftrs{bnum}.(ff{fnum}){flynum},[],numframes));
      count = count + numframes;
    end
  end
end
