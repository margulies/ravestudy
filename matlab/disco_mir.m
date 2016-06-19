% Music feature extraction using MIRToolbox v1.6.1
% Time courses or frame decompositions of various music features


soundfile = './ravestudy_data/music/Science of Disco Set.wav';
folder = '/SCR/ellamil/ravestudy_stats/disco/features/frame';


%%% Dynamics

energy = mirrms(soundfile,'Frame');
feature = 'energy';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);


%%% Rhythm

tempo = mirtempo(soundfile,'Frame');
feature = 'tempo';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

[metroid,mstrength] = mirmetroid(soundfile); % default: Frame
feature = 'metroid';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

% [metroid,mstrength] = mirmetroid(soundfile); % default: Frame
feature = 'mstrength';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

pulse = mirpulseclarity(soundfile,'Frame');
feature = 'pulse';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);


%%% Timbre

attack = mirattackslope(soundfile); % default: Frame
feature = 'attack';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

noise = mirzerocross(soundfile,'Frame');
feature = 'noise';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

flux = mirflux(soundfile,'Frame','SubBand'); % High- and low-frequency spectral flux
feature = 'flux';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

bright = mirbrightness(soundfile,'Frame');
feature = 'bright';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

rough = mirroughness(soundfile,'Frame');
feature = 'rough';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

irregular = mirregularity(soundfile,'Frame');
feature = 'irregular';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);


%%% Pitch

pitch = mirpitch(soundfile,'Frame');
feature = 'pitch';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

% Extract music features by song because too slow with whole sound file 
song(1) = miraudio( soundfile , 'Extract' , 00 * 60 + 00 * 1 , 03 * 60 + 52 * 1 ); % 00:00 - 03:52
song(2) = miraudio( soundfile , 'Extract' , 03 * 60 + 52 * 1 , 06 * 60 + 35 * 1 ); % 03:52 - 06:35
song(3) = miraudio( soundfile , 'Extract' , 06 * 60 + 35 * 1 , 09 * 60 + 40 * 1 ); % 06:35 - 09:40
song(4) = miraudio( soundfile , 'Extract' , 09 * 60 + 40 * 1 , 13 * 60 + 10 * 1 ); % 09:40 - 13:10
song(5) = miraudio( soundfile , 'Extract' , 13 * 60 + 10 * 1 , 16 * 60 + 34 * 1 ); % 13:10 - 16:34
song(6) = miraudio( soundfile , 'Extract' , 16 * 60 + 34 * 1 , 19 * 60 + 40 * 1 ); % 16:34 - 19:40
song(7) = miraudio( soundfile , 'Extract' , 19 * 60 + 40 * 1 , 23 * 60 + 28 * 1 ); % 19:40 - 23:28
song(8) = miraudio( soundfile , 'Extract' , 23 * 60 + 28 * 1 , 27 * 60 + 00 * 1 ); % 23:28 - 27:00
song(9) = miraudio( soundfile , 'Extract' , 27 * 60 + 00 * 1 , 31 * 60 + 00 * 1 ); % 27:00 - 31:00

inharmonic = [];
for i = 1:length(song)    
    inharmonic0(i) = mirinharmonicity(song(i),'Frame');
    inharmonic1{i} = mirgetdata(inharmonic0(i));
end
for i = 1:length(inharmonic1) 
    inharmonic = [inharmonic inharmonic1{i}];
end
feature = 'inharmonic';
save([folder,'/disco_mir_',feature,'.mat'],[feature,'*'],'-v7.3');
clear([feature,'*']);


%%% Tone

mode = mirmode(soundfile,'Frame');
feature = 'mode';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);

hcdf = mirhcdf(soundfile); % default: Frame
feature = 'hcdf';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);


%%% High-Level

novel = [];
for i = 1:length(song)    
    novel0(i) = mirnovelty(song(i)); % default: Frame
    novel1{i} = mirgetdata(novel0(i));
end
for i = 1:length(novel1) 
    novel = [novel novel1{i}];
end
feature = 'novel';
save([folder,'/disco_mir_',feature,'.mat'],[feature,'*'],'-v7.3');
clear([feature,'*']);


%%% Emotion

emotion = miremotion(soundfile,'Frame'); % Valence, activity, tension; happy, sad, tender, anger, fear
feature = 'emotion';
save([folder,'/disco_mir_',feature,'.mat'],feature,'-v7.3');
clear(feature);