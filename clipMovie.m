function clipMovie(indir,outdir,startFrame,endFrame)
% function clipMovie(indir,outdir,startFrame,endFrame)

if ~exist(outdir,'dir'),
  mkdir(outdir,'perframe');
end

if ~exist(fullfile(outdir,'movie.ufmf'),'file')
  copyfile(fullfile(indir,'movie.ufmf'),fullfile(outdir,'movie.ufmf'));
end

Q = load(fullfile(indir,'trx.mat'));
selflds = {'x','y','theta','a','b','timestamps',...
  'x_mm','y_mm','theta_mm','a_mm','b_mm'};
pfstart = [];
pfend = [];
for ndx = 1:numel(Q.trx)
  if Q.trx(ndx).firstframe > endFrame || Q.trx(ndx).endframe < startFrame
    Q.trx(ndx).firstframe = 0;
    Q.trx(ndx).endframe = -1;
    for fnum = 1:numel(selflds)
      Q.trx(ndx).(selflds{fnum}) = [];
    end
    Q.trx(ndx).dt = [];
    Q.trx(ndx).nframes = 0;
    pfstart(ndx) = nan; pfend(ndx) = nan;
  else
    curStart = max(Q.trx(ndx).firstframe,startFrame);
    curEnd = min(Q.trx(ndx).endframe,endFrame);
    for fnum = 1:numel(selflds)
      Q.trx(ndx).(selflds{fnum}) = Q.trx(ndx).(selflds{fnum})(curStart:curEnd);
    end
    Q.trx(ndx).dt = Q.trx(ndx).dt(curStart:curEnd-1);
    Q.trx(ndx).endframe = curEnd;
    Q.trx(ndx).nframes = curEnd-curStart+1;
    Q.trx(ndx).firstframe = curStart;
    pfstart(ndx) = curStart;
    pfend(ndx) = curEnd;
  end
end
Q.timestamps = Q.timestamps(startFrame:endFrame);
save(fullfile(outdir,'trx.mat'),'-struct','Q');

if ~exist(fullfile(outdir,'perframe'),'dir'),
  mkdir(fullfile(outdir,'perframe'));
end

dd = dir(fullfile(indir,'perframe','*.mat'));
for pf = 1:numel(dd)
  Q = load(fullfile(indir,'perframe',dd(pf).name));
  for ndx = 1:numel(Q.data)
    if isnan( pfstart(ndx))
      Q.data{ndx} = [];
    else
      Q.data{ndx} = Q.data{ndx}(pfstart(ndx):pfend(end));
    end
  end
  save(fullfile(outdir,'perframe',dd(pf).name),'-struct','Q');
  
end
