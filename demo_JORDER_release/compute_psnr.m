function [psnr] = compute_psnr(im1,im2, title)
    rmse = compute_rmse(im1, im2);
    psnr = 20*log10(255/rmse);
    fprintf([title ' PSNR: %f\n'],psnr);
    fprintf('\n');
end