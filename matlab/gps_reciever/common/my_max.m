function [ max_pn,max_dopp,max_mag]=my_max(max_ind,max_mag);
[max_mag,max_dopp]=max(max_mag);
max_pn=max_ind(max_dopp);
end
