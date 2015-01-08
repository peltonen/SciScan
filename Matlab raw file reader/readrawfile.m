function data=readrawfile(filename,skipframes,channel,frames)

%
%
%
% syntax:
% data=readrawfile(filename,skipframes,channel,frames);
%
% filename: a string containing the entire path and filename of the raw file
%               to read; leave empty to prompt file selection dialog
% skipframes: number of frames to skip at the beginning of the raw file
% channel: options are   'first' - loads only channel 1
%                        'second' - loads only channel 2
%                        'all' - loads both channels
% frames: number of frames to load; leave empty to load all frames
%
%
% usage examples:
%
% data=readrawfile;
%                   opens file selection dialog and loads all frames of
%                   selected raw file
%
% data=readrawfile('H:\test\(20131024_07_21_50)\(20131024_07_21_50)_test_XYT.raw');
%                   reads the specified file
%
% data=readrawfile([],10,'first');
%                   opens file selection dialog, skips the first ten frames, then loads all frames of
%                   channel 1 of the selected raw file
%
% data=readrawfile([],10,'second',100);
%                   opens file selection dialog, skips the first ten frames, then loads 100 frames of
%                   channel 2 of the selected raw file
%

prevstr=[];
if ~exist('filename') || ~ischar(filename)
    [FileName,PathName] = uigetfile('*.raw','Select raw data file');
    filename=fullfile(PathName,FileName);
end
if ~exist('channel') || ~ischar(channel)
    channel='all';
end
[pathstr, filenameWOext] = fileparts(filename);
inifilename=[filenameWOext '.ini'];
inistring=fileread(fullfile(pathstr,inifilename));
x=readVarIni(inistring,'x.pixels');
y=readVarIni(inistring,'y.pixels');
framecount=readVarIni(inistring,'no..of.frames.to.acquire');
recorded_ch=readVarIni(inistring,'record.settings');

if ~exist('frames') || isempty(frames)
    frames=framecount;   
end

if strcmp(recorded_ch,'both') || length(recorded_ch)<3
    
    fid=fopen(filename,'r','b');
    if exist('skipframes') && ~isempty(skipframes)
        fseek(fid,skipframes.*8.*prod([x y]),'bof');
    end
    
    switch channel
        
        case 'first'
            data=single(zeros(x*y,frames));
            for fr=1:frames;
                if ~rem(fr,100)
                    str=['loading frame ' num2str(fr) '/' num2str(frames)];
                    
                    refreshdisp(str,prevstr,fr);
                    prevstr=str;
                end
                try
                data(:,fr)=fread(fid,prod([x y]),[num2str(prod([x y])) '*float32=>float32'],4*prod([x y]));
                catch
                    fr=fr-1;
                    data=data(:,1:fr);
                    break
                end     
            end
            data=reshape(data,[x y fr]);
            
        case 'second'
            data=single(zeros(x*y,frames));
            dump=fread(fid,prod([x y]),'float32=>float32');
            for fr=1:frames;
                if ~rem(fr,10)
                    str=['loading frame ' num2str(fr) '/' num2str(frames)];
                    
                    refreshdisp(str,prevstr,fr);
                    prevstr=str;
                end
                try
                data(:,fr)=fread(fid,prod([x y]),[num2str(prod([x y])) '*float32=>float32'],4*prod([x y]));
                catch
                    fr=fr-1;
                    data=data(:,1:fr);
                    break
                end     
            end
            data=reshape(data,[x y fr]);
            
        case 'all'
            y=y*2;
            data=single(zeros(x*y,frames));
            for fr=1:frames;
                if ~rem(fr,10)
                    str=['loading frame ' num2str(fr) '/' num2str(frames)];
                    
                    refreshdisp(str,prevstr,fr);
                    prevstr=str;
                end
                try
                data(:,fr)=fread(fid,prod([x y]),[num2str(prod([x y])) '*float32=>float32']);
                catch
                    fr=fr-1;
                    data=data(:,1:fr);
                    break
                end     
            end
            data=reshape(data,[x y/2 2 fr]);
            data=permute(data,[1 2 4 3]);
    end
            
            else
                fid=fopen(filename,'r','b');
                if exist('skipframes')
                    fseek(fid,skipframes.*4.*prod([x y]),'bof');
                end
                
                data=single(zeros(x*y,frames));
                for fr=1:frames;
                    if ~rem(fr,100)
                        str=['loading frame ' num2str(fr) '/' num2str(frames)];
                        
                        refreshdisp(str,prevstr,fr);
                        prevstr=str;
                    end
                    try
                    data(:,fr)=fread(fid,prod([x y]),[num2str(prod([x y])) '*float32=>float32']);
                    catch
                    fr=fr-1;
                    data=data(:,1:fr);
                    break
                end     
                end
                data=reshape(data,[x y fr]);
               
                
    end
    
    
fprintf('\n');
fclose(fid);
