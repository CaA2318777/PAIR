function save_tif(V, filename)

fname=filename;
I = V;
num_images = size(I,3);
for i=1:num_images
    imwrite((I(:,:,i)),fname,'WriteMode','append','Compression','none');
end
