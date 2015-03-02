function ftrs = genFeatures(readfcn,headerinfo,fstart,fend,tracks)

%% parameters

npatches = 8;
psize = 10; % patch size for hog/hof
nbins = 8; % number of bins in hog/hof
patchsz = psize*npatches;

optflowwinsig = 3;
optflowsig = 2;
optreliability = 1e-4;

%% Read the images into a buffer.

tic;

nframes = numel(fstart:fend+1);
im = uint8(zeros(headerinfo.nc,headerinfo.nr,nframes));
count = 1;
for ndx = fstart:fend
  im(:,:,count) = readfcn(ndx);
  count = count + 1;
end
if fend==headerinfo.nframes
  im(:,:,count) = im(:,:,count-1);
else
  im(:,:,count) = readfcn(fend+1);
end

tread =toc;
% fprintf('Read %d frames in %.2fs\n',nframes,tread);

%% preallocate hogftrs and flowftrs

nflies = numel(tracks);
ftrsz = [npatches npatches 8]; 

hogftrs = cell(1,nflies);
flowftrs = cell(1,nflies);
for fly = 1:nflies
  curframes =fstart:fend;
  frames_fly = nnz( curframes<=tracks(fly).endframe & ...
                    curframes>=tracks(fly).firstframe);
  hogftrs{fly} = zeros([ftrsz frames_fly],'single');
  flowftrs{fly} = zeros([ftrsz frames_fly],'single');
  
end

%% Compute the features.

flycount = ones(1,nflies);
for ndx = fstart:fend
  
  for fly = 1:nflies
    if tracks(fly).firstframe > ndx || tracks(fly).endframe < ndx,
      continue;
    end
    trackndx = ndx - tracks(fly).firstframe + 1;
    locy = round(tracks(fly).y(trackndx));
    locx = round(tracks(fly).x(trackndx));
    curpatch = extractPatch(im(:,:, ndx-fstart + 1),...
      locy,locx,tracks(fly).theta(trackndx),patchsz);
    curpatch2 = extractPatch(im(:,:, ndx-fstart + 2),...
      locy,locx,tracks(fly).theta(trackndx),patchsz);
    
    curpatch = single(curpatch);
    [M,O] = gradientMag(curpatch(:,:,1)/255);
    O = min(O,pi-1e-6);
    hogftrs{fly}(:,:,:,flycount(fly)) = single(gradientHist(M,O,psize,nbins,false));
    [Vx,Vy,~] = optFlowLk(curpatch,curpatch2,[],optflowwinsig,optflowsig,optreliability); % Using soft windows
%    [Vx,Vy,~] = optFlowLk(curpatch,curpatch2,4,[],optflowsig); % Using hard windows
    M = single(sqrt(Vx.^2 + Vy.^2));
    O = mod(atan2(Vy,Vx)/2,pi);
    O = single(min(O,pi-1e-6));
    flowftrs{fly}(:,:,:,flycount(fly)) = single(gradientHist(M,O,psize,nbins,true));
    
    
    flycount(fly) = flycount(fly) + 1;
  end
end
  
ftrs.hogftrs = hogftrs;
ftrs.flowftrs = flowftrs;
  
