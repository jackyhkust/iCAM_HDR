clc;clear all;close all;

image = read_radiance('hdr2.hdr');
outImage = iCAM06_HDR(image);

