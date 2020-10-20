function [ output_str ] = pad( input_str )
inp_len = length(input_str);
tot_len = 10;
output_str ='';
for i = 1:(tot_len-inp_len)
   output_str = strcat(output_str,{' '}); 
end
output_str = strcat(output_str,input_str);
output_str = output_str{1}
end
