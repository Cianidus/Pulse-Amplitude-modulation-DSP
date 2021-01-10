
width = 14;
depth = 1000;

file = fopen('pam_data.mif', 'w');
fprintf(file, 'WIDTH = 14;\n', width);
fprintf(file, 'DEPTH = 1000;\n', depth);
fprintf(file, 'ADDRESS_RADIX=UNS;\n');
fprintf(file, 'DATA_RADIX=DEC;\n');
fprintf(file, 'CONTENT BEGIN\n');


d = int16(pam(52:150)*6000);

for i=1:length(d)
    fprintf(file, '%d:%d;\n', i, d(i));
end
fprintf(file, 'END; \n');
fclose(file);

