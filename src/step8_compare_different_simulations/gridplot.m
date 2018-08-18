function gridplot(X,opt)
%X = [1 2 3 4];

if nargin == 1
  opt=gridplotOpt();
end

[numRow,numColumn] = size(X);

maxWidth = numColumn*opt.RectSize;
maxHeigh = numRow*opt.RectSize;

normalizeX = (X - min(X(:))+.001)/(max(X(:))-min(X(:))+.002);

figure('Position', [100 100 opt.winSize ceil(opt.winSize/maxWidth*maxHeigh)])
ThisColorMap = colormap(opt.nameColorMap);
for i = 1:numRow
  for j = 1:numColumn
    rectangle(...
      'Position',[(j-1)*opt.RectSize,(i-1)*opt.RectSize,opt.RectSize,opt.RectSize],...
      'FaceColor',ThisColorMap(ceil(normalizeX(i,j)*64),:),...
      'EdgeColor','k',...
      'LineWidth',opt.gridLineWidth....
    )
    text((j-.5)*opt.RectSize,(i-.5)*opt.RectSize,...
      num2str(X(i,j),'%1.2f'),'HorizontalAlignment','center', 'VerticalAlignment','middle', 'fontsize', 8);
    %text((j-.95)*opt.RectSize,(i-.5)*opt.RectSize,num2str(X(i,j)));
    %text((j-.1)*opt.RectSize,(i-.5)*opt.RectSize,num2str(X(i,j)));
  end
end

colorbar
set(gca,'position',[0 0.05 .85 .9],'units','normalized')
axis off




