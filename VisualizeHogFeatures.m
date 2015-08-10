function im = VisualizeHogFeatures(bdir,fly,fnum)
%% inputs.

moviename = fullfile(bdir,'movie.ufmf');
trackfilename = fullfile(bdir,'trx.mat');

fname = 'hf';
wd = 2;
%% params

scale = 6;
npatches = 8;
psize = 10; % patch size for hog/hof
nbins = 8; % number of bins in hog/hof
patchsz = psize*npatches;

%% compute the bins

% tmptheta = (0:179)*pi/180;
% res = nan(nbins,numel(tmptheta));
% m = single(ones(10,10));
% o = single(zeros(10,10));
% for i = 1:numel(tmptheta),
% %   fprintf('i = %d, theta = %f\n',i,tmptheta(i));
%   o(:) = single(tmptheta(i));
%   rescurr = gradientHist(m,o,1,nbins,1);
%   res(:,i) = rescurr(1,1,:);
% end

bincenters = nan(1,nbins);
for i = 1:nbins,
  bincenters(i) = tmptheta(argmax(res(i,:)));
end

% this seems to be what the centers correspond to
bincenters = linspace(0,pi,nbins+1);
bincenters = bincenters(1:nbins);
dt = mean(diff(bincenters));
binedges = [bincenters(1)-dt/2,(bincenters(1:end-1)+bincenters(2:end))/2,bincenters(end)+dt/2];


%% 

tracks = load(trackfilename);
tracks = tracks.trx;

[readfcn,nframes,fid,headerinfo] = get_readframe_fcn(moviename);
im1 = readfcn(fnum);

trackndx = fnum - tracks(fly).firstframe + 1;
locy = round(tracks(fly).y(trackndx));
locx = round(tracks(fly).x(trackndx));
im1 = extractPatch(im1,...
  locy,locx,tracks(fly).theta(trackndx),patchsz);

H = zeros(8,8,8);
for yy = 1:8
  for xx = 1:8
    for oo = 1:8
      pfname = fullfile(bdir,'perframe',sprintf('%s_%02d_%02d_%d.mat',fname,yy,xx,oo));
      q = load(pfname);
      trackndx = fnum - tracks(fly).firstframe + 1;
      H(yy,xx,oo) = q.data{fly}(trackndx);
      
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

him = imshow(imresize(im1curr,scale));
axis image;
truesize;
colormap gray;
hold on;
axis off;

colors = hsv(nbins);

[nr,nc,~] = size(im1);
maxv2 = max(H(:));

patch = [-1 1 1 -1 1;wd wd -wd -wd wd];
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
      tmp = bincenter(bini);
      curpatch = [cos(tmp) -sin(tmp); sin(tmp) cos(tmp)]*patch;
      xcurr = cx + curpatch*scale;
      ycurr = cy + curpatch*scale;
      h(yi,xi,bini) = patch(xcurr,ycurr,colors(bini,:),'LineStyle','none','FaceAlpha',min(1,F(yi,xi,bini)/maxv2));
    end
    
  end
end
im = getFrame(hax);
