
%% histogram of flow values to find the clipping range.
rr = randsample(headerinfo.nframes-1,50);

vals = [];
for ndx = 1:numel(rr)
  I1 = readframefcn(rr(ndx));
  I2 = readframefcn(rr(ndx)+1);
  [Vx,Vy,~] = optFlowLk(I1,I2,[],3);
  xx = [Vx(:) Vy(:)];
  xx(abs(xx)<1) = [];
  vals = [vals xx];
  
end

vals(vals<3) = [];
figure; hist(vals);

%% create an ufmf movie

hh = ufmf_read_header('../mated10_20140714T131113/movie.ufmf');
outfile = '../temp/test.ufmf';
fig = figure('Visible','off');
fid = fopen(outfile,'w');

% Setup the ufmf.
if strcmp(hh.coding,'MONO8'),
  ncolors = 1;
end

gui = get(fig,'UserData');
[im,hh1,timestamp,bb,mu] = ufmf_read_frame(hh,1);

gui.bg.params.UpdatePeriod = inf;
gui.bg.params.NFrames = inf;
gui.bg.params.boxBasedCompression = true;
gui.bg.params.KeyframePeriod = inf;

nroi = 1;
roi = [1 1 hh.max_height hh.max_width];
gui.bg.lastkeyframetime = -inf;
tmp = struct('loc',cast([],'int64'),'timestamp',[]);
index = struct;
index.frame = tmp;
index.keyframe.mean = tmp;
gui.bg.index = repmat(index,[1,nroi]);
% (re)initialize the bg models
if ~isfield(gui.bg,'model') || length(gui.bg.model) ~= nroi,  
  gui.bg.model = struct('roi',cell(1,nroi),'mu',cell(1,nroi),'nframes',cell(1,nroi));
  for i = 1:nroi,
    gui.bg.model(i) = struct('roi',roi(i,:),...
      'mu',mu,...
      'nframes',0);
%      'mu',zeros([roi(i,4),roi(i,3),ncolors],'uint8'),...
  end
end
gui.bg.lastupdatetime = -inf;
gui.isBGModel = true;
set(fig,'UserData',gui);

writeUFMFHeader(fid,fig,1);

% Write few frames
writeUFMFKeyFrame(fig,timestamp,fid,1);

for ndx = 1:10
  [im,hh1,timestamp,bb] = ufmf_read_frame(hh,ndx);
  %bb = bb(:,[2 1 4 3]);
  mywriteUFMFFrame(fig,im,timestamp,fid,1,bb);
  
end

% wrap up the ufmf


wrapupUFMF(fid,fig,1);
fclose(fid);
fclose(hh.fid);
close(fig);
% read the created ufmf

hh1 = ufmf_read_header(outfile);
hh = ufmf_read_header('../mated10_20140714T131113/movie.ufmf');

%
figure;
for ndx = 1:10
  [im1,hh2,timestamp,bb] = ufmf_read_frame(hh1,ndx);
  subplot(1,3,1); imshow(im1);
  [im2,hh2,timestamp,bb] = ufmf_read_frame(hh,ndx);
  subplot(1,3,2); imshow(im2);
  dd = abs(double(im1)-double(im2));
  subplot(1,3,3); imshow(uint8(dd));
  title(sprintf('%d %d',max(dd(:)),nnz(dd(:))));
  pause;
end
fclose all
%%

[readfcn,nframes,fid,headerinfo] = get_readframe_fcn('../mated10_20140714T131113/movie.ufmf');
im = uint8([]);
fstarts= [540,610,96705,97577,98161,105925,106136,106507,106600,115402];
flies = [2 4 9 11 9 11 6 10 6 8];
names = {'front_leg_grooming'
  'wing_grooming'
  'back_leg_grooming'
  'eye_grooming'
  'back_leg_grooming'
  'abdomen_grooming'
  'mid_abdomen_grooming'
  'under_wing_grooming'
  'front_leg_grooming'
  'abdomen_grooming'
  };

for clipno = 1:numel(fstarts)
  fstart = fstarts(clipno);
  flynum = flies(clipno);
  name = names{clipno};
  
  fend = fstart+10;
  count = 1;
  for ndx =fstart:(fend+2)
    im(:,:,count) = readfcn(ndx);
    count = count+1;
  end
  
  % visualize the hog/hof features
  
  I = [];
  
  ftrs = genFeatures(readfcn,headerinfo,fstart,fend,tracks);
  hogftrs = ftrs.hogftrs;
  flowftrs = ftrs.flowftrs;
  
  npatches = 8;
  psize = 10; % patch size for hog/hof
  nbins = 8; % number of bins in hog/hof
  patchsz = psize*npatches;
  
  limshog = prctile(hogftrs{flynum}(:),[1 99]);
  limsflow = prctile(flowftrs{flynum}(:),[1 99]);
  
  for fno = fstart:fend;
    curpatch = [];
    trackndx = fno - tracks(flynum).firstframe + 1;
    locy = round(tracks(flynum).y(trackndx));
    locx = round(tracks(flynum).x(trackndx));
    theta = tracks(flynum).theta(trackndx);
    curpatch(:,:,1) = imsharpen(extractPatch(im(:,:, fno-fstart+1),...
      locy,locx,theta,patchsz));
    % locy = round(tracks(flynum).y(trackndx+1));
    % locx = round(tracks(flynum).x(trackndx+1));
    % theta = tracks(flynum).theta(trackndx+1);
    curpatch(:,:,2) = imsharpen(extractPatch(im(:,:, fno-fstart+2),...
      locy,locx,theta,patchsz));
    
    ftrndx = fno-fstart+1;
    curpatch = imresize(curpatch,2,'bilinear');
    hogI = myhogDraw(hogftrs{flynum}(:,:,:,ftrndx),psize*2,false);
    flowI = myhogDraw(flowftrs{flynum}(:,:,:,ftrndx),psize*2,true);
    
    hogI = (hogI-limshog(1))/(limshog(2)-limshog(1));
    flowI = (flowI-limsflow(1))/(limsflow(2)-limsflow(1));
    
    hogI = uint8(hogI*256);
    flowI =uint8(flowI*256);
    hogI = repmat(hogI,[1 1 3]);
    flowI = repmat(flowI,[1 1 3]);
    curI = repmat(curpatch(:,:,1),[1 1 3]);
    curI = addgrid(curI,[psize psize]*2);
    curdI = imfuse(curpatch(:,:,1),curpatch(:,:,2));
    curdI = addgrid(curdI,[psize psize]*2);
    I(:,:,:,ftrndx,1) = curI;
    I(:,:,:,ftrndx,2) = hogI;
    I(:,:,:,ftrndx,3) = curdI;
    I(:,:,:,ftrndx,4) = flowI;
  end
  
  sz = size(I);
  I = reshape(I,[sz(1) sz(2) sz(3) sz(4)*sz(5)]);
  figure; h = montage2(uint8(I),struct('mm',4,'hasChn',1));
  pI = get(h,'CData');
  tI = cell(1,4);
  count = 1;
  for ndx = 1:size(I,4)
    idx = mod(ndx-1,4)+1;
    tI{idx} = cat(2,tI{idx},I(:,:,:,count));
    count = count + 1;
  end
  imwrite(pI,sprintf('../Figures/mated_frame%d_fly%d_%s.png',fstart,flynum,name))
  % outI = [];
  % for ndx = 1:sz(5)
  %   outI = cat(1,outI,tI{ndx});
  % end
  % figure; imshow(uint8(outI))
end
fclose(fid);
