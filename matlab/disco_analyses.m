% Song Synchrony

load('/SCR/ellamil/ravestudy_stats/disco/disco_parser.mat','samplerateMSall');
samplerate = ceil(samplerateMSall);

[SYNCpart,SYNCname] = disco_song(...
    '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat',...
    '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_wholesongs.mat',...
    samplerate);


% Song Popularity

% Number of song plays / scrobbles
SCROBsong = ... 
[   1427228
    773514
    365335
    760696
    628852
    3174790
    1108520
    441468
    850543   ]; 

% Number of artist plays / scrobbles
SCROBartist = ... 
[   33124230
    6754282
    1125535
    7049555
    3267270
    113888779
    6533460
    1947368
    2855596   ];

[RHOsong(1),RHOsong(2)] = corr(SYNCpart(:,1),SCROBsong,'type','spearman'); % Song popularity (r,p)
[RHOartist(1),RHOartist(2)] = corr(SYNCpart(:,1),SCROBartist,'type','spearman'); % Artist popularity (r,p)


% Song Segments

load('/SCR/ellamil/ravestudy_stats/disco/disco_parser.mat','samplerateMSall');
samplerate = ceil(samplerateMSall);

[model,ftest,stats,contrasts,segment] = disco_segment(...
    '/SCR/ellamil/ravestudy_stats/disco/disco_ips_coif1_mean_linear_zalign.mat',...
    '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_songparts.mat',...
    '/SCR/ellamil/ravestudy_stats/disco/disco_millisecond_wholesongs.mat',...
    samplerate);