% MorphMap - Automated Geomorphic Mapping Software
% Alan Kasprak, U.S. Geological Survey, Grand Canyon Monitoring and Research Center
% akasprak@usgs.gov

% GRID I/O functions from Joe Wheaton's DoD3 geomorphic change detection software
% for more information see gcd.joewheaton.org 

% some workspace cleanup before getting started
clear all
close all

% import a DEM-of-Difference, or DoD in ASCII format
[filename, pathname]=uigetfile('*.asc','Select a DoD file (ARC ascii format)');    
filename_DoD=[pathname filename];

    fid=fopen(filename_DoD,'r');        % open the file for reading and assign it a variable (fid)
    dum1=fscanf(fid,'%s',1);            % assign first header item's text (ncols) to temp variable
    nx=fscanf(fid,'%u',1);              % assign first header item's value to nx
    dum2=fscanf(fid,'%s',1);            % assign second header item's text (nrows) to temp variable
    ny=fscanf(fid,'%u',1);              % assign second header item's value to ny
    dum3=fscanf(fid,'%s',1);            % assign third header item's text (xllcorner) to temp variable
    xll=fscanf(fid,'%f',1);             % assign third header item's value to xll
    dum4=fscanf(fid,'%s',1);            % assign fourth header item's text (yllcorner) to temp variable
    yll=fscanf(fid,'%f',1);             % assign fourth header item's value to yll
    dum5=fscanf(fid,'%s',1);            % assign fifth header item's text (cellsize) to temp variable
    lx=fscanf(fid,'%f',1);              % assign fifth header item's value to lx
    dum6=fscanf(fid,'%s',1);            % assign sixth header item's text (nodata_value) to temp variable
    nodata=fscanf(fid,'%f',1);          % assign sixth header item's value to nodata
    DoD=fscanf(fid,'%f',[nx,ny]);       % work through remainder of file (the data) and store values in an array
    fclose(fid);

% convert all nodata values in the DoD to NaN for working in matlab
DoD(DoD == -9999) = NaN;

[filename, pathname]=uigetfile('*.asc','Select INITIAL DEM file (ARC ascii format)'); 
filename_DEMold=[pathname filename];

	fid=fopen(filename_DEMold,'r');    % the exact same routine as above for splitting out the header and saving data    
    dum1=fscanf(fid,'%s',1);            
    nx=fscanf(fid,'%u',1);              
    dum2=fscanf(fid,'%s',1);            
    ny=fscanf(fid,'%u',1);              
    dum3=fscanf(fid,'%s',1);            
    xll=fscanf(fid,'%f',1);             
    dum4=fscanf(fid,'%s',1);            
    yll=fscanf(fid,'%f',1);             
    dum5=fscanf(fid,'%s',1);            
    lx=fscanf(fid,'%f',1);              
    dum6=fscanf(fid,'%s',1);            
    nodata=fscanf(fid,'%f',1);          
    DEM_initial=fscanf(fid,'%f',[nx,ny]);      
    fclose(fid);

% convert all nodata values in the initial DEM to NaN for working in matlab
DEM_initial(DEM_initial == nodata) = NaN;

[filename, pathname]=uigetfile('*.asc','Select FINAL DEM file (ARC ascii format)'); 
filename_DEMnew=[pathname filename];

	fid=fopen(filename_DEMnew,'r');    % the exact same routine as above for splitting out the header and saving data
    dum1=fscanf(fid,'%s',1);            
    nx=fscanf(fid,'%u',1);              
    dum2=fscanf(fid,'%s',1);            
    ny=fscanf(fid,'%u',1);              
    dum3=fscanf(fid,'%s',1);            
    xll=fscanf(fid,'%f',1);             
    dum4=fscanf(fid,'%s',1);            
    yll=fscanf(fid,'%f',1);             
    dum5=fscanf(fid,'%s',1);            
    lx=fscanf(fid,'%f',1);              
    dum6=fscanf(fid,'%s',1);            
    nodata=fscanf(fid,'%f',1);          
    DEM_final=fscanf(fid,'%f',[nx,ny]);       
    fclose(fid);

% convert all nodata values in the final DEM to NaN for working in matlab
DEM_final(DEM_final == nodata) = NaN;


% all the processing for the DEMs and DoDs will live in here:
DoD_new = DoD*1000;


% this will result in a classified DoD, which we'll now export to an Arc ASCII file:

DoD_new(isnan(DoD_new)) = nodata;
     
[filename,pathname]=uiputfile('*.asc','Save the Output DEM of Difference to a File');    % Ask for the file name
DoD_file_name=[pathname filename];   
  
        % write the classified DoD to a temporary ASCII file
        fid1= fopen('temp.txt', 'w');
            i=0;
            j=0;
            for i=1:ny;              % Loop through all the rows
                for j=1:nx;          % Loop through all the columns

                	% this may not be necessary, but I'll leave it in to see
                    % if ((DoD_new(j,i) == nodata) | (DoD_new(j,i) == 0));
                    %   fprintf(fid1, '%d ',DoD_new(j,i));  
                    % else    

                      fprintf(fid1, '%6.4f ',DoD_new(j,i));

                    %end

                end                 
                fprintf(fid1, '\n');
            end                     
        fclose(fid1);
     
        fid1 = fopen('temp.txt', 'r');
        fid2 = fopen(DoD_file_name, 'w');
        
        %% Using the header information from earlier, append a six-line header so Arc can read the DoD
        fprintf(fid2,'ncols \t %d \n', nx);
        fprintf(fid2,'nrows \t %d \n', ny);
        fprintf(fid2,'xllcorner \t %10.4f \n', xll);
        fprintf(fid2,'yllcorner \t %10.4f \n', yll);
        fprintf(fid2,'cellsize \t %d \n', lx);
        fprintf(fid2,'NODATA_value \t %d \n', nodata);
        
        while ~feof(fid1),
            st = fgetl(fid1);
            fprintf(fid2,'%s\n',st);
        end
        fclose(fid1); fclose(fid2);
        delete ('temp.txt');