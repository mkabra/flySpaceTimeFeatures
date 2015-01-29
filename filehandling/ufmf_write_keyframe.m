function frameloc = ufmf_write_keyframe(fp,stamp,im,keyframe_type)

w = size(im,1);
h = size(im,2);
frameloc = ftell(fp);

% this is a keyframe
fwrite(fp,0,'uchar');

% write keyframe_type
fwrite(fp,numel(keyframe_type),'uchar');
fwrite(fp,keyframe_type,'char');
% write dtype 
dtype = matlabclass2dtypechar(class(im));
fwrite(fp,dtype,'char');
% width, height
fwrite(fp,[w,h],'ushort');
% stamp
fwrite(fp,stamp,'double');

% write the data
fwrite(fp,im,class(im));
