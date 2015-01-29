function extractPerframeFtrs(outdir,ftrs)

if ~exist(fullfile(outdir,'perframe'),'dir'),
  mkdir( fullfile(outdir,'perframe'));
end

ff = fields(ftrs);

% Initialize the struct for features of all the frames
for fnum = 1:numel(ff)
  for ftrnum = 1:size(ftrs.(ff{fnum}){1},1)
    perframe = struct;
    perframe.units.num = {};
    perframe.units.den = {'s'};
    for fly = 1:numel(ftrs.(ff{fnum}))
      perframe.data{fly} = ftrs.(ff{fnum}){fly}(ftrnum,:);
    end
    perframe_name = sprintf('%s_%04d',ff{fnum},ftrnum);
    outfilename = fullfile(outdir,'perframe',perframe_name);
    save(outfilename,'-struct','perframe');
    
  end
end
