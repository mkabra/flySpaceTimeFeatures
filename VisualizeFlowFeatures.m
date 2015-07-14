function VisualizeFlowFeatures(bdir,fly,frame,stationary)
%% inputs.

% fnum = 10125;
% fly = 1;
% fstart = 10000;
% stationary = true;
% 
% bdir = '../mated10_20140714T131113/';
moviename = fullfile(bdir,'movie.ufmf');
trackfilename = fullfile(bdir,'trx.mat');

%% params

scale = 6;
npatches = 8;
psize = 10; % patch size for hog/hof
nbins = 8; % number of bins in hog/hof
patchsz = psize*npatches;

optflowwinsig = 3;
optflowsig = 2;
optreliability = 1e-4;
%% compute the bins

tmptheta = (0:179)*pi/180;
res = nan(nbins,numel(tmptheta));
m = single(ones(10,10));
o = single(zeros(10,10));
for i = 1:numel(tmptheta),
  fprintf('i = %d, theta = %f\n',i,tmptheta(i));
  o(:) = single(tmptheta(i));
  rescurr = gradientHist(m,o,1,nbins,1);
  res(:,i) = rescurr(1,1,:);
end

bincenters = nan(1,nbins);
for i = 1:nbins,
  bincenters(i) = tmptheta(argmax(res(i,:)));
end

% this seems to be what the centers correspond to
bincenters = linspace(0,pi,nbins+1);
bincenters = bincenters(1:nbins);

% mayank divides by 2
bincenters2 = bincenters*2;
dt = mean(diff(bincenters2));
binedges2 = [bincenters2(1)-dt/2,(bincenters2(1:end-1)+bincenters2(2:end))/2,bincenters2(end)+dt/2];




%% 

tracks = load(trackfilename);
tracks = tracks.trx;

[readfcn,nframes,fid,headerinfo] = get_readframe_fcn(moviename);
im1 = readfcn(fnum);
im2 = readfcn(fnum+1);

trackndx = fnum - tracks(fly).firstframe + 1;
locy = round(tracks(fly).y(trackndx));
locx = round(tracks(fly).x(trackndx));
im1 = extractPatch(im1,...
  locy,locx,tracks(fly).theta(trackndx),patchsz);
if stationary
  locy = round(tracks(fly).y(trackndx+1));
  locx = round(tracks(fly).x(trackndx+1));
end
im2 = extractPatch(im2,...
  locy,locx,tracks(fly).theta(trackndx),patchsz);

fname = 'ff';
if stationary,
  fname = [fname 's']; 
end

F = zeros(8,8,8);
for yy = 1:8
  for xx = 1:8
    for oo = 1:8
      pfname = fullfile(bdir,'perframe',sprintf('%s_%02d_%02d_%d.mat',fname,yy,xx,oo));
      q = load(pfname);
      trackndx = fnum - tracks(fly).firstframe + 1;
      F(yy,xx,oo) = q.data{fly}(trackndx);
      
    end
  end
end
  
% plot

hfig = 100;
figure(hfig);
clf;
hax = axes('Position',[0,0,1,1]);
set(hfig,'Units','pixels','Position',get(0,'ScreenSize'));

im1curr = im1;
im2curr = im2;

[Vx,Vy,~] = optFlowLk(im1curr,im2curr,[],optflowwinsig,optflowsig,optreliability);

subplot(1,2,1); imshow(flowToColor(cat(3,Vx,Vy)));

subplot(1,2,2);
him = imshowpair(imresize(im1curr,scale),imresize(im2curr,scale));
axis image;
truesize;
colormap gray;
hold on;
axis off;

colors = hsv(nbins);

[nr,nc,~] = size(im1);
maxv2 = max(F(:));

h = [];
for xi = 1:ceil(nc/psize),
  cx = (psize/2 + 1 + (xi-1)*psize)*scale;
  if cx+psize/2 > nc*scale,
    break;
  end
  for yi = 1:ceil(nr/psize),
    cy = (psize/2 + 1 + (yi-1)*psize)*scale;
    if cy+psize/2 > nr*scale,
      break;
    end
    
    for bini = 1:nbins,
      tmp = linspace(binedges2(bini),binedges2(bini+1),20);
      xcurr = cx + [0,psize/2*cos(tmp),0]*scale;
      ycurr = cy + [0,psize/2*sin(tmp),0]*scale;
      h(yi,xi,bini) = patch(xcurr,ycurr,colors(bini,:),'LineStyle','none','FaceAlpha',min(1,F(yi,xi,bini)/maxv2));
    end
    
  end
end
