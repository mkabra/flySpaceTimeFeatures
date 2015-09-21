mcc -m computeFeaturesCompiled ...
  -R -singleCompThread ...
  -a filehandling/ ...
  -a misc/ ...
  -a toolbox/ ...
  -a optflow_deqing/ ...
  -a deepmatching/deepmex.mexa64
if exist('readme.txt','file'),
  delete('readme.txt');
end
if exist('mccExcludedFiles.log','file'),
  delete('mccExcludedFiles.log');
end
if exist('requiredMCRProducts.txt','file'),
  delete('requiredMCRProducts.txt');
end

