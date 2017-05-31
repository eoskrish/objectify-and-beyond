close all

%extract the cadherin labeled .tif file
[filename filepath] = uigetfile('*.tif');
FileTif=[filename];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
imcad=zeros(nImage,mImage,NumberImages,'uint16');
TifLink = Tiff(FileTif, 'r');

for i=1:NumberImages
   TifLink.setDirectory(i);
   imcad(:,:,i)=TifLink.read();
end
% imagesc(imcad(:,:,1))
% pause

%extract the myosin labeled .tif file
[filename filepath] = uigetfile('*.tif');
FileTif=[filename];
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
immyo=zeros(nImage,mImage,NumberImages,'uint16');
TifLink = Tiff(FileTif, 'r');

for i=1:NumberImages
   TifLink.setDirectory(i);
   immyo(:,:,i)=TifLink.read();
end
% imagesc(immyo(:,:,1))
% pause

for k = 1 : NumberImages
  % close all;

  im = imcad(:,:,k);
  % size(im)
  % fig1 = figure(1);
  % imagesc(im)
  % colorbar
  % title('Ecad')
  % pause

  [Gmag, Gdir] = imgradient(im);
  % fig2 = figure(2);
  % imagesc(Gmag)
  % colorbar
  % title('gradient magnitude')
  % pause

  G = fspecial('gaussian', [10 10], 10);
  ig = imfilter(Gmag, G, 'same');
  % fig = figure(3);
  % imshow(ig)
  % title('Gaussian filter')

  check = sprintf('n');

  level = 0.75*(max(max(ig))/min(min(ig)));
  % while strcmp(check, 'n') == 1
    % prompt = 'set a value for level';
    % level = input(prompt);
    ig(ig<level) = 0;
    ig(ig>level) = 1;
    % fig4 = figure(4);
    % imagesc(ig)
    % title('binarized')

    % pause
    % prompt = 'Does this look ok? y or n';
    % check = input(prompt,'s');
  % end

  iginv = ones(size(ig)) - ig;
  %  [filename filepath] = uigetfile('*.tif');
  %  imcad = imread(filename);
  %  [filename filepath] = uigetfile('*.tif');
  %  immyo = imread(filename);

  % immyo = immyo(:, 1:size(immyo,2));

  seg = zeros(nImage,mImage,NumberImages);
  % seg = zeros(nImage,mImage);
  for i = 1 : size(imcad,1)
    for j = 1 : size(imcad,2)
      seg(i,j,k) = iginv(i,j) * immyo(i,j,k);
    end
  end

  % fig5 = figure(5);
  % imagesc(seg(:,:));
  % colorbar
  % title('ROI multiplied')
  % pause

  outputFile = 'seg_stack.tiff';
  imwrite(seg(:,:,k), outputFile, 'Writemode', 'append', 'Compression', 'none');
  disp(k)
end

% print(fig1, 'nicepic', '-djpeg');
% im = imread(filename);
% fname =  sprintf('ROI');
% print(fig, fname, '-djpeg')
% imwrite(ig, 'ROI.jpeg')
