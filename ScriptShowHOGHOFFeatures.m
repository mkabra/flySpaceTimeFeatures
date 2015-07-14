nbins = 8;
psize = 10;
npatches = 8;
optflowwinsig = 3;
optflowsig = 2;
optreliability = 1e-4;
patchsz = psize*npatches;

scale = 6;


expdir = '/groups/branson/home/kabram/flyMovies/maansiMovie';
frames = 10900 +(1:100);
fly = 1;

moviefilestr = 'movie.ufmf';
moviefile = fullfile(expdir,moviefilestr);
trxfilestr = 'trx.mat';
trxfile = fullfile(expdir,trxfilestr);


[readframe,nframes] = get_readframe_fcn(moviefile);
td = load(trxfile);
tracks = td.trx;

for i = 1:numel(frames),
  curf = readframe(frames(i));
  nextf = readframe(frames(i)+1);
  
  trackndx = frames(i) - tracks(fly).firstframe + 1;
  locy = round(tracks(fly).y(trackndx));
  locx = round(tracks(fly).x(trackndx));
  curpatch = extractPatch(curf,...
    locy,locx,tracks(fly).theta(trackndx),patchsz);
  locy = round(tracks(fly).y(trackndx+1));
  locx = round(tracks(fly).x(trackndx+1));
  curpatch2 = extractPatch(nextf,...
    locy,locx,tracks(fly).theta(trackndx+1),patchsz);

  im1(:,:,i) = curpatch;
  im2(:,:,i) = curpatch2;
    
end



[nr,nc,~] = size(im1);
%
% figure out the histogram bins
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


%% make a video
hfig = 100;
t0 = frames(1);
t1 = frames(end);
colorpos = [1,0,0];
colorneg = [0,.3,1];

maxv2 = maxv;
for t = t0:20:t1,

  im1curr = im1(:,:,t-t0+1);
  im2curr = im2(:,:,t-t0+1);
  [Vx,Vy,~] = optFlowLk(im1(:,:,i),im2(:,:,i),[],optflowwinsig,optflowsig,optreliability);
%  [Vx,Vy,] = optFlowHorn(im1curr,im2curr,optflowsig);

  M = sqrt(Vx.^2 + Vy.^2);
  O = mod(atan2(Vy,Vx)/2,pi);
  O = min(O,pi-1e-6);
  H = gradientHist(single(M),single(O),psize,nbins,1);
  maxv2 = max(maxv2,max(H(:)));
end

vid = VideoWriter(sprintf('GrabHOF_%s.avi',datestr(now,'yyyymmdd')));
open(vid);

for t = t0:t1,

  im1curr = im1(:,:,t-t0+1);
  im2curr = im2(:,:,t-t0+1);
  if t == t0,
    figure(hfig);
    clf;
    hax = axes('Position',[0,0,1,1]);
    set(hfig,'Units','pixels','Position',get(0,'ScreenSize'));

%     him = imagesc(im1curr);
    him = imshowpair(imresize(im1curr,scale),imresize(im2curr,scale));
    axis image;
    truesize;
    colormap gray;
    hold on;
    axis off;
    htext = text(1,nr-1,sprintf('%.2f s',(t-1)/200),'Color','k','HorizontalAlignment','left','VerticalAlignment','bottom','FontSize',18);

  else
    delete(h(ishandle(h)));
%     set(him,'CData',im1curr);
    him = imshowpair(imresize(im1curr,scale),imresize(im2curr,scale));
    set(htext,'String',sprintf('%.2f s',(t-1)/200));
  end

%   [Vx,Vy,~] = optFlowLk(im1curr,im2curr,[],3);
  [Vx,Vy,~] = optFlowLk(im1curr,im2curr,[],optflowwinsig,optflowsig,optreliability);
%   [Vx,Vy,] = optFlowHorn(im1curr,im2curr,optflowsig);

  M = sqrt(Vx.^2 + Vy.^2);
  O = mod(atan2(Vy,Vx)/2,pi);
  O = min(O,pi-1e-6);
  H = gradientHist(single(M),single(O),psize,nbins,1);

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
        h(yi,xi,bini) = patch(xcurr,ycurr,colors(bini,:),'LineStyle','none','FaceAlpha',min(1,H(yi,xi,bini)/maxv2));
      end
      
    end
  end
  
  drawnow;
  fr = getframe(hax);
  writeVideo(vid,fr);
  pause(2);
end
close(vid);